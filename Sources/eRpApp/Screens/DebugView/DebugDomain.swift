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
import Combine
import ComposableArchitecture
import CryptoKit
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import ErxTaskRepository
import FeatureCardWall
import FeatureHelpers
import FHIRVZD
import Foundation
import IDP
import PushNotificationCrypto
import Settings

// swiftlint:disable type_body_length file_length
@Reducer
struct DebugDomain {
    @ObservableState
    struct State: Equatable {
        var trackingOptIn: Bool

        #if ENABLE_DEBUG_VIEW
        @Shared(.showDebugPharmacies) var showDebugPharmacies
        @Shared(.fhirVZDToken) var fhirVZDToken
        @Shared(.overwriteDIGAIK) var overwriteDIGAIK
        @Shared(.appDefaults) var appDefaults
        @Shared(.euRedeemPrescriptionsFeature) var euRedeemPrescriptionsFeature: Bool
        @Shared(.communicationsV3Feature) var communicationsV3Feature: Bool
        @Shared(.useWorkflow16ForSending) var useWorkflow16: Bool
        @Shared(.enablePushNotifications) var enablePushNotifications: Bool

        @Shared(.isVirtualEGKEnabled) var isVirtualEGKEnabled
        @Shared(.virtualEGKCCHAut) var virtualEGKCCHAut
        @Shared(.virtualEGKPrkCHAut) var virtualEGKPrkCHAut

        @Shared(.selectedProfileId) var profileId

        var localTasks: [ErxTask] = []
        var hideOnboarding = true

        var hideCardWallIntro = true
        var useDebugDeviceCapabilities = false
        var isNFCReady = true
        var isMinimumOS14 = true

        var debugCapabilities = DebugDeviceCapabilities(isNFCReady: true, isMinimumOS14: true)

        var isAuthenticated: Bool?
        var token: IDPToken?
        var accessCodeText: String = ""
        var lastIDPToken: IDPToken?
        var profile: Profile?
        var hidePkvConsentDrawerOnMainView: Bool {
            profile?.hidePkvConsentDrawerOnMainView ?? false
        }

        var fakeTaskStatus = String(ErxTask.minTimeIntervalForCompletion)

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
        var logState = DebugLogsDomain.State(logs: [])
        var encryptedCiphertext: String = ""
        var timeMessageEncrypted: String = ""
        var deviceToken: String = ""
        var tokenError: String = ""
        #endif

        struct ServerEnvironment: Identifiable, Equatable {
            let name: String
            let configuration: AppConfiguration

            var id: UUID {
                configuration.uuid
            }
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        #if ENABLE_DEBUG_VIEW
        case hideOnboardingReceived(String?)
        case hideCardWallIntroReceived(Bool)
        case resetPnKeyGenerationsButtonTapped
        case resetCanButtonTapped
        case deleteKeyAndEGKAuthCertForBiometric
        case loadAllLocalTasksReceived(Result<[ErxTask], ErxRepositoryError>)
        case deleteAllTasks
        case deleteAllTasksReceived(String?)
        case markCommunicationsAsRead
        case deleteSSOToken
        case falsifySSOToken
        case resetTrustStoreButtonTapped
        case isAuthenticatedReceived(Bool?)
        case logoutButtonTapped
        case invalidateAccessToken
        case profileReceived(Result<UserProfile, UserProfileServiceError>)
        case setProfileInsuranceTypeToPKV
        case hidePkvConsentDrawerMainViewToggleTapped
        case loginWithToken
        case tokenReceived(IDPToken?)
        case configurationReceived(State.ServerEnvironment?)
        case setServerEnvironment(String?)
        case showAlert(Bool)
        case resetAlertText
        case resetAppDefaults
        case appear
        case resetTooltips
        case logAction(action: DebugLogsDomain.Action)
        case initializePushNotificationKeyChain(iss: String, timeISSCreated: String, keyIdentifier: String)
        case encryptPushNotificationPayload(plaintext: String, keyIdentifier: String)
        case requestPushPermissionAndRegister
        case pushNotificationRegisterReceived(deviceToken: String?, error: String?)
        #endif
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userDataStore) var localUserStore: UserDataStore
    @Dependency(\.tracker) var tracker: Tracker
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.serviceLocatorDebugAccess) var serviceLocatorDebugAccess: ServiceLocatorDebugAccess
    @Dependency(\.pushNotificationCrypto) var pushNotificationCrypto: PushNotificationCrypto
    @Dependency(\.pushNotificationCryptoStorage) var pushNotificationCryptoStorage: PushNotificationCryptoStorage
    @Dependency(\.apnsRegistrationService) var apnsRegistrationService: APNSRegistrationService

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        #if ENABLE_DEBUG_VIEW
        switch action {
        case .binding(\.hideOnboarding):
            localUserStore.set(hideOnboarding: false)
            localUserStore.set(onboardingVersion: nil)
            return .none
        case let .hideOnboardingReceived(onboardingVersion):
            state.hideOnboarding = onboardingVersion != nil
            return .none
        case .binding(\.hideCardWallIntro):
            localUserStore.set(hideCardWallIntro: state.hideCardWallIntro)
            return .none
        case let .hideCardWallIntroReceived(hideCardWallIntro):
            state.hideCardWallIntro = hideCardWallIntro
            return .none
        case .resetPnKeyGenerationsButtonTapped:
            return .run { _ in
                // Use the same keyIdentifier that's used in DebugPushNotificationView
                let keyIdentifier = "123e4567-e89b-12d3-a456-426614174000"
                do {
                    let allGenerations = try pushNotificationCryptoStorage.loadAllKeyGenerations(keyIdentifier)
                    let yearMonths = allGenerations.map(\.yearMonth)
                    if !yearMonths.isEmpty {
                        try pushNotificationCryptoStorage.deleteKeyGenerations(keyIdentifier, yearMonths)
                    }
                } catch {
                    // Silently handle errors in debug tool
                    print("Failed to reset push notification key generations: \(error)")
                }
                print("Ran resetPnKeyGenerationsButtonTapped ")
            }
        case .resetCanButtonTapped:
            userSession.secureUserStore.set(can: nil)
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
            } else {
                state.alertText = "No idp token available!"
                state.showAlert = true
            }
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
            } else {
                state.alertText = "No idp token available!"
                state.showAlert = true
            }
            return .none
        case .falsifySSOToken:
            if let token = state.token,
               let ssoToken = token.ssoToken,
               let falseSSOToken = falsify(ssoToken: ssoToken) {
                let modifiedToken = IDPToken(
                    accessToken: token.accessToken,
                    expires: Date(), // set expire to use sso token
                    idToken: token.idToken,
                    ssoToken: falseSSOToken,
                    redirect: token.redirect
                )
                userSession.secureUserStore.set(token: modifiedToken)
            } else {
                state.alertText = "No idp token available!"
                state.showAlert = true
            }
            return .none
        case .deleteKeyAndEGKAuthCertForBiometric:
            userSession.secureUserStore.set(keyIdentifier: nil)
            userSession.secureUserStore.set(certificate: nil)
            return .none
        case .resetTrustStoreButtonTapped:
            userSession.trustStoreSession.reset()
            return .none
        case .binding(\.useDebugDeviceCapabilities):
            let serviceLocatorDebugAccess = serviceLocatorDebugAccess
            if state.useDebugDeviceCapabilities {
                serviceLocatorDebugAccess.setDeviceCapabilities(state.debugCapabilities)
            } else {
                serviceLocatorDebugAccess.setDeviceCapabilities(RealDeviceCapabilities())
            }
            return .none
        case .binding(\.isNFCReady):
            state.debugCapabilities.isNFCReady = state.isNFCReady
            return .none
        case .binding(\.isMinimumOS14):
            state.debugCapabilities.isMinimumOS14 = state.isMinimumOS14
            return .none
        case let .isAuthenticatedReceived(isAuthenticated):
            state.isAuthenticated = isAuthenticated
            return .none
        case .binding(\.fakeTaskStatus):
            ErxTask.minTimeIntervalForCompletion = Double(state.fakeTaskStatus) ?? 0
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
        case let .loadAllLocalTasksReceived(result):
            switch result {
            case let .success(tasks):
                state.localTasks = tasks
            case let .failure(error):
                state.alertText = error.localizedDescription
                state.showAlert = true
            }
            return .none
        case .deleteAllTasks:
            guard !state.localTasks.isEmpty else {
                return .none
            }
            return .run { [tasks = state.localTasks, profileId = state.profileId] send in
                var responses: [Response<ErxTask>] = []
                for task in tasks {
                    do {
                        _ = try await erxTaskRepository.deleteTask([task], profileId)
                        responses.append(.init(value: task, result: .success))
                    } catch {
                        responses.append(.init(value: task, result: .failure(error)))
                    }
                }

                let errorResponses = responses.compactMap { response in
                    if case let .failure(error) = response.result {
                        return "task (\(response.value.id)) failed: \(error.localizedDescription)"
                    } else {
                        return nil
                    }
                }

                if !errorResponses.isEmpty {
                    await send(.deleteAllTasksReceived(errorResponses.joined(separator: "\n")))
                } else {
                    await send(.deleteAllTasksReceived(nil))
                }
            }
        case .markCommunicationsAsRead:
            guard !state.localTasks.isEmpty else {
                return .none
            }

            let communications = state.localTasks
                .map(\.communications)
                .flatMap { $0 }
                .map { communication -> ErxTask.Communication in
                    var readCommunication = communication
                    readCommunication.isRead = true
                    return readCommunication
                }

            return .run { [profileId = state.profileId, profile = state.profile] _ in
                _ = try await erxTaskRepository.saveLocalCommunications(communications, profileId)
                if profile?.insuranceType == .pKV {
                    for taskId in Set(communications.map(\.taskId)) {
                        if var chargeItem = try await erxTaskRepository.loadLocalChargeItem(profileId, taskId)?
                            .chargeItem {
                            chargeItem.isRead = true
                            _ = try await erxTaskRepository.saveChargeItems([chargeItem.sparseChargeItem], profileId)
                        }
                    }
                }
            }
        case let .deleteAllTasksReceived(localizedError):
            if let localizedError {
                state.alertText = localizedError
            } else {
                state.alertText = "Did delete all tasks!"
            }
            state.showAlert = true
            return .none
        case let .configurationReceived(configuration):
            state.selectedEnvironment = configuration
            return .none
        case let .setServerEnvironment(name):
            userSession.vauStorage.set(userPseudonym: nil)
            userSession.trustStoreSession.reset()
            userSession.secureUserStore.set(discovery: nil)

            @Shared(.fhirVZDToken) var token
            $token.withLock { $0 = nil }

            localUserStore.set(serverEnvironmentConfiguration: name)
            return .none
        case .binding(\.trackingOptIn):
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
                loadAllLocalTasks(),
                onReceiveHideOnboarding(),
                onReceiveHideCardWallIntro(),
                onReceiveToken(),
                onReceiveConfigurationName(for: state.availableEnvironments),
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
        case .hidePkvConsentDrawerMainViewToggleTapped:
            guard let profile = state.profile, profile.insuranceType.canReceiveChargeItems else {
                return .none
            }
            let newValue = !profile.hidePkvConsentDrawerOnMainView
            state.profile?.hidePkvConsentDrawerOnMainView = newValue
            return setHidePkvConsentDrawerOnMainView(to: newValue, profileId: profile.id)
        case .resetTooltips:
            UserDefaults.standard.setValue([String: Any](), forKey: "TOOLTIPS")
            return .none
        case .resetAppDefaults:
            state.$appDefaults.withLock { $0 = AppDefaults() }
            return .none
        case let .tokenReceived(token):
            state.token = token
            return .none
        case .logAction:
            return .none
        case let .initializePushNotificationKeyChain(iss, timeISSCreated, keyIdentifier):
            return .run { _ in
                let issData = try Data(hex: iss)
                try pushNotificationCrypto.initializeKeyChain(issData, timeISSCreated, keyIdentifier)
            }
        case let .encryptPushNotificationPayload(plaintext, keyIdentifier):
            do {
                let allGenerations = try pushNotificationCryptoStorage.loadAllKeyGenerations(keyIdentifier)
                guard let latestGeneration = allGenerations.last else {
                    throw PushNotificationCryptoError.noKeyAvailable
                }

                let encryptedPayload = encryptPushNotificationPayload(
                    plaintext: plaintext,
                    aesGCMKey: latestGeneration.aesGCMKey
                )
                state.encryptedCiphertext = encryptedPayload

                state.timeMessageEncrypted = latestGeneration.yearMonth
            } catch {
                state.encryptedCiphertext = "Encryption failed: \(error.localizedDescription)"
            }
            return .none
        case .requestPushPermissionAndRegister:
            return .run { send in
                do {
                    let token = try await apnsRegistrationService.requestAuthorizationAndRegister()
                    let hexToken = token.map { String(format: "%02x", $0) }.joined()
                    await send(.pushNotificationRegisterReceived(deviceToken: hexToken, error: nil))
                } catch APNSRegistrationError.permissionDenied {
                    await send(.pushNotificationRegisterReceived(
                        deviceToken: nil,
                        error: "Notification permission denied."
                    ))
                } catch {
                    await send(.pushNotificationRegisterReceived(deviceToken: nil, error: error.localizedDescription))
                }
            }
        case let .pushNotificationRegisterReceived(deviceToken, error):
            if let deviceToken {
                state.deviceToken = deviceToken
                state.tokenError = ""
            } else {
                state.deviceToken = ""
                state.tokenError = error ?? "Unknown error"
            }
            return .none
        case .binding:
            return .none
        }
        #else
        return .none
        #endif
    }

    func encryptPushNotificationPayload(plaintext: String, aesGCMKey: Data) -> String {
        do {
            let framedPayload = PNM1Framing.apply(Data(plaintext.utf8))

            // AES/GCM encrypt
            let symmetricKey = SymmetricKey(data: aesGCMKey)
            let sealedBox = try AES.GCM.seal(framedPayload, using: symmetricKey)
            guard let combined = sealedBox.combined else {
                return "Encryption failed: Unable to combine sealed box components."
            }
            return combined.base64EncodedString()
        } catch {
            return "Encryption failed: \(error.localizedDescription)"
        }
    }

    var body: some Reducer<State, Action> {
        #if ENABLE_DEBUG_VIEW
        Scope(state: \.logState, action: \.logAction) {
            DebugLogsDomain(loggingStore: DebugLiveLogger.shared)
        }

        BindingReducer()

        Reduce(core)
        #else
        EmptyReducer()
        #endif
    }

    struct Response<T> {
        let value: T
        let result: Result

        enum Result {
            case success
            case failure(Error)
        }
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    /// A key to determine whether the app should show settings for push notifications.
    public static var enablePushNotifications: Self {
        Self[.appStorage("enable_push_notifications"), default: false]
    }
}

#if ENABLE_DEBUG_VIEW
extension DebugDomain {
    func falsify(ssoToken: String) -> String? {
        // <Header>.<Encrypted Key>.<IV>.<Ciphertext>.<Authentication Tag>
        var jweElements = ssoToken.split(separator: ".").map { String($0) }
        if let jweHeader = jweElements.first,
//           let decodedHeader = try? Base64.decode(string: jweHeader),
           let decodedHeader = Data(base64Encoded: jweHeader),
           let header = try? JSONDecoder().decode(SSOTokenHeader.self, from: decodedHeader) {
            let modifiedHeader = SSOTokenHeader(
                exp: header.exp,
                enc: header.enc,
                alg: header.alg,
                cty: header.cty,
                kid: "invalid"
            )
            guard let headerData = try? JSONEncoder().encode(modifiedHeader) else {
                return nil
            }
            let headerBase64 = headerData.base64EncodedString()
            jweElements[0] = headerBase64
            return jweElements.joined(separator: ".")
        } else {
            return nil
        }
    }

    func loadAllLocalTasks() -> Effect<DebugDomain.Action> {
        .publisher(
            erxTaskRepository.loadLocalAllTasks(nil)
                .catchToPublisher()
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.loadAllLocalTasksReceived)
                .eraseToAnyPublisher
        )
    }

    func onReceiveHideOnboarding() -> Effect<DebugDomain.Action> {
        .publisher(
            localUserStore.onboardingVersion
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.hideOnboardingReceived)
                .eraseToAnyPublisher
        )
    }

    func onReceiveHideCardWallIntro() -> Effect<DebugDomain.Action> {
        .publisher(
            localUserStore.hideCardWallIntro
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.hideCardWallIntroReceived)
                .eraseToAnyPublisher
        )
    }

    func onReceiveToken() -> Effect<DebugDomain.Action> {
        .publisher(
            userSession.idpSession.autoRefreshedToken
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.tokenReceived)
                .catch { _ in Empty() }
                .eraseToAnyPublisher
        )
    }

    func onReceiveConfigurationName(for availableEnvironments: [DebugDomain.State.ServerEnvironment])
        -> Effect<DebugDomain.Action> {
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

    func onReceiveCurrentProfile() -> Effect<DebugDomain.Action> {
        .publisher(
            userProfileService
                .activeUserProfilePublisher()
                .catchToPublisher()
                .receive(on: schedulers.main)
                .map(DebugDomain.Action.profileReceived)
                .eraseToAnyPublisher
        )
    }

    func setProfileInsuranceTypeToPKV(profileId: UUID) -> Effect<DebugDomain.Action> {
        let userProfileService = userProfileService

        return .run { _ in
            _ = try await userProfileService
                .update(profileId: profileId) { profile in
                    profile.insuranceType = .pKV
                    profile.insurance = "Dummy pKV"
                }
                .async()
        }
    }

    func setHidePkvConsentDrawerOnMainView(to value: Bool, profileId: UUID) -> Effect<DebugDomain.Action> {
        let userProfileService = userProfileService

        return .run { _ in
            _ = try await userProfileService
                .update(profileId: profileId) { profile in
                    profile.hidePkvConsentDrawerOnMainView = value
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

// swiftlint:enable type_body_length file_length
