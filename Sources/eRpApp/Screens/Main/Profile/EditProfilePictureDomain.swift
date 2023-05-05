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
import SwiftUI

struct EditProfilePictureDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case updateProfile
    }

    struct State: Equatable {
        var profile: UserProfile
        var color: ProfileColor?
        var picture: ProfilePicture?
    }

    enum Action: Equatable {
        case setProfileValues
        case editColor(ProfileColor?)
        case editPicture(ProfilePicture?)
        case delegate(DelegateAction)
        case updateProfileReceived(Result<Bool, UserProfileServiceError>)
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setProfileValues:
            state.color = state.profile.color
            state.picture = state.profile.image
            return .none
        case let .editColor(color):
            state.color = color
            return updateProfile(with: state.profile.id) { profile in
                profile.color = (color ?? .grey).erxColor
            }
            .map(Action.updateProfileReceived)
        case let .editPicture(picture):
            state.picture = picture
            return updateProfile(with: state.profile.id) { profile in
                profile.image = (picture ?? .none).erxPicture
            }
            .map(Action.updateProfileReceived)
        case .updateProfileReceived(.success):
            return .none
        case let .updateProfileReceived(.failure(error)):
            state.color = state.profile.color
            state.picture = state.profile.image
            return .init(value: .delegate(.failure(error)))
        case .delegate:
            return .none
        }
    }
}

extension EditProfilePictureDomain {
    func updateProfile(
        with profileId: UUID,
        mutating: @escaping (inout eRpKit.Profile) -> Void
    ) -> Effect<Result<Bool, UserProfileServiceError>, Never> {
        userProfileService
            .update(profileId: profileId, mutating: mutating)
            .receive(on: schedulers.main)
            .first()
            .catchToEffect()
    }
}

extension EditProfilePictureDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: EditProfilePictureDomain()
        )

        static let state = State(profile: UserProfile.Dummies.profileA, color: .red)

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: EditProfilePictureDomain()
            )
        }
    }
}
