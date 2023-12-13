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
import eRpKit
import Foundation
import IDP

// swiftlint:disable:next type_body_length
struct DebugDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

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
        var profile: Profile?

        var fakeTaskStatus = String(ErxTask.scannedTaskMinIntervalForCompletion)

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
        case invalidateAccessToken
        case accessCodeTextReceived(String)
        case profileReceived(Result<UserProfile, UserProfileServiceError>)
        case setProfileInsuranceTypeToPKV
        case toggleVirtualLogin(Bool)
        case virtualPrkCHAutReceived(String)
        case virtualCCHAutReceived(String)
        case setFaceErxTaskStatus(String)
        case loginWithToken
        case toggleTrackingTapped
        case tokenReceived(IDPToken?)
        case configurationReceived(State.ServerEnvironment?)
        case setServerEnvironment(String?)
        case showAlert(Bool)
        case resetAlertText
        case appear
        case resetTooltips
        case logAction(action: DebugLogDomain.Action)
        #endif
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userDataStore) var localUserStore: UserDataStore
    @Dependency(\.tracker) var tracker: Tracker
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    @Dependency(\.secureEnclaveSignatureProvider) var signatureProvider: SecureEnclaveSignatureProvider
    @Dependency(\.serviceLocatorDebugAccess) var serviceLocatorDebugAccess: ServiceLocatorDebugAccess

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        #if ENABLE_DEBUG_VIEW
        switch action {
        case .hideOnboardingToggleTapped:
            localUserStore.set(hideOnboarding: false)
            localUserStore.set(onboardingVersion: nil)
            return .none
        case let .hideOnboardingReceived(onboardingVersion):
            state.hideOnboarding = onboardingVersion != nil
            return .none
        case .hideCardWallIntroToggleTapped:
            state.hideCardWallIntro.toggle()
            localUserStore.set(hideCardWallIntro: state.hideCardWallIntro)
            return .none
        case let .hideCardWallIntroReceived(hideCardWallIntro):
            state.hideCardWallIntro = hideCardWallIntro
            return .none
        case .resetCanButtonTapped:
            userSession.secureUserStore.set(can: nil)
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
                userSession.secureUserStore.set(token: modifiedToken)
            }
            return .none
        case .deleteKeyAndEGKAuthCertForBiometric:
            userSession.secureUserStore.set(keyIdentifier: nil)
            userSession.secureUserStore.set(certificate: nil)
            return .none
        case .resetOcspAndCertListButtonTapped:
            userSession.trustStoreSession.reset()
            return .none
        case .useDebugDeviceCapabilitiesToggleTapped:
            state.useDebugDeviceCapabilities.toggle()
            let serviceLocatorDebugAccess = serviceLocatorDebugAccess
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
        case let .setFaceErxTaskStatus(seconds):
            ErxTask.scannedTaskMinIntervalForCompletion = Double(seconds) ?? 0
            state.fakeTaskStatus = seconds
            return .none
        case let .accessCodeTextReceived(accessCodeText):
            state.accessCodeText = accessCodeText
            return .none
        case .loginWithToken:
            if let idpToken = state.lastIDPToken {
                userSession.secureUserStore.set(token: idpToken)
            } else {
                let idpToken = IDPToken(
                    accessToken: state.accessCodeText,
                    expires: Date(timeIntervalSinceNow: 3600 * 24),
                    idToken: "",
                    redirect: "todo"
                )
                userSession.secureUserStore.set(token: idpToken)
            }
            return .none
        case .logoutButtonTapped:
            if let token = state.token {
                state.lastIDPToken = token
                state.accessCodeText = token.accessToken
            }
            userSession.secureUserStore.set(token: nil)
            return .none
        case .invalidateAccessToken:
            if let token = state.token {
                state.lastIDPToken = token
                state.accessCodeText = token.accessToken

                let modifiedToken = IDPToken(
                    accessToken: token.accessToken,
                    expires: Date(),
                    idToken: token.idToken,
                    ssoToken: token.ssoToken,
                    redirect: token.redirect
                )
                userSession.secureUserStore.set(token: modifiedToken)
            }
            return .none
        case let .configurationReceived(configuration):
            state.selectedEnvironment = configuration
            return .none
        case let .setServerEnvironment(name):
            userSession.vauStorage.set(userPseudonym: nil)
            userSession.trustStoreSession.reset()
            userSession.secureUserStore.set(discovery: nil)

            localUserStore.set(serverEnvironmentConfiguration: name)
            return .none
        case .toggleTrackingTapped:
            tracker.optIn.toggle()
            state.trackingOptIn = tracker.optIn

            return .none
        case let .showAlert(showAlert):
            state.showAlert = showAlert
            return .none
        case .resetAlertText:
            state.alertText = nil
            return .none
        case .appear:
            state.trackingOptIn = tracker.optIn
            return .merge(
                onReceiveHideOnboarding(),
                onReceiveHideCardWallIntro(),
                onReceiveIsAuthenticated(),
                onReceiveToken(),
                onReceiveConfigurationName(for: state.availableEnvironments),
                onReceiveVirtualEGK(),
                onReceiveCurrentProfile()
            )
        case let .profileReceived(.success(profile)):
            state.profile = profile.profile
            return .none
        case .profileReceived(.failure):
            state.profile = nil
            return .none
        case .setProfileInsuranceTypeToPKV:
            guard let profile = state.profile, profile.insuranceType != .pKV else {
                return .none
            }

            state.profile?.insuranceType = .pKV

            return setProfileInsuranceTypeToPKV(profileId: profile.id)
        case .resetTooltips:
            UserDefaults.standard.setValue([String: Any](), forKey: "TOOLTIPS")
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
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.logState, action: /Action.logAction) {
            DebugLogDomain(loggingStore: DebugLiveLogger.shared)
        }

        Reduce(self.core)
    }
    #else
    var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
    #endif
}

#if ENABLE_DEBUG_VIEW
extension DebugDomain {
    func onReceiveHideOnboarding() -> EffectTask<DebugDomain.Action> {
        .publisher(
            localUserStore.onboardingVersion
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.hideOnboardingReceived)
                .eraseToAnyPublisher
        )
    }

    func onReceiveHideCardWallIntro() -> EffectTask<DebugDomain.Action> {
        .publisher(
            localUserStore.hideCardWallIntro
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.hideCardWallIntroReceived)
                .eraseToAnyPublisher
        )
    }

    func onReceiveIsAuthenticated() -> EffectTask<DebugDomain.Action> {
        .publisher(
            userSession.isAuthenticated
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.isAuthenticatedReceived)
                .catch { _ in
                    Just(DebugDomain.Action.isAuthenticatedReceived(nil))
                }
                .eraseToAnyPublisher
        )
    }

    func onReceiveToken() -> EffectTask<DebugDomain.Action> {
        .publisher(
            userSession.idpSession.autoRefreshedToken
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.tokenReceived)
                .catch { _ in Empty() }
                .eraseToAnyPublisher
        )
    }

    func onReceiveConfigurationName(for availableEnvironments: [DebugDomain.State.ServerEnvironment])
        -> EffectTask<DebugDomain.Action> {
        .publisher(
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
                .eraseToAnyPublisher
        )
    }

    func onReceiveVirtualEGK() -> EffectTask<DebugDomain.Action> {
        .concatenate([
            EffectTask.send(DebugDomain.Action.toggleVirtualLogin(UserDefaults.standard.isVirtualEGKEnabled)),
            EffectTask.send(DebugDomain.Action
                .virtualPrkCHAutReceived(UserDefaults.standard.virtualEGKPrkCHAut ?? "")),
            EffectTask.send(DebugDomain.Action.virtualCCHAutReceived(UserDefaults.standard.virtualEGKCCHAut ?? "")),
        ])
    }

    func onReceiveCurrentProfile() -> EffectTask<DebugDomain.Action> {
        .publisher(
            userProfileService
                .activeUserProfilePublisher()
                .catchToPublisher()
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.profileReceived)
                .eraseToAnyPublisher
        )
    }

    func setProfileInsuranceTypeToPKV(profileId: UUID) -> EffectTask<DebugDomain.Action> {
        let userProfileService = self.userProfileService

        return .run { _ in
            _ = try await userProfileService
                .update(profileId: profileId) { profile in
                    profile.insuranceType = .pKV
                    profile.insurance = "Dummy pKV"
                }
                .async()
        }
    }
}
#endif

extension DebugDomain {
    enum Dummies {
        static let state = State(trackingOptIn: false)

        static let store = Store(
            initialState: state
        ) {
            DebugDomain()
        }
    }
}
