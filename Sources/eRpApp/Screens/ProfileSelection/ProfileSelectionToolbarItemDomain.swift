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

import ComposableArchitecture

enum ProfileSelectionToolbarItemDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case profileUpdates
    }

    enum Action: Equatable {
        case profileSelection(action: ProfileSelectionDomain.Action)

        case registerProfileListener
        case unregisterProfileListener
        case profileReceived(Result<UserProfile, UserProfileServiceError>)
    }

    struct State: Equatable {
        var profile: UserProfile?
        var profileSelectionState: ProfileSelectionDomain.State = .init()
    }

    typealias Environment = ProfileSelectionDomain.Environment

    static let reducer: Reducer = .combine(
        profileSelectionReducer,
        domainReducer
    )

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .profileSelection:
            return .none
        case .unregisterProfileListener:
            return .cancel(id: Token.profileUpdates)
        case .registerProfileListener:
            return environment.userProfileService.activeUserProfilePublisher()
                .catchToEffect()
                .map(Action.profileReceived)
                .cancellable(id: Token.profileUpdates, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .profileReceived(.failure(error)):
            return .none
        case let .profileReceived(.success(profile)):
            state.profile = profile
            return .none
        }
    }

    private static let profileSelectionReducer: Reducer =
        ProfileSelectionDomain.reducer.pullback(
            state: \.profileSelectionState,
            action: /ProfileSelectionToolbarItemDomain.Action.profileSelection(action:)
        ) {
            $0
        }
}

extension ProfileSelectionToolbarItemDomain {
    enum Dummies {
        static let state = State(
            profile: nil,
            profileSelectionState: .init(
                profiles: [],
                selectedProfileId: nil,
                route: nil
            )
        )

        static let environment = ProfileSelectionDomain.Dummies.environment

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
