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

import CasePaths
import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import IDP
import SwiftUI

// swiftlint:disable type_body_length file_length
@Reducer
struct MainDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = main_createProfile
        case createProfile(CreateProfileDomain)
        // sourcery: AnalyticsScreen = main_editProfilePicture
        case editProfilePicture(EditProfilePictureDomain)
        // sourcery: AnalyticsScreen = main_editName
        case editProfileName(EditProfileNameDomain)
        // sourcery: AnalyticsScreen = main_scanner
        case scanner(ScannerDomain)
        // sourcery: AnalyticsScreen = main_deviceSecurity
        case deviceSecurity(DeviceSecurityDomain)
        // sourcery: AnalyticsScreen = cardWall
        case cardWall(CardWallIntroductionDomain)
        // sourcery: AnalyticsScreen = main_prescriptionArchive
        case prescriptionArchive(PrescriptionArchiveDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail
        case prescriptionDetail(PrescriptionDetailDomain)
        // sourcery: AnalyticsScreen = main_medicationReminder
        case medicationReminder(MedicationReminderOneDaySummaryDomain)
        // sourcery: AnalyticsScreen = main_welcomeDrawer
        case welcomeDrawer
        // sourcery: AnalyticsScreen = main_consentDrawer
        case grantChargeItemConsentDrawer
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case toast(ToastState<Toast>)
        // sourcery: AnalyticsScreen = digasMain
        case diGaDetail(DiGaDetailDomain)

        enum Alert {
            case dismiss
            case cardWall
            case retryGrantChargeItemConsent
            case dismissGrantChargeItemConsent
            case consentServiceErrorOkay
            case consentServiceErrorAuthenticate
            case consentServiceErrorRetry
            case goToAppStore
        }

        enum Toast {
            case routeToChargeItemsList
        }
    }

    @ObservableState
    struct State: Equatable {
        var isDemoMode = false
        @Presents var destination: Destination.State?

        var path = StackState<Path.State>()

        // Child domain states
        var prescriptionListState: PrescriptionListDomain.State
        var extAuthPendingState = ExtAuthPendingDomain.State()
        var horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State
        var updateChecked = false

        init(isDemoMode: Bool = false,
             destination: Destination.State? = nil,
             prescriptionListState: PrescriptionListDomain.State,
             extAuthPendingState: ExtAuthPendingDomain.State = ExtAuthPendingDomain.State(),
             horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State,
             updateChecked: Bool = false) {
            self.isDemoMode = isDemoMode
            self.destination = destination
            self.prescriptionListState = prescriptionListState
            self.extAuthPendingState = extAuthPendingState
            self.horizontalProfileSelectionState = horizontalProfileSelectionState
            self.updateChecked = updateChecked
        }
    }

    enum Action: Equatable {
        /// Presents the `ScannerView`
        case showScannerView
        case showMedicationReminder([UUID])
        /// Hides the `ScannerView`
        case loadDeviceSecurityView
        /// Check for forced updates
        case checkForForcedUpdates
        /// Start listening to demo mode changes
        case subscribeToDemoModeChange
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode
        case externalLogin(URL)
        case importTaskByUrl(URL)
        case showDrawer
        case grantChargeItemsConsentActivate
        case grantChargeItemsConsentDismiss
        case refreshPrescription
        case destination(PresentationAction<Destination.Action>)
        case path(StackActionOf<Path>)
        case setNavigation(tag: Bool?)
        case startCardWall
        case redeemPrescriptions(_ prescriptions: Shared<[Prescription]>)
        case redeemFromPharmacy(_ pharmacy: PharmacyLocation, option: RedeemOption)
        case response(Response)

        // Child Domain Actions
        case extAuthPending(action: ExtAuthPendingDomain.Action)
        case prescriptionList(action: PrescriptionListDomain.Action)
        case horizontalProfileSelection(action: HorizontalProfileSelectionDomain.Action)

        enum Response: Equatable {
            case loadDeviceSecurityViewReceived(DeviceSecurityDomain.State?)
            case demoModeChangeReceived(Bool)
            case importReceived(Result<[ErxTask], Error>)
            case showDrawer(MainDomain.Environment.DrawerEvaluationResult)
            case grantChargeItemsConsentActivate(ChargeItemConsentService.GrantResult)
            case showUpdateAlertResponse(Bool)
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        // sourcery: AnalyticsScreen = redeem_methodSelection
        case redeemMethods(RedeemMethodsDomain)
        // sourcery: AnalyticsScreen = redeem_overview
        case redeem(PharmacyRedeemDomain)
        // sourcery: AnalyticsScreen = pharmacySearch
        case pharmacy(PharmacySearchDomain)
    }

    // sourcery: CodedError = "015"
    @CasePathable
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case localStoreError(LocalStoreError)
        // sourcery: errorCode = "02"
        case userSessionError(UserSessionError)
        // sourcery: errorCode = "03"
        /// Import of shared Task failed due to being a duplicate already existing within the app
        case importDuplicate
        // sourcery: errorCode = "04"
        /// Saving or retrieving data failed
        case repositoryError(ErxRepositoryError)
    }

    @Dependency(\.schedulers) var schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.deviceSecurityManager) var deviceSecurityManager
    @Dependency(\.profileSecureDataWiper) var profileSecureDataWiper: ProfileSecureDataWiper
    @Dependency(\.chargeItemConsentService) var chargeItemConsentService: ChargeItemConsentService
    @Dependency(\.profileDataStore) var profileDataStore
    @Dependency(\.router) var router: Routing

    var environment: Environment {
        .init(
            router: router,
            userSessionContainer: userSessionContainer,
            userSession: userSession,
            erxTaskRepository: erxTaskRepository,
            schedulers: schedulers,
            fhirDateFormatter: fhirDateFormatter,
            userDataStore: userDataStore,
            deviceSecurityManager: deviceSecurityManager,
            profileSecureDataWiper: profileSecureDataWiper,
            profileDataStore: profileDataStore,
            chargeItemConsentService: chargeItemConsentService
        )
    }

    var body: some Reducer<State, Action> {
        Scope(state: \State.prescriptionListState, action: \.prescriptionList) {
            PrescriptionListDomain()
        }
        Scope(state: \State.horizontalProfileSelectionState, action: \.horizontalProfileSelection) {
            HorizontalProfileSelectionDomain()
        }
        Scope(state: \State.extAuthPendingState, action: \.extAuthPending) {
            ExtAuthPendingDomain()
        }

        Reduce(self.core)
            .forEach(\.path, action: \.path)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .turnOffDemoMode:
            return .run { _ in
                await environment.router.routeTo(.settings(nil))
            }
        case let .prescriptionList(action: .profilePictureViewTapped(profile)):
            state.destination = .editProfilePicture(
                EditProfilePictureDomain.State(
                    profileId: profile.id,
                    color: profile.color,
                    picture: profile.image,
                    userImageData: profile.userImageData ?? Data(),
                    isFullScreenPresented: false
                )
            )
            return .none
        case .showScannerView:
            state.destination = .scanner(ScannerDomain.State())
            return .none
        case .loadDeviceSecurityView:
            return .publisher(
                environment.deviceSecurityManager.showSystemSecurityWarning
                    .map { type in
                        switch type {
                        case .none:
                            return nil
                        default:
                            return DeviceSecurityDomain.State(warningType: type)
                        }
                    }
                    .map { .response(.loadDeviceSecurityViewReceived($0)) }
                    .receive(on: environment.schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.loadDeviceSecurityViewReceived(deviceSecurityState)):
            if let deviceSecurityState = deviceSecurityState {
                state.destination = .deviceSecurity(deviceSecurityState)
            }
            return .none
        case .checkForForcedUpdates:
            // [REQ:BSI-eRp-ePA:O.Arch_10#3] The actual business logic for the update check
            return .run(operation: { [updateChecked = state.updateChecked] send in
                @Dependency(\.userSession.updateChecker) var updateChecker

                guard !updateChecked else { return }

                if await updateChecker.isUpdateAvailable() {
                    await send(.response(.showUpdateAlertResponse(true)))
                    return
                }
                await send(.response(.showUpdateAlertResponse(false)))
            })
        case .subscribeToDemoModeChange:
            return .publisher(
                environment.userSessionContainer.isDemoMode
                    .map { .response(.demoModeChangeReceived($0)) }
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.showUpdateAlertResponse(show)):
            state.updateChecked = true
            if show, state.destination == nil {
                state.destination = .alert(AlertStates.forcedUpdateAlert())
            }
            return .none
        case let .response(.demoModeChangeReceived(demoModeValue)):
            state.isDemoMode = demoModeValue
            return .none
        case let .externalLogin(url):
            // [REQ:BSI-eRp-ePA:O.Source_1#7] redirect into correct domain
            // [REQ:gemSpec_IDP_Frontend:A_22301-01#6|3] Redirect into ExtAuthPendingDomain
            return .run { send in
                await send(.extAuthPending(action: .externalLogin(url)))
            }
        case let .importTaskByUrl(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  components.path.contains("prescription"),
                  let fragment = components.fragment?.data(using: .utf8),
                  let sharedTasks = try? JSONDecoder().decode([SharedTask].self, from: fragment) else {
                return .none
            }
            return environment.checkForTaskDuplicatesThenSave(sharedTasks)
        case .response(.importReceived(.success)):
            state.destination = .alert(.init(title: L10n.erxTxtPrescriptionAddedAlertTitle))
            return .none
        case let .response(.importReceived(.failure(error))):
            state.destination = .alert(.init(for: error, title: L10n.erxTxtPrescriptionDuplicateAlertTitle))
            return .none
        case .destination(.presented(.deviceSecurity(.delegate(.close)))),
             .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case let .showMedicationReminder(scheduleEntries):
            state.destination = .medicationReminder(.init(entries: scheduleEntries))
            return .none
        case .startCardWall,
             .destination(.presented(.alert(.cardWall))):
            environment.userSession.idpSession.invalidateAccessToken()
            state.destination = .cardWall(.init(isNFCReady: true, profileId: environment.userSession.profileId))
            return .none
        case let .prescriptionList(action: .response(.errorReceived(error))):
            switch error {
            case .idpError(.biometrics) where error.contains(PrivateKeyContainer.Error.canceledByUser):
                state.destination = .alert(.init(for: error, title: L10n.errSpecificI10808Title, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                }))
            case let .idpError(.serverError(response))
                where response.code == IDPError.Code.pairingAuthorizationFailed.rawValue:
                state.destination = .alert(AlertStates.devicePairingInvalid())
                return .run { [profileId = environment.userSession.profileId] _ in
                    _ = try await environment.profileSecureDataWiper.wipeSecureData(of: profileId).async()
                }
            case .idpError(.biometrics), .idpError(.serverError):
                state.destination = .alert(AlertStates.loginNecessaryAlert(for: error))
            default:
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
            }
            return .none
        case let .prescriptionList(action: .response(.showCardWallReceived(cardWallState))):
            state.destination = .cardWall(cardWallState)
            return .none
        case let .prescriptionList(action: .diGaDetailViewTapped(prescription, profile)):
            guard let diGaInfo = prescription.erxTask.deviceRequest?.diGaInfo else { return .none }
            state.destination = .diGaDetail(DiGaDetailDomain.State(
                diGaTask: .init(prescription: prescription),
                diGaInfo: diGaInfo,
                profile: profile
            ))
            return .none
        case let .prescriptionList(action: .prescriptionDetailViewTapped(prescription)):
            state.destination = .prescriptionDetail(PrescriptionDetailDomain.State(
                prescription: prescription,
                isArchived: prescription.isArchived
            ))
            return .none
        case .destination(.presented(.diGaDetail(action: .delegate(.closeFromDelete)))):
            state.destination = nil
            return .none
        case let .prescriptionList(action: .redeemButtonTapped(openPrescriptions)):
            state.destination = nil
            if openPrescriptions.filter(\.isDiGaPrescription).count >= 1,
               openPrescriptions.filter({ !$0.isDiGaPrescription }).isEmpty {
                // redeem DiGa
                return .none
            }
            state.path.append(.redeemMethods(RedeemMethodsDomain.State(
                prescriptions: openPrescriptions.filter(\.isPharmacyRedeemable)
            )))
            return .none
        case .prescriptionList(action: .showArchivedButtonTapped):
            state.destination = .prescriptionArchive(.init())
            return .none
        case .destination(.presented(.cardWall(action: .delegate(.close)))):
            state.destination = nil
            return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
        case .destination(.presented(.prescriptionArchive(action: .delegate(.close)))),
             .destination(.presented(.prescriptionDetail(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case let .horizontalProfileSelection(action: .response(.loadReceived(.failure(error)))):
            state.destination = .alert(
                .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                })
            )
            return .none
        case .showDrawer:
            guard state.destination == nil
            else { return .none }
            return .run { send in
                await send(.response(.showDrawer(environment.showDrawerEvaluation())))
            }

        case let .response(.showDrawer(drawerEvaluationResult)):
            switch drawerEvaluationResult {
            case .welcomeDrawer:
                state.destination = .welcomeDrawer
                environment.userDataStore.hideWelcomeDrawer = true
                return .none
            case .consentDrawer:
                state.destination = .grantChargeItemConsentDrawer
                // memorise the fact that the consent drawer has been shown to this profile
                return .run { _ in
                    _ = try await environment.setHidePkvConsentDrawerOnMainViewToTrue()
                }
            case .none:
                return .none
            }

        case .grantChargeItemsConsentActivate,
             .destination(.presented(.alert(.retryGrantChargeItemConsent))):

            state.destination = nil
            let profileId = userSession.profileId
            return .run { send in
                let result = try await chargeItemConsentService.grantConsent(profileId)
                await send(.response(.grantChargeItemsConsentActivate(result)))
            }
        case let .response(.grantChargeItemsConsentActivate(result)):
            switch result {
            case .success:
                state.destination = .toast(ToastStates.grantConsentSuccess)
            case .notAuthenticated:
                state.destination = .alert(AlertStates.grantConsentServiceNotAuthenticated)
            case .conflict:
                state.destination = .toast(ToastStates.conflictToast)
            case let .error(chargeItemConsentServiceError):
                if let alertState = chargeItemConsentServiceError.alertState {
                    // in case of an expected (specified) http error
                    state.destination = .alert(alertState.mainDomainErpAlertState)
                } else {
                    // in case of an unexpected (not specified) error
                    state.destination = .alert(AlertStates.grantConsentErrorFor(error: chargeItemConsentServiceError))
                }
            }
            return .none
        case .destination(.presented(.toast(.routeToChargeItemsList))):
            state.destination = nil
            return .run { _ in
                await environment.router
                    .routeTo(.settings(.editProfile(.chargeItemListFor(environment.userSession.profileId))))
            }
        case .grantChargeItemsConsentDismiss,
             .destination(.presented(.alert(.dismissGrantChargeItemConsent))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.consentServiceErrorOkay))):
            state.destination = nil
            return .none
        case .destination(.presented(.alert(.consentServiceErrorRetry))):
            state.destination = nil
            return .run { send in
                await send(.grantChargeItemsConsentActivate)
            }
        case .destination(.presented(.alert(.goToAppStore))):
            @Dependency(\.resourceHandler) var resourceHandler

            guard let url = URL(string: "https://itunes.apple.com/app/id1511792179?mt=8") else {
                return .none
            }
            resourceHandler.open(url)
            return .none
        case .destination(.presented(.alert(.consentServiceErrorAuthenticate))):
            state.destination = .cardWall(.init(isNFCReady: true, profileId: environment.userSession.profileId))
            return .none

        case .refreshPrescription:
            return Effect.send(.prescriptionList(action: .refresh))
        case .horizontalProfileSelection(action: .showAddProfileView):
            state.destination = .createProfile(CreateProfileDomain.State())
            return .none
        case let .horizontalProfileSelection(action: .showEditProfileNameView(profileId, profileName)):
            state
                .destination = .editProfileName(EditProfileNameDomain
                    .State(profileName: profileName, profileId: profileId))
            return .none
        case let .destination(.presented(.createProfile(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case let .destination(.presented(.editProfileName(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case let .destination(.presented(.editProfilePicture(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case .destination(.presented(.cardWall(action: .delegate(.unlockCardClose)))):
            state.destination = nil
            return .run { _ in
                await environment.router.routeTo(.settings(.unlockCard))
            }
        case let .destination(.presented(.prescriptionDetail(action: .delegate(.redeem(prescription))))):
            state.destination = nil
            let prescriptions = Shared(value: [prescription])
            return .run { send in
                // wait for running effects to finish
                try await schedulers.main.sleep(for: 0.05)
                await send(.redeemPrescriptions(prescriptions))
            }
        case let .path(.element(id: _, action: .redeemMethods(.delegate(delegate)))):
            switch delegate {
            case let .redeemOverview(prescriptions):
                let prescriptions = Shared(value: prescriptions)
                return .send(.redeemPrescriptions(prescriptions))
            case .close:
                guard !state.path.isEmpty else {
                    reportIssue(
                        "RedeemMethodsDomain was closed but no redeem path is available. This should not happen."
                    )
                    return .none
                }
                state.path.removeLast()
                return .none
            }
        case let .path(.element(id: _, action: .pharmacy(
            .destination(.presented(
                .pharmacyDetail(.delegate(.redeem(
                    prescriptions: _,
                    selectedPrescriptions: _,
                    pharmacy: pharmacy,
                    option: redeemOption
                )))
            ))
        ))),
        let .path(.element(id: _, action: .pharmacy(
            .destination(.presented(
                .pharmacyMapSearch(.destination(.presented(
                    .pharmacy(.delegate(.redeem(
                        prescriptions: _,
                        selectedPrescriptions: _,
                        pharmacy: pharmacy,
                        option: redeemOption
                    )))
                )))
            ))
        ))):
            return .run { send in
                // wait for running effects to finish
                try await schedulers.main.sleep(for: 0.05)
                await send(.redeemFromPharmacy(pharmacy, option: redeemOption))
            }
        case let .redeemPrescriptions(prescriptions):
            state.path.append(.redeem(PharmacyRedeemDomain.State(
                prescriptions: prescriptions,
                selectedPrescriptions: Shared(value: prescriptions.wrappedValue)
            )))
            return .none
        case let .redeemFromPharmacy(pharmacy, option: redeemOption):
            guard !state.path.isEmpty else {
                reportIssue("state.path is empty but should not be empty here. This should not happen.")
                return .none
            }
            state.path.removeLast()

            guard let redeemId = state.path.ids.last
            else { return .none }
            state.path[id: redeemId, case: \.redeem]?.pharmacy = pharmacy
            state.path[id: redeemId, case: \.redeem]?.serviceOptionState.selectedOption = redeemOption
            return .none
        case let .path(.element(id: _, action: .redeem(.delegate(delegate)))):
            switch delegate {
            case .close:
                state.path.removeAll()
                return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
            case .changePharmacy:
                state.path.append(.pharmacy(PharmacySearchDomain.State(
                    selectedPrescriptions: Shared(value: []),
                    inRedeemProcess: true
                )))
            }
            return .none
        case .path(.element(id: _, action: .pharmacy(.delegate(.close)))),
             .path(.element(id: _,
                            action: .pharmacy(.destination(.presented(.pharmacyMapSearch(.delegate(.close))))))),
             .path(.element(id: _, action: .pharmacy(.destination(.presented(.pharmacyDetail(.delegate(.close))))))):
            state.path.removeAll()
            return .none
//        case .destination(.presented(.diGaDetail(.refreshTask))):
//            return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
        case .destination,
             .path,
             .setNavigation,
             .prescriptionList,
             .extAuthPending,
             .horizontalProfileSelection:
            return .none
        }
    }
}

// swiftlint:enable type_body_length
