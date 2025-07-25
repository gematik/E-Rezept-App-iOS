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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import IDP

@Reducer
struct ProfilesDomain {
    @ObservableState
    struct State: Equatable {
        var profiles: [UserProfile]
        var selectedProfileId: UUID?
    }

    enum Action: Equatable {
        case registerListener
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

    var body: some Reducer<State, Action> {
        Reduce(core)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .registerListener:
            return .merge(
                .publisher(
                    userProfileService.userProfilesPublisher()
                        .catchToPublisher()
                        .map(Action.Response.loadReceived)
                        .map(Action.response)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                ),
                .publisher(
                    userProfileService.selectedProfileId
                        .compactMap { $0 }
                        .map(Action.Response.selectedProfileReceived)
                        .map(Action.response)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            )
        case let .response(.loadReceived(.failure(error))):
            return .send(.delegate(.alert(.init(for: error, title: L10n.errTxtDatabaseAccess))))
        case let .response(.loadReceived(.success(profiles))):
            state.profiles = profiles
            return .none
        case let .response(.selectedProfileReceived(profileId)):
            state.selectedProfileId = profileId
            return .none
        case let .editProfile(profile):
            return .send(.delegate(.showEditProfile(.init(profile: profile))))
        case .addNewProfile:
            return .send(.delegate(.showNewProfile))
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
            initialState: state
        ) {
            ProfilesDomain()
        }
    }
}
