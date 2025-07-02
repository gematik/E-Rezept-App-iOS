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
struct RegisterAuthenticationDomain {
    @ObservableState
    struct State: Equatable {
        let timeout: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.5)
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption = .unsecured
        var securityOptionsError: AppSecurityManagerError?

        @Presents var alertState: AlertState<Action.Alert>?

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

    enum Action: Equatable {
        case loadAvailableSecurityOptions
        case startBiometry(AppSecurityOption)
        case authenticationChallengeResponse(AuthenticationChallengeProviderResult)

        case delegate(Delegate)
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {}

        enum Delegate: Equatable {
            case showRegisterPassword
            case nextPage
        }
    }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider
    @Dependency(\.feedbackReceiver) var feedbackReceiver

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$alertState, action: \.alert)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadAvailableSecurityOptions:
            let availableOptions = appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableOptions.options
            state.securityOptionsError = availableOptions.error
            return .none
        case let .startBiometry(option):
            state.selectedSecurityOption = option
            return .publisher(
                authenticationChallengeProvider
                    .startAuthenticationChallenge()
                    .first()
                    .map { Action.authenticationChallengeResponse($0) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .authenticationChallengeResponse(response):
            switch response {
            case let .failure(error):
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
            case let .success(result):
                guard result == true else { return .none }
                feedbackReceiver.hapticFeedbackSuccess()
                return .run { [timeout = state.timeout] send in
                    try await schedulers.main.sleep(for: timeout)
                    await send(.delegate(.nextPage))
                }
                .animation()
            }
            return .none
        case .delegate(.showRegisterPassword):
            state.selectedSecurityOption = .password
            return .none
        case .delegate,
             .alert:
            // handled by OnboardingDomain
            return .none
        }
    }
}

extension RegisterAuthenticationDomain {
    enum Dummies {
        static let state = State(
            availableSecurityOptions: [.password, .biometry(.faceID)]
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
