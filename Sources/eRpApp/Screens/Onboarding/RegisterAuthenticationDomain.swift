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

import Combine
import ComposableArchitecture
import eRpKit
import LocalAuthentication
import SwiftUI
import Zxcvbn

enum RegisterAuthenticationDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case comparePasswords
    }

    struct State: Equatable {
        let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var passwordA: String = ""
        var passwordB: String = ""
        var passwordStrength = PasswordStrength.none
        var showPasswordErrorMessage = false
        var passwordErrorMessage: String? {
            guard showPasswordErrorMessage, !passwordA.isEmpty else {
                return nil
            }

            guard passwordStrength.passesMinimumThreshold else {
                return NSLocalizedString("onb_auth_txt_password_strength_insufficient", comment: "")
            }

            guard !passwordB.isEmpty else {
                return nil
            }

            guard passwordA == passwordB else {
                return NSLocalizedString("onb_auth_txt_passwords_dont_match", comment: "")
            }

            return nil
        }

        var showNoSelectionMessage = false
        var securityOptionsError: AppSecurityManagerError?
        var alertState: AlertState<Action>?

        var hasValidSelection: Bool {
            guard selectedSecurityOption != nil else {
                return false
            }
            if selectedSecurityOption == .password {
                return hasValidPasswordEntries
            } else {
                return true
            }
        }

        var hasValidPasswordEntries: Bool {
            passwordA == passwordB && passwordStrength.passesMinimumThreshold
        }
    }

    enum Action: Equatable {
        case loadAvailableSecurityOptions
        case select(_ option: AppSecurityOption)
        case authenticationChallengeResponse(AppAuthenticationBiometricsDomain.AuthenticationResult)
        case alertDismissButtonTapped
        case setPasswordA(String)
        case setPasswordB(String)
        case comparePasswords
        case enterButtonTapped
        case saveSelection
        case saveSelectionSuccess
    }

    struct Environment {
        let appSecurityManager: AppSecurityManager
        let userDataStore: UserDataStore
        let schedulers: Schedulers
        let authenticationChallengeProvider: AuthenticationChallengeProvider
        let passwordStrengthTester: PasswordStrengthTester
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadAvailableSecurityOptions:
            let availableOptions = environment.appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableOptions.options
            state.securityOptionsError = availableOptions.error
            return .none
        case let .select(option):
            state.selectedSecurityOption = option
            state.showNoSelectionMessage = false
            if case .biometry = option {
                // reset password state when selecting biometry
                state.passwordA = ""
                state.passwordB = ""
                UIApplication.shared.dismissKeyboard()
                return environment
                    .authenticationChallengeProvider
                    .startAuthenticationChallenge()
                    .first()
                    .map { Action.authenticationChallengeResponse($0) }
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToEffect()
            }
            return .none
        case let .authenticationChallengeResponse(response):
            switch response {
            case .success(false):
                state.selectedSecurityOption = nil
            case let .failure(error):
                state.selectedSecurityOption = nil
                if let errorMessage = error.errorDescription {
                    state.alertState = AlertState(
                        title: TextState(L10n.alertErrorTitle),
                        message: TextState(errorMessage),
                        dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
                    )
                }
            case .success(true):
                return .none
            }
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case let .setPasswordA(string):
            state.passwordStrength = environment.passwordStrengthTester.passwordStrength(for: string)
            state.selectedSecurityOption = .password
            state.showPasswordErrorMessage = false
            state.passwordA = string
            return Effect(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)

        case let .setPasswordB(string):
            state.showPasswordErrorMessage = false
            state.passwordB = string
            return Effect(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)

        case .comparePasswords:
            if state.hasValidPasswordEntries {
                state.showPasswordErrorMessage = false
                state.showNoSelectionMessage = false
                UIApplication.shared.dismissKeyboard()
            } else {
                state.showPasswordErrorMessage = true
            }
            return .none
        case .enterButtonTapped:
            return Effect(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)
        case .saveSelection:
            guard state.hasValidSelection,
                  let selectedOption = state.selectedSecurityOption else {
                if state.selectedSecurityOption == .password {
                    state.showPasswordErrorMessage = true
                    state.showNoSelectionMessage = false
                } else {
                    state.showPasswordErrorMessage = false
                    state.showNoSelectionMessage = true
                }
                return .none
            }

            if case .password = selectedOption {
                guard let success = try? environment.appSecurityManager
                    .save(password: state.passwordA),
                    success == true else {
                    state.showNoSelectionMessage = true
                    return .none
                }
                environment.userDataStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .saveSelectionSuccess)
            } else {
                environment.userDataStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .saveSelectionSuccess)
            }
        case .saveSelectionSuccess:
            // handled by OnboardingDomain
            return .none
        }
    }

    static let reducer = Reducer.combine(
        domainReducer
    )
}

extension RegisterAuthenticationDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [.password, .biometry(.faceID)])

        static let environment = Environment(
            appSecurityManager: DummyAppSecurityManager(),
            userDataStore: DemoUserDefaultsStore(),
            schedulers: Schedulers(),
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider(),
            passwordStrengthTester: DefaultPasswordStrengthTester()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )

        static func store(with state: State) -> Store {
            Store(
                initialState: state,
                reducer: reducer,
                environment: Environment(
                    appSecurityManager: DummyAppSecurityManager(options: state.availableSecurityOptions,
                                                                error: state.securityOptionsError),
                    userDataStore: DemoUserDefaultsStore(),
                    schedulers: Schedulers(),
                    authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider(),
                    passwordStrengthTester: DefaultPasswordStrengthTester()
                )
            )
        }
    }
}
