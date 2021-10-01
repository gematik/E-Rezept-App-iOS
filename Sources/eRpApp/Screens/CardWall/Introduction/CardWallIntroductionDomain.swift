//
//  Copyright (c) 2021 gematik GmbH
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

enum CardWallIntroductionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var showNextScreen = false
        var isEGKOrderInfoViewPresented = false
    }

    enum Action: Equatable {
        case advance(forward: Bool)
        case showEGKOrderInfoView
        case dismissEGKOrderInfoView
        case close
    }

    struct Environment {
        let userSession: UserSession
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case let .advance(forward):
            state.showNextScreen = forward
            if forward {
                environment.userSession.localUserStore.set(hideCardWallIntro: true)
            }
            return .none
        case .close:
            return .none
        case .showEGKOrderInfoView:
            state.isEGKOrderInfoViewPresented = true
            return .none
        case .dismissEGKOrderInfoView:
            state.isEGKOrderInfoViewPresented = false
            return .none
        }
    }
}

extension CardWallIntroductionDomain {
    enum Dummies {
        static let state = State()
        static let environment = Environment(userSession: DemoSessionContainer())

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
