//
//  Copyright (c) 2021 gematik GmbH
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
import IDP

enum SettingsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var isDemoMode: Bool
        var alertState: AlertState<Action>?
        var showLegalNoticeView = false
        var showDataProtectionView = false
        var showFOSSView = false
        var showTermsOfUseView = false
        var showDebugView = false
        var appSecurityState =
            AppSecurityDomain.State()
        var appVersion = AppVersion.current
        var trackerOptIn = false
        var showTrackerComplyView = false
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
        case appSecurity(action: AppSecurityDomain.Action)
        case logout
    }

    struct Environment {
        let changeableUserSessionContainer: UsersSessionContainer
        let schedulers: Schedulers
        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider

        func logout() -> Effect<Never, Never> {
            // [REQ:gemSpec_IDP_Frontend:A_20499] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
            // [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
            changeableUserSessionContainer.userSession.secureUserStore.set(token: nil)
            changeableUserSessionContainer.userSession.secureUserStore.set(can: nil)
            changeableUserSessionContainer.userSession.secureUserStore.set(discovery: nil)
            changeableUserSessionContainer.userSession.vauStorage.set(userPseudonym: nil)
            changeableUserSessionContainer.userSession.idpSession.invalidateAccessToken()

            // [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
            changeableUserSessionContainer.userSession.secureUserStore.set(certificate: nil)

            return changeableUserSessionContainer.userSession.secureUserStore.keyIdentifier
                .flatMap { identifier -> Effect<Never, Never> in
                    if let someIdentifier = identifier,
                       let identifier = Base64.urlSafe.encode(data: someIdentifier).utf8string {
                        // [REQ:gemSpec_IDP_Frontend:A_21603] key identifier
                        changeableUserSessionContainer.userSession.secureUserStore.set(keyIdentifier: nil)
                        // If deletion fails we cannot do anything
                        // [REQ:gemSpec_IDP_Frontend:A_21603] PrK_SE_AUT/PuK_SE_AUT
                        _ = try? PrivateKeyContainer.deleteExistingKey(for: identifier)
                    }
                    return Effect<Never, Never>.none
                }
                .eraseToEffect()
        }
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        // Init & Close
        case .initSettings:
            return
                UserDefaults.standard.publisher(for: \UserDefaults.kAppTrackingAllowed)
                    .map(Action.trackerStatusReceived)
                    .eraseToEffect()
        case let .trackerStatusReceived(value):
            state.trackerOptIn = value
            return .none
        case .close:
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
                UserDefaults.standard.setValue(state.trackerOptIn, forKey: UserDefaults.kAppTrackingAllowed)
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090]
        case .confirmedOptInTracking:
            state.trackerOptIn = true
            UserDefaults.standard.setValue(state.trackerOptIn, forKey: UserDefaults.kAppTrackingAllowed)
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
        case .appSecurity:
            return .none

        // Debug
        case let .toggleDebugView(show):
            state.showDebugView = show
            if !show {
                return DebugDomain.cleanup()
            }
            return .none

        // Logout
        case .logout:
            return environment.logout().eraseToEffect().fireAndForget()
        }
    }

    static let reducer: Reducer = .combine(
        appSecurityPullbackReducer,
        domainReducer
    )

    private static let appSecurityPullbackReducer: Reducer =
        AppSecurityDomain.reducer.pullback(
            state: \.appSecurityState,
            action: /SettingsDomain.Action.appSecurity(action:)
        ) {
            AppSecurityDomain.Environment(userDataStore: $0.changeableUserSessionContainer.userSession.localUserStore,
                                          appSecurityPasswordManager: $0.changeableUserSessionContainer.userSession
                                              .appSecurityPasswordManager,
                                          schedulers: $0.schedulers)
        }

    static var demoModeOnAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOn),
            dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
        )
    }()

    static var demoModeOffAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOff),
            dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
        )
    }()
}

extension SettingsDomain {
    enum Dummies {
        static let state = State(
            isDemoMode: false,
            appVersion: AppVersion(productVersion: "1.0",
                                   buildNumber: "LOCAL BUILD",
                                   buildHash: "LOCAL BUILD")
        )

        static let environment = Environment(
            changeableUserSessionContainer: DummyUserSessionContainer(),
            schedulers: AppContainer.shared.schedulers,
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        )

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
