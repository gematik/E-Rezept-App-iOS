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
import SwiftUI

@Reducer
struct EditProfileNameDomain {
    typealias Store = StoreOf<Self>

    @ObservableState
    struct State: Equatable {
        var profileName: String
        var profileId: UUID
    }

    enum Action: Equatable {
        case setProfileName(String)
        case saveEditedProfileName(name: String)
        case saveEditedProfileNameReceived(Result<Bool, UserProfileServiceError>)
        case saveButtonTapped
        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setProfileName(profileName):
            state.profileName = profileName
            return .none
        case .saveButtonTapped:
            return Effect.send(.saveEditedProfileName(name: state.profileName))
        case let .saveEditedProfileName(name):
            let name = name.trimmed()
            if name.lengthOfBytes(using: .utf8) > 0 {
                return updateProfile(with: state.profileId, name: state.profileName)
                    .map(Action.saveEditedProfileNameReceived)
            }
            return .send(.delegate(.close))
        case .saveEditedProfileNameReceived(.success):
            return .send(.delegate(.close))
        case let .saveEditedProfileNameReceived(.failure(error)):
            return .send(.delegate(.failure(error)))
        case .delegate:
            return .none
        }
    }
}

extension EditProfileNameDomain {
    func updateProfile(
        with profileId: UUID,
        name: String
    ) -> Effect<Result<Bool, UserProfileServiceError>> {
        .publisher(
            userProfileService
                .update(profileId: profileId, mutating: ({ profile in profile.name = name }))
                .receive(on: schedulers.main)
                .catchToPublisher()
                .eraseToAnyPublisher
        )
    }
}

extension EditProfileNameDomain {
    enum Dummies {
        static let store = Store(initialState: Dummies.state) {
            EditProfileNameDomain()
        }

        static let state = State(profileName: "Lazy Niklas", profileId: UUID())

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state) {
                EditProfileNameDomain()
            }
        }
    }
}
