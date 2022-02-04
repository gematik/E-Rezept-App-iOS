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
import eRpLocalStorage
import IDP

enum EditProfileDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case idpTokenListener
    }

    enum Route: Equatable {
        case alert(AlertState<Action>)
        case token(IDPToken)
        case auditEvents(AuditEventsDomain.State)

        enum Tag: Int {
            case alert
            case token
            case auditEvents
        }

        var tag: Tag {
            switch self {
            case .alert:
                return .alert
            case .token:
                return .token
            case .auditEvents:
                return .auditEvents
            }
        }
    }

    struct State: Equatable {
        let profileId: UUID
        var name: String
        var acronym: String
        var fullName: String?
        var insurance: String?
        var insuranceId: String?
        var emoji: String?
        var color: ProfileColor
        var token: IDPToken?

        var route: Route?

        init(name: String,
             acronym: String,
             fullName: String?,
             insurance: String?,
             insuranceId: String?,
             emoji: String? = nil,
             color: ProfileColor,
             profileId: UUID,
             token: IDPToken? = nil,
             route: Route? = nil) {
            self.name = name
            self.acronym = acronym
            self.fullName = fullName
            self.insurance = insurance
            self.insuranceId = insuranceId
            self.emoji = emoji
            self.color = color
            self.profileId = profileId
            self.route = route
            self.token = token
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
    }

    enum Action: Equatable {
        case setName(String)
        case setEmoji(String?)
        case setColor(ProfileColor)
        case delete
        case close
        case dismissAlert
        case confirmDelete
        case updateResultReceived(Result<Bool, LocalStoreError>)
        case logout
        case login

        case registerListener
        case tokenReceived(IDPToken?)

        case profileReceived(Result<Profile?, LocalStoreError>)

        case setNavigation(tag: Route.Tag?)
        case auditEvents(action: AuditEventsDomain.Action)
    }

    struct Environment {
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let userDataStore: UserDataStore
        let profileSecureDataWiper: ProfileSecureDataWiper
        let router: Routing
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerListener:
            // [REQ:gemSpec_BSI_FdV:O.Tokn_9] observe token updates
            return .concatenate(
                environment.subscribeToTokenUpdates(with: state.profileId)
                    .cancellable(id: Token.idpTokenListener, cancelInFlight: true),
                environment.profileDataStore.fetchProfile(by: state.profileId)
                    .first()
                    .catchToEffect()
                    .map(Action.profileReceived)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
            )
        case let .tokenReceived(token):
            state.token = token
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
                .map(Action.updateResultReceived)
        case let .setName(name):
            let name = name.trimmed()
            state.name = name
            state.acronym = name.acronym()

            guard name.lengthOfBytes(using: .utf8) > 0 else { return .none }

            return environment
                .updateProfile(with: state.profileId) { profile in
                    profile.name = name
                }
                .map(Action.updateResultReceived)
        case let .setColor(color):
            state.color = color
            return environment
                .updateProfile(with: state.profileId) { profile in
                    profile.color = color.erxColor
                }
                .map(Action.updateResultReceived)
        case .delete:
            state.route = .alert(AlertStates.deleteProfile)
            return .none
        case .confirmDelete:
            return environment
                .deleteProfile(with: state.profileId)
                .map { result in
                    switch result {
                    case .success:
                        return Action.close
                    case let .failure(error):
                        return Action.updateResultReceived(.failure(error))
                    }
                }
                .eraseToEffect()
        case .updateResultReceived(.success):
            return .none
        case let .updateResultReceived(.failure(error)):
            state.route = .alert(AlertStates.for(error))
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
        case .setNavigation(tag: .auditEvents):
            state.route = .auditEvents(.init(profileUUID: state.profileId))
            return .none
        case .setNavigation:
            return .none
        case .auditEvents(action:):
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        auditEventsReducer,
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
}

extension EditProfileDomain.Environment {
    typealias Action = EditProfileDomain.Action

    func subscribeToTokenUpdates(with profileId: UUID) -> Effect<Action, Never> {
        profileSecureDataWiper.secureStorage(of: profileId).token
            .receive(on: schedulers.main)
            .map(Action.tokenReceived)
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
                    let profile = Profile(name: "Profilname",
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

extension ProfileDataStore {}

extension EditProfileDomain {
    enum AlertStates {
        typealias Action = EditProfileDomain.Action

        static func `for`(_ error: LocalStoreError) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.stgTxtEditProfileErrorMessageTitle),
                message: TextState(error.localizedDescription),
                dismissButton: .default(TextState(L10n.alertBtnOk))
            )
        }

        static var deleteProfile: AlertState<Action> =
            .init(title: TextState(L10n.stgTxtEditProfileDeleteConfirmationTitle),
                  message: TextState(L10n.stgTxtEditProfileDeleteConfirmationMessage),
                  primaryButton: .destructive(TextState(L10n.dtlTxtDeleteYes), action: .send(.confirmDelete)),
                  secondaryButton: .cancel(
                      TextState(L10n.stgBtnEditProfileDeleteAlertCancel),
                      action: .send(.dismissAlert)
                  ))
    }
}

extension EditProfileDomain {
    enum Dummies {
        static let state = State(profile: UserProfile.Dummies.profileA)
        static let environment = Environment(schedulers: Schedulers(),
                                             profileDataStore: DemoProfileDataStore(),
                                             userDataStore: DemoUserDefaultsStore(),
                                             profileSecureDataWiper: DummyProfileSecureDataWiper(),
                                             router: DummyRouter())

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
