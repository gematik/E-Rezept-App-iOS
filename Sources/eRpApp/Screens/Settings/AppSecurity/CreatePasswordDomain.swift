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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import Zxcvbn

struct CreatePasswordDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    enum CancelID: CaseIterable, Hashable {
        case comparePasswords
    }

    struct State: Equatable {
        let mode: Mode
        var password: String = ""

        var passwordA: String = ""
        var passwordB: String = ""
        var passwordStrength = PasswordStrength.none
        var showPasswordErrorMessage = false
        var passwordErrorMessage: String? {
            guard showPasswordErrorMessage, !passwordA.isEmpty else {
                return nil
            }

            guard passwordStrength.passesMinimumThreshold else {
                return L10n.cpwTxtPasswordStrengthInsufficient.text
            }

            guard !passwordB.isEmpty else {
                return nil
            }

            guard passwordA == passwordB else {
                return L10n.onbAuthTxtPasswordsDontMatch.text
            }

            return nil
        }

        var showOriginalPasswordWrong = false

        var hasValidPasswordEntries: Bool {
            passwordA == passwordB && passwordStrength.passesMinimumThreshold
        }

        enum Mode {
            case create
            case update
        }
    }

    enum Action: Equatable {
        enum Delegate: Equatable {
            case closeAfterPasswordSaved
        }

        case setCurrentPassword(String)
        case setPasswordA(String)
        case setPasswordB(String)
        case comparePasswords
        case saveButtonTapped
        case enterButtonTapped

        case delegate(Delegate)
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.passwordStrengthTester) var passwordStrengthTester: PasswordStrengthTester
    @Dependency(\.userDataStore) var userDataStore: UserDataStore

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setCurrentPassword(string):
            state.password = string
            state.showOriginalPasswordWrong = false
            return .none
        case let .setPasswordA(string):
            state.passwordStrength = passwordStrengthTester.passwordStrength(for: string)
            state.passwordA = string
            return .run { send in
                try await schedulers.main.sleep(for: Self.timeout)
                await send(.comparePasswords)
            }
            .animation(.default)
            .cancellable(id: CancelID.comparePasswords, cancelInFlight: true)

        case let .setPasswordB(string):
            state.passwordB = string
            return .run { send in
                try await schedulers.main.sleep(for: Self.timeout)
                await send(.comparePasswords)
            }
            .animation(.default)
            .cancellable(id: CancelID.comparePasswords, cancelInFlight: true)

        case .comparePasswords:
            if !state.passwordA.isEmpty {
                state.showPasswordErrorMessage = true
            } else {
                state.showPasswordErrorMessage = false
            }
            return .none

        case .enterButtonTapped:
            return .run { send in
                try await schedulers.main.animation().sleep(for: Self.timeout)
                await send(.comparePasswords)
            }
            .animation(.default)
            .cancellable(id: CancelID.comparePasswords, cancelInFlight: true)

        case .saveButtonTapped:
            guard state.hasValidPasswordEntries else {
                if !state.passwordA.isEmpty {
                    state.showPasswordErrorMessage = true
                }
                return .none
            }

            guard state.mode == .create ||
                (try? appSecurityManager.matches(password: state.password)) ?? false else {
                state.showOriginalPasswordWrong = true
                return .none
            }
            state.showOriginalPasswordWrong = false

            guard !state.passwordA.isEmpty,
                  state.hasValidPasswordEntries,
                  let success = try? appSecurityManager.save(password: state.passwordA),
                  success == true else {
                return .cancel(id: CancelID.comparePasswords)
            }

            return .concatenate(
                .cancel(id: CancelID.comparePasswords),
                EffectTask.send(.delegate(.closeAfterPasswordSaved))
            )

        case .delegate:
            return .none
        }
    }

    private static let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
}

extension CreatePasswordDomain {
    enum Dummies {
        static let state = State(mode: .update)

        static let store = Store(
            initialState: state
        ) {
            CreatePasswordDomain()
        }
    }
}
