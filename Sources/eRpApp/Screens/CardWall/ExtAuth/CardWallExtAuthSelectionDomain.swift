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
import IDP
import UIKit

enum CardWallExtAuthSelectionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Route: Equatable {
        // sourcery: AnalyticsScreen = cardWallExtAuthConfirm
        case confirmation(CardWallExtAuthConfirmationDomain.State?)
        case egk(OrderHealthCardDomain.State)
    }

    enum Token: CaseIterable, Hashable {
        case loadKKList
    }

    struct State: Equatable {
        var kkList: KKAppDirectory?
        var filteredKKList: KKAppDirectory = .init(apps: [KKAppDirectory.Entry]())
        var error: IDPError?
        var selectedKK: KKAppDirectory.Entry?
        var searchText: String = ""

        var orderEgkVisible = false
        var route: Route?
    }

    enum Action: Equatable {
        case loadKKList
        case loadKKListReceived(Result<KKAppDirectory, IDPError>)
        case selectKK(KKAppDirectory.Entry)
        case confirmKK
        case error(IDPError)
        case close
        case updateSearchText(newString: String)
        case setNavigation(tag: Route.Tag?)
        case egkAction(action: OrderHealthCardDomain.Action)
        case confirmation(action: CardWallExtAuthConfirmationDomain.Action)
        case filteredKKList(search: String)
        case reset
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadKKList:
            state.error = nil
            state.selectedKK = nil
            // [REQ:gemSpec_IDP_Sek:A_22296] Load available apps
            return environment.idpSession.loadDirectoryKKApps()
                .first()
                .catchToEffect()
                .map(Action.loadKKListReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.loadKKList)
        case let .loadKKListReceived(.success(result)):
            state.error = nil
            state.kkList = result
            return .none
        case let .loadKKListReceived(.failure(error)):
            state.error = error
            return .none
        case let .selectKK(entry):
            // [REQ:gemSpec_IDP_Sek:A_22294] Select KK
            state.selectedKK = entry
            return .none
        case .confirmKK:
            guard let selectedKK = state.selectedKK else { return .none }

            state.route = .confirmation(.init(selectedKK: selectedKK))
            return .none
        case let .filteredKKList(search):
            if let kkList = state.kkList {
                state
                    .filteredKKList = KKAppDirectory(apps: kkList.apps
                        .filter { $0.name.lowercased().contains(search.lowercased()) })
            }
            return .none
        case .reset:
            state.filteredKKList = state.kkList ?? .init(apps: [KKAppDirectory.Entry]())
            return .none
        case let .updateSearchText(newString):
            state.searchText = newString.trimmed()
            return state.searchText
                .isEmpty ? Effect(value: .reset) : Effect(value: .filteredKKList(search: state.searchText))
        case .setNavigation(tag: nil),
             .egkAction(action: .close):
            state.route = nil
            return .none
        case let .error(error):
            state.error = error
            return .none
        case .confirmation(.close):
            return Effect(value: .close)
        case .setNavigation(tag: .egk):
            state.route = .egk(.init())
            return .none
        case .setNavigation:
            return .none
        case .close,
             .confirmation,
             .egkAction:
            return .none // Handled by parent domain
        }
    }

    static let reducer: Reducer = .combine(
        confirmationPullback,
        orderHealthCardPullbackReducer,
        domainReducer
    )

    private static let confirmationPullback: Reducer =
        CardWallExtAuthConfirmationDomain.reducer
            ._pullback(
                state: (\State.route).appending(path: /Route.confirmation),
                action: /Action.confirmation(action:)
            ) {
                .init(idpSession: $0.idpSession,
                      schedulers: $0.schedulers,
                      canOpenURL: UIApplication.shared.canOpenURL,
                      openURL: UIApplication.shared.open)
            }

    static let orderHealthCardPullbackReducer: Reducer =
        OrderHealthCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.egk),
            action: /Action.egkAction(action:)
        ) { _ in OrderHealthCardDomain.Environment() }
}

extension KKAppDirectory.Entry: Identifiable {
    public var id: String {
        identifier
    }
}

extension CardWallExtAuthSelectionDomain {
    enum Dummies {
        static let state = State()
        static let environment = Environment(idpSession: DemoIDPSession(storage: MemoryStorage()),
                                             schedulers: Schedulers())

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
