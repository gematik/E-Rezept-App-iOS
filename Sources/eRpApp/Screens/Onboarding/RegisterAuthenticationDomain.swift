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
import LocalAuthentication
import SwiftUI
import Zxcvbn

@Reducer
struct RegisterAuthenticationDomain {
    @ObservableState
    struct State: Equatable {
        let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption = .unsecured
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
        @Presents var alertState: AlertState<Action.Alert>?

        var hasValidSelection: Bool {
            guard selectedSecurityOption != .unsecured else {
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

        var hasPasswordOption: Bool {
            availableSecurityOptions.contains(AppSecurityOption.password)
        }

        var hasFaceIdOption: Bool {
            availableSecurityOptions.contains(AppSecurityOption.biometry(.faceID))
        }

        var hasTouchIdOption: Bool {
            availableSecurityOptions.contains(AppSecurityOption.biometry(.touchID))
        }
    }

    enum Action: BindableAction, Equatable {
        case loadAvailableSecurityOptions
        case startBiometry
        case authenticationChallengeResponse(AuthenticationChallengeProviderResult)

        case binding(BindingAction<State>)

        case comparePasswords
        case enterButtonTapped
        case saveSelection
        case saveSelectionSuccess
        case continueBiometry
        case nextPage
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {}
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider
    @Dependency(\.passwordStrengthTester) var passwordStrengthTester: PasswordStrengthTester
    @Dependency(\.feedbackReceiver) var feedbackReceiver

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .loadAvailableSecurityOptions:
                let availableOptions = appSecurityManager.availableSecurityOptions
                state.availableSecurityOptions = availableOptions.options
                state.securityOptionsError = availableOptions.error
                if state.selectedSecurityOption == .unsecured {
                    if availableOptions.options.contains(AppSecurityOption.biometry(.faceID)) {
                        state.selectedSecurityOption = .biometry(.faceID)
                    } else if availableOptions.options.contains(AppSecurityOption.biometry(.touchID)) {
                        state.selectedSecurityOption = .biometry(.touchID)
                    } else {
                        state.selectedSecurityOption = .password
                    }
                }
                return .none
            case .binding(\.selectedSecurityOption):
                state.showNoSelectionMessage = state.selectedSecurityOption == .unsecured
                return .none
            case .startBiometry:
                if case .biometry = state.selectedSecurityOption {
                    // reset password state when selecting biometry
                    state.passwordA = ""
                    state.passwordB = ""
                    UIApplication.shared.dismissKeyboard()
                    return .publisher(
                        authenticationChallengeProvider
                            .startAuthenticationChallenge()
                            .first()
                            .map { Action.authenticationChallengeResponse($0) }
                            .receive(on: schedulers.main.animation())
                            .eraseToAnyPublisher
                    )
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
                            title: { TextState(L10n.alertErrorTitle) },
                            actions: {
                                ButtonState(role: .cancel, action: .send(.none)) {
                                    TextState(L10n.alertBtnOk)
                                }
                            },
                            message: { TextState(errorMessage) }
                        )
                    }
                case .success(true):
                    state.biometrySuccessful = true
                    feedbackReceiver.hapticFeedbackSuccess()
                    switch state.selectedSecurityOption {
                    case .biometry:
                        return .run { [timeout = state.timeout] send in
                            try await schedulers.main.sleep(for: timeout)
                            await send(.continueBiometry)
                        }
                        .animation()
                    default:
                        return .none
                    }
                }
                return .none
            case .binding(\.passwordA):
                // [REQ:BSI-eRp-ePA:O.Pass_2#3] Testing the acutal password strength
                state.passwordStrength = passwordStrengthTester.passwordStrength(for: state.passwordA)
                state.showPasswordErrorMessage = false
                return .run { [timeout = state.timeout] send in
                    try await schedulers.main.sleep(for: timeout)
                    await send(.comparePasswords)
                }
                .animation()
            case .binding(\.passwordB):
                state.showPasswordErrorMessage = false
                return .run { [timeout = state.timeout] send in
                    try await schedulers.main.sleep(for: timeout)
                    await send(.comparePasswords)
                }
                .animation()
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
                return .run { [timeout = state.timeout] send in
                    try await schedulers.main.sleep(for: timeout)
                    await send(.comparePasswords)
                }
                .animation()
            case .saveSelection:
                guard state.hasValidSelection,
                      state.selectedSecurityOption != .unsecured else {
                    if state.selectedSecurityOption == .password {
                        state.showPasswordErrorMessage = true
                        state.showNoSelectionMessage = false
                    } else {
                        state.showPasswordErrorMessage = false
                        state.showNoSelectionMessage = true
                    }
                    return .none
                }

                if case .password = state.selectedSecurityOption {
                    guard let success = try? appSecurityManager
                        .save(password: state.passwordA),
                        success == true else {
                        state.showNoSelectionMessage = true
                        return .none
                    }
                    userDataStore.set(appSecurityOption: state.selectedSecurityOption)
                    return Effect.send(.saveSelectionSuccess)
                } else {
                    userDataStore.set(appSecurityOption: state.selectedSecurityOption)
                    return Effect.send(.saveSelectionSuccess)
                }
            case .saveSelectionSuccess,
                 .continueBiometry,
                 .nextPage,
                 .binding,
                 .alert:
                // handled by OnboardingDomain
                return .none
            }
        }.ifLet(\.$alertState, action: \.alert)
    }
}

extension RegisterAuthenticationDomain {
    enum Dummies {
        static let state = State(
            availableSecurityOptions: [.password, .biometry(.faceID)],
            selectedSecurityOption: .biometry(.faceID)
        )

        static let store = Store(
            initialState: state
        ) {
            RegisterAuthenticationDomain()
        }

        static func store(with state: State) -> StoreOf<RegisterAuthenticationDomain> {
            Store(initialState: state) {
                RegisterAuthenticationDomain()
            }
        }
    }
}
