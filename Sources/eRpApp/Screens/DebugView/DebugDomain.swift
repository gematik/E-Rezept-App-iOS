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
import eRpKit
import Foundation
import IDP

// swiftlint:disable:next superfluous_disable_command
// swiftlint:disable type_body_length
enum DebugDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case updates
    }

    struct State: Equatable {
        var trackingOptIn: Bool

        #if ENABLE_DEBUG_VIEW
        var hideOnboarding = true

        var hideCardWallIntro = true
        var useDebugDeviceCapabilities = false
        var isNFCReady = true
        var isMinimumOS14 = true

        var debugCapabilities = DebugDeviceCapabilities(isNFCReady: true, isMinimumOS14: true)

        var isAuthenticated: Bool?
        var token: IDPToken?
        var accessCodeText: String = "" +
            ""
        var lastIDPToken: IDPToken?

        var useVirtualLogin: Bool = UserDefaults.standard.isVirtualEGKEnabled
        var virtualLoginPrivateKey: String = UserDefaults.standard.virtualEGKPrkCHAut ?? ""
        var virtualLoginCertKey: String = UserDefaults.standard.virtualEGKCCHAut ?? ""

        var vauUrlText: String = "http://some-service.com:8003/"
        var idpUrlText: String = "http://some-service.com:8003/"

        #if TEST_ENVIRONMENT || DEFAULT_ENVIRONMENT_RU_DEV
        var availableEnvironments: [ServerEnvironment] = configurations
            .map { ServerEnvironment(name: $0.key, configuration: $0.value) }
            .sorted { $0.name < $1.name }
        #else
        var availableEnvironments: [ServerEnvironment] = [ServerEnvironment(
            name: defaultConfiguration.name,
            configuration: defaultConfiguration
        )]
        #endif

        var selectedEnvironment: ServerEnvironment?

        var showAlert = false
        var alertText: String?
        var logState = DebugLogDomain.State(logs: [])
        #endif

        struct ServerEnvironment: Identifiable, Equatable {
            let name: String
            let configuration: AppConfiguration

            var id: UUID {
                configuration.uuid
            }
        }
    }

    enum Action: Equatable {
        #if ENABLE_DEBUG_VIEW
        case hideOnboardingToggleTapped
        case hideOnboardingReceived(String?)
        case hideCardWallIntroToggleTapped
        case hideCardWallIntroReceived(Bool)
        case resetCanButtonTapped
        case deleteKeyAndEGKAuthCertForBiometric
        case deleteSSOToken
        case resetOcspAndCertListButtonTapped
        case useDebugDeviceCapabilitiesToggleTapped
        case nfcReadyToggleTapped
        case isMinimumOS14ToggleTapped
        case isAuthenticatedReceived(Bool?)
        case logoutButtonTapped
        case accessCodeTextReceived(String)
        case toggleVirtualLogin(Bool)
        case virtualPrkCHAutReceived(String)
        case virtualCCHAutReceived(String)
        case loginWithToken
        case toggleTrackingTapped
        case tokenReceived(IDPToken?)
        case configurationReceived(State.ServerEnvironment?)
        case setServerEnvironment(String?)
        case showAlert(Bool)
        case resetAlertText
        case appear
        case resetHintEvents
        case logAction(action: DebugLogDomain.Action)
        #endif
    }

    struct Environment {
        var schedulers: Schedulers
        var userSession: UserSession
        let localUserStore: UserDataStore
        let tracker: Tracker
        var serverEnvironmentConfiguration: AppConfiguration?

        let signatureProvider: SecureEnclaveSignatureProvider
        let serviceLocatorDebugAccess: ServiceLocatorDebugAccess
    }

    static let domainReducer = Reducer { state, action, environment in
        #if ENABLE_DEBUG_VIEW
        switch action {
        case .hideOnboardingToggleTapped:
            environment.localUserStore.set(hideOnboarding: false)
            environment.localUserStore.set(onboardingVersion: nil)
            return .none
        case let .hideOnboardingReceived(onboardingVersion):
            state.hideOnboarding = onboardingVersion != nil
            return .none
        case .hideCardWallIntroToggleTapped:
            state.hideCardWallIntro.toggle()
            environment.localUserStore.set(hideCardWallIntro: state.hideCardWallIntro)
            return .none
        case let .hideCardWallIntroReceived(hideCardWallIntro):
            state.hideCardWallIntro = hideCardWallIntro
            return .none
        case .resetCanButtonTapped:
            environment.userSession.secureUserStore.set(can: nil)
            return .none
        case .deleteSSOToken:
            if let token = state.token {
                let modifiedToken = IDPToken(
                    accessToken: token.accessToken,
                    expires: Date(),
                    idToken: token.idToken,
                    ssoToken: nil,
                    redirect: token.redirect
                )
                environment.userSession.secureUserStore.set(token: modifiedToken)
            }
            return .none
        case .deleteKeyAndEGKAuthCertForBiometric:
            environment.userSession.secureUserStore.set(keyIdentifier: nil)
            environment.userSession.secureUserStore.set(certificate: nil)
            return .none
        case .resetOcspAndCertListButtonTapped:
            environment.userSession.trustStoreSession.reset()
            return .none
        case .useDebugDeviceCapabilitiesToggleTapped:
            state.useDebugDeviceCapabilities.toggle()
            let serviceLocatorDebugAccess = environment.serviceLocatorDebugAccess
            if state.useDebugDeviceCapabilities {
                serviceLocatorDebugAccess.setDeviceCapabilities(state.debugCapabilities)
            } else {
                serviceLocatorDebugAccess.setDeviceCapabilities(RealDeviceCapabilities())
            }
            return .none
        case .nfcReadyToggleTapped:
            state.isNFCReady.toggle()
            state.debugCapabilities.isNFCReady = state.isNFCReady
            return .none
        case .isMinimumOS14ToggleTapped:
            state.isMinimumOS14.toggle()
            state.debugCapabilities.isMinimumOS14 = state.isMinimumOS14
            return .none
        case let .isAuthenticatedReceived(isAuthenticated):
            state.isAuthenticated = isAuthenticated
            return .none
        case let .toggleVirtualLogin(useVirtualLogin):
            state.useVirtualLogin = useVirtualLogin
            UserDefaults.standard.isVirtualEGKEnabled = useVirtualLogin
            return .none
        case let .virtualCCHAutReceived(cchaut):
            state.virtualLoginCertKey = cchaut
            UserDefaults.standard.virtualEGKCCHAut = cchaut
            return .none
        case let .virtualPrkCHAutReceived(prkchaut):
            state.virtualLoginPrivateKey = prkchaut
            UserDefaults.standard.virtualEGKPrkCHAut = prkchaut
            return .none
        case let .accessCodeTextReceived(accessCodeText):
            state.accessCodeText = accessCodeText
            return .none
        case .loginWithToken:
            if let idpToken = state.lastIDPToken {
                environment.userSession.secureUserStore.set(token: idpToken)
            } else {
                let idpToken = IDPToken(
                    accessToken: state.accessCodeText,
                    expires: Date(timeIntervalSinceNow: 3600 * 24),
                    idToken: "",
                    redirect: "todo"
                )
                environment.userSession.secureUserStore.set(token: idpToken)
            }
            return .none
        case .logoutButtonTapped:
            if let token = state.token {
                state.lastIDPToken = token
                state.accessCodeText = token.accessToken
            }
            environment.userSession.secureUserStore.set(token: nil)
            return .none
        case let .configurationReceived(configuration):
            state.selectedEnvironment = configuration
            return .none
        case let .setServerEnvironment(name):
            environment.userSession.vauStorage.set(userPseudonym: nil)
            environment.userSession.trustStoreSession.reset()
            environment.userSession.secureUserStore.set(discovery: nil)

            environment.localUserStore.set(serverEnvironmentConfiguration: name)
            return .none
        case .toggleTrackingTapped:
            environment.tracker.optIn.toggle()
            state.trackingOptIn = environment.tracker.optIn

            return .none
        case let .showAlert(showAlert):
            state.showAlert = showAlert
            return .none
        case .resetAlertText:
            state.alertText = nil
            return .none
        case .appear:
            state.trackingOptIn = environment.tracker.optIn
            return Effect.merge(
                environment.onReceiveHideOnboarding(),
                environment.onReceiveHideCardWallIntro(),
                environment.onReceiveIsAuthenticated(),
                environment.onReceiveToken(),
                environment.onReceiveConfigurationName(for: state.availableEnvironments),
                environment.onReceiveVirtualEGK()
            )
            .cancellable(id: Token.updates)
        case .resetHintEvents:
            environment.userSession.hintEventsStore.hintState = HintState()
            return .none

        case let .tokenReceived(token):
            state.token = token
            return .none
        case .logAction:
            return .none
        }
        #endif
    }

    #if ENABLE_DEBUG_VIEW
    static let reducer: Reducer = .combine(
        DebugLogDomain.reducer.pullback(state: \.logState, action: /Action.logAction) { _ in
            DebugLogDomain.Environment()
        },
        domainReducer
    )
    #else
    static let reducer = Reducer.empty
    #endif
}

#if ENABLE_DEBUG_VIEW
extension DebugDomain.Environment {
    func onReceiveHideOnboarding() -> Effect<DebugDomain.Action, Never> {
        localUserStore.onboardingVersion
            .receive(on: schedulers.main)
            .map(DebugDomain.Action.hideOnboardingReceived)
            .eraseToEffect()
    }

    func onReceiveHideCardWallIntro() -> Effect<DebugDomain.Action, Never> {
        localUserStore.hideCardWallIntro
            .receive(on: schedulers.main)
            .map(DebugDomain.Action.hideCardWallIntroReceived)
            .eraseToEffect()
    }

    func onReceiveIsAuthenticated() -> Effect<DebugDomain.Action, Never> {
        userSession.isAuthenticated
            .receive(on: schedulers.main)
            .map(DebugDomain.Action.isAuthenticatedReceived)
            .catch { _ in
                Just(DebugDomain.Action.isAuthenticatedReceived(nil))
            }
            .eraseToEffect()
    }

    func onReceiveToken() -> Effect<DebugDomain.Action, Never> {
        userSession.idpSession.autoRefreshedToken
            .receive(on: schedulers.main)
            .map(DebugDomain.Action.tokenReceived)
            .catch { _ in Effect.none }
            .eraseToEffect()
    }

    func onReceiveConfigurationName(for availableEnvironments: [DebugDomain.State.ServerEnvironment])
        -> Effect<DebugDomain.Action, Never> {
        localUserStore.serverEnvironmentConfiguration
            .map { name in
                let configuration = availableEnvironments.first { environment in
                    environment.name == name
                }
                guard let unwrappedConfiguration = configuration else {
                    return DebugDomain.State.ServerEnvironment(name: "Default", configuration: defaultConfiguration)
                }
                return unwrappedConfiguration
            }
            .receive(on: schedulers.main)
            .map(DebugDomain.Action.configurationReceived)
            .eraseToEffect()
    }

    func onReceiveVirtualEGK() -> Effect<DebugDomain.Action, Never> {
        .concatenate([
            Effect(value: DebugDomain.Action.toggleVirtualLogin(UserDefaults.standard.isVirtualEGKEnabled)),
            Effect(value: DebugDomain.Action.virtualPrkCHAutReceived(UserDefaults.standard.virtualEGKPrkCHAut ?? "")),
            Effect(value: DebugDomain.Action.virtualCCHAutReceived(UserDefaults.standard.virtualEGKCCHAut ?? "")),
        ])
    }
}
#endif

extension DebugDomain {
    enum Dummies {
        static let state = State(trackingOptIn: false)

        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            localUserStore: DemoUserDefaultsStore(),
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            serviceLocatorDebugAccess: ServiceLocatorDebugAccess(serviceLocator: ServiceLocator())
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
