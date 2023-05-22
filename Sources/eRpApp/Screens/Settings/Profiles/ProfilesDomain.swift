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

struct ProfilesDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        .concatenate(
            EditProfileDomain.cleanup(),
            EffectTask<T>.cancel(ids: Token.allCases)
        )
    }

    enum Token: CaseIterable, Hashable {
        case loadProfiles
        case loadProfileId
    }

    struct State: Equatable {
        var profiles: [UserProfile]
        var selectedProfileId: UUID?
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener

        case addNewProfile
        case editProfile(UserProfile)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case loadReceived(Result<[UserProfile], UserProfileServiceError>)
            case selectedProfileReceived(UUID)
        }

        enum Delegate: Equatable {
            case alert(ErpAlertState<ProfilesDomain.Action>)
            case showEditProfile(EditProfileDomain.State)
            case showNewProfile
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerListener:
            return .merge(
                userProfileService.userProfilesPublisher()
                    .catchToEffect()
                    .map(Action.Response.loadReceived)
                    .map(Action.response)
                    .receive(on: schedulers.main.animation())
                    .eraseToEffect()
                    .cancellable(id: Token.loadProfiles, cancelInFlight: true),
                userProfileService.selectedProfileId
                    .compactMap {
                        $0
                    }
                    .map(Action.Response.selectedProfileReceived)
                    .map(Action.response)
                    .receive(on: schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.loadProfileId, cancelInFlight: true)
            )
        case .unregisterListener:
            return .cancel(id: Token.loadProfiles)
        case let .response(.loadReceived(.failure(error))):
            return .task {
                .delegate(.alert(.init(for: error, title: TextState(L10n.errTxtDatabaseAccess))))
            }
        case let .response(.loadReceived(.success(profiles))):
            state.profiles = profiles
            return .none
        case let .response(.selectedProfileReceived(profileId)):
            state.selectedProfileId = profileId
            return .none
        case let .editProfile(profile):
            return .task {
                .delegate(.showEditProfile(.init(profile: profile)))
            }
        case .addNewProfile:
            return .task {
                .delegate(.showNewProfile)
            }
        case .delegate:
            return .none
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

extension Profile.ProfilePictureType {
    var viewModelPicture: ProfilePicture {
        switch self {
        case .baby:
            return .baby
        case .boyWithCard:
            return .boyWithCard
        case .developer:
            return .developer
        case .doctorFemale:
            return .doctorFemale
        case .pharmacist:
            return .pharmacist
        case .manWithPhone:
            return .manWithPhone
        case .oldDoctor:
            return .oldDoctor
        case .oldMan:
            return .oldMan
        case .oldWoman:
            return .oldWoman
        case .doctorMale:
            return .doctorMale
        case .pharmacist2:
            return .pharmacist2
        case .wheelchair:
            return .wheelchair
        case .womanWithPhone:
            return .womanWithPhone
        case .none:
            return .none
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

        static let store = Store(
            initialState: state,
            reducer: ProfilesDomain()
        )
    }
}
