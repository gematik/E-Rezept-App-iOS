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

import ComposableArchitecture
import Foundation

enum CreatePasswordDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Token: CaseIterable, Hashable {
        case comparePasswords
    }

    struct State: Equatable {
        let mode: Mode
        var password: String = ""

        var passwordA: String = ""
        var passwordB: String = ""
        var showPasswordsNotEqualMessage = false
        var showOriginalPasswordWrong = false

        var hasValidPasswordEntries: Bool {
            passwordA == passwordB && passwordA.lengthOfBytes(using: .utf8) > 0
        }

        enum Mode {
            case create
            case update
        }
    }

    enum Action: Equatable {
        case setCurrentPassword(String)
        case setPasswordA(String)
        case setPasswordB(String)
        case comparePasswords
        case saveButtonTapped
        case closeAfterPasswordSaved
    }

    struct Environment {
        let passwordManager: AppSecurityManager
        let schedulers: Schedulers
    }

    static let reducer: Reducer = .init { state, action, environment in
        switch action {
        case let .setCurrentPassword(string):
            state.password = string
            state.showOriginalPasswordWrong = false
            return .none
        case let .setPasswordA(string):
            state.passwordA = string
            return Effect(value: .comparePasswords)
                .delay(for: timeout, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)

        case let .setPasswordB(string):
            state.passwordB = string
            return Effect(value: .comparePasswords)
                .delay(for: timeout, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)

        case .comparePasswords:
            if !state.passwordA.isEmpty, !state.passwordB.isEmpty {
                state.showPasswordsNotEqualMessage = state.passwordA != state.passwordB
            } else {
                state.showPasswordsNotEqualMessage = false
            }
            return .none

        case .saveButtonTapped:
            state.showPasswordsNotEqualMessage = state.passwordA != state.passwordB
            guard state.mode == .create ||
                (try? environment.passwordManager.matches(password: state.password)) ?? false else {
                state.showOriginalPasswordWrong = true
                return .none
            }
            state.showOriginalPasswordWrong = false

            guard !state.passwordA.isEmpty,
                  state.hasValidPasswordEntries,
                  let success = try? environment.passwordManager.save(password: state.passwordA),
                  success == true else {
                return Effect.cancel(id: Token.comparePasswords)
            }
            return Effect.concatenate(
                Effect.cancel(id: Token.comparePasswords),
                Effect(value: .closeAfterPasswordSaved)
            )
        case .closeAfterPasswordSaved:
            return .none
        }
    }

    private static let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
}

extension CreatePasswordDomain {
    enum Dummies {
        static let state = State(mode: .update)

        static let environment = Environment(
            passwordManager: DummyAppSecurityManager(),
            schedulers: Schedulers()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
