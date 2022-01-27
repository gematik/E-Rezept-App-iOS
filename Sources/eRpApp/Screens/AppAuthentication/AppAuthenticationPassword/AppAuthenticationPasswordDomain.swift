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

enum AppAuthenticationPasswordDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var password: String = ""
        var lastMatchResultSuccessful: Bool?
    }

    enum Action: Equatable {
        case setPassword(String)
        case loginButtonTapped
        case passwordVerificationReceived(Bool)
    }

    struct Environment {
        let appSecurityPasswordManager: AppSecurityManager
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .setPassword(password):
            state.password = password
            return .none

        case .loginButtonTapped:
            guard let success = try? environment.appSecurityPasswordManager.matches(password: state.password) else {
                return Effect(value: .passwordVerificationReceived(false))
            }
            return Effect(value: .passwordVerificationReceived(success))

        case let .passwordVerificationReceived(isLoggedIn):
            state.lastMatchResultSuccessful = isLoggedIn
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension AppAuthenticationPasswordDomain {
    enum Dummies {
        static let state = State()

        static let environment = Environment(
            appSecurityPasswordManager: DummyAppSecurityManager()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: reducer,
                environment: environment
            )
        }
    }
}
