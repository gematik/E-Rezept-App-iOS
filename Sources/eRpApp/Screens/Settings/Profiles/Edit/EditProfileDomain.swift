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
// swiftlint:disable file_length

import Combine
import ComposableArchitecture
import DataKit
import eRpKit
import eRpLocalStorage
import Foundation
import IDP

enum EditProfileDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case idpTokenListener
        case idpBiometricKeyIDListener
        case canListener
        case profileReceived
    }

    enum Route: Equatable {
        case alert(ErpAlertState<Action>)
        case token(IDPToken)
        case linkedDevices
        case auditEvents(AuditEventsDomain.State)
        case registeredDevices(RegisteredDevicesDomain.State)
    }

    struct State: Equatable {
        let profileId: UUID
        var name: String
        var acronym: String
        var fullName: String?
        var insurance: String?
        var can: String?
        var insuranceId: String?
        var emoji: String?
        var color: ProfileColor
        var token: IDPToken?
        var hasBiometricKeyID: Bool?
        var availableSecurityOptions: [AppSecurityOption] = []
        var securityOptionsError: AppSecurityManagerError?
        var route: Route?
    }

    enum Action: Equatable {
        case setName(String)
        case setEmoji(String?)
        case setColor(ProfileColor)
        case showDeleteProfileAlert
        case confirmDeleteProfile
        case close
        case dismissAlert
        case updateProfileReceived(Result<Bool, LocalStoreError>)
        case logout
        case login
        case relogin

        case showDeleteBiometricPairingAlert
        case confirmDeleteBiometricPairing
        case deleteBiometricPairingReceived(Result<Bool, IDPError>)

        case loadAvailableSecurityOptions
        case registerListener
        case tokenReceived(IDPToken?)
        case biometricKeyIDReceived(Bool)
        case canReceived(String?)
        case profileReceived(Result<Profile?, LocalStoreError>)
        case setNavigation(tag: Route.Tag?)
        case auditEvents(action: AuditEventsDomain.Action)
        case registeredDevices(action: RegisteredDevicesDomain.Action)
    }

    struct Environment {
        let appSecurityManager: AppSecurityManager
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let userDataStore: UserDataStore
        let profileSecureDataWiper: ProfileSecureDataWiper
        let router: Routing
        let userSession: UserSession
        let userSessionProvider: UserSessionProvider
        let secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider
        let nfcSignatureProvider: NFCSignatureProvider
        let signatureProvider: SecureEnclaveSignatureProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }
}

extension EditProfileDomain {
    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadAvailableSecurityOptions:
            let availableOptions = environment.appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableOptions.options
            state.securityOptionsError = availableOptions.error
            return .none
        case .registerListener:
            return .merge(
                // [REQ:gemSpec_BSI_FdV:O.Tokn_9] observe token updates
                environment.subscribeToTokenUpdates(for: state.profileId)
                    .cancellable(id: Token.idpTokenListener, cancelInFlight: true),
                environment.subscribeToBiometricKeyIDUpdates(for: state.profileId)
                    .cancellable(id: Token.idpBiometricKeyIDListener, cancelInFlight: true),
                environment.subscribeToCanUpdates(with: state.profileId)
                    .cancellable(id: Token.canListener, cancelInFlight: true),
                environment.profileDataStore.fetchProfile(by: state.profileId)
                    .first()
                    .catchToEffect()
                    .map(Action.profileReceived)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.profileReceived, cancelInFlight: true)
            )
        case let .tokenReceived(token):
            state.token = token
            return .none
        case let .biometricKeyIDReceived(result):
            state.hasBiometricKeyID = result
            return .none
        case let .canReceived(can):
            state.can = can
            return .none
        case let .profileReceived(.success(profile)):
            state.insuranceId = profile?.insuranceId
            state.insurance = profile?.insurance
            state.fullName = profile?.fullName
            return .none
        case .profileReceived(.failure):
            return .none
        case let .setEmoji(emoji):
            state.emoji = emoji

            return environment
                .updateProfile(with: state.profileId) { profile in
                    profile.emoji = emoji
                }
                .map(Action.updateProfileReceived)
        case let .setName(name):
            let name = name.trimmed()
            state.name = name
            state.acronym = name.acronym()

            guard name.lengthOfBytes(using: .utf8) > 0 else { return .none }

            return environment
                .updateProfile(with: state.profileId) { profile in
                    profile.name = name
                }
                .map(Action.updateProfileReceived)
        case let .setColor(color):
            state.color = color
            return environment
                .updateProfile(with: state.profileId) { profile in
                    profile.color = color.erxColor
                }
                .map(Action.updateProfileReceived)
        case .showDeleteProfileAlert:
            state.route = .alert(AlertStates.deleteProfile)
            return .none
        case .confirmDeleteProfile:
            return
                .concatenate(
                    cleanup(),
                    environment
                        .deleteProfile(with: state.profileId)
                        .map { result in
                            switch result {
                            case .success: return Action.close
                            case let .failure(error): return Action.updateProfileReceived(.failure(error))
                            }
                        }
                        .eraseToEffect()
                )
        case .updateProfileReceived(.success):
            return .none
        case let .updateProfileReceived(.failure(error)):
            state.route = .alert(.init(for: error))
            return .none
        case .dismissAlert:
            state.route = nil
            return .none
        case .logout:
            state.token = nil
            return environment.profileSecureDataWiper.wipeSecureData(of: state.profileId).fireAndForget()
        case .login:
            environment.userDataStore.set(selectedProfileId: state.profileId)
            environment.router.routeTo(.mainScreen(.login))
            return .none
        case .relogin:
            state.token = nil
            return environment.profileSecureDataWiper.wipeSecureData(of: state.profileId)
                .handleEvents(receiveCompletion: { [state] _ in
                    environment.userDataStore.set(selectedProfileId: state.profileId)
                    environment.router.routeTo(.mainScreen(.login))
                })
                .fireAndForget()
        case .close:
            return cleanup()
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .setNavigation(tag: .token):
            if let token = state.token {
                state.route = .token(token)
            }
            return .none
        case .setNavigation(tag: .linkedDevices):
            state.route = .linkedDevices
            return .none
        case .setNavigation(tag: .registeredDevices):
            state.route = .registeredDevices(.init(profileId: state.profileId))
            return .none
        case .setNavigation(tag: .auditEvents):
            state.route = .auditEvents(.init(profileUUID: state.profileId))
            return .none
        case .setNavigation:
            return .none
        case .auditEvents,
             .registeredDevices:
            return .none
        case .showDeleteBiometricPairingAlert:
            state.route = .alert(AlertStates.deleteBiometricPairing)
            return .none
        case .confirmDeleteBiometricPairing:
            state.route = nil
            return environment.deleteBiometricPairing(for: state.profileId)
        case let .deleteBiometricPairingReceived(result):
            switch result {
            case .success:
                state.route = nil
                return environment.profileSecureDataWiper.wipeSecureData(of: state.profileId).fireAndForget()
            case let .failure(error):
                state.route = .alert(AlertStates.deleteBiometricPairingFailed(with: error))
                return .none
            }
        }
    }
}

extension EditProfileDomain {
    static let reducer: Reducer = .combine(
        auditEventsReducer,
        registeredDevicesDomain,
        domainReducer
    )

    private static let auditEventsReducer: Reducer =
        AuditEventsDomain.reducer._pullback(
            state: (\State.route).appending(path: /EditProfileDomain.Route.auditEvents),
            action: /EditProfileDomain.Action.auditEvents(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                profileDataStore: $0.profileDataStore
            )
        }

    private static let registeredDevicesDomain: Reducer =
        RegisteredDevicesDomain.reducer._pullback(
            state: (\State.route).appending(path: /EditProfileDomain.Route.registeredDevices),
            action: /EditProfileDomain.Action.registeredDevices(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                userSession: $0.userSession,
                userSessionProvider: $0.userSessionProvider,
                secureEnclaveSignatureProvider: $0.secureEnclaveSignatureProvider,
                nfcSignatureProvider: $0.nfcSignatureProvider,
                sessionProvider: RegisterSessionProvider(
                    userSessionProvider: $0.userSessionProvider,
                    userSession: $0.userSession
                ),
                accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver,
                registeredDevicesService: DefaultRegisteredDevicesService(userSessionProvider: $0.userSessionProvider)
            )
        }
}

extension EditProfileDomain.State {
    init(name: String,
         acronym: String,
         fullName: String?,
         insurance: String?,
         can: String?,
         insuranceId: String?,
         emoji: String? = nil,
         color: ProfileColor,
         profileId: UUID,
         token: IDPToken? = nil,
         hasBiometricKeyID: Bool? = nil,
         route: EditProfileDomain.Route? = nil,
         availableSecurityOptions: [AppSecurityOption] = [],
         securityOptionsError: AppSecurityManagerError? = nil) {
        self.name = name
        self.acronym = acronym
        self.fullName = fullName
        self.insurance = insurance
        self.can = can
        self.insuranceId = insuranceId
        self.emoji = emoji
        self.color = color
        self.profileId = profileId
        self.route = route
        self.token = token
        self.hasBiometricKeyID = hasBiometricKeyID
        self.availableSecurityOptions = availableSecurityOptions
        self.securityOptionsError = securityOptionsError
    }

    init(profile: UserProfile) {
        profileId = profile.id
        emoji = profile.emoji
        name = profile.name
        acronym = profile.name.acronym()
        fullName = profile.fullName
        insurance = profile.insurance
        insuranceId = profile.insuranceId
        color = profile.color
    }

    enum AuthenticationType: Equatable {
        case biometric
        case card
        case biometryNotEnrolled(String)
        case none
    }

    var authType: AuthenticationType {
        if let error = securityOptionsError {
            return .biometryNotEnrolled(error.localizedDescriptionWithErrorList)
        }
        if hasBiometricKeyID == true {
            return .biometric
        }
        if token != nil {
            return .card
        }
        return .none
    }
}

extension EditProfileDomain.Environment {
    typealias Action = EditProfileDomain.Action

    func subscribeToTokenUpdates(for profileId: UUID) -> Effect<Action, Never> {
        userSessionProvider.userSession(for: profileId).secureUserStore.token
            .receive(on: schedulers.main.animation())
            .map(Action.tokenReceived)
            .eraseToEffect()
    }

    func subscribeToCanUpdates(with profileId: UUID) -> Effect<Action, Never> {
        userSessionProvider.userSession(for: profileId).secureUserStore.can
            .receive(on: schedulers.main.animation())
            .map(Action.canReceived)
            .eraseToEffect()
    }

    func subscribeToBiometricKeyIDUpdates(for profileId: UUID) -> Effect<Action, Never> {
        userSessionProvider.userSession(for: profileId).secureUserStore.keyIdentifier
            .receive(on: schedulers.main.animation())
            .map { $0 != nil }
            .map(Action.biometricKeyIDReceived)
            .eraseToEffect()
    }

    func updateProfile(
        with profileId: UUID,
        mutating: @escaping (inout eRpKit.Profile) -> Void
    ) -> Effect<Result<Bool, LocalStoreError>, Never> {
        profileDataStore
            .update(profileId: profileId, mutating: mutating)
            .receive(on: schedulers.main)
            .catchToEffect()
    }

    func deleteProfile(
        with profileId: UUID
    ) -> Effect<Result<Bool, LocalStoreError>, Never> {
        let profile = Profile(name: "",
                              identifier: profileId,
                              insuranceId: nil,
                              color: .blue,
                              lastAuthenticated: nil,
                              erxTasks: [])

        return
            Just(true)
                .setFailureType(to: LocalStoreError.self)
                .createProfileIfOnlyOneProfileIsLeft(profileDataStore: profileDataStore)
                .setNewActiveProfileIfNecessary(profileId: profileId,
                                                profileDataStore: profileDataStore,
                                                userDataStore: userDataStore)
                .flatMap { _ in
                    self.profileSecureDataWiper.wipeSecureData(of: profile)
                }
                .flatMap { _ -> AnyPublisher<Bool, LocalStoreError> in
                    profileDataStore.delete(profiles: [profile])
                }
                .receive(on: schedulers.main)
                .catchToEffect()
    }

    func deleteBiometricPairing(for profileId: UUID) -> Effect<Action, Never> {
        let profileUserSession = userSessionProvider.userSession(for: profileId)
        let loginHandler = DefaultLoginHandler(
            idpSession: profileUserSession.biometrieIdpSession,
            signatureProvider: DefaultSecureEnclaveSignatureProvider(storage: profileUserSession.secureUserStore)
        )
        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { result -> AnyPublisher<IDPToken?, Never> in
                if case .failure = result {
                    return Just(nil).eraseToAnyPublisher()
                }
                return profileUserSession.biometrieIdpSession.autoRefreshedToken // -> AnyPublisher<IDPToken?, IDPError>
                    .catch { _ in Just(nil) }
                    .eraseToAnyPublisher()
            }
            .first()
            .combineLatest(
                profileUserSession.secureUserStore.keyIdentifier // -> AnyPublisher<Data?, Never>
            )
            .first()
            .flatMap { pairingToken, keyIdentifier -> Effect<Action, Never> in
                guard let keyIdentifier = keyIdentifier,
                      let pairingToken = pairingToken,
                      let deviceIdentifier = Base64.urlSafe.encode(data: keyIdentifier, with: .none).utf8string else {
                    return Effect(value: Action.relogin)
                }

                return profileUserSession.biometrieIdpSession.unregisterDevice(deviceIdentifier, token: pairingToken)
                    // -> AnyPublisher<Bool, IDPError>
                    .catchToEffect()
                    .map(Action.deleteBiometricPairingReceived)
            }
            .first()
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension Publisher where Failure == LocalStoreError, Output == Bool {
    func createProfileIfOnlyOneProfileIsLeft(profileDataStore: ProfileDataStore)
        -> AnyPublisher<Bool, LocalStoreError> {
        profileDataStore
            .listAllProfiles()
            .first()
            // Create a new profile, if this deletion would result in no profile available
            .flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
                if profiles.count == 1 {
                    let profile = Profile(name: L10n.onbProfileName.text,
                                          identifier: UUID(),
                                          insuranceId: nil,
                                          color: .blue,
                                          emoji: nil,
                                          lastAuthenticated: nil,
                                          erxTasks: [])
                    return profileDataStore.save(profiles: [profile])
                }
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setNewActiveProfileIfNecessary(
        profileId: UUID,
        profileDataStore: ProfileDataStore,
        userDataStore: UserDataStore
    ) -> AnyPublisher<Bool, LocalStoreError> {
        // Select a new profile if the selected profile gets deleted
        flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
            userDataStore.selectedProfileId
                .first()
                .flatMap { selectedProfileId -> AnyPublisher<Bool, LocalStoreError> in
                    if selectedProfileId == profileId {
                        return profileDataStore
                            .listAllProfiles()
                            .first()
                            .flatMap { profiles -> AnyPublisher<Bool, LocalStoreError> in
                                let profileIds = profiles
                                    .map(\.id)
                                    .filter { $0 != selectedProfileId }

                                guard let newSelectedProfileId = profileIds.first else {
                                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                                }
                                userDataStore.set(selectedProfileId: newSelectedProfileId)

                                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

extension EditProfileDomain {
    enum AlertStates {
        typealias Action = EditProfileDomain.Action

        static var deleteProfile: ErpAlertState<Action> =
            .init(title: TextState(L10n.stgTxtEditProfileDeleteConfirmationTitle),
                  message: TextState(L10n.stgTxtEditProfileDeleteConfirmationMessage),
                  primaryButton: .destructive(TextState(L10n.dtlTxtDeleteYes), action: .send(.confirmDeleteProfile)),
                  secondaryButton: .cancel(
                      TextState(L10n.stgBtnEditProfileDeleteAlertCancel),
                      action: .send(.dismissAlert)
                  ))

        static var deleteBiometricPairing: ErpAlertState<Action> =
            .init(title: TextState(L10n.stgTxtEditProfileDeletePairingTitle),
                  message: TextState(L10n.stgTxtEditProfileDeletePairingMessage),
                  primaryButton: .destructive(
                      TextState(L10n.dtlTxtDeleteYes),
                      action: .send(.confirmDeleteBiometricPairing)
                  ),
                  secondaryButton: .cancel(
                      TextState(L10n.stgBtnEditProfileDeleteAlertCancel),
                      action: .send(.dismissAlert)
                  ))

        static func deleteBiometricPairingFailed(with error: IDPError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: TextState(L10n.stgTxtEditProfileDeletePairingError),
                primaryButton: .destructive(
                    TextState(L10n.dtlTxtDeleteYes),
                    action: .send(.confirmDeleteBiometricPairing)
                ),
                secondaryButton: .cancel(
                    TextState(L10n.stgBtnEditProfileDeleteAlertCancel),
                    action: .send(.dismissAlert)
                )
            )
        }
    }
}

extension EditProfileDomain {
    enum Dummies {
        static let onlineState: State = {
            var state = State(profile: UserProfile.Dummies.profileA)
            state.token = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "")
            return state
        }()

        static let environment = Environment(
            appSecurityManager:
            DummyAppSecurityManager(
                options: onlineState.availableSecurityOptions,
                error: onlineState.securityOptionsError
            ),
            schedulers: Schedulers(),
            profileDataStore: DemoProfileDataStore(),
            userDataStore: DemoUserDefaultsStore(),
            profileSecureDataWiper: DummyProfileSecureDataWiper(),
            router: DummyRouter(),
            userSession: DummySessionContainer(),
            userSessionProvider: DummyUserSessionProvider(),
            secureEnclaveSignatureProvider: DummySecureEnclaveSignatureProvider(),
            nfcSignatureProvider: DemoSignatureProvider(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        ) { _ in }

        static let store = Store(
            initialState: onlineState,
            reducer: reducer,
            environment: environment
        )
    }
}
