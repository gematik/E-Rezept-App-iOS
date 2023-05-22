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

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case cancelMatrixCodeGeneration
        case deleteErxTask
        case saveErxTask
    }

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
        var destination: Destinations.State?
        // holdes the handoff feature in memory as long as the view is visible
        var userActivity: NSUserActivity?
    }

    enum Action: Equatable {
        case startHandoffActivity
        /// starts generation of data matrix code
        case loadMatrixCodeImage(screenSize: CGSize)
        /// Initial delete action
        case delete
        /// User has confirmed to delete task
        case confirmedDelete
        /// Toggle medication redeem state
        case toggleRedeemPrescription
        case openEmailClient(body: String)
        case openUrlGesundBundDe

        case response(Response)
        case delegate(Delegate)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

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
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.erxTaskMatrixCodeGenerator) var matrixCodeGenerator: ErxTaskMatrixCodeGenerator
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.dateProvider) var dateProvider: () -> Date
    @Dependency(\.uiDateFormatter) var uiDateFormatter
    @Dependency(\.resourceHandler) var resourceHandler

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
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

            return matrixCodeGenerator.publishedMatrixCode(
                for: [state.prescription.erxTask],
                with: calcMatrixCodeSize(screenSize: screenSize)
            )
            .mapError { _ in
                LoadingImageError.matrixCodeGenerationFailed
            }
            .catchToLoadingStateEffect()
            .map { Action.response(.matrixCodeImageReceived($0)) }
            .cancellable(id: Token.cancelMatrixCodeGeneration, cancelInFlight: true)
            .receive(on: schedulers.main)
            .eraseToEffect()

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
        case .confirmedDelete:
            state.destination = nil
            state.isDeleting = true
            return erxTaskRepository.delete(erxTasks: [state.prescription.erxTask])
                .first()
                .receive(on: schedulers.main)
                .catchToEffect()
                .map { Action.response(.taskDeletedReceived($0)) }
                .cancellable(id: Token.deleteErxTask)
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
            return Self.cleanup()
        case let .response(.taskDeletedReceived(.success(success))):
            state.isDeleting = false
            if success {
                return EffectTask(value: .delegate(.close))
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
            state.prescription = Prescription(erxTask: erxTask)
            return saveErxTasks(erxTasks: [erxTask])
        case let .response(.redeemedOnSavedReceived(success)):
            if !success {
                state.isArchived.toggle()
            }
            return .none
        case let .openEmailClient(body):
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
                let validity = Destinations.PrescriptionValidityState(
                    authoredOnDate: uiDateFormatter.date(state.prescription.authoredOn),
                    acceptUntilDate: uiDateFormatter.date(state.prescription.acceptedUntil),
                    expiresOnDate: uiDateFormatter.date(state.prescription.expiresOn)
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

    static var confirmDeleteAlertState: ErpAlertState<Action> = {
        ErpAlertState<Action>(
            title: TextState(L10n.dtlTxtDeleteAlertTitle),
            message: TextState(L10n.dtlTxtDeleteAlertMessage),
            primaryButton: .destructive(TextState(L10n.dtlTxtDeleteYes), action: .send(.confirmedDelete)),
            secondaryButton: .cancel(TextState(L10n.dtlTxtDeleteNo), action: .send(.setNavigation(tag: nil)))
        )
    }()

    static func deletionNotAllowedAlertState(_ prescription: Prescription) -> ErpAlertState<Action> {
        var title = L10n.prscDtlAlertTitleDeleteNotAllowed
        if prescription.type == .directAssignment {
            title = L10n.prscDeleteNoteDirectAssignment
        } else if prescription.erxTask.status == .inProgress {
            title = L10n.dtlBtnDeleteDisabledNote
        } else {
            assertionFailure("check prescription.isDeletable state for more reasons")
        }

        return ErpAlertState(
            title: TextState(title),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }

    static func deleteFailedAlertState(error: CodedError, localizedError: String) -> ErpAlertState<Action> {
        .init(for: error,
              title: TextState(L10n.dtlTxtDeleteMissingTokenAlertTitle),
              primaryButton: .default(TextState(L10n.prscFdBtnErrorBanner),
                                      action: .send(.openEmailClient(body: localizedError))),
              secondaryButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil))))
    }

    static func missingTokenAlertState() -> ErpAlertState<Action> {
        ErpAlertState(
            title: TextState(L10n.dtlTxtDeleteMissingTokenAlertTitle),
            message: TextState(L10n.dtlTxtDeleteMissingTokenAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
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
    // TODO: Same func is in RedeemMatrixCodeDomain. swiftlint:disable:this todo
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
        erxTaskRepository.save(erxTasks: erxTasks)
            .first()
            .receive(on: schedulers.main.animation())
            .replaceError(with: false)
            .map { PrescriptionDetailDomain.Action.response(.redeemedOnSavedReceived($0)) }
            .eraseToEffect()
            .cancellable(id: PrescriptionDetailDomain.Token.saveErxTask)
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

        static let store = Store(initialState: state,
                                 reducer: PrescriptionDetailDomain())

        static func storeFor(_ state: State) -> StoreOf<PrescriptionDetailDomain> {
            Store(initialState: state,
                  reducer: PrescriptionDetailDomain())
        }
    }
}
