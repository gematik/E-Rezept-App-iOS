//
//  Copyright (c) 2024 gematik GmbH
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

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
struct PrescriptionDetailDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var prescription: Prescription
        var profile: UserProfile?
        var chargeItemConsentState: ChargeItemConsentState = .notAuthenticated
        var chargeItem: ErxSparseChargeItem?
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var isArchived: Bool
        var isDeleting = false
        @PresentationState var destination: Destinations.State?
        // holdes the handoff feature in memory as long as the view is visible
        var userActivity: NSUserActivity?
        @BindingState var focus: Field?
    }

    enum Action: Equatable {
        case task
        case startHandoffActivity
        /// starts generation of data matrix code
        case loadMatrixCodeImage(screenSize: CGSize)
        /// Initial delete action
        case delete
        /// Toggle medication redeem state
        case toggleRedeemPrescription
        case openUrlGesundBundDe
        /// Listener for active UserProfile update changes (including connectivity status, activity status)
        case registerActiveUserProfileListener
        case chargeItemConsentCheck
        case showGrantConsentAlert
        case chargeItemGrantConsent
        case fetchChargeItemLocal
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
            case activeUserProfileReceived(Result<UserProfile, UserProfileServiceError>)
            case changeNameReceived(Result<ErxTask, ErxRepositoryError>)
            case chargeItemConsentCheckReceived(ChargeItemConsentService.CheckResult)
            case chargeItemGrantConsentReceived(ChargeItemConsentService.GrantResult)
            case fetchChargeItemLocal(Result<ErxSparseChargeItem?, ErxRepositoryError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.chargeItemConsentService) var chargeItemConsentService: ChargeItemConsentService
    // [REQ:gemSpec_eRp_FdV:A_20603] Usages of matrixCodeGenerator for code generation. UserProfile is neither part of
    // the screen nor the state.
    @Dependency(\.erxMatrixCodeGenerator) var matrixCodeGenerator: ErxMatrixCodeGenerator
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.dateProvider) var dateProvider: () -> Date
    @Dependency(\.uiDateFormatter) var uiDateFormatter
    @Dependency(\.resourceHandler) var resourceHandler
    @Dependency(\.medicationReminderParser) var medicationParser

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            let isPKVInsured = state.profile?.profile.insuranceType == .pKV
            return .run { send in
                await send(.registerActiveUserProfileListener)
                await send(.fetchChargeItemLocal)
                if isPKVInsured {
                    await send(.chargeItemConsentCheck)
                }
            }
        case .chargeItemConsentCheck:
            return .run { send in
                let result = try await chargeItemConsentService.checkForConsent(userSession.profileId)
                await send(.response(.chargeItemConsentCheckReceived(result)))
            }
        case .fetchChargeItemLocal:
            return .run { [identifier = state.prescription.id] send in
                let result = try await erxTaskRepository.loadLocal(by: identifier)
                    .asyncResult(/ErxRepositoryError.self)
                await send(.response(.fetchChargeItemLocal(result)))
            }
        case .registerActiveUserProfileListener:
            return .run { send in
                let result = try await userProfileService.activeUserProfilePublisher()
                    .asyncResult(/UserProfileServiceError.self)
                await send(.response(.activeUserProfileReceived(result)))
            }
        case .response(.activeUserProfileReceived(.failure)):
            state.profile = nil
            return .none
        case let .response(.activeUserProfileReceived(.success(profile))):
            state.profile = profile
            return .none
        case let .response(.fetchChargeItemLocal(result)):
            switch result {
            case let .success(item):
                state.chargeItem = item
            case .failure:
                break
            }
            return .none
        case let .response(.chargeItemConsentCheckReceived(checkResult)):
            switch checkResult {
            case .granted:
                state.chargeItemConsentState = .granted
            case .notGranted:
                state.chargeItemConsentState = .notGranted
            case .notAuthenticated:
                state.chargeItemConsentState = .notAuthenticated
            case let .error(chargeItemConsentServiceError):
                switch chargeItemConsentServiceError {
                // state.chargeItemConsentState = ???
                default: break // todo ralph
                }
            }
            // do nothing
            // We silently ignore the error since the user does not know about the check in background.
            return .none
        case .startHandoffActivity:
            state.userActivity = Alerts.createHandoffActivity(with: state.prescription.erxTask)
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
            if state.prescription.isDeletable {
                state.destination = .alert(Alerts.confirmDeleteAlertState)
            } else {
                state.destination = .alert(Alerts.deletionNotAllowedAlertState(state.prescription))
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
            switch fail {
            // state.chargeItemConsentState = ???
            default: break // todo ralph
            }

            // for now we wrap the erxRepositoryError in an ChargeItemConsentService.Error to get access
            // to the localized error messages for http codes 400...500
            // it's technically not correct, since the consent service is not
            // these lines will be corrected (automatically) when the task deletion is implemented using
            // structured concurrency
            let chargeItemConsentServiceError = ChargeItemConsentService.Error.erxRepository(fail)
            if case let .remote(.fhirClient(.http(fhirClientHttpError))) = fail,
               fhirClientHttpError.httpClientError == .authentication(IDPError.tokenUnavailable) {
                state.destination = .alert(Alerts.missingTokenAlertState())
            } else if let alertState = chargeItemConsentServiceError.alertState {
                state.destination = .alert(alertState.prescriptionDetailDomainErpAlertState)
            } else {
                state.destination = .alert(
                    Alerts.deleteFailedAlertState(error: fail, localizedError: fail.localizedDescriptionWithErrorList)
                )
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
        case .showGrantConsentAlert:
            state.destination = .alert(Alerts.grantConsentRequest)
            return .none
        case .destination(.presented(.alert(.grantConsent))):
            return .run { send in
                await send(.chargeItemGrantConsent)
            }

        case .chargeItemGrantConsent:
            guard let profileId = state.profile?.id
            else { return .none }
            return .run { send in
                let result = try await chargeItemConsentService.grantConsent(profileId)
                await send(.response(.chargeItemGrantConsentReceived(result)))
            }
        case let .response(.chargeItemGrantConsentReceived(grantResult)):
            switch grantResult {
            case .success:
                state.chargeItemConsentState = .granted
            case .notAuthenticated:
                state.chargeItemConsentState = .notAuthenticated
            case .conflict:
                state.chargeItemConsentState = .granted
                state.destination = .toast(ToastStates.conflictToast)
            case let .error(chargeItemConsentServiceError):
                switch chargeItemConsentServiceError {
                // state.chargeItemConsentState = ???
                default: break // todo ralph
                }
                if let alertState = chargeItemConsentServiceError.alertState {
                    state.destination = .alert(alertState.prescriptionDetailDomainErpAlertState)
                } else {
                    state.destination = .alert(
                        Alerts.deleteFailedAlertState(
                            error: chargeItemConsentServiceError,
                            localizedError: chargeItemConsentServiceError.localizedDescriptionWithErrorList
                        )
                    )
                }
            }
            return .none
        case .destination(.presented(.alert(.grantConsentDeny))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.consentServiceErrorOkay))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.consentServiceErrorRetry))):
            return .run { send in
                await send(.chargeItemGrantConsent)
            }
        case .destination(.presented(.alert(.consentServiceErrorAuthenticate))):
            state.destination = .alert(Alerts.missingTokenAlertState())
            return .none
        case let .setNavigation(tag: tag):
            switch tag {
            case .chargeItem:
                guard let chargeItem = state.chargeItem?.chargeItem
                else { return .none }
                state.destination = .chargeItem(.init(
                    profileId: userSession.profileId,
                    chargeItem: chargeItem,
                    showRouteToChargeItemListButton: true
                ))
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
            case .dosageInstructionsInfo:
                let dosageInstructionsState = Destinations.DosageInstructionsState(
                    dosageInstructions: state.prescription.medicationRequest.dosageInstructions
                )
                state.destination = .dosageInstructionsInfo(dosageInstructionsState)
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
            case .toast:
                return .none
            case .medicationReminder:
                let schedule = state.prescription.medicationSchedule ??
                    medicationParser.parse(state.prescription.erxTask)
                state
                    .destination = .medicationReminder(MedicationReminderSetupDomain
                        .State(medicationSchedule: schedule))
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
            state.prescription = Prescription.lens.erxTask.set(newErxTask)(state.prescription)

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
            state.destination = .alert(Alerts.changeNameReceivedAlertState(error: error))
            return .none
        case .response(.changeNameReceived(.success)):
            return .none
        case .pencilButtonTapped:
            state.focus = .medicationName
            return .none

        case let .destination(.presented(.medicationReminder(action: .delegate(delegateAction)))):
            switch delegateAction {
            case let .saveButtonTapped(medicationSchedule):
                let newErxTask = ErxTask.lens.medicationSchedule.set(medicationSchedule)(state.prescription.erxTask)
                state.prescription = Prescription.lens.erxTask.set(newErxTask)(state.prescription)
                state.destination = nil
            }
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

extension PrescriptionDetailDomain {
    // sourcery: CodedError = "016"
    enum LoadingImageError: Error, Equatable, LocalizedError {
        // sourcery: errorCode = "01"
        case matrixCodeGenerationFailed
    }

    enum ChargeItemConsentState: Equatable {
        case granted
        case notGranted
        case notAuthenticated
    }
}

extension RemoteStoreError {
    var fhirClientOperationOutcome: String? {
        guard case let .fhirClient(.http(fhirClientError)) = self,
              let operationOutcome = fhirClientError.operationOutcome else {
            return nil
        }
        return operationOutcome.issue.first?.details?.text?.value?.string
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

extension PrescriptionDetailDomain.State {
    enum Field: Hashable {
        case medicationName
    }

    func createReportEmail(body: String) -> URL? {
        var urlString = URLComponents(string: "mailto:app-feedback@gematik.de")
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: "Fehlerreport iOS App"))
        queryItems.append(URLQueryItem(name: "body", value: body))

        urlString?.queryItems = queryItems

        return urlString?.url
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
