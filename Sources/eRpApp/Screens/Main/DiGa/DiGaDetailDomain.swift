//
//  Copyright (c) 2025 gematik GmbH
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
import eRpKit
import eRpStyleKit
import Foundation
import IDP
import Pharmacy
import SwiftUI

// swiftlint:disable file_length type_body_length
@Reducer
struct DiGaDetailDomain {
    @ObservableState
    struct State: Equatable {
        @Shared(.appDefaults) var appDefaults

        var diGaTask: DiGaTask
        var diGaInfo: DiGaInfo
        var bfarmDiGaDetails: BfArMDiGaDetails?
        var profile: UserProfile?
        var refresh = false
        var refreshTime: Date?
        var successCopied = false
        var selectedView: DiGaDetailSegments = .overview
        var displayDiGaStates: [DiGaInfo.DiGaState] {
            if diGaInfo.diGaState == .noInformation {
                return [.request, .insurance]
            }
            return [.request, .insurance, .download, .activate]
        }

        var showMainButton: Bool {
            diGaInfo.diGaState != .insurance
        }

        var patientInfoText: String {
            (diGaTask.practitioner ?? L10n.digaDtlTxtNa.text) + " " + L10n.digaDtlTxtOverviewSubheader.text
        }

        var supportURLText: String {
            L10n.digaDtlSupportTxtLink.text + " " + (bfarmDiGaDetails?.supportUrl ?? L10n.prscFdTxtNa.text)
        }

        var diGaDispense: DiGaDispense? {
            diGaTask.erxTask.medicationDispenses.first?.diGaDispense
        }

        @Presents var destination: Destination.State?
    }

    enum DiGaDetailSegments: CaseIterable, Equatable {
        case overview
        case details

        var displayText: String {
            switch self {
            case .overview: L10n.digaDtlPickerOverview.text
            case .details: L10n.digaDtlPickerDetails.text
            }
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = digasMain:descriptionScreen
        case descriptionDiGA(EmptyDomain)
        // sourcery: AnalyticsScreen = digasMain:howLongDigaValidBottomSheetScreen
        case validDiGa(EmptyDomain)
        // sourcery: AnalyticsScreen = digasMain:digaSupportBottomSheetScreen
        case supportDiGa(EmptyDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = cardWall
        case cardWall(CardWallIntroductionDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_patient
        case patient(PatientDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_practitioner
        case practitioner(PractitionerDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_organization
        case organization(OrganizationDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_technicalInfo
        case technicalInformations(TechnicalInformationsDomain)

        enum Tag: Int {
            case descriptionDiGA
            case validDiGa
            case supportDiGa
            case alert
            case cardWall
            case patient
            case practitioner
            case organization
            case technicalInformations
        }

        enum Alert: Equatable {
            case dismiss
            case confirmedDelete
            case openEmailClient(body: String)
        }
    }

    enum Action: Equatable {
        case task
        case mainButtonTapped
        case changePickerView(DiGaDetailSegments)
        case refreshTask(silent: Bool)
        case copyCode(String)
        case copyCompleted
        case delete
        case openLink(urlString: String?)
        case redeem
        case archive
        case unarchive
        case showCardWall
        case setNavigation(tag: Destination.Tag?)
        case destination(PresentationAction<Destination.Action>)
        case response(Response)
        case delegate(Delegate)
        case receivedTaskUpdate(Result<ErxTask?, ErxRepositoryError>)

        enum Response: Equatable {
            case updateDiGaInfoReceived(Result<DiGaInfo, ErxRepositoryError>)
            case taskDeletedReceived(Result<Bool, ErxRepositoryError>)
            case receivedTelematikId(Result<String?, PharmacyRepositoryError>)
            case redeemReceived(Result<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError>)
            case loadRemotePrescriptionsAndSaveReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
        }

        enum Delegate: Equatable {
            case closeFromDelete
        }
    }

    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.pasteboardService) var pasteboardService: PasteboardService
    @Dependency(\.feedbackReceiver) var feedbackReceiver
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.redeemOrderService) var redeemOrderService: RedeemOrderService
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.uiDateFormatter) var uiDateFormatter
    @Dependency(\.date) var dateGenerator: DateGenerator

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            // MockData for future bfarm api call
//            state.bfarmDiGaDetails = Dummies.placeholderValues

            let loadingTask = Effect.publisher {
                erxTaskRepository.loadLocal(by: state.diGaInfo.taskId, accessCode: nil)
                    .catchToPublisher()
                    .map(Action.receivedTaskUpdate)
            }

            if !state.diGaInfo.isRead {
                return .concatenate(
                    update(diGaInfo: state.diGaInfo.with(isRead: true)),
                    loadingTask
                )
            }
            return loadingTask
        case let .changePickerView(newView):
            state.selectedView = newView
            return .none
        case .mainButtonTapped:
            switch state.diGaInfo.diGaState {
            case .request:
                #if ENABLE_DEBUG_VIEW
                @Shared(.overwriteDIGAIK) var overwriteDIGAIK

                let ikNumber: String?
                if !overwriteDIGAIK.isEmpty {
                    ikNumber = overwriteDIGAIK
                } else {
                    ikNumber = state.profile?.insuranceIK
                }
                guard let ikNumber else { return .none }
                #else
                guard let ikNumber = state.profile?.insuranceIK else { return .none }
                #endif
                return .publisher(
                    pharmacyRepository.fetchTelematikId(ikNumber: ikNumber)
                        .catchToPublisher()
                        .map { Action.response(.receivedTelematikId($0)) }
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            case .download:
                // Open deeplink or bfarm link (bfarm has the app store id)
                return .concatenate(
                    .run { [url = state.diGaDispense?.deepLink] send in
                        await send(.openLink(urlString: url))
                    },
                    update(diGaInfo: state.diGaInfo.with(diGaState: .activate))
                )
            case .activate:
                // Copy redeem code to pasteboard and open app
                guard let redeemCode = state.diGaDispense?.redeemCode else { return .none }
                return .concatenate(
                    .run { [code = redeemCode] send in
                        await send(.copyCode(code))
                    },
                    // open the app (bfarm has the app store id)
                    update(diGaInfo: state.diGaInfo.with(diGaState: .completed))
                )
            case .completed:
                return update(diGaInfo: state.diGaInfo
                    .with(diGaState: DiGaInfo.DiGaState.archive(state.diGaInfo.diGaState)))
            case let .archive(previousState):
                return update(diGaInfo: state.diGaInfo.with(diGaState: previousState))
            case .insurance, .noInformation:
                break
            }
            return .none
        case let .response(.receivedTelematikId(result)):
            switch result {
            case let .success(telematikId):
                if let telematikId = telematikId {
                    let transactionId = UUID()
                    let request = OrderDiGaRequest(
                        orderID: UUID(),
                        flowType: state.diGaTask.erxTask.flowType.rawValue,
                        transactionID: transactionId,
                        taskID: state.diGaTask.erxTask.id,
                        accessCode: state.diGaTask.erxTask.accessCode ?? "",
                        telematikId: telematikId
                    )
                    return .run { send in
                        do {
                            let orderResponses = try await redeemOrderService.redeemViaErxTaskRepositoryDiGa([request])
                            await send(.response(.redeemReceived(.success(orderResponses))))
                        } catch RedeemOrderServiceError.redeem(.noTokenAvailable) {
                            await send(.setNavigation(tag: .cardWall))
                        } catch let RedeemOrderServiceError.redeem(error) {
                            await send(.response(.redeemReceived(.failure(error))))
                        } catch let error as RedeemServiceError {
                            await send(.response(.redeemReceived(.failure(error))))
                        }
                    }
                }
                // TelematikId is empty or not found
                state.destination = .alert(AlertStates.telematikIdEmpty())
                return .none
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                return .none
            }
        case let .response(.redeemReceived(result)):
            switch result {
            case let .success(responses):
                if responses.arePartiallySuccessful || responses.areFailing {
                    state.destination = .alert(AlertStates.failingRequest(count: responses.failedCount))
                } else if responses.areSuccessful {
                    return .concatenate(
                        update(diGaInfo: state.diGaInfo.with(diGaState: .insurance)),
                        // update the Task to load communications
                        .run { send in
                            // wait for 10 seconds, refresh again
                            try await schedulers.main.sleep(for: 10)
                            await send(.refreshTask(silent: true))
                        }
                    )
                }
                return .none
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                return .none
            }
        case let .openLink(urlString):
            guard let urlString = urlString,
                  let url = URL(string: urlString),
                  resourceHandler.canOpenURL(url) else {
                return .none
            }
            resourceHandler.open(url)
            return .none
        case let .copyCode(text):
            pasteboardService.copy(text)
            feedbackReceiver.hapticFeedbackSuccess()
            state.successCopied = true
            return .run { send in
                // wait for 5 second to set successCopied to false
                try await schedulers.main.sleep(for: 5)
                await send(.copyCompleted)
            }
        case .copyCompleted:
            state.successCopied = false
            return .none
        case let .refreshTask(silent):
            @Dependency(\.prescriptionRepository) var prescriptionRepository
            state.refresh = silent ? false : true
            return .publisher(
                prescriptionRepository
                    .silentLoadRemote(for: Locale.current.language.languageCode?.identifier ?? "de")
                    .map { status -> DiGaDetailDomain.Action in
                        switch status {
                        case let .prescriptions(value):
                            return .response(.loadRemotePrescriptionsAndSaveReceived(.value(value)))
                        case .notAuthenticated,
                             .authenticationRequired:
                            return .setNavigation(tag: .cardWall)
                        }
                    }
                    .catch { _ in Just(.response(.loadRemotePrescriptionsAndSaveReceived(.idle))) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .receivedTaskUpdate(.success(erxTask)):
            @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

            guard let erxTask else { return .none }

            state.diGaTask = .init(prescription: Prescription(erxTask: erxTask, dateFormatter: uiDateFormatter))

            if let diGaInfo = erxTask.deviceRequest?.diGaInfo {
                state.diGaInfo = diGaInfo
            }
            if state.diGaInfo.diGaState == .activate || state.diGaInfo.diGaState == .completed,
               !state.appDefaults.diga.hasRedeemdADiga {
                state.$appDefaults.withLock { $0.diga.hasRedeemdADiga = true }
            }
            state.refresh = false
            state.refreshTime = dateGenerator.now
            return .none
        case .receivedTaskUpdate:
            state.refresh = false
            state.refreshTime = dateGenerator.now
            return .none
        // no actual response
        case let .response(.updateDiGaInfoReceived(.failure(error))):
            state.destination = .alert(AlertStates.alertFor(error))
            return .none
        case .response(.updateDiGaInfoReceived):
            return .none
        case let .response(.loadRemotePrescriptionsAndSaveReceived(.error(error))):
            state.refresh = false
            state.destination = .alert(ErpAlertState(for: error))
            return .none
        case .response(.loadRemotePrescriptionsAndSaveReceived):
            state.refresh = false
            return .none
        case let .setNavigation(tag: tag):
            state.refresh = false
            switch tag {
            case .descriptionDiGA:
                state.destination = .descriptionDiGA(.init())
            case .validDiGa:
                state.destination = .validDiGa(.init())
            case .supportDiGa:
                state.destination = .supportDiGa(.init())
            case .cardWall:
                guard let profileId = state.profile?.id else { return .none }
                state.destination = .cardWall(CardWallIntroductionDomain.State(
                    isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                    profileId: profileId
                ))
            case .patient:
                guard let patient = state.diGaTask.erxTask.patient else { return .none }
                let patientState = PatientDomain.State(patient: patient)
                state.destination = .patient(patientState)
            case .practitioner:
                guard let practitioner = state.diGaTask.erxTask.practitioner else { return .none }
                let practitionerState = PractitionerDomain.State(practitioner: practitioner)
                state.destination = .practitioner(practitionerState)
            case .organization:
                guard let organization = state.diGaTask.erxTask.organization else { return .none }
                let organizationState = OrganizationDomain.State(organization: organization)
                state.destination = .organization(organizationState)
            case .technicalInformations:
                let techInfoState = TechnicalInformationsDomain.State(
                    taskId: state.diGaTask.prescription.erxTask.identifier,
                    accessCode: state.diGaTask.prescription.accessCode
                )
                state.destination = .technicalInformations(techInfoState)
            case .none:
                state.destination = nil
            case .alert:
                return .none
            }
            return .none
        case .delete:
            if state.diGaTask.isDeletable {
                state.destination = .alert(AlertStates.confirmDeleteAlertState)
            } else {
                state.destination = .alert(AlertStates.deletionNotAllowedAlertState(isDeletable:
                    state.diGaTask.isDeletable))
            }
            return .none
        case .destination(.presented(.alert(.confirmedDelete))):
            state.destination = nil
            return delete(erxTask: state.diGaTask.erxTask)
        case let .response(.taskDeletedReceived(.failure(error))):
            if case let .remote(.fhirClient(.http(fhirClientHttpError))) = error,
               fhirClientHttpError.httpClientError == .authentication(IDPError.tokenUnavailable) {
                state.destination = .alert(AlertStates.missingTokenAlertState())
            } else {
                state.destination = .alert(
                    AlertStates.deleteFailedAlertState(
                        error: error,
                        localizedError: error.localizedDescriptionWithErrorList
                    )
                )
            }
            return .none
        case let .response(.taskDeletedReceived(.success(success))):
            if success {
                return Effect.send(.delegate(.closeFromDelete))
            }
            return .none
        case let .destination(.presented(.alert(.openEmailClient(body)))):
            state.destination = nil
            guard let email = createReportEmail(body: body), resourceHandler.canOpenURL(email) else { return .none }
            resourceHandler.open(email)
            return .none
        case .archive:
            return update(diGaInfo: state.diGaInfo
                .with(diGaState: DiGaInfo.DiGaState.archive(state.diGaInfo.diGaState)))
        case .unarchive:
            if case let DiGaInfo.DiGaState.archive(previousState) = state.diGaInfo.diGaState {
                return update(diGaInfo: state.diGaInfo.with(diGaState: previousState))
            }
            return .none
        case .redeem:
            #if ENABLE_DEBUG_VIEW
            @Shared(.overwriteDIGAIK) var overwriteDIGAIK

            let ikNumber: String?
            if !overwriteDIGAIK.isEmpty {
                ikNumber = overwriteDIGAIK
            } else {
                ikNumber = state.profile?.insuranceIK
            }
            guard let ikNumber else { return .none }
            #else
            guard let ikNumber = state.profile?.insuranceIK else { return .none }
            #endif
            return .publisher(
                pharmacyRepository.fetchTelematikId(ikNumber: ikNumber)
                    .catchToPublisher()
                    .map { Action.response(.receivedTelematikId($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case .showCardWall:
            guard let profileId = state.profile?.id else { return .none }
            state.destination = .cardWall(CardWallIntroductionDomain.State(
                isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                profileId: profileId
            ))
            return .none
        case .destination(.presented(.cardWall(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination,
             .delegate,
             .response:
            return .none
        }
    }
}

extension DiGaDetailDomain {
    struct DiGaTask: Equatable {
        let appName: String?
        let patientName: String?
        let practitioner: String?
        let organization: String?
        let authoredOnDate: String?
        let authoredOn: String?
        let expiresOn: String?
        let acceptedUntil: String?
        let completedDate: String
        let declinedDate: String
        let requestedAtDate: String
        let erxTask: ErxTask
        let prescription: Prescription
        var isDeletable = false

        init(prescription: Prescription) {
            @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

            appName = prescription.erxTask.deviceRequest?.appName
            patientName = prescription.erxTask.patient?.name
            practitioner = prescription.erxTask.practitioner?.name
            organization = prescription.erxTask.organization?.name
            authoredOnDate = prescription.authoredOnDate
            authoredOn = uiDateFormatter.date(prescription.erxTask.authoredOn)
            expiresOn = prescription.erxTask.expiresOn
            acceptedUntil = prescription.erxTask.acceptedUntil
            completedDate = L10n
                .erxTxtDigaClaimedAt(uiDateFormatter
                    .relativeTime(
                        from: prescription.erxTask.lastModified?.date,
                        formattingContext: .middleOfSentence
                    ) ??
                    L10n
                    .digaDtlTxtNa.text)
                .text
            declinedDate = L10n
                .erxTxtDigaRejectedAt(uiDateFormatter.date(prescription.erxTask.lastModified) ?? L10n.digaDtlTxtNa.text)
                .text
            requestedAtDate = {
                let recentCommunicationDate = prescription.erxTask.communications.filter { $0.profile == .dispReq }
                    .compactMap(\.timestamp.date)
                    .max()
                let localizedString = uiDateFormatter.relativeTime(from: recentCommunicationDate,
                                                                   formattingContext: .middleOfSentence)
                return L10n.erxTxtDigaRequestedAt(localizedString ?? L10n.digaDtlTxtNa.text).text
            }()
            erxTask = prescription.erxTask
            self.prescription = prescription
            isDeletable = prescription.isDeletable
        }

        var expiresUntilDisplayDate: String {
            @Dependency(\.uiDateFormatter) var uiDateFormatter

            return L10n.digaDtlTxtRedeemUnitl(
                uiDateFormatter.date(
                    expiresOn
                ) ?? L10n.digaDtlTxtNa.text
            ).text
        }

        var expiresOnDisplayDate: String {
            let oneDay: TimeInterval = 60 * 60 * 24
            @Dependency(\.uiDateFormatter) var uiDateFormatter

            return uiDateFormatter.date(
                expiresOn,
                advancedBy: -oneDay
            ) ?? L10n.digaDtlTxtNa.text
        }
    }

    /// bfarmDiGaDetails contain information from bfarm
    struct BfArMDiGaDetails: Equatable {
        /// DiGa description
        let description: String?
        /// available languages
        let languages: String?
        /// iOS or/and Android
        let platform: String?
        /// vertragsärztliche Leistung
        let contractMedicalService: String?
        /// additional device
        let additionalDevice: String?
        /// patient cost
        let patientCost: String?
        /// producer cost
        let producerCost: String?
        /// support url for DiGa
        let supportUrl: String?

        init(description: String? = nil,
             languages: String? = nil,
             platform: String? = nil,
             contractMedicalService: String? = nil,
             additionalDevice: String? = nil,
             patientCost: String? = nil,
             producerCost: String? = nil,
             supportUrl: String? = nil) {
            self.description = description
            self.languages = languages
            self.platform = platform
            self.contractMedicalService = contractMedicalService
            self.additionalDevice = additionalDevice
            self.patientCost = patientCost
            self.producerCost = producerCost
            self.supportUrl = supportUrl
        }
    }

    func createReportEmail(body: String) -> URL? {
        var urlString = URLComponents(string: "mailto:app-feedback@gematik.de")
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "subject", value: "Fehlerreport iOS App"))
        queryItems.append(URLQueryItem(name: "body", value: body))

        urlString?.queryItems = queryItems

        return urlString?.url
    }

    func update(diGaInfo: DiGaInfo) -> Effect<DiGaDetailDomain.Action> {
        .run { send in
            let result = try await erxTaskRepository.updateLocal(diGaInfo: diGaInfo).asyncResult(\.self)
            let diGaResult: Result<DiGaInfo, ErxRepositoryError> = result.map { _ in diGaInfo }
            await send(.response(.updateDiGaInfoReceived(diGaResult)))
        }
    }

    func delete(erxTask: ErxTask) -> Effect<DiGaDetailDomain.Action> {
        .run { send in
            let result = try await erxTaskRepository.delete(erxTasks: [erxTask]).asyncResult(\.self)
            await send(.response(.taskDeletedReceived(result)))
        }
    }
}

extension DiGaInfo.DiGaState {
    var description: String? {
        switch self {
        case .request: return L10n.digaDtlTxtOverviewListRequestDesc.text
        case .insurance: return L10n.digaDtlTxtOverviewListInsuranceDesc.text
        case .download: return L10n.digaDtlTxtOverviewListDownloadDesc.text
        case .activate: return L10n.digaDtlTxtOverviewListActivateDesc.text
        case .completed, .archive, .noInformation: return nil
        }
    }

    var buttonText: String? {
        switch self {
        case .request: return L10n.digaDtlBtnMainRequest.text
        case .download: return L10n.digaDtlBtnMainDownload.text
        case .activate: return L10n.digaDtlBtnMainActivate.text
        case .archive: return L10n.digaDtlBtnMainArchive.text
        case .completed: return L10n.digaDtlBtnMainCompleted.text
        case .insurance, .noInformation: return nil
        }
    }

    var accessiblilityText: StringAsset {
        switch self {
        case .request: return L10n.digaDtlTxtAccessRequest
        case .insurance: return L10n.digaDtlTxtAccessInsurance
        case .download: return L10n.digaDtlTxtAccessDownload
        case .activate: return L10n.digaDtlTxtAccessActivate
        case .archive: return L10n.digaDtlTxtAccessArchive
        case .completed: return L10n.digaDtlTxtAccessDone
        case .noInformation: return L10n.digaDtlTxtAccessNotDone
        }
    }

    var stateNumber: Int {
        switch self {
        case .request: return 1
        case .insurance: return 2
        case .download: return 3
        case .activate: return 4
        case .completed: return 5
        case let .archive(previous): return previous.stateNumber
        case .noInformation: return 3
        }
    }

    enum DisplayType: Equatable {
        case text(String)
        case symbol(String)
    }

    func getAccessibilityHint(currentState: DiGaInfo.DiGaState) -> String {
        let isCompleted = stateNumber < currentState.stateNumber

        if self == .insurance, currentState == self {
            return L10n.digaDtlTxtAccessWaiting.text
        } else if isCompleted {
            return L10n.digaDtlTxtAccessDone.text
        } else {
            return L10n.digaDtlTxtAccessNotDone.text
        }
    }

    func getLeadingItem(currentState: DiGaInfo.DiGaState) -> DisplayType {
        let isCompleted = stateNumber < currentState.stateNumber

        if self == .insurance, currentState == self {
            return .symbol(SFSymbolName.hourglass)
        } else if isCompleted {
            return .symbol(SFSymbolName.checkmark)
        } else {
            return .text("\(stateNumber).")
        }
    }

    func backgroundColor(currentState: DiGaInfo.DiGaState?) -> Color {
        if currentState == self {
            return currentState == .insurance ? Colors.yellow100 : Colors.primary100
        } else {
            return Colors.systemColorClear
        }
    }

    func foregroundColor(currentState: DiGaInfo.DiGaState?) -> Color {
        if self == .insurance, currentState == self {
            return Colors.yellow900
        } else {
            return Colors.systemLabel
        }
    }
}

extension DiGaDetailDomain {
    enum Dummies {
        static let prescription = Prescription(erxTask: ErxTask.Demo.expiredErxTask(with: .ready),
                                               dateFormatter: UIDateFormatter.previewValue)

        static let state = State(diGaTask: .init(prescription: prescription),
                                 diGaInfo: DiGaInfo(diGaState: .request),
                                 profile: UserProfile.Dummies.profileA)

        static let placeholderValues: BfArMDiGaDetails = .init(description: "pretty long text",
                                                               languages: "Deutsch, Englisch",
                                                               platform: "iOS, Android",
                                                               contractMedicalService: "Nein",
                                                               additionalDevice: "Keine Zusatzgeräte benötigt",
                                                               patientCost: "0 €",
                                                               producerCost: "500 €",
                                                               supportUrl: "https://www.gematik.de")

        static let store = Store(
            initialState: state
        ) {
            DiGaDetailDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<DiGaDetailDomain> {
            Store(
                initialState: state
            ) {
                DiGaDetailDomain()
            }
        }
    }
}

// swiftlint:enable file_length type_body_length
