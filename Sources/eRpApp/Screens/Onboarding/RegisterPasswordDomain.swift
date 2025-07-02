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

import Combine
import ComposableArchitecture
import eRpKit
import LocalAuthentication
import SwiftUI
import Zxcvbn

@Reducer
struct RegisterPasswordDomain {
    @ObservableState
    struct State: Equatable {
        let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
        var passwordA: String = ""
        var passwordB: String = ""
        var passwordStrength = PasswordStrength.none
        var showPasswordErrorMessage = false
        var passwordErrorMessage: String? {
            guard showPasswordErrorMessage, !passwordA.isEmpty else {
                return nil
            }

            guard passwordStrength.passesMinimumThreshold else {
                return L10n.onbAuthTxtPasswordStrengthInsufficient.text
            }

            guard !passwordB.isEmpty else {
                return nil
            }

            guard passwordA == passwordB else {
                return L10n.onbAuthTxtPasswordsDontMatch.text
            }

            return nil
        }

        var hasValidPasswordEntries: Bool {
            passwordA == passwordB && passwordStrength.passesMinimumThreshold
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case comparePasswords
        case enterButtonTapped

        enum Delegate: Equatable {
            case prevPage
            case nextPage
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.passwordStrengthTester) var passwordStrengthTester: PasswordStrengthTester

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce(core)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding(\.passwordA):
            // [REQ:BSI-eRp-ePA:O.Pass_2#3] Testing the actual password strength
            state.passwordStrength = passwordStrengthTester.passwordStrength(for: state.passwordA)
            if state.passwordA.isEmpty { return .none }
            return .run { [timeout = state.timeout] send in
                try await schedulers.main.sleep(for: timeout)
                await send(.comparePasswords)
            }
            .animation()
        case .binding(\.passwordB):
            if state.passwordB.isEmpty { return .none }
            return .run { [timeout = state.timeout] send in
                try await schedulers.main.sleep(for: timeout)
                await send(.comparePasswords)
            }
            .animation()
        case .comparePasswords:
            if state.hasValidPasswordEntries {
                // Only dismiss keyboard when verdict changes from "error" to "valid"
                // Don't dismiss keyboard when verdict was already "valid" so user can modify the password
                if state.showPasswordErrorMessage {
                    UIApplication.shared.dismissKeyboard()
                }
                state.showPasswordErrorMessage = false
            } else if state.passwordA.isEmpty, state.passwordB.isEmpty {
                state.showPasswordErrorMessage = false
            } else {
                state.showPasswordErrorMessage = true
            }
            return .none
        case .enterButtonTapped:
            return .run { [timeout = state.timeout] send in
                try await schedulers.main.sleep(for: timeout)
                await send(.comparePasswords)
            }
            .animation()
        case .delegate(.nextPage):
            UIApplication.shared.dismissKeyboard()
            // handled by OnboardingDomain
            return .none
        case .binding,
             .delegate:
            // handled by OnboardingDomain
            return .none
        }
    }
}

extension RegisterPasswordDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(
            initialState: state
        ) {
            RegisterPasswordDomain()
        }

        static func store(with state: State) -> StoreOf<RegisterPasswordDomain> {
            Store(initialState: state) {
                RegisterPasswordDomain()
            }
        }
    }
}
