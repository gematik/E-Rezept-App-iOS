//
//  Copyright (c) 2022 gematik GmbH
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
import DataKit
import eRpKit
import IDP

// swiftlint:disable:next type_body_length
enum SettingsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case healthCardResetCounterNoNewSecret(ResetRetryCounterDomain.State)
        case healthCardResetCounterWithNewSecret(ResetRetryCounterDomain.State)

        enum Tag: Int {
            case healthCardResetCounterNoNewSecret
            case healthCardResetCounterWithNewSecret
        }

        var tag: Tag {
            switch self {
            case .healthCardResetCounterNoNewSecret:
                return .healthCardResetCounterNoNewSecret
            case .healthCardResetCounterWithNewSecret:
                return .healthCardResetCounterWithNewSecret
            }
        }
    }

    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            .cancel(token: Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            ProfilesDomain.cleanup(),
            ResetRetryCounterDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case updates
    }

    struct State: Equatable {
        var isDemoMode: Bool
        var alertState: AlertState<Action>?
        var showLegalNoticeView = false
        var showDataProtectionView = false
        var showFOSSView = false
        var showTermsOfUseView = false
        var showDebugView = false
        var showOrderHealthCardView = false
        var appSecurityState: AppSecurityDomain.State
        var profiles = ProfilesDomain.State(profiles: [], selectedProfileId: nil, route: nil)
        var appVersion = AppVersion.current
        var trackerOptIn = false
        var showTrackerComplyView = false

        var route: Route?
    }

    enum Action: Equatable {
        case close
        case initSettings
        case trackerStatusReceived(Bool)
        case alertDismissButtonTapped
        case toggleDemoModeSwitch
        case toggleTrackingTapped(Bool)
        case confirmedOptInTracking
        case dismissTrackerComplyView
        case toggleLegalNoticeView(Bool)
        case toggleDataProtectionView(Bool)
        case toggleFOSSView(Bool)
        case toggleTermsOfUseView(Bool)
        case toggleDebugView(Bool)
        case toggleOrderHealthCardView(Bool)
        case appSecurity(action: AppSecurityDomain.Action)
        case profiles(action: ProfilesDomain.Action)
        case healthCardResetCounterNoNewSecret(action: ResetRetryCounterDomain.Action)
        case healthCardResetCounterWithNewSecret(action: ResetRetryCounterDomain.Action)
        case popToRootView

        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        let changeableUserSessionContainer: UsersSessionContainer
        let schedulers: Schedulers
        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider
        let nfcResetRetryCounterController: NFCResetRetryCounterController
        let appSecurityManager: AppSecurityManager
        let router: Routing
        let userSessionProvider: UserSessionProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .initSettings:
            return UserDefaults.standard.publisher(for: \UserDefaults.appTrackingAllowed)
                .map(Action.trackerStatusReceived)
                .eraseToEffect()
        case let .trackerStatusReceived(value):
            state.trackerOptIn = value
            return .none
        case let .toggleOrderHealthCardView(value):
            state.showOrderHealthCardView = value
            return .none
        case .close:
            state.appSecurityState.availableSecurityOptions = []
            return .none

        // Alert
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none

        // Demo-Mode
        case .toggleDemoModeSwitch:
            if state.isDemoMode {
                environment.changeableUserSessionContainer.switchToStandardMode()
            } else {
                environment.changeableUserSessionContainer.switchToDemoMode()
            }
            state.alertState = state.isDemoMode ? demoModeOffAlertState : demoModeOnAlertState
            state.isDemoMode.toggle()
            return .none

        // Tracking
        // [REQ:gemSpec_eRp_FdV:A_19089, A_19092, A_19097] OptIn for user tracking
        case let .toggleTrackingTapped(optIn):
            if optIn {
                state.showTrackerComplyView = true
            } else {
                state.trackerOptIn = false
                environment.tracker.optIn = false
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090]
        case .confirmedOptInTracking:
            state.trackerOptIn = true
            environment.tracker.optIn = true
            state.showTrackerComplyView = false
            return .none
        case .dismissTrackerComplyView:
            state.showTrackerComplyView = false
            return .none

        // Legal Infos
        case let .toggleLegalNoticeView(show):
            state.showLegalNoticeView = show
            return .none

        // Data protection & security
        case let .toggleDataProtectionView(show):
            state.showDataProtectionView = show
            return .none
        case let .toggleFOSSView(show):
            state.showFOSSView = show
            return .none
        case let .toggleTermsOfUseView(show):
            state.showTermsOfUseView = show
            return .none
        case .appSecurity,
             .profiles:
            return .none
        case .healthCardResetCounterNoNewSecret(.readCard(.navigateToSettings)),
             .healthCardResetCounterWithNewSecret(.readCard(.navigateToSettings)):
            state.route = nil
            return cleanupSubDomains()

        case .healthCardResetCounterNoNewSecret,
             .healthCardResetCounterWithNewSecret:
            return .none

        case .setNavigation(tag: .healthCardResetCounterNoNewSecret):
            state.route = .healthCardResetCounterNoNewSecret(.init(withNewPin: false))
            return .none
        case .setNavigation(tag: .healthCardResetCounterWithNewSecret):
            state.route = .healthCardResetCounterWithNewSecret(.init(withNewPin: true))
            return .none
        case .setNavigation(tag: nil):
            state.route = nil
            return cleanup()
        case .setNavigation:
            return .none

        // Debug
        case let .toggleDebugView(show):
            state.showDebugView = show
            if !show {
                return DebugDomain.cleanup()
            }
            return .none
        case .popToRootView:
            state.profiles.route = nil
            state.appSecurityState.createPasswordState = nil
            state.showFOSSView = false
            state.showDebugView = false
            state.showTrackerComplyView = false
            state.showLegalNoticeView = false
            state.showDataProtectionView = false
            state.showTermsOfUseView = false
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        appSecurityPullbackReducer,
        profilesPullbackReducer,
        healthCardResetPinCounterNoNewSecretPullbackReducer,
        healthCardResetPinCounterWithNewSecretPullbackReducer,
        domainReducer
    )

    private static let appSecurityPullbackReducer: Reducer =
        AppSecurityDomain.reducer.pullback(
            state: \.appSecurityState,
            action: /SettingsDomain.Action.appSecurity(action:)
        ) {
            AppSecurityDomain.Environment(userDataStore: $0.changeableUserSessionContainer.userSession.localUserStore,
                                          appSecurityManager: $0.appSecurityManager,
                                          schedulers: $0.schedulers)
        }

    private static let profilesPullbackReducer: Reducer =
        ProfilesDomain.reducer.pullback(
            state: \.profiles,
            action: /SettingsDomain.Action.profiles(action:)
        ) {
            .init(
                appSecurityManager: $0.appSecurityManager,
                schedulers: $0.schedulers,
                profileDataStore: $0.changeableUserSessionContainer.userSession.profileDataStore,
                userDataStore: $0.changeableUserSessionContainer.userSession.localUserStore,
                userProfileService: DefaultUserProfileService(
                    profileDataStore: $0.changeableUserSessionContainer.userSession.profileDataStore,
                    profileOnlineChecker: DefaultProfileOnlineChecker(),
                    userSession: $0.changeableUserSessionContainer.userSession
                ),
                profileSecureDataWiper: DefaultProfileSecureDataWiper(userSessionProvider: $0.userSessionProvider),
                router: $0.router,
                secureEnclaveSignatureProvider: $0.signatureProvider,
                userSessionProvider: $0.userSessionProvider,
                nfcSignatureProvider: $0.changeableUserSessionContainer.userSession.nfcSessionProvider,
                userSession: $0.changeableUserSessionContainer.userSession,
                signatureProvider: $0.signatureProvider,
                accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver
            )
        }

    // swiftlint:disable:next identifier_name
    private static let healthCardResetPinCounterNoNewSecretPullbackReducer: Reducer =
        ResetRetryCounterDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.healthCardResetCounterNoNewSecret),
            action: /SettingsDomain.Action.healthCardResetCounterNoNewSecret(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcResetRetryCounterController
            )
        }

    // swiftlint:disable:next identifier_name
    private static let healthCardResetPinCounterWithNewSecretPullbackReducer: Reducer =
        ResetRetryCounterDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.healthCardResetCounterWithNewSecret),
            action: /SettingsDomain.Action.healthCardResetCounterWithNewSecret(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcResetRetryCounterController
            )
        }

    static var demoModeOnAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOn),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
    }()

    static var demoModeOffAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOff),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
    }()
}

extension SettingsDomain {
    enum Dummies {
        static let state = State(
            isDemoMode: false,
            appSecurityState: AppSecurityDomain.State(availableSecurityOptions: []),
            profiles: ProfilesDomain.Dummies.state,
            appVersion: AppVersion(productVersion: "1.0",
                                   buildNumber: "LOCAL BUILD",
                                   buildHash: "LOCAL BUILD")
        )

        static let environment = Environment(
            changeableUserSessionContainer: DummyUserSessionContainer(),
            schedulers: Schedulers(),
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            nfcResetRetryCounterController: DummyResetRetryCounterController(),
            appSecurityManager: DummyAppSecurityManager(),
            router: DummyRouter(),
            userSessionProvider: DummyUserSessionProvider()
        ) { _ in }

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: reducer,
                environment: environment
            )
        }
    }
}