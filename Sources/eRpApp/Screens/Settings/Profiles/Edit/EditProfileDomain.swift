//
//  Copyright (c) 2024 gematik GmbH
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
import eRpLocalStorage
import Foundation
import IDP

// swiftlint:disable type_body_length file_length
@Reducer
struct EditProfileDomain {
    @ObservableState
    struct State: Equatable {
        let profileId: UUID
        var name: String
        var acronym: String
        var fullName: String?
        var insurance: String?
        var can: String?
        var insuranceId: String?
        var image: ProfilePicture?
        var userImageData: Data?
        var color: ProfileColor
        var token: IDPToken?
        var hasBiometricKeyID: Bool?
        var availableSecurityOptions: [AppSecurityOption] = []
        var securityOptionsError: AppSecurityManagerError?
        @Presents var destination: Destination.State?
        var insuranceType: Profile.InsuranceType
        var routeToChargeItemList = false

        init(name: String,
             acronym: String,
             fullName: String?,
             insurance: String?,
             can: String?,
             insuranceId: String?,
             image: ProfilePicture?,
             userImageData _: Data?,
             color: ProfileColor,
             profileId: UUID,
             token: IDPToken? = nil,
             hasBiometricKeyID: Bool? = nil,
             destination: EditProfileDomain.Destination.State? = nil,
             availableSecurityOptions: [AppSecurityOption] = [],
             securityOptionsError: AppSecurityManagerError? = nil,
             insuranceType: Profile.InsuranceType = .unknown) {
            self.name = name
            self.acronym = acronym
            self.fullName = fullName
            self.insurance = insurance
            self.can = can
            self.insuranceId = insuranceId
            self.image = image
            self.color = color
            self.profileId = profileId
            self.destination = destination
            self.token = token
            self.hasBiometricKeyID = hasBiometricKeyID
            self.availableSecurityOptions = availableSecurityOptions
            self.securityOptionsError = securityOptionsError
            self.insuranceType = insuranceType
        }

        init(
            profile: UserProfile,
            routeToChargeItemList: Bool = false
        ) {
            profileId = profile.id
            name = profile.name
            acronym = profile.name.acronym()
            fullName = profile.fullName
            insurance = profile.insurance
            insuranceId = profile.insuranceId
            image = profile.image
            userImageData = profile.userImageData
            color = profile.color
            insuranceType = profile.profile.insuranceType
            self.routeToChargeItemList = routeToChargeItemList
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = profile_auditEvents
        case auditEvents(AuditEventsDomain)
        // sourcery: AnalyticsScreen = profile_registeredDevices
        case registeredDevices(RegisteredDevicesDomain)
        // sourcery: AnalyticsScreen = chargeItemList
        case chargeItemList(ChargeItemListDomain)
        case editProfilePicture(EditProfilePictureDomain)

        enum Alert: Equatable {
            case confirmDeleteProfile
            case confirmDeleteBiometricPairing
        }
    }

    enum Action: BindableAction, Equatable {
        case task
        case onAppear
        case binding(BindingAction<State>)
        case showDeleteProfileAlert
        case login
        case relogin
        case showDeleteBiometricPairingAlert

        case destination(PresentationAction<Destination.Action>)
        case resetNavigation
        case registeredDevicesTapped
        case auditEventsTapped
        case chargeItemListTapped
        case editProfilePictureTapped
        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case updateProfileReceived(Result<Bool, LocalStoreError>)
            case deleteBiometricPairingReceived(Result<Bool, IDPError>)
            case canReceived(String?)
            case tokenReceived(IDPToken?)
            case biometricKeyIDReceived(Bool)
            case profileReceived(Result<Profile?, LocalStoreError>)
        }

        enum Delegate {
            case close
            case logout
        }
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore

    // Use changebaleUserSesisonContainer to set the correct user session for demo mode
    var userDataStore: UserDataStore {
        changeableUserSessionContainer.userSession.localUserStore
    }

    @Dependency(\.changeableUserSessionContainer) var changeableUserSessionContainer
    @Dependency(\.profileSecureDataWiper) var profileSecureDataWiper: ProfileSecureDataWiper
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.router) var router: Routing

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            let availableOptions = appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableOptions.options
            state.securityOptionsError = availableOptions.error

            return .merge(
                subscribeToTokenUpdates(for: state.profileId),
                subscribeToBiometricKeyIDUpdates(for: state.profileId),
                subscribeToCanUpdates(with: state.profileId),
                .publisher(
                    profileDataStore.fetchProfile(by: state.profileId)
                        .first()
                        .catchToPublisher()
                        .map(Action.Response.profileReceived)
                        .map(Action.response)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            )
        case .onAppear:
            // Routing needs to be split from EditProfileView on
            // downwards the navigation tree and delayed to work properly
            if state.routeToChargeItemList {
                state.routeToChargeItemList = false
                return .run { send in
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.chargeItemListTapped)
                }
            }
            return .none
        case let .response(.tokenReceived(token)):
            state.token = token
            return .none
        case let .response(.biometricKeyIDReceived(result)):
            state.hasBiometricKeyID = result
            return .none
        case let .response(.canReceived(can)):
            state.can = can
            return .none
        case let .response(.profileReceived(.success(profile))):
            state.image = profile?.image.viewModelPicture
            state.userImageData = profile?.userImageData
            state.color = profile?.color.viewModelColor ?? .grey
            state.insuranceId = profile?.insuranceId
            state.insurance = profile?.insurance
            state.fullName = profile?.fullName
            return .none
        case .response(.profileReceived(.failure)):
            return .none
        case .binding(\.name):
            let name = state.name.trimmed()
            state.name = name
            state.acronym = name.acronym()

            guard name.lengthOfBytes(using: .utf8) > 0 else { return .none }

            return .publisher(
                updateProfile(with: state.profileId) { profile in
                    profile.name = name
                    profile.shouldAutoUpdateNameAtNextLogin = false
                }
                .map(Action.Response.updateProfileReceived)
                .map(Action.response)
                .eraseToAnyPublisher
            )
        case .binding(\.color):
            let color = state.color.erxColor
            return .publisher(
                updateProfile(with: state.profileId) { profile in
                    profile.color = color
                }
                .map(Action.Response.updateProfileReceived)
                .map(Action.response)
                .eraseToAnyPublisher
            )
        case .showDeleteProfileAlert:
            state.destination = .alert(AlertStates.deleteProfile)
            return .none
        case .destination(.presented(.alert(.confirmDeleteProfile))):
            return .publisher(
                deleteProfile(with: state.profileId)
                    .map { result in
                        switch result {
                        case .success: return Action.delegate(.close)
                        case let .failure(error): return Action.response(.updateProfileReceived(.failure(error)))
                        }
                    }
                    .eraseToAnyPublisher
            )
        case .response(.updateProfileReceived(.success)):
            return .none
        case let .response(.updateProfileReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none

        // [REQ:BSI-eRp-ePA:O.Auth_14#3|6] The domain accepts the intent and wipes tokens and other login related data
        case .delegate(.logout):
            state.token = nil
            // [REQ:gemSpec_IDP_Frontend:A_20499-01#1] Call the SSO_TOKEN removal upon manual logout
            return .run { [profileId = state.profileId] _ in
                try await profileSecureDataWiper.wipeSecureData(of: profileId).async()
            }
        case .login:
            userDataStore.set(selectedProfileId: state.profileId)
            return .run { _ in
                await router.routeTo(.mainScreen(.login))
            }
        case .relogin:
            state.token = nil
            return .run { [profileId = state.profileId] _ in
                try await profileSecureDataWiper.wipeSecureData(of: profileId).async()

                userDataStore.set(selectedProfileId: profileId)
                await router.routeTo(.mainScreen(.login))
            }
        case .resetNavigation:
            state.destination = nil
            return .none
        case .registeredDevicesTapped:
            state.destination = .registeredDevices(.init(profileId: state.profileId))
            return .none
        case .auditEventsTapped:
            state.destination = .auditEvents(.init(profileUUID: state.profileId))
            return .none
        case .chargeItemListTapped:
            state.destination = .chargeItemList(.init(profileId: state.profileId))
            return .none
        case .editProfilePictureTapped:
            state.destination = .editProfilePicture(.init(
                profileId: state.profileId,
                color: state.color,
                picture: state.image ?? .none,
                userImageData: state.userImageData ?? Data(),
                isFullScreenPresented: true
            ))
            return .none
        case .destination(.presented(.auditEvents)),
             .destination(.presented(.registeredDevices)),
             .destination(.presented(.chargeItemList)),
             .destination(.presented(.editProfilePicture)):
            return .none
        case .showDeleteBiometricPairingAlert:
            state.destination = .alert(AlertStates.deleteBiometricPairing)
            return .none
        case .destination(.presented(.alert(.confirmDeleteBiometricPairing))):
            state.destination = nil
            return .publisher(
                deleteBiometricPairing(for: state.profileId)
                    .eraseToAnyPublisher
            )
        case let .response(.deleteBiometricPairingReceived(result)):
            switch result {
            case .success:
                state.destination = nil
                let profileId = state.profileId
                return .run { _ in
                    try await profileSecureDataWiper.wipeSecureData(of: profileId).async()
                }
            case let .failure(error):
                state.destination = .alert(AlertStates.deleteBiometricPairingFailed(with: error))
                return .none
            }
        case .destination,
             .binding,
             .delegate:
            return .none
        }
    }
}

extension EditProfileDomain {
    func subscribeToTokenUpdates(for profileId: UUID) -> Effect<Action> {
        .publisher(
            userSessionProvider.userSession(for: profileId).secureUserStore.token
                .receive(on: schedulers.main.animation())
                .map(Action.Response.tokenReceived)
                .map(Action.response)
                .eraseToAnyPublisher
        )
    }

    func subscribeToCanUpdates(with profileId: UUID) -> Effect<Action> {
        .publisher(
            userSessionProvider.userSession(for: profileId).secureUserStore.can
                .receive(on: schedulers.main.animation())
                .map(Action.Response.canReceived)
                .map(Action.response)
                .eraseToAnyPublisher
        )
    }

    func subscribeToBiometricKeyIDUpdates(for profileId: UUID) -> Effect<Action> {
        .publisher(
            userSessionProvider.userSession(for: profileId).secureUserStore.keyIdentifier
                .receive(on: schedulers.main.animation())
                .map { $0 != nil }
                .map(Action.Response.biometricKeyIDReceived)
                .map(Action.response)
                .eraseToAnyPublisher
        )
    }

    func updateProfile(
        with profileId: UUID,
        mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Result<Bool, LocalStoreError>, Never> {
        profileDataStore
            .update(profileId: profileId, mutating: mutating)
            .receive(on: schedulers.main)
            .catchToPublisher()
    }

    func deleteProfile(
        with profileId: UUID
    ) -> AnyPublisher<Result<Bool, LocalStoreError>, Never> {
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
                .catchToPublisher()
    }

    func deleteBiometricPairing(for profileId: UUID) -> AnyPublisher<Action, Never> {
        let profileUserSession = userSessionProvider.userSession(for: profileId)
        let loginHandler = profileUserSession.pairingIdpSessionLoginHandler

        return loginHandler.isAuthenticatedOrAuthenticate()
            .first()
            .flatMap { result -> AnyPublisher<IDPToken?, Never> in
                if case .failure = result {
                    return Just(nil).eraseToAnyPublisher()
                }
                return profileUserSession.pairingIdpSession.autoRefreshedToken // -> AnyPublisher<IDPToken?, IDPError>
                    .catch { _ in Just(nil) }
                    .eraseToAnyPublisher()
            }
            .first()
            .combineLatest(
                profileUserSession.secureUserStore.keyIdentifier // -> AnyPublisher<Data?, Never>
            )
            .first()
            .flatMap { pairingToken, keyIdentifier -> AnyPublisher<Action, Never> in
                guard let keyIdentifier = keyIdentifier,
                      let pairingToken = pairingToken,
                      let base64KeyIdentifier = keyIdentifier.encodeBase64UrlSafe(),
                      let deviceIdentifier = String(data: base64KeyIdentifier, encoding: .utf8) else {
                    return Just(Action.relogin).eraseToAnyPublisher()
                }

                return profileUserSession.pairingIdpSession.unregisterDevice(deviceIdentifier, token: pairingToken)
                    // -> AnyPublisher<Bool, IDPError>
                    .catchToPublisher()
                    .map(Action.Response.deleteBiometricPairingReceived)
                    .map(Action.response)
                    .eraseToAnyPublisher()
            }
            .first()
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
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
                                          lastAuthenticated: nil,
                                          erxTasks: [],
                                          shouldAutoUpdateNameAtNextLogin: true)
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
        typealias Action = EditProfileDomain.Destination.Alert

        static let deleteProfile: ErpAlertState<Action> = {
            .init(
                title: L10n.stgTxtEditProfileDeleteConfirmationTitle,
                actions: {
                    ButtonState(role: .destructive, action: .confirmDeleteProfile) {
                        .init(L10n.dtlTxtDeleteYes)
                    }
                    ButtonState(role: .cancel) {
                        .init(L10n.stgBtnEditProfileDeleteAlertCancel)
                    }
                },
                message: L10n.stgTxtEditProfileDeleteConfirmationMessage
            )
        }()

        static let deleteBiometricPairing: ErpAlertState<Action> = {
            .init(
                title: L10n.stgTxtEditProfileDeletePairingTitle,
                actions: {
                    ButtonState(role: .destructive, action: .confirmDeleteBiometricPairing) {
                        .init(L10n.dtlTxtDeleteYes)
                    }
                    ButtonState(role: .cancel) {
                        .init(L10n.stgBtnEditProfileDeleteAlertCancel)
                    }
                },
                message: L10n.stgTxtEditProfileDeletePairingMessage
            )
        }()

        static func deleteBiometricPairingFailed(with error: IDPError) -> ErpAlertState<Action> {
            .init(
                for: error,
                title: L10n.stgTxtEditProfileDeletePairingError
            ) {
                ButtonState(role: .destructive, action: .confirmDeleteBiometricPairing) {
                    .init(L10n.dtlTxtDeleteYes)
                }
                ButtonState(role: .cancel) {
                    .init(L10n.stgBtnEditProfileDeleteAlertCancel)
                }
            }
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

        static let store = Store(
            initialState: onlineState
        ) {
            EditProfileDomain()
        }
    }
}

// swiftlint:enable type_body_length
