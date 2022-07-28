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
import eRpKit

enum OnboardingNewProfileDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var name: String
        var alertState: AlertState<Action>?

        var hasValidName: Bool {
            !name.isEmpty
        }
    }

    enum Action: Equatable {
        case setName(String)
        case dismissAlert
    }

    struct Environment {}

    static let domainReducer = Reducer { state, action, _ in
        switch action {
        case let .setName(name):
            state.name = name.trimmed()
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension OnboardingNewProfileDomain {
    enum AlertStates {
        typealias Action = OnboardingNewProfileDomain.Action

        static var emptyName = AlertState<Action>(
            title: TextState(L10n.onbPrfTxtAlertTitle),
            message: TextState(L10n.onbPrfTxtAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk))
        )

        static func `for`(_ error: LocalStoreError) -> AlertState<Action> {
            AlertState(
                title: TextState(L10n.onbPrfTxtAlertTitle),
                message: TextState(error.localizedDescriptionWithErrorList),
                dismissButton: .default(TextState(L10n.alertBtnOk))
            )
        }
    }
}

extension OnboardingNewProfileDomain {
    enum Dummies {
        static let state = State(name: "")
        static let environment = Environment()
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)

        static func store(with state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: Environment())
        }
    }
}
