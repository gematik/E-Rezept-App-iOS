//
//  Copyright (c) 2023 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
import ComposableArchitecture
import Dependencies
import eRpKit
import FHIRClient
import IDP
import SwiftUI

struct PrescriptionDetailDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    // sourcery: CodedError = "016"
    enum LoadingImageError: Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case matrixCodeGenerationFailed
    }

    struct State: Equatable {
        var prescription: Prescription
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var isArchived: Bool
        var isDeleting = false
        @PresentationState var destination: Destinations.State?
        // holdes the handoff feature in memory as long as the view is visible
        var userActivity: NSUserActivity?
        @BindingState var focus: Field?

        enum Field: Hashable {
            case medicationName
        }
    }

    enum Action: Equatable {
        case startHandoffActivity
        /// starts generation of data matrix code
        case loadMatrixCodeImage(screenSize: CGSize)
        /// Initial delete action
        case delete
        /// Toggle medication redeem state
        case toggleRedeemPrescription
        case openUrlGesundBundDe

        case setName(String)
        case pencilButtonTapped
        case setFocus(PrescriptionDetailDomain.State.Field?)

        case response(Response)
        case delegate(Delegate)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        enum Delegate: Equatable {
            /// Closes the details page
            case close
        }

        enum Response: Equatable {
            /// When a new data matrix code was generated
            case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
            /// When user chooses to not delete
            case taskDeletedReceived(Result<Bool, ErxRepositoryError>)
            /// Responds after save
            case redeemedOnSavedReceived(Bool)
            /// Responds after update Medication.name
            case changeNameReceived(Result<ErxTask, ErxRepositoryError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    // [REQ:gemSpec_eRp_FdV:A_20603] Usages of matrixCodeGenerator for code generation. UserProfile is neither part of
    // the screen nor the state.
    @Dependency(\.erxMatrixCodeGenerator) var matrixCodeGenerator: ErxMatrixCodeGenerator
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.dateProvider) var dateProvider: () -> Date
    @Dependency(\.uiDateFormatter) var uiDateFormatter
    @Dependency(\.resourceHandler) var resourceHandler

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .startHandoffActivity:
            state.userActivity = Self.createHandoffActivity(with: state.prescription.erxTask)
            return .none
        // Matrix Code
        case let .loadMatrixCodeImage(screenSize):
            state.loadingState = .loading(nil)

            return .publisher(
                matrixCodeGenerator.publishedMatrixCode(
                    for: [state.prescription.erxTask],
                    with: calcMatrixCodeSize(screenSize: screenSize)
                )
                .mapError { _ in
                    LoadingImageError.matrixCodeGenerationFailed
                }
                .catchToLoadingStateEffect()
                .map { Action.response(.matrixCodeImageReceived($0)) }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
            )

        case let .response(.matrixCodeImageReceived(loadingState)):
            state.loadingState = loadingState
            guard let url = state.prescription.erxTask.shareUrl() else { return .none }
            // we ignore if generating the data matrix code image fails and share at least the link
            state.destination = .sharePrescription(.init(url: url, dataMatrixCodeImage: loadingState.value))
            return .none

        // Delete
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .delete:
            if state.prescription.isDeleteable {
                state.destination = .alert(Self.confirmDeleteAlertState)
            } else {
                state.destination = .alert(Self.deletionNotAllowedAlertState(state.prescription))
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19229]
        case .destination(.presented(.alert(.confirmedDelete))):
            state.destination = nil
            state.isDeleting = true
            return .publisher(
                erxTaskRepository.delete(erxTasks: [state.prescription.erxTask])
                    .first()
                    .receive(on: schedulers.main)
                    .catchToPublisher()
                    .map { Action.response(.taskDeletedReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .response(.taskDeletedReceived(.failure(fail))):
            state.isDeleting = false
            if fail == .remote(.fhirClientError(IDPError.tokenUnavailable)) {
                state.destination = .alert(Self.missingTokenAlertState())
            } else if case let ErxRepositoryError.remote(error) = fail,
                      let outcome = error.fhirClientOperationOutcome {
                state.destination = .alert(Self.deleteFailedAlertState(error: error, localizedError: outcome))
            } else {
                state
                    .destination =
                    .alert(Self
                        .deleteFailedAlertState(error: fail, localizedError: fail.localizedDescriptionWithErrorList))
            }
            return .none
        case let .response(.taskDeletedReceived(.success(success))):
            state.isDeleting = false
            if success {
                return EffectTask.send(.delegate(.close))
            }
            return .none

        // Redeem
        case .toggleRedeemPrescription:
            guard state.prescription.isManualRedeemEnabled else {
                return .none
            }
            state.isArchived.toggle()
            var erxTask = state.prescription.erxTask
            if state.isArchived {
                let redeemedOn = fhirDateFormatter.stringWithLongUTCTimeZone(
                    from: dateProvider()
                )
                erxTask.update(with: redeemedOn)
            } else {
                erxTask.update(with: nil)
            }
            state.prescription = Prescription(erxTask: erxTask, dateFormatter: uiDateFormatter)
            return saveErxTasks(erxTasks: [erxTask])
        case let .response(.redeemedOnSavedReceived(success)):
            if !success {
                state.isArchived.toggle()
            }
            return .none
        case let .destination(.presented(.alert(.openEmailClient(body)))):
            state.destination = nil
            guard let email = state.createReportEmail(body: body) else { return .none }
            if UIApplication.shared.canOpenURL(email) {
                UIApplication.shared.open(email)
            }
            return .none

        case let .setNavigation(tag: tag):
            switch tag {
            case .sharePrescription:
                // is set by.response(.matrixCodeImageReceived)
                return .none
            case .substitutionInfo:
                state.destination = .substitutionInfo
            case .directAssignmentInfo:
                state.destination = .directAssignmentInfo
            case .prescriptionValidityInfo:
                let oneDay: TimeInterval = 60 * 60 * 24
                // If acceptedUntil date is today, the acceptance period already expired --> display minus one day
                let validity = Destinations.PrescriptionValidityState(
                    acceptBeginDisplayDate: uiDateFormatter.date(state.prescription.authoredOn),
                    acceptEndDisplayDate: uiDateFormatter.date(state.prescription.acceptedUntil, advancedBy: -oneDay),
                    expiresBeginDisplayDate: uiDateFormatter.date(state.prescription.acceptedUntil),
                    expiresEndDisplayDate: uiDateFormatter.date(state.prescription.expiresOn, advancedBy: -oneDay)
                )
                state.destination = .prescriptionValidityInfo(validity)

            case .errorInfo:
                state.destination = .errorInfo
            case .scannedPrescriptionInfo:
                state.destination = .scannedPrescriptionInfo
            case .coPaymentInfo:
                guard let status = state.prescription.erxTask.medicationRequest.coPaymentStatus else { return .none }
                let coPaymentState = Destinations.CoPaymentState(status: status)
                state.destination = .coPaymentInfo(coPaymentState)
            case .emergencyServiceFeeInfo:
                state.destination = .emergencyServiceFeeInfo
            case .none:
                state.destination = nil
            case .alert:
                return .none
            case .medication, .medicationOverview:
                guard let medication = state.prescription.medication else { return .none }
                if state.prescription.medicationDispenses.isEmpty {
                    state.destination = .medication(.init(subscribed: medication))
                } else {
                    state.destination = .medicationOverview(
                        .init(subscribed: medication, dispensed: state.prescription.medicationDispenses)
                    )
                }
            case .patient:
                guard let patient = state.prescription.patient else { return .none }
                let patientState = Destinations.PatientState(patient: patient)
                state.destination = .patient(patientState)
            case .practitioner:
                guard let practitioner = state.prescription.practitioner else { return .none }
                let practitionerState = Destinations.PractitionerState(practitioner: practitioner)
                state.destination = .practitioner(practitionerState)
            case .organization:
                guard let organization = state.prescription.organization else { return .none }
                let organizationState = Destinations.OrganizationState(organization: organization)
                state.destination = .organization(organizationState)
            case .accidentInfo:
                guard let accidentInfo = state.prescription.medicationRequest.accidentInfo else { return .none }
                let accidentInfoState = Destinations.AccidentInfoState(accidentInfo: accidentInfo)
                state.destination = .accidentInfo(accidentInfoState)
            case .technicalInformations:
                let techInfoState = Destinations.TechnicalInformationsState(
                    taskId: state.prescription.erxTask.identifier,
                    accessCode: state.prescription.accessCode
                )
                state.destination = .technicalInformations(techInfoState)
            }

            return .none
        case .openUrlGesundBundDe:
            guard let url = URL(string: "https://gesund.bund.de"),
                  resourceHandler.canOpenURL(url) else { return .none }

            resourceHandler.open(url)
            return .none
        case let .setName(newName):
            let name = newName
            guard
                name.trimmed().lengthOfBytes(using: .utf8) > 0,
                let erxMedication = state.prescription.erxTask.medication
            else { return .none }
            let newErxMedication = ErxMedication.lens.name.set(name)(erxMedication)
            let newErxTask = ErxTask.lens.medication.set(newErxMedication)(state.prescription.erxTask)

            return .publisher(
                erxTaskRepository.save(erxTasks: [newErxTask])
                    .first()
                    .map { _ in newErxTask } // erxTaskRepository.save does only return `true` or Error
                    .receive(on: schedulers.main)
                    .catchToPublisher()
                    .map { .response(.changeNameReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .response(.changeNameReceived(.failure(error))):
            state.destination = .alert(Self.changeNameReceivedAlertState(error: error))
            return .none
        case let .response(.changeNameReceived(.success(newErxTask))):
            state.prescription = Prescription.lens.erxTask.set(newErxTask)(state.prescription)
            return .none
        case .pencilButtonTapped:
            state.focus = .medicationName
            return .none
        case let .setFocus(field):
            state.focus = field
            return .none
        case .destination:
            return .none
        case .delegate:
            return .none
        }
    }
}

extension PrescriptionDetailDomain.State {
    func createReportEmail(body: String) -> URL? {
        var urlString = URLComponents(string: "mailto:app-feedback@gematik.de")
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: "Fehlerreport iOS App"))
        queryItems.append(URLQueryItem(name: "body", value: body))

        urlString?.queryItems = queryItems

        return urlString?.url
    }
}

extension PrescriptionDetailDomain {
    /// Creates the handoff action for sharing the url between devices
    static func createHandoffActivity(with task: ErxTask) -> NSUserActivity? {
        guard let url = task.shareUrl() else {
            return nil
        }

        let activity = NSUserActivity(activityType: "de.gematik.erp4ios.eRezept.Share")
        activity.title = "Share with other stuff"
        activity.isEligibleForHandoff = true
        activity.webpageURL = url
        activity.becomeCurrent()

        return activity
    }

    static var confirmDeleteAlertState: ErpAlertState<Destinations.Action.Alert> = {
        .init(
            title: L10n.dtlTxtDeleteAlertTitle,
            actions: {
                ButtonState(role: .destructive, action: .confirmedDelete) {
                    .init(L10n.dtlTxtDeleteYes)
                }
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.dtlTxtDeleteNo)
                }
            },
            message: L10n.dtlTxtDeleteAlertMessage
        )
    }()

    static func deletionNotAllowedAlertState(_ prescription: Prescription) -> ErpAlertState<Destinations.Action.Alert> {
        var title = L10n.prscDtlAlertTitleDeleteNotAllowed
        if prescription.type == .directAssignment {
            title = L10n.prscDeleteNoteDirectAssignment
        } else if prescription.erxTask.status == .inProgress {
            title = L10n.dtlBtnDeleteDisabledNote
        } else {
            assertionFailure("check prescription.isDeletable state for more reasons")
        }

        return .init(title: title) {
            ButtonState(role: .cancel, action: .dismiss) {
                .init(L10n.alertBtnOk)
            }
        }
    }

    static func deleteFailedAlertState(error: CodedError,
                                       localizedError: String) -> ErpAlertState<Destinations.Action.Alert> {
        .init(
            for: error,
            title: L10n.dtlTxtDeleteMissingTokenAlertTitle
        ) {
            ButtonState(action: .openEmailClient(body: localizedError)) {
                .init(L10n.prscFdBtnErrorBanner)
            }
            ButtonState(role: .cancel, action: .send(.dismiss)) {
                .init(L10n.alertBtnOk)
            }
        }
    }

    static func missingTokenAlertState() -> ErpAlertState<Destinations.Action.Alert> {
        .init(
            title: L10n.dtlTxtDeleteMissingTokenAlertTitle,
            actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.alertBtnOk)
                }
            },
            message: L10n.dtlTxtDeleteMissingTokenAlertMessage
        )
    }

    static func changeNameReceivedAlertState(error: CodedError) -> ErpAlertState<Destinations.Action.Alert> {
        // swiftlint:disable:next trailing_closure
        .init(for: error, actions: {
            ButtonState(role: .cancel, action: .dismiss) {
                .init(L10n.alertBtnOk)
            }
        })
    }
}

extension RemoteStoreError {
    var fhirClientOperationOutcome: String? {
        guard case let .fhirClientError(error) = self,
              let fhirClientError = error as? FHIRClient.Error,
              case let .operationOutcome(outcome) = fhirClientError else {
            return nil
        }
        return outcome.issue.first?.details?.text?.value?.string
    }
}

extension PrescriptionDetailDomain {
    // TODO: Same func is in MatrixCodeDomain. swiftlint:disable:this todo
    // Maybe find a way to have only one implementation!
    /// Will calculate the size for the matrix code based on current screen size
    func calcMatrixCodeSize(screenSize: CGSize) -> CGSize {
        let padding: CGFloat = 16
        let minScreenDimension = min(screenSize.width, screenSize.height)
        let pixelDimension = Int(minScreenDimension - 2 * padding)
        return CGSize(width: pixelDimension, height: pixelDimension)
    }

    func saveErxTasks(erxTasks: [ErxTask])
        -> EffectTask<PrescriptionDetailDomain.Action> {
        .publisher(
            erxTaskRepository.save(erxTasks: erxTasks)
                .first()
                .receive(on: schedulers.main.animation())
                .replaceError(with: false)
                .map { PrescriptionDetailDomain.Action.response(.redeemedOnSavedReceived($0)) }
                .eraseToAnyPublisher
        )
    }
}

extension ErxTask {
    func shareUrl() -> URL? {
        let sharedTask = SharedTask(with: self)
        guard let encoded = try? JSONEncoder().encode([sharedTask]),
              var urlComponents = URLComponents(string: "https://das-e-rezept-fuer-deutschland.de/prescription") else {
            return nil
        }
        urlComponents.fragment = String(data: encoded, encoding: .utf8)

        return urlComponents.url
    }
}

extension PrescriptionDetailDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State(
            prescription: Prescription.Dummies.prescriptionReady,
            isArchived: false
        )

        static let store = Store(
            initialState: state
        ) {
            PrescriptionDetailDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<PrescriptionDetailDomain> {
            Store(
                initialState: state
            ) {
                PrescriptionDetailDomain()
            }
        }
    }
}
