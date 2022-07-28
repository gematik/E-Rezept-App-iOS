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
import IDP

enum ProfilesDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: Token.self),
            EditProfileDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case loadProfiles
    }

    enum Route: Equatable {
        case editProfile(EditProfileDomain.State)
        case newProfile(NewProfileDomain.State)
        case alert(AlertState<Action>)

        enum Tag: Int {
            case details
            case newProfile
            case alert
        }

        var tag: Tag {
            switch self {
            case .editProfile:
                return .details
            case .newProfile:
                return .newProfile
            case .alert:
                return .alert
            }
        }
    }

    struct State: Equatable {
        var profiles: [UserProfile]
        var selectedProfileId: UUID?

        var route: Route?
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener
        case loadReceived(Result<[UserProfile], UserProfileServiceError>)
        case selectedProfileReceived(UUID)

        case addNewProfile
        case editProfile(UserProfile)

        case profile(action: EditProfileDomain.Action)
        case newProfile(action: NewProfileDomain.Action)

        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        let appSecurityManager: AppSecurityManager
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let userDataStore: UserDataStore
        let userProfileService: UserProfileService
        let profileSecureDataWiper: ProfileSecureDataWiper
        let router: Routing
        let secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider
        let userSessionProvider: UserSessionProvider
        let nfcSignatureProvider: NFCSignatureProvider
        let userSession: UserSession
        let signatureProvider: SecureEnclaveSignatureProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerListener:
            return .merge(
                environment.userProfileService.userProfilesPublisher()
                    .catchToEffect()
                    .map(Action.loadReceived)
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToEffect()
                    .cancellable(id: Token.loadProfiles, cancelInFlight: true),
                environment.userDataStore.selectedProfileId
                    .compactMap { $0 }
                    .map(Action.selectedProfileReceived)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
            )
        case .unregisterListener:
            return .cancel(id: Token.loadProfiles)
        case let .loadReceived(.failure(error)):
            state.route = .alert(AlertStates.for(error))
            return .none
        case let .loadReceived(.success(profiles)):
            state.profiles = profiles
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return EditProfileDomain.cleanup()
        case let .selectedProfileReceived(profileId):
            state.selectedProfileId = profileId
            return .none
        case let .editProfile(profile):
            state.route = .editProfile(.init(profile: profile))
            return .none
        case .addNewProfile:
            state.route = .newProfile(.init(name: "", acronym: "", emoji: nil, color: .blue))
            return .none
        case .profile(action: .logout):
            return .init(value: .registerListener)
        case .profile(action: .close),
             .newProfile(action: .close):
            state.route = nil
            return .none
        case .profile,
             .newProfile,
             .setNavigation:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        profilePullback,
        newProfilePullback,
        domainReducer
    )

    private static let profilePullback: Reducer =
        EditProfileDomain.reducer._pullback(
            state: (\State.route).appending(path: /ProfilesDomain.Route.editProfile),
            action: /ProfilesDomain.Action.profile(action:)
        ) {
            .init(appSecurityManager: $0.appSecurityManager,
                  schedulers: $0.schedulers,
                  profileDataStore: $0.profileDataStore,
                  userDataStore: $0.userDataStore,
                  profileSecureDataWiper: $0.profileSecureDataWiper,
                  router: $0.router,
                  userSession: $0.userSession,
                  userSessionProvider: $0.userSessionProvider,
                  secureEnclaveSignatureProvider: $0.secureEnclaveSignatureProvider,
                  nfcSignatureProvider: $0.nfcSignatureProvider,
                  signatureProvider: $0.signatureProvider,
                  accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver)
        }

    private static let newProfilePullback: Reducer =
        NewProfileDomain.reducer._pullback(
            state: (\State.route).appending(path: /ProfilesDomain.Route.newProfile),
            action: /ProfilesDomain.Action.newProfile(action:)
        ) {
            .init(schedulers: $0.schedulers,
                  userDataStore: $0.userDataStore,
                  profileDataStore: $0.profileDataStore)
        }
}

extension ProfilesDomain {
    enum AlertStates {
        typealias Action = ProfilesDomain.Action

        static func `for`(_ error: LocalizedError & CodedError) -> AlertState<Action> {
            AlertState(title: TextState(L10n.errTxtDatabaseAccess),
                       message: TextState(error.localizedDescriptionWithErrorList),
                       dismissButton: .default(TextState(L10n.alertBtnOk)))
        }
    }
}

extension Profile.Color {
    var viewModelColor: ProfileColor {
        switch self {
        case .grey:
            return .grey
        case .yellow:
            return .yellow
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}

extension ProfilesDomain {
    enum Dummies {
        static let state = State(
            profiles: [
                UserProfile.Dummies.profileA,
                UserProfile.Dummies.profileB,
                UserProfile.Dummies.profileC,
            ],
            selectedProfileId: UserProfile.Dummies.profileA.id
        )

        static let environment = Environment(
            appSecurityManager: DummyAppSecurityManager(),
            schedulers: Schedulers(),
            profileDataStore: DemoProfileDataStore(),
            userDataStore: DemoUserDefaultsStore(),
            userProfileService: DummyUserProfileService(),
            profileSecureDataWiper: DummyProfileSecureDataWiper(),
            router: DummyRouter(),
            secureEnclaveSignatureProvider: DummySecureEnclaveSignatureProvider(),
            userSessionProvider: DummyUserSessionProvider(),
            nfcSignatureProvider: DemoSignatureProvider(),
            userSession: DemoSessionContainer(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        ) { _ in }

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
