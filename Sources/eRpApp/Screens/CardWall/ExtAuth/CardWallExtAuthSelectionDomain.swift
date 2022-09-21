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
import IDP
import UIKit

enum CardWallExtAuthSelectionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var kkList: KKAppDirectory?
        var error: IDPError?
        var selectedKK: KKAppDirectory.Entry?

        var orderEgkVisible = false
        var confirmation: CardWallExtAuthConfirmationDomain.State?
    }

    enum Action: Equatable {
        case loadKKList
        case loadKKListReceived(Result<KKAppDirectory, IDPError>)
        case selectKK(KKAppDirectory.Entry)
        case confirmKK
        case error(IDPError)
        case close

        case showOrderEgk(Bool)
        case hideConfirmation

        case confirmation(_ action: CardWallExtAuthConfirmationDomain.Action)
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .showOrderEgk(show):
            state.orderEgkVisible = show
            return .none
        case .loadKKList:
            state.error = nil
            state.selectedKK = nil
            // [REQ:gemSpec_IDP_Sek:A_22296] Load available apps
            return environment.idpSession.loadDirectoryKKApps()
                .catchToEffect()
                .map(Action.loadKKListReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
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

            state.confirmation = CardWallExtAuthConfirmationDomain.State(selectedKK: selectedKK,
                                                                         error: nil)
            return .none
        case .hideConfirmation:
            state.confirmation = nil
            return .none
        case let .error(error):
            state.error = error
            return .none
        case .confirmation(.close):
            return Effect(value: .close)
        case .close,
             .confirmation:
            return .none // Handled by parent domain
        }
    }

    static let reducer: Reducer = .combine(
        confirmationPullback,
        domainReducer
    )

    private static let confirmationPullback: Reducer =
        CardWallExtAuthConfirmationDomain.reducer
            .optional()
            .pullback(state: \.confirmation,
                      action: /Action.confirmation) {
                .init(idpSession: $0.idpSession,
                      schedulers: $0.schedulers,
                      canOpenURL: UIApplication.shared.canOpenURL,
                      openURL: UIApplication.shared.open)
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
        static let environment = Environment(idpSession: DemoIDPSession(storage: MemoryStorage()),
                                             schedulers: Schedulers())

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
