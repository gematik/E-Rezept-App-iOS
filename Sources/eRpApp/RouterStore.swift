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

import ComposableArchitecture
import Foundation

enum Endpoint: Equatable {
    case settings(SettingsScreen?)
    case scanner
    case orders
    case mainScreen(MainScreen?)
    case universalLink(URL)

    enum MainScreen: Equatable {
        case login
    }

    enum SettingsScreen: Equatable {
        case unlockCard
        case editProfile(EditProfileScreen)
    }

    enum EditProfileScreen: Equatable {
        case chargeItemListFor(_ profileId: UserProfile.ID)
    }
}

protocol Routing: AnyObject {
    func routeTo(_ endpoint: Endpoint)
}

class RouterStore<ContentReducer: ReducerProtocol>: Routing
    where ContentReducer.Action: Equatable, ContentReducer.State: Equatable {
    private let store: StoreOf<RouterReducer<_DependencyKeyWritingReducer<ContentReducer>>>
    var wrappedStore: StoreOf<ContentReducer> {
        store.scope(
            state: { $0 },
            action: RouterReducer<_DependencyKeyWritingReducer<ContentReducer>>.Action.action
        )
    }

    private let routerInstance = RouterInstance()

    init(
        initialState: ContentReducer.State,
        reducer: ContentReducer,
        router: @escaping (Endpoint) -> EffectTask<ContentReducer.Action>
    ) {
        store = Store(
            initialState: initialState
        ) { [routerInstance = routerInstance] in
            RouterReducer(
                contentReducer: reducer.dependency(\.router, routerInstance),
                router: router
            )
        }

        routerInstance.delegate = self
    }

    func routeTo(_ endpoint: Endpoint) {
        let viewStore = ViewStore(store) { $0 }
        viewStore.send(.routeTo(endpoint))
    }

    private class RouterInstance: Routing {
        func routeTo(_ endpoint: eRpApp.Endpoint) {
            delegate?.routeTo(endpoint)
        }

        weak var delegate: Routing?
    }
}

struct RouterReducer<ContentReducer: ReducerProtocol>: ReducerProtocol
    where ContentReducer.Action: Equatable {
    typealias State = ContentReducer.State

    enum Action: Equatable {
        case routeTo(Endpoint)
        case action(ContentReducer.Action)
    }

    let contentReducer: ContentReducer
    let router: (Endpoint) -> EffectTask<ContentReducer.Action>

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .action(action):
                return contentReducer.reduce(into: &state, action: action).map(Action.action)
            case let .routeTo(route):
                return router(route).map(Action.action)
            }
        }
    }
}

struct RoutingDependency: DependencyKey {
    static let liveValue: Routing = UnimplementedRouting()

    static let previewValue: Routing = UnimplementedRouting()

    static let testValue: Routing = UnimplementedRouting()
}

extension DependencyValues {
    var router: Routing {
        get { self[RoutingDependency.self] }
        set { self[RoutingDependency.self] = newValue }
    }
}

class DummyRouter: Routing {
    func routeTo(_: Endpoint) {}
}
