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

// [REQ:BSI-eRp-ePA:O.Auth_7#2] Domain handling App Authentication
@Reducer
struct AppAuthenticationPasswordDomain {
    @ObservableState
    struct State: Equatable {
        var password: String = ""
        var lastMatchResultSuccessful: Bool?
    }

    enum Action: Equatable {
        case setPassword(String)
        case loginButtonTapped
        case passwordVerificationReceived(Bool)
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setPassword(password):
            state.password = password
            return .none

        case .loginButtonTapped:
            guard let success = try? appSecurityManager.matches(password: state.password) else {
                return Effect.send(.passwordVerificationReceived(false))
            }
            return Effect.send(.passwordVerificationReceived(success))

        case let .passwordVerificationReceived(isLoggedIn):
            state.lastMatchResultSuccessful = isLoggedIn
            return .none
        }
    }
}

extension AppAuthenticationPasswordDomain {
    enum Dummies {
        static let state = State()

        static let store = StoreOf<AppAuthenticationPasswordDomain>(initialState: state) {
            AppAuthenticationPasswordDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<AppAuthenticationPasswordDomain> {
            Store(
                initialState: state
            ) {
                AppAuthenticationPasswordDomain()
            }
        }
    }
}
