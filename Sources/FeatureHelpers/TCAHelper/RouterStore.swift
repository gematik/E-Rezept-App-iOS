//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import Foundation

public enum Endpoint: Equatable, Sendable {
    case settings(SettingsScreen?)
    case scanner
    case orders
    case mainScreen(MainScreen?)
    case universalLink(URL)

    public enum MainScreen: Equatable, Sendable {
        case login
        case medicationReminder([UUID])
    }

    public enum SettingsScreen: Equatable, Sendable {
        case unlockCard
        case editProfile(EditProfileScreen)
        case medicationSchedule
    }

    public enum EditProfileScreen: Equatable, Sendable {
        case chargeItemListFor(_ profileId: UUID)
    }

    /// Checks if a URL is a supported universal link
    public static func isUniversalLinkSupported(_ url: URL) -> Bool {
        // Check if the host matches the expected domain (allowing subdomains)
        guard let host = url.host,
              host.hasSuffix("erezept.gematik.de") || host == "erezept.gematik.de" else {
            return false
        }

        // Check if the path is one of the supported paths
        switch url.path {
        case "/extauth",
             "/pharmacies/index.html",
             "/pharmacies",
             "/prescription":
            return true
        default:
            return false
        }
    }
}

public protocol Routing: AnyObject {
    func routeTo(_ endpoint: Endpoint) async
}

public class RouterStore<ContentReducer: Reducer>: Routing
    where ContentReducer.Action: Equatable, ContentReducer.State: Equatable {
    private let store: StoreOf<RouterReducer<_DependencyKeyWritingReducer<ContentReducer>>>
    public var wrappedStore: StoreOf<ContentReducer> {
        store.scope(state: \.self, action: \.action)
    }

    private let routerInstance = RouterInstance()

    public init(
        initialState: ContentReducer.State,
        reducer: ContentReducer,
        router: @escaping (Endpoint) -> Effect<ContentReducer.Action>
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

    @MainActor
    public func routeTo(_ endpoint: Endpoint) {
        let viewStore = ViewStore(store) { $0 }
        viewStore.send(.routeTo(endpoint))
    }

    private class RouterInstance: Routing {
        func routeTo(_ endpoint: Endpoint) async {
            await delegate?.routeTo(endpoint)
        }

        weak var delegate: Routing?
    }
}

/// A reducer that wraps another reducer and adds routing capabilities.
@Reducer
public struct RouterReducer<ContentReducer: Reducer>
    where ContentReducer.Action: Equatable {
    /// The state is the same as the content reducer's state.
    public typealias State = ContentReducer.State

    /// The actions are either routing actions or actions for the content reducer.
    public enum Action: Equatable {
        /// An action to route to a specific endpoint.
        case routeTo(Endpoint)
        /// An action for the content reducer.
        case action(ContentReducer.Action)
    }

    /// The content reducer to wrap.
    public let contentReducer: ContentReducer
    /// A function that takes an endpoint and returns an effect that produces actions for the content reducer.
    public let router: (Endpoint) -> Effect<ContentReducer.Action>

    /// The body of the reducer combines the content reducer and the routing logic.
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .action(action):
                return contentReducer.reduce(into: &state, action: action).map { Action.action($0) }
            case let .routeTo(route):
                return router(route).map { Action.action($0) }
            }
        }
    }
}

// sourcery: skipUnimplemented
public struct RoutingDependency: DependencyKey {
    public static let liveValue: Routing = UnimplementedRouting()

    public static let previewValue: Routing = UnimplementedRouting()

    public static let testValue: Routing = UnimplementedRouting()
}

extension DependencyValues {
    /// Access the current `Routing` implementation.
    public var router: Routing {
        get { self[RoutingDependency.self] }
        set { self[RoutingDependency.self] = newValue }
    }
}

public class DummyRouter: Routing {
    public init() {}

    public func routeTo(_: Endpoint) {}
}

class UnimplementedRouting: NSObject, Routing {
    override init() {}

    // swiftlint:disable:next unavailable_function
    func routeTo(_: Endpoint) async {
        fatalError("routeTo(_:) has not been implemented")
    }
}
