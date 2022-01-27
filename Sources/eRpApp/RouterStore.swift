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
import Foundation

enum Endpoint: Equatable {
    case settings
    case scanner
    case messages
    case mainScreen(MainScreen?)
    case universalLink(URL)

    enum MainScreen: Equatable {
        case login
    }
}

protocol Routing {
    func routeTo(_ endpoint: Endpoint)
}

class RouterStore<State: Equatable, Action: Equatable, Environment> {
    private let store: Store<State, RoutingAction<Action, Endpoint>>
    var wrappedStore: Store<State, Action> {
        store.scope(state: { (state: State) -> State in state },
                    action: { localAction in RoutingAction.action(localAction) })
    }

    init(
        initialState: State,
        reducer: Reducer<State, Action, Environment>,
        environment: Environment,
        router: @escaping (Endpoint) -> Effect<Action, Never>

    ) {
        store = Store(initialState: initialState,
                      reducer: reducer.routed(by: router),
                      environment: environment)
    }

    func route(to endpoint: Endpoint) {
        let viewStore = ViewStore(store)
        viewStore.send(.routeTo(endpoint))
    }
}

private enum RoutingAction<Action: Equatable, Endpoint: Equatable>: Equatable {
    case routeTo(Endpoint)
    case action(Action)
}

extension Reducer where Action: Equatable {
    fileprivate func routed<Endpoint: Equatable>( // swiftlint:disable:this strict_fileprivate
        by router: @escaping (Endpoint) -> Effect<Action, Never>
    ) -> Reducer<State, RoutingAction<Action, Endpoint>, Environment> {
        .init { state, action, environment in
            switch action {
            case let .action(action):
                return self.run(&state, action, environment).map(RoutingAction.action)
            case let .routeTo(route):
                return router(route).map(RoutingAction.action)
            }
        }
    }
}

class DummyRouter: Routing {
    func routeTo(_: Endpoint) {}
}
