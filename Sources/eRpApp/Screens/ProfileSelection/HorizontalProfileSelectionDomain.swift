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
import DataKit
import eRpKit
import Foundation
import IDP

enum HorizontalProfileSelectionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case loadProfiles
        case loadSelectedProfile
    }

    struct State: Equatable {
        var profiles: [UserProfile] = []
        var selectedProfileId: UUID?
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener
        case loadReceived(Result<[UserProfile], UserProfileServiceError>)
        case selectedProfileReceived(UUID)
        case selectProfile(UserProfile)
        case showAddProfileView
    }

    struct Environment {
        let schedulers: Schedulers
        let userProfileService: UserProfileService
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerListener:
            return .merge(
                environment.userProfileService.userProfilesPublisher()
                    .catchToEffect()
                    .map(Action.loadReceived)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.loadProfiles, cancelInFlight: true),
                environment.userProfileService.selectedProfileId
                    .compactMap { $0 }
                    .map(Action.selectedProfileReceived)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.loadSelectedProfile, cancelInFlight: true)
            )
        case let .loadReceived(.failure(error)):
            // Handled by parent domain
            return .none
        case let .loadReceived(.success(profiles)):
            state.profiles = profiles
            return .none
        case let .selectedProfileReceived(profileId):
            state.selectedProfileId = profileId
            return .none
        case let .selectProfile(profile):
            state.selectedProfileId = profile.id
            environment.userProfileService.set(selectedProfileId: profile.id)
            return .none
        case .showAddProfileView:
            return .none
        case .unregisterListener:
            return cleanup()
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
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

        static let environment = Environment(
            schedulers: Schedulers(),
            userProfileService: DummyUserProfileService()
        )

        static let store = Store(
            initialState: state,
            reducer: .empty,
            environment: environment
        )
    }
}
