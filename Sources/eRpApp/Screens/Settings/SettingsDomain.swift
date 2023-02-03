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
import DataKit
import eRpKit
import Foundation
import IDP

// swiftlint:disable:next type_body_length
enum SettingsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    enum Route: Equatable {
        case debug(DebugDomain.State)
        case alert(AlertState<Action>)
        case healthCardPasswordForgotPin(HealthCardPasswordDomain.State)
        case healthCardPasswordSetCustomPin(HealthCardPasswordDomain.State)
        case healthCardPasswordUnlockCard(HealthCardPasswordDomain.State)
        case setAppPassword(CreatePasswordDomain.State)
        case complyTracking
        case legalNotice
        case dataProtection
        case openSourceLicence
        case termsOfUse
        case egk(OrderHealthCardDomain.State)
    }

    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            cleanupSubDomains(),
            .cancel(token: Token.self),
            ProfilesDomain.cleanup()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            HealthCardPasswordDomain.cleanup(),
            DebugDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case trackingStatus
        case demoModeStatus
    }

    struct State: Equatable {
        var isDemoMode: Bool
        var appSecurityState: AppSecurityDomain.State
        var profiles = ProfilesDomain.State(profiles: [], selectedProfileId: nil, route: nil)
        var appVersion = AppVersion.current
        var trackerOptIn = false

        var route: Route?
    }

    enum Action: Equatable {
        case close
        case initSettings
        case trackerStatusReceived(Bool)
        case demoModeStatusReceived(Bool)
        case toggleTrackingTapped(Bool)
        case confirmedOptInTracking
        case toggleDemoModeSwitch
        case appSecurity(action: AppSecurityDomain.Action)
        case profiles(action: ProfilesDomain.Action)
        case debug(action: DebugDomain.Action)
        case healthCardPasswordUnlockCard(action: HealthCardPasswordDomain.Action)
        case healthCardPasswordForgotPin(action: HealthCardPasswordDomain.Action)
        case healthCardPasswordSetCustomPin(action: HealthCardPasswordDomain.Action)
        case createPassword(action: CreatePasswordDomain.Action)
        case popToRootView
        case egkAction(action: OrderHealthCardDomain.Action)
        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        let changeableUserSessionContainer: UsersSessionContainer
        let schedulers: Schedulers
        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider
        let nfcHealthCardPasswordController: NFCHealthCardPasswordController
        let appSecurityManager: AppSecurityManager
        let router: Routing
        let userSessionProvider: UserSessionProvider
        let serviceLocator: ServiceLocator
        let userDataStore: UserDataStore
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .initSettings:
            return .merge(
                environment.tracker.optInPublisher
                    .map(Action.trackerStatusReceived)
                    .eraseToEffect()
                    .cancellable(id: Token.trackingStatus, cancelInFlight: true),
                environment.changeableUserSessionContainer.isDemoMode
                    .map(Action.demoModeStatusReceived)
                    .eraseToEffect()
                    .cancellable(id: Token.demoModeStatus, cancelInFlight: true)
            )
        case let .demoModeStatusReceived(isDemo):
            state.isDemoMode = isDemo
            return .none
        case let .trackerStatusReceived(value):
            state.trackerOptIn = value
            return .none
        case .close:
            state.appSecurityState.availableSecurityOptions = []
            return .none

        // Demo-Mode
        case .toggleDemoModeSwitch:
            state.route = .alert(state.isDemoMode ? demoModeOffAlertState : demoModeOnAlertState)
            if state.isDemoMode {
                environment.changeableUserSessionContainer.switchToStandardMode()
            } else {
                environment.changeableUserSessionContainer.switchToDemoMode()
            }
            return .none

        // Tracking
        // [REQ:gemSpec_eRp_FdV:A_19088, A_19089, A_19092, A_19097] OptIn for user tracking
        case let .toggleTrackingTapped(optIn):
            if optIn {
                state.route = .complyTracking
            } else {
                // [REQ:gemSpec_eRp_FdV:A_20185] OptOut for user
                state.trackerOptIn = false
                environment.tracker.optIn = false
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090]
        case .confirmedOptInTracking:
            state.trackerOptIn = true
            environment.tracker.optIn = true
            state.route = nil
            return .none
        case .healthCardPasswordUnlockCard(.readCard(.navigateToSettings)),
             .healthCardPasswordForgotPin(.readCard(.navigateToSettings)),
             .healthCardPasswordSetCustomPin(.readCard(.navigateToSettings)):
            state.route = nil
            return HealthCardPasswordReadCardDomain.cleanup()
        case .setNavigation(tag: .healthCardPasswordForgotPin):
            state.route = .healthCardPasswordForgotPin(.init(mode: .forgotPin))
            return .none
        case .setNavigation(tag: .healthCardPasswordSetCustomPin):
            state.route = .healthCardPasswordSetCustomPin(.init(mode: .setCustomPin))
            return .none
        case .setNavigation(tag: .healthCardPasswordUnlockCard):
            state.route = .healthCardPasswordUnlockCard(.init(mode: .unlockCard))
            return .none
        case let .setNavigation(tag: tag):
            switch tag {
            case .debug:
                state.route = .debug(DebugDomain.State(trackingOptIn: environment.tracker.optIn))
            case .egk:
                state.route = .egk(.init())
            case .legalNotice:
                state.route = .legalNotice
            case .dataProtection:
                state.route = .dataProtection
            case .openSourceLicence:
                state.route = .openSourceLicence
            case .termsOfUse:
                state.route = .termsOfUse
            case .none:
                state.route = nil
                return cleanupSubDomains()
            default: break
            }
            return .none
        case .egkAction(action: .close):
            state.route = nil
            return cleanup()
        case .egkAction:
            return .none

        // create password navigation
        case .appSecurity(action: .select(.password)):
            if state.appSecurityState.selectedSecurityOption == .password {
                state.route = .setAppPassword(CreatePasswordDomain.State(mode: .update))
            } else {
                state.route = .setAppPassword(CreatePasswordDomain.State(mode: .create))
            }
            return .none
        case .createPassword(.closeAfterPasswordSaved):
            state.route = nil
            return .none
        case .popToRootView:
            state.route = nil
            state.profiles.route = nil
            return .none
        case .healthCardPasswordUnlockCard,
             .healthCardPasswordForgotPin,
             .healthCardPasswordSetCustomPin,
             .createPassword,
             .debug,
             .appSecurity,
             .profiles:
            return .none
        }
    }

    #if ENABLE_DEBUG_VIEW
    static let reducer: Reducer = .combine(
        createPasswordPullbackReducer,
        appSecurityPullbackReducer,
        profilesPullbackReducer,
        healthCardPasswordForgotPinPullbackReducer,
        healthCardPasswordSetCustomPinPullbackReducer,
        healthCardPasswordUnlockCardPullbackReducer,
        debugPullbackReducer,
        domainReducer
    )

    private static let debugPullbackReducer: Reducer =
        DebugDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.debug),
            action: /SettingsDomain.Action.debug(action:)
        ) { environment in
            DebugDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.changeableUserSessionContainer.userSession,
                localUserStore: environment.changeableUserSessionContainer.userSession.localUserStore,
                tracker: environment.tracker,
                signatureProvider: environment.signatureProvider,
                serviceLocatorDebugAccess: ServiceLocatorDebugAccess(serviceLocator: environment.serviceLocator)
            )
        }
    #else
    static let reducer: Reducer = .combine(
        createPasswordPullbackReducer,
        appSecurityPullbackReducer,
        profilesPullbackReducer,
        healthCardPasswordForgotPinPullbackReducer,
        healthCardPasswordSetCustomPinPullbackReducer,
        healthCardPasswordUnlockCardPullbackReducer,
        orderHealthCardPullbackReducer,
        domainReducer
    )
    #endif

    static let createPasswordPullbackReducer: Reducer =
        CreatePasswordDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.setAppPassword),
            action: /SettingsDomain.Action.createPassword(action:)
        ) { global in
            CreatePasswordDomain.Environment(passwordManager: global.appSecurityManager,
                                             schedulers: global.schedulers,
                                             passwordStrengthTester: DefaultPasswordStrengthTester(),
                                             userDataStore: global.userDataStore)
        }

    private static let appSecurityPullbackReducer: Reducer =
        AppSecurityDomain.reducer.pullback(
            state: \.appSecurityState,
            action: /SettingsDomain.Action.appSecurity(action:)
        ) {
            .init(
                userDataStore: $0.changeableUserSessionContainer.userSession.localUserStore,
                appSecurityManager: $0.appSecurityManager,
                schedulers: $0.schedulers
            )
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
                    userSession: $0.changeableUserSessionContainer.userSession,
                    userSessionProvider: $0.userSessionProvider
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
    private static let healthCardPasswordForgotPinPullbackReducer: Reducer =
        HealthCardPasswordDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.healthCardPasswordForgotPin),
            action: /SettingsDomain.Action.healthCardPasswordForgotPin(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcHealthCardPasswordController
            )
        }

    // swiftlint:disable:next identifier_name
    private static let healthCardPasswordSetCustomPinPullbackReducer: Reducer =
        HealthCardPasswordDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.healthCardPasswordSetCustomPin),
            action: /SettingsDomain.Action.healthCardPasswordSetCustomPin(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcHealthCardPasswordController
            )
        }

    // swiftlint:disable:next identifier_name
    private static let healthCardPasswordUnlockCardPullbackReducer: Reducer =
        HealthCardPasswordDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.healthCardPasswordUnlockCard),
            action: /SettingsDomain.Action.healthCardPasswordUnlockCard(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcHealthCardPasswordController
            )
        }

    static let orderHealthCardPullbackReducer: Reducer =
        OrderHealthCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.egk),
            action: /Action.egkAction(action:)
        ) { _ in OrderHealthCardDomain.Environment() }

    static var demoModeOnAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOn),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }()

    static var demoModeOffAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoModeOff),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOff),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
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
            nfcHealthCardPasswordController: DummyNFCHealthCardPasswordController(),
            appSecurityManager: DummyAppSecurityManager(),
            router: DummyRouter(),
            userSessionProvider: DummyUserSessionProvider(),
            serviceLocator: ServiceLocator(),
            userDataStore: DummySessionContainer().localUserStore
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
