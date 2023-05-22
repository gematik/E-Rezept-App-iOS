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

struct CardWallExtAuthSelectionDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
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
        var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardWall_extAuthConfirm
            case confirmation(CardWallExtAuthConfirmationDomain.State)
            // sourcery: AnalyticsScreen = contactInsuranceCompany
            case egk(OrderHealthCardDomain.State)
        }

        enum Action: Equatable {
            case egkAction(action: OrderHealthCardDomain.Action)
            case confirmation(action: CardWallExtAuthConfirmationDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.confirmation,
                action: /Action.confirmation
            ) {
                CardWallExtAuthConfirmationDomain()
            }

            Scope(
                state: /State.egk,
                action: /Action.egkAction(action:)
            ) {
                OrderHealthCardDomain()
            }
        }
    }

    enum Action: Equatable {
        case loadKKList
        case selectKK(KKAppDirectory.Entry)
        case confirmKK
        case error(IDPError)
        case updateSearchText(newString: String)

        case filteredKKList(search: String)
        case reset

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            case loadKKList(Result<KKAppDirectory, IDPError>)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.idpSession) var idpSession: IDPSession
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadKKList:
            state.error = nil
            state.selectedKK = nil
            // [REQ:gemSpec_IDP_Sek:A_22296] Load available apps
            return idpSession.loadDirectoryKKApps()
                .first()
                .catchToEffect()
                .map { Action.response(.loadKKList($0)) }
                .receive(on: schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.loadKKList)
        case let .response(.loadKKList(.success(result))):
            state.error = nil
            state.kkList = result
            return .none
        case let .response(.loadKKList(.failure(error))):
            state.error = error
            return .none
        case let .selectKK(entry):
            // [REQ:gemSpec_IDP_Sek:A_22294] Select KK
            state.selectedKK = entry
            return .none
        case .confirmKK:
            guard let selectedKK = state.selectedKK else { return .none }

            state.destination = .confirmation(.init(selectedKK: selectedKK))
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
                .isEmpty ? EffectTask(value: .reset) : EffectTask(value: .filteredKKList(search: state.searchText))
        case .setNavigation(tag: nil),
             .destination(.egkAction(action: .delegate(.close))):
            state.destination = nil
            return .none
        case let .error(error):
            state.error = error
            return .none
        case .destination(.confirmation(action: .delegate(.close))):
            return EffectTask(value: .delegate(.close))
        case .setNavigation(tag: .egk):
            state.destination = .egk(.init())
            return .none
        case .setNavigation:
            return .none
        case .destination,
             .delegate:
            return .none // Handled by parent domain
        }
    }
}

extension KKAppDirectory.Entry: Identifiable {
    public var id: String {
        identifier
    }
}

extension CardWallExtAuthSelectionDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(initialState: state, reducer: CardWallExtAuthSelectionDomain())
    }
}
