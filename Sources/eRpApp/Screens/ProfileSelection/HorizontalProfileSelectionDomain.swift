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
import Foundation
import IDP

@Reducer
struct HorizontalProfileSelectionDomain {
    @ObservableState
    struct State: Equatable {
        var profiles: [UserProfile] = []
        var selectedProfileId: UUID?
        var profileName: String?
    }

    enum Action: Equatable {
        case registerListener
        case selectProfile(UserProfile)
        case showAddProfileView
        case profileButtonLongPressed(UserProfile)
        case showEditProfileNameView(UUID, String)

        case response(Response)

        enum Response: Equatable {
            case loadReceived(Result<[UserProfile], UserProfileServiceError>)
            case selectedProfileReceived(UUID)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
        case .response(.loadReceived(.failure)):
            // Handled by parent domain
            return .none
        case let .response(.loadReceived(.success(profiles))):
            state.profiles = profiles
            return .none
        case let .selectProfile(profile):
            state.selectedProfileId = profile.id
            userProfileService.set(selectedProfileId: profile.id)
            return .none
        case let .response(.selectedProfileReceived(profileId)):
            state.selectedProfileId = profileId
            return .none
        case let .profileButtonLongPressed(profile):
            return .concatenate(
                Effect.send(.selectProfile(profile)),
                Effect.send(.showEditProfileNameView(profile.id, profile.name))
            )
        case .showEditProfileNameView:
            return .none
        case .showAddProfileView:
            return .none
        }
    }
}

extension HorizontalProfileSelectionDomain {
    enum Dummies {
        static let state = State(
            profiles: [
                UserProfile.Dummies.profileA,
                UserProfile.Dummies.profileB,
                UserProfile.Dummies.profileC,
            ],
            selectedProfileId: UserProfile.Dummies.profileA.id
        )

        static let store = StoreOf<HorizontalProfileSelectionDomain>(
            initialState: state
        ) {
            EmptyReducer()
        }
    }
}
