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

struct CreateProfileDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case createAndSave
    }

    struct State: Equatable {
        var profileName: String = ""

        var isValidName: Bool {
            !profileName.trimmed().isEmpty
        }
    }

    enum Action: Equatable {
        case set(profileName: String)

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

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .set(profileName):
            state.profileName = profileName
            return .none

        case let .createAndSaveProfile(name):
            let displayName = name.trimmed()
            guard state.isValidName else { return .none }
            return createAndSaveProfile(name: displayName)

        case let .createAndSaveProfileReceived(.success(profileId)):
            userProfileService.set(selectedProfileId: profileId)
            return .init(value: .delegate(.close))
        case let .createAndSaveProfileReceived(.failure(error)):
            return .init(value: .delegate(.failure(error)))

        case .delegate:
            return .none
        }
    }
}

extension CreateProfileDomain {
    func createAndSaveProfile(name: String) -> Effect<CreateProfileDomain.Action, Never> {
        let profile = Profile(name: name)
        return userProfileService
            .save(profiles: [profile])
            .first()
            .catchToEffect()
            // Proceed regardless whether `Result` is .success(true) or .success(false)
            .map { $0.map { _ in profile.id } }
            .cancellable(id: CreateProfileDomain.Token.createAndSave)
            .map { .createAndSaveProfileReceived($0) }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension CreateProfileDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: CreateProfileDomain()
        )

        static let state = State()

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: CreateProfileDomain()
            )
        }
    }
}
