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
struct CreateProfileDomain {
    typealias Store = StoreOf<Self>

    @ObservableState
    struct State: Equatable {
        var profileName: String = ""

        var isValidName: Bool {
            !profileName.trimmed().isEmpty
        }
    }

    enum Action: Equatable {
        case setProfileName(String)

        case createAndSaveProfile(name: String)
        case createAndSaveProfileReceived(Result<UUID, UserProfileServiceError>)

        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case close
        case failure(UserProfileServiceError)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setProfileName(profileName):
                state.profileName = profileName
                return .none

            case let .createAndSaveProfile(name):
                let displayName = name.trimmed()
                guard state.isValidName else { return .none }
                return createAndSaveProfile(name: displayName)

            case let .createAndSaveProfileReceived(.success(profileId)):
                userProfileService.set(selectedProfileId: profileId)
                return .send(.delegate(.close))
            case let .createAndSaveProfileReceived(.failure(error)):
                return .send(.delegate(.failure(error)))

            case .delegate:
                return .none
            }
        }
    }
}

extension CreateProfileDomain {
    func createAndSaveProfile(name: String) -> Effect<CreateProfileDomain.Action> {
        let profile = Profile(name: name)
        return .publisher(
            userProfileService
                .save(profiles: [profile])
                .first()
                .catchToPublisher()
                // Proceed regardless whether `Result` is .success(true) or .success(false)
                .map { $0.map { _ in profile.id } }
                .map { .createAndSaveProfileReceived($0) }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
    }
}

extension CreateProfileDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state
        ) {
            CreateProfileDomain()
        }

        static let state = State()

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state) {
                CreateProfileDomain()
            }
        }
    }
}
