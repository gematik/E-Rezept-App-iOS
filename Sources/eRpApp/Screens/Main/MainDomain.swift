//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import AsyncHelpers
import CasePaths
import CodedError
import Combine
import ComposableArchitecture
import ConsentService
import eRpKit
import eRpResources
import ErxTaskRepository
import FeatureCardWall
import FeatureEURedeem
import FeatureHelpers
import Foundation
import IDP
import Settings
import SwiftUI

// swiftlint:disable type_body_length file_length
@Reducer
struct MainDomain {
    @Reducer
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
        // sourcery: AnalyticsScreen = main_osDeprecationDrawer
        case osDeprecation(OSDeprecationDomain)

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
        @Shared(.selectedProfileId) var profileId
        @Shared(.isDemoMode) var isDemoMode
        /// Delete this after iOS 16 deprecation
        var showIOS16DeprecationBanner: Bool {
            ProcessInfo().operatingSystemVersion.majorVersion == 16
        }

        @Presents var destination: Destination.State?

        var path = StackState<Path.State>()

        // Child domain states
        var prescriptionListState: PrescriptionListDomain.State
        var extAuthPendingState = ExtAuthPendingDomain.State()
        var horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State
        var updateChecked = false

        init(destination: Destination.State? = nil,
             prescriptionListState: PrescriptionListDomain.State,
             extAuthPendingState: ExtAuthPendingDomain.State = ExtAuthPendingDomain.State(),
             horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State,
             updateChecked: Bool = false) {
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
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode
        /// Tapping the OS deprecation banner shows more information
        case osDeprecationBannerTapped
        case gkvInsuredButtonTapped
        case pkvInsuredButtonTapped
        case federalInsuredButtonTapped
        case externalLogin(URL)
        case importTaskByUrl(URL)
        case showDrawer
        case grantChargeItemsConsentActivate
        case grantChargeItemsConsentDismiss
        case grantChargeItemsConsentCloseButtonTapped
        case refreshPrescription
        case destination(PresentationAction<Destination.Action>)
        case path(StackActionOf<Path>)
        case setNavigation(tag: Bool?)
        case startCardWall
        case redeemPrescriptions(_ prescriptions: Shared<[Prescription]>)
        case redeemFromPharmacy(_ pharmacy: PharmacyLocation, option: RedeemOption)
        case euRedeemSelection(_ prescriptions: Shared<[Prescription]>)
        case euRedeemInstructions(_ isRedeeming: Bool, countryCode: String?)
        case euRedeemCode(countryCode: String)
        case euNoCountryAlert
        case response(Response)

        // Child Domain Actions
        case extAuthPending(action: ExtAuthPendingDomain.Action)
        case prescriptionList(action: PrescriptionListDomain.Action)
        case horizontalProfileSelection(action: HorizontalProfileSelectionDomain.Action)

        enum Response: Equatable {
            case loadDeviceSecurityViewReceived(DeviceSecurityDomain.State?)
            case importReceived(Result<[ErxTask], Error>)
            case showDrawer(DrawerEvaluation.DrawerEvaluationResult)
            case grantChargeItemsConsentActivate(ConsentService.GrantResult)
            case showUpdateAlertResponse(Bool)
        }
    }

    @Reducer
    enum Path {
        // sourcery: AnalyticsScreen = redeem_methodSelection
        case redeemMethods(RedeemMethodsDomain)
        // sourcery: AnalyticsScreen = redeem_overview
        case redeem(PharmacyRedeemDomain)
        // sourcery: AnalyticsScreen = pharmacySearch
        case pharmacy(PharmacySearchDomain)

        /// EU redeem selection screen
        case euRedeemSelection(EURedeemSelectionDomain)
        /// Country selection screen
        case countrySelection(CountrySelectionDomain)
        /// Prescription selection screen
        case prescriptionSelection(SelectEUPrescriptionsDomain)
        /// Instructions screen
        case instructions(InstructionsDomain)
        /// Code display screen
        case code(CodeDomain)
    }

    @CodedError("015")
    @CasePathable
    enum Error: Swift.Error, Equatable {
        @ErrorCode("01")
        case localStoreError(LocalStoreError)
        @ErrorCode("02")
        case userSessionError(UserSessionError)
        /// Import of shared Task failed due to being a duplicate already existing within the app
        @ErrorCode("03")
        case importDuplicate
        /// Saving or retrieving data failed
        @ErrorCode("04")
        case repositoryError(ErxRepositoryError)
    }

    @Dependency(\.schedulers) var schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.deviceSecurityManager) var deviceSecurityManager
    @Dependency(\.profileSecureDataWiper) var profileSecureDataWiper: ProfileSecureDataWiper
    @Dependency(\.consentService) var consentService: ConsentService
    @Dependency(\.profileDataStore) var profileDataStore
    @Dependency(\.router) var router: Routing
    @Dependency(\.drawerEvaluation) var drawerEvaluation: DrawerEvaluation
    @Dependency(\.updateChecker) var updateChecker: UpdateChecker

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
            consentService: consentService
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

        Reduce(core)
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
        case .osDeprecationBannerTapped:
            state.destination = .osDeprecation(
                OSDeprecationDomain.State(version: "16")
            )
            return .none
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
            if let deviceSecurityState {
                state.destination = .deviceSecurity(deviceSecurityState)
            }
            return .none
        case .checkForForcedUpdates:
            // [REQ:BSI-eRp-ePA:O.Arch_10#3] The actual business logic for the update check
            return .run { [updateChecked = state.updateChecked] send in
                guard !updateChecked else { return }

                if await updateChecker.isUpdateAvailable() {
                    await send(.response(.showUpdateAlertResponse(true)))
                    return
                }
                await send(.response(.showUpdateAlertResponse(false)))
            }
        case let .response(.showUpdateAlertResponse(show)):
            state.updateChecked = true
            if show, state.destination == nil {
                state.destination = .alert(AlertStates.forcedUpdateAlert())
            }
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
            return environment.checkForTaskDuplicatesThenSave(sharedTasks, profileId: state.profileId)
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
                state.destination = .alert(.init(for: error, title: L10n.errSpecificI10808Title) {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                })
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
                    .init(
                        for: error,
                        title: nil
                    ) {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    }
                )
            }
            return .none
        case let .prescriptionList(action: .response(.showCardWallReceived(cardWallState))):
            state.destination = .cardWall(cardWallState)
            return .none
        case .prescriptionList(action: .response(.showInsuranceTypeSelectionSheetReceived)):
            state.destination = .welcomeDrawer
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
               !openPrescriptions.contains(where: { !$0.isDiGaPrescription }) {
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
        case .destination(.dismiss):
            if state.destination.is(\.cardWall) {
                return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
            }
            return .none
        case .destination(.presented(.cardWall(action: .delegate(.close)))),
             .extAuthPending(action: .hide):
            state.destination = nil
            return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
        case .destination(.presented(.prescriptionArchive(action: .delegate(.close)))),
             .destination(.presented(.prescriptionDetail(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.osDeprecation(action: .delegate(.continueWithAppButtonTapped)))):
            state.destination = nil
            return .none
        case let .horizontalProfileSelection(action: .response(.loadReceived(.failure(error)))):
            state.destination = .alert(
                .init(
                    for: error,
                    title: nil
                ) {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                }
            )
            return .none
        case .showDrawer:
            guard state.destination == nil
            else { return .none }
            return .run { send in
                await send(.response(.showDrawer(drawerEvaluation.showDrawerEvaluation())))
            }
        case .gkvInsuredButtonTapped:
            guard let profileId = state.horizontalProfileSelectionState.selectedProfileId else {
                return .none
            }

            return .run { send in
                _ = try await userProfileService
                    .update(profileId: profileId) { profile in
                        profile.insuranceType = .gKV
                    }
                    .async()
                await send(.startCardWall)
            }
        case .pkvInsuredButtonTapped:
            guard let profileId = state.horizontalProfileSelectionState.selectedProfileId else {
                return .none
            }

            return .run { send in
                _ = try await userProfileService
                    .update(profileId: profileId) { profile in
                        profile.insuranceType = .pKV
                    }
                    .async()
                await send(.startCardWall)
            }
        case .federalInsuredButtonTapped:
            guard let profileId = state.horizontalProfileSelectionState.selectedProfileId else {
                return .none
            }

            return .run { send in
                _ = try await userProfileService
                    .update(profileId: profileId) { profile in
                        profile.insuranceType = .federalKV
                    }
                    .async()
                await send(.startCardWall)
            }
        case let .response(.showDrawer(drawerEvaluationResult)):
            switch drawerEvaluationResult {
            case .welcomeDrawer:
                state.destination = .welcomeDrawer
                // welcome drawer has been shown to this profile
                return .run { _ in
                    _ = try await environment.setHideWelcomeDrawerOnMainViewToTrue()
                }
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
                let result = try await consentService.grantConsent(.chargcons, profileId)
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
            case let .error(consentServiceError):
                if let alertState = consentServiceError.alertState {
                    // in case of an expected (specified) http error
                    state.destination = .alert(alertState.mainDomainErpAlertState)
                } else {
                    // in case of an unexpected (not specified) error
                    state.destination = .alert(AlertStates.grantConsentErrorFor(error: consentServiceError))
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
        case .grantChargeItemsConsentCloseButtonTapped:
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
            @Dependency(\.openURLHandler) var openURLHandler

            guard let url = URL(string: "https://itunes.apple.com/app/id1511792179?mt=8") else {
                return .none
            }
            return .run { _ in
                _ = await openURLHandler.open(url)
            }
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
                    .init(
                        for: error,
                        title: nil
                    ) {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    }
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
                    .init(
                        for: error,
                        title: nil
                    ) {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    }
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
                    .init(
                        for: error,
                        title: nil
                    ) {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    }
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
            case let .euRedeemTapped(prescriptions):
                let prescriptions = Shared(value: prescriptions)
                return .send(.euRedeemSelection(prescriptions))
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
        case .destination(
            .presented(
                .prescriptionDetail(action: .destination(.presented(.matrixCode(.delegate(.euRedeemButtonTapped)))))
            )
        ),
        .destination(.presented(.prescriptionDetail(action: .delegate(.euRedeemButtonTapped)))):
            state.destination = nil
            let prescriptions = state.prescriptionListState.openPrescriptions
            return .run { send in
                // wait for running effects to finish
                try await schedulers.main.sleep(for: 0.05)
                let prescriptions = Shared(value: prescriptions)
                await send(.euRedeemSelection(prescriptions))
            }
        case let .path(.element(id: _, action: .countrySelection(.selectCountry(country)))):
            state.path.removeLast()
            guard let id = state.path.ids.last
            else { return .none }
            state.path[id: id, case: \.euRedeemSelection]?.selectedCountry = country
            return .none
        case let .path(.popFrom(id: id)):
            // Back navigation from PrescriptionSelection to EURedeemSelection
            if let path = state.path[id: id, case: \.prescriptionSelection] {
                let prescriptions = path.prescriptions.filter(\.isSetEURedeemableByPatient)
                guard state.path.ids.count > 1 else { return .none }
                let previousId = state.path.ids[state.path.index(before: state.path.endIndex - 1)]
                state.path[id: previousId, case: \.euRedeemSelection]?.$selectedPrescriptions
                    .withLock { $0 = prescriptions }
            }
            return .none
        case let .path(.element(id: id, action: .euRedeemSelection(.delegate(delegate)))):
            switch delegate {
            case .selectPrescriptionsButtonTapped:
                state.path.append(.prescriptionSelection(.init()))
                return .none
            case .selectCountryButtonTapped:
                state.path.append(.countrySelection(.init()))
                return .none
            case let .selectInstructionButtonTapped(countryCode: code):
                return .send(.euRedeemInstructions(false, countryCode: code))
            case .redeemPrescriptions:
                return .run { [path = state.path, userDataStore = self.userDataStore] send in
                    let hideEURedeemInstructions = try await userDataStore.hideEURedeemInstructions.async()
                    guard let code = path[id: id, case: \.euRedeemSelection]?.selectedCountry?.countryCode else {
                        await send(.euNoCountryAlert)
                        return
                    }
                    if hideEURedeemInstructions {
                        await send(.euRedeemCode(countryCode: code))
                    } else {
                        userDataStore.set(hideEURedeemInstructions: true)
                        await send(.euRedeemInstructions(true, countryCode: code))
                    }
                }
            case .back:
                state.path.pop(from: id)
                return .none
            case .close:
                state.path.removeAll()
                return .none
            case .unlockCardClose:
                state.path.removeAll()
                return .run { _ in
                    await environment.router.routeTo(.settings(.unlockCard))
                }
            }
        case .euNoCountryAlert:
            guard let id = state.path.ids.last
            else { return .none }
            state.path[id: id, case: \.euRedeemSelection]?
                .destination = .alert(EURedeemSelectionDomain.AlertStates.noCountryCode)
            return .none
        case let .euRedeemSelection(prescriptions):
            let prescriptions = Shared(value: prescriptions.wrappedValue.map { EUPrescription(erxTask: $0.erxTask) })
            state.path.append(.euRedeemSelection(.init(
                prescriptions: prescriptions
            )))
            return .none
        case let .euRedeemInstructions(isRedeeming, countryCode: code):
            state.path.append(.instructions(.init(isRedeeming: isRedeeming, countryCode: code)))
            return .none
        case let .euRedeemCode(countryCode):
            state.path.append(.code(.init(countryCode: countryCode)))
            return .none
        case let .path(.element(id: _, action: .instructions(.delegate(delegate)))):
            switch delegate {
            case .continueButtonTapped:
                state.path.removeLast()
                guard let id = state.path.ids.last
                else { return .none }

                guard let code = state.path[id: id, case: \.euRedeemSelection]?.selectedCountry?.countryCode else {
                    state.path[id: id, case: \.euRedeemSelection]?
                        .destination = .alert(EURedeemSelectionDomain.AlertStates.noCountryCode)
                    return .none
                }
                return .send(.euRedeemCode(countryCode: code))
            case .close:
                state.path.removeAll()
                return .none
            }
        case let .path(.element(id: _, action: .code(.delegate(delegate)))):
            switch delegate {
            case .takeReceipt:
                state.path.removeAll()
                return .none
            case .close:
                state.path.removeAll()
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
                let selectedPrescriptions = state.path.last?.redeem?.$selectedPrescriptions ?? Shared(value: [])
                state.path.append(.pharmacy(PharmacySearchDomain.State(
                    selectedPrescriptions: selectedPrescriptions,
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

extension MainDomain.Destination.State: Equatable {}
extension MainDomain.Destination.Action: Equatable {}
extension MainDomain.Path.State: Equatable {}
extension MainDomain.Path.Action: Equatable {}
// swiftlint:enable type_body_length
