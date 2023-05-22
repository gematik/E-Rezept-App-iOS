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

import Combine
import ComposableArchitecture
import eRpKit
import LocalAuthentication
import SwiftUI
import Zxcvbn

struct RegisterAuthenticationDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case comparePasswords
        case continueBiometry
    }

    struct State: Equatable {
        let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var biometrySuccessful = false
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

        var showNoSelectionMessage = false
        var securityOptionsError: AppSecurityManagerError?
        var alertState: AlertState<Action>?

        var hasValidSelection: Bool {
            guard selectedSecurityOption != nil else {
                return false
            }
            if selectedSecurityOption == .password {
                return hasValidPasswordEntries
            } else if selectedSecurityOption == .biometry(.faceID) {
                return biometrySuccessful
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
        case startBiometry
        case authenticationChallengeResponse(AppAuthenticationBiometricsDomain.AuthenticationResult)
        case alertDismissButtonTapped
        case setPasswordA(String)
        case setPasswordB(String)
        case comparePasswords
        case enterButtonTapped
        case saveSelection
        case saveSelectionSuccess
        case continueBiometry
        case nextPage
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider
    @Dependency(\.passwordStrengthTester) var passwordStrengthTester: PasswordStrengthTester
    @Dependency(\.feedbackReceiver) var feedbackReceiver

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadAvailableSecurityOptions:
            let availableOptions = appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableOptions.options
            state.securityOptionsError = availableOptions.error
            if state.selectedSecurityOption == nil {
                if availableOptions.options.contains(AppSecurityOption.biometry(.faceID)) {
                    state.selectedSecurityOption = .biometry(.faceID)
                } else if availableOptions.options.contains(AppSecurityOption.biometry(.touchID)) {
                    state.selectedSecurityOption = .biometry(.touchID)
                } else {
                    state.selectedSecurityOption = .password
                }
            }
            return .none
        case let .select(option):
            state.selectedSecurityOption = option
            state.showNoSelectionMessage = false
            return .none
        case .startBiometry:
            if case .biometry = state.selectedSecurityOption {
                // reset password state when selecting biometry
                state.passwordA = ""
                state.passwordB = ""
                UIApplication.shared.dismissKeyboard()
                return authenticationChallengeProvider
                    .startAuthenticationChallenge()
                    .first()
                    .map { Action.authenticationChallengeResponse($0) }
                    .receive(on: schedulers.main.animation())
                    .eraseToEffect()
            }
            return .none
        case let .authenticationChallengeResponse(response):
            switch response {
            case .success(false):
                state.biometrySuccessful = false
            case let .failure(error):
                state.biometrySuccessful = false
                if let errorMessage = error.errorDescription {
                    state.alertState = AlertState(
                        title: TextState(L10n.alertErrorTitle),
                        message: TextState(errorMessage),
                        dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
                    )
                }
            case .success(true):
                state.biometrySuccessful = true
                feedbackReceiver.hapticFeedbackSuccess()
                switch state.selectedSecurityOption {
                case .biometry:
                    return EffectTask(value: .continueBiometry)
                        .delay(for: state.timeout, scheduler: schedulers.main.animation())
                        .eraseToEffect()
                        .cancellable(id: Token.continueBiometry, cancelInFlight: true)
                default:
                    return .none
                }
            }
            return .none
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case let .setPasswordA(string):
            guard string != state.passwordA else {
                return .none
            }
            state.passwordStrength = passwordStrengthTester.passwordStrength(for: string)
            state.showPasswordErrorMessage = false
            state.passwordA = string
            return EffectTask(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.comparePasswords, cancelInFlight: true)

        case let .setPasswordB(string):
            guard string != state.passwordB else {
                return .none
            }
            state.showPasswordErrorMessage = false
            state.passwordB = string
            return EffectTask(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: schedulers.main.animation())
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
            return EffectTask(value: .comparePasswords)
                .delay(for: state.timeout, scheduler: schedulers.main.animation())
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
                guard let success = try? appSecurityManager
                    .save(password: state.passwordA),
                    success == true else {
                    state.showNoSelectionMessage = true
                    return .none
                }
                userDataStore.set(appSecurityOption: selectedOption)
                return EffectTask(value: .saveSelectionSuccess)
            } else {
                userDataStore.set(appSecurityOption: selectedOption)
                return EffectTask(value: .saveSelectionSuccess)
            }
        case .saveSelectionSuccess,
             .continueBiometry,
             .nextPage:
            // handled by OnboardingDomain
            return .none
        }
    }
}

extension RegisterAuthenticationDomain {
    enum Dummies {
        static let state = State(
            availableSecurityOptions: [.password, .biometry(.faceID)],
            selectedSecurityOption: .biometry(.faceID)
        )

        static let store = Store(
            initialState: state,
            reducer: RegisterAuthenticationDomain()
        )

        static func store(with state: State) -> Store {
            Store(
                initialState: state,
                reducer: RegisterAuthenticationDomain()
            )
        }
    }
}
