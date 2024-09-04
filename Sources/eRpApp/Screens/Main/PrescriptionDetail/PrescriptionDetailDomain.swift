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

@Reducer // swiftlint:disable:next type_body_length
struct PrescriptionDetailDomain {
    @ObservableState
    struct State: Equatable {
        var prescription: Prescription
        var profile: UserProfile?
        var chargeItemConsentState: ChargeItemConsentState = .notAuthenticated
        var chargeItem: ErxSparseChargeItem?
        var loadingState: LoadingState<UIImage, LoadingImageError> = .idle
        var isArchived: Bool
        var isDeleting = false
        @Presents var destination: Destination.State?
        // holdes the handoff feature in memory as long as the view is visible
        var userActivity: NSUserActivity?
        var focus: Field?
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case task
        case startHandoffActivity
        /// starts generation of data matrix code
        case loadMatrixCodeImage(screenSize: CGSize)
        /// Initial delete action
        case delete
        case showConfirmDeleteChargeItemAlert
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
        case setNavigation(tag: Destination.Tag?)
        case destination(PresentationAction<Destination.Action>)

        case redeemPressed

        enum Delegate: Equatable {
            /// Closes the details page
            case close
            /// Closes the details page and starts the redeem process
            case redeem(Prescription)
        }

        enum Response: Equatable {
            /// When a new data matrix code was generated
            case matrixCodeImageReceived(LoadingState<UIImage, LoadingImageError>)
            case taskDeletedReceived(Result<Bool, ErxRepositoryError>)
            case chargeItemDeletedReceived(Result<Bool, ErxRepositoryError>)
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
    @Dependency(\.imageGenerator) var imageGenerator: ImageGenerator

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> Effect<Action> {
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
            guard let image = loadingState.value else { return .none }
            state.destination = .sharePrescription(
                .init(
                    string: L10n.dmcTxtShareMessage(state.prescription.title).text,
                    url: state.prescription.erxTask.shareUrl(),
                    dataMatrixCodeImage: imageGenerator.addCaption(
                        image,
                        L10n.dmcTxtCodeSingle.text,
                        state.prescription.title
                    )
                )
            )
            return .none
        // Delete
        // [REQ:gemSpec_eRp_FdV:A_19229-01#2] Deletion button is tapped -> delete confirmation dialog shows
        case .delete:
            if state.prescription.isDeletable {
                state.destination = .alert(Alerts.confirmDeleteAlertState)
            } else {
                state.destination = .alert(Alerts.deletionNotAllowedAlertState(state.prescription))
            }
            return .none
        case .showConfirmDeleteChargeItemAlert:
            state.destination = .alert(Alerts.confirmDeleteWithChargeItemAlertState)
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19229-01#3] Confirmation dialog was confirmed, deletion is triggered
        case .destination(.presented(.alert(.confirmedDelete))):
            // check if prescription is pkv and show chargeItem deletion warning
            if state.prescription.erxTask.flowType == .directAssignmentForPKV
                || state.prescription.erxTask.flowType == .pharmacyOnlyForPKV {
                state.destination = nil
                return .run { send in await send(.showConfirmDeleteChargeItemAlert) }
            }

            state.destination = nil
            state.isDeleting = true
            return delete(erxTask: state.prescription.erxTask)
        case .destination(.presented(.alert(.confirmedDeleteWithChargeItem))):
            state.destination = nil
            state.isDeleting = true
            return delete(erxTask: state.prescription.erxTask)
        case let .response(.taskDeletedReceived(.failure(fail))):
            state.isDeleting = false
            state.destination = handleResponse(error: fail)
            return .none
        case let .response(.taskDeletedReceived(.success(success))):
            if success,
               state.prescription.erxTask.flowType == .directAssignmentForPKV
               || state.prescription.erxTask.flowType == .pharmacyOnlyForPKV {
                return deleteChargeItem(erxTask: state.prescription.erxTask)
            }
            state.isDeleting = false
            if success {
                return Effect.send(.delegate(.close))
            }
            return .none
        case let .response(.chargeItemDeletedReceived(.failure(failure))):
            state.isDeleting = false
            state.destination = handleResponse(error: failure)
            return .none
        case let .response(.chargeItemDeletedReceived(.success(success))):
            state.isDeleting = false
            if success {
                return Effect.send(.delegate(.close))
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
            return save(erxTasks: [erxTask])
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
        case .redeemPressed:
            return .send(.delegate(.redeem(state.prescription)))
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
                state.destination = .substitutionInfo(
                    SubstitutionInfoDomain.State(
                        substitutionAllowed: state.prescription.medicationRequest.substitutionAllowed
                    )
                )
            case .directAssignmentInfo:
                state.destination = .directAssignmentInfo(.init())
            case .prescriptionValidityInfo:
                let oneDay: TimeInterval = 60 * 60 * 24
                // If acceptedUntil date is today, the acceptance period already expired --> display minus one day
                let validity: PrescriptionValidityDomain.State

                if state.prescription.type == .multiplePrescription {
                    validity = PrescriptionValidityDomain.State(
                        acceptBeginDisplayDate: uiDateFormatter
                            .date(state.prescription.medicationRequest.multiplePrescription?.startPeriod),
                        acceptEndDisplayDate: uiDateFormatter.date(
                            state.prescription.medicationRequest.multiplePrescription?.endPeriod,
                            advancedBy: -oneDay
                        ),
                        expiresBeginDisplayDate: nil,
                        expiresEndDisplayDate: nil,
                        isMVO: true
                    )
                } else {
                    validity = PrescriptionValidityDomain.State(
                        acceptBeginDisplayDate: uiDateFormatter.date(state.prescription.authoredOn),
                        acceptEndDisplayDate: uiDateFormatter.date(
                            state.prescription.acceptedUntil,
                            advancedBy: -oneDay
                        ),
                        expiresBeginDisplayDate: uiDateFormatter.date(state.prescription.acceptedUntil),
                        expiresEndDisplayDate: uiDateFormatter.date(state.prescription.expiresOn, advancedBy: -oneDay),
                        isMVO: false
                    )
                }
                state.destination = .prescriptionValidityInfo(validity)
            case .errorInfo:
                state.destination = .errorInfo(.init())
            case .selfPayerInfo:
                state.destination = .selfPayerInfo(.init())
            case .scannedPrescriptionInfo:
                state.destination = .scannedPrescriptionInfo(.init())
            case .coPaymentInfo:
                guard let status = state.prescription.erxTask.medicationRequest.coPaymentStatus else { return .none }
                let coPaymentState = CoPaymentDomain.State(status: status)
                state.destination = .coPaymentInfo(coPaymentState)
            case .dosageInstructionsInfo:
                let dosageInstructionsState = PrescriptionDosageInstructionsDomain.State(
                    dosageInstructions: state.prescription.medicationRequest.dosageInstructions
                )
                state.destination = .dosageInstructionsInfo(dosageInstructionsState)
            case .emergencyServiceFeeInfo:
                state.destination = .emergencyServiceFeeInfo(.init())
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
                let patientState = PatientDomain.State(patient: patient)
                state.destination = .patient(patientState)
            case .practitioner:
                guard let practitioner = state.prescription.practitioner else { return .none }
                let practitionerState = PractitionerDomain.State(practitioner: practitioner)
                state.destination = .practitioner(practitionerState)
            case .organization:
                guard let organization = state.prescription.organization else { return .none }
                let organizationState = OrganizationDomain.State(organization: organization)
                state.destination = .organization(organizationState)
            case .accidentInfo:
                guard let accidentInfo = state.prescription.medicationRequest.accidentInfo else { return .none }
                let accidentInfoState = AccidentInfoDomain.State(accidentInfo: accidentInfo)
                state.destination = .accidentInfo(accidentInfoState)
            case .technicalInformations:
                let techInfoState = TechnicalInformationsDomain.State(
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
            case .matrixCode:
                state.destination = .matrixCode(
                    .init(
                        type: .erxTask,
                        erxTasks: [state.prescription.erxTask]
                    )
                )
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
        case .destination,
             .delegate,
             .binding:
            return .none
        }
    }

    private func handleResponse(error: ErxRepositoryError) -> PrescriptionDetailDomain.Destination.State {
        // for now we wrap the erxRepositoryError in an ChargeItemConsentService.Error to get access
        // to the localized error messages for http codes 400...500
        // it's technically not correct, since the consent service is not
        // these lines will be corrected (automatically) when the task deletion is implemented using
        // structured concurrency
        let chargeItemConsentServiceError = ChargeItemConsentService.Error.erxRepository(error)
        if case let .remote(.fhirClient(.http(fhirClientHttpError))) = error,
           fhirClientHttpError.httpClientError == .authentication(IDPError.tokenUnavailable) {
            return .alert(Alerts.missingTokenAlertState())
        } else if let alertState = chargeItemConsentServiceError.alertState {
            return .alert(alertState.prescriptionDetailDomainErpAlertState)
        } else {
            return .alert(
                Alerts.deleteFailedAlertState(error: error, localizedError: error.localizedDescriptionWithErrorList)
            )
        }
    }

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

extension ErxTask {
    func shareUrl() -> URL? {
        nil
        // TODO: sharing task data as url fragment must approved by security first //swiftlint:disable:this todo
//        let sharedTask = SharedTask(with: self)
//        guard let encoded = try? JSONEncoder().encode([sharedTask]),
//              var urlComponents = URLComponents(string: "https://erezept.gematik.de/prescription") else {
//            return nil
//        }
//        urlComponents.fragment = String(data: encoded, encoding: .utf8)
//        return urlComponents.url
    }
}

extension Collection where Element == ErxTask {
    func shareUrl() -> URL? {
        nil
        // TODO: sharing task data as url fragment must approved by security first //swiftlint:disable:this todo
//        let shareTasks = map { SharedTask(with: $0).asString }.joined(separator: "&")
//        guard let encoded = try? JSONEncoder().encode([shareTasks]),
//              var urlComponents = URLComponents(string: "https://erezept.gematik.de/prescription") else {
//            return nil
//        }
//
//        urlComponents.fragment = String(data: encoded, encoding: .utf8)
//        return urlComponents.url
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
