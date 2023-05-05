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

import ComposableArchitecture

struct ProfileSelectionToolbarItemDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
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

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService

    var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.profileSelectionState,
            action: /ProfileSelectionToolbarItemDomain.Action.profileSelection(action:)
        ) {
            ProfileSelectionDomain()
        }

        Reduce(core)
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .profileSelection:
            return .none
        case .unregisterProfileListener:
            return .cancel(id: Token.profileUpdates)
        case .registerProfileListener:
            return userProfileService.activeUserProfilePublisher()
                .catchToEffect()
                .map(Action.profileReceived)
                .cancellable(id: Token.profileUpdates, cancelInFlight: true)
                .receive(on: schedulers.main)
                .eraseToEffect()
        case .profileReceived(.failure):
            return .none
        case let .profileReceived(.success(profile)):
            state.profile = profile
            return .none
        }
    }
}

extension ProfileSelectionToolbarItemDomain {
    enum Dummies {
        static let state = State(
            profile: nil,
            profileSelectionState: .init(
                profiles: [],
                selectedProfileId: nil,
                destination: nil
            )
        )

        static let store = Store(initialState: state,
                                 reducer: EmptyReducer())
    }
}
