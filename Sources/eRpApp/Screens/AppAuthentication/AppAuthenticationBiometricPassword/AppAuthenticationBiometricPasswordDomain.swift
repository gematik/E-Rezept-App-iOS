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
import Foundation
import LocalAuthentication

@Reducer
struct AppAuthenticationBiometricPasswordDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {}
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?

        let biometryType: BiometryType
        let startImmediateAuthenticationChallenge: Bool
        var authenticationResult: AuthenticationChallengeProviderResult?
        var showPassword = false
        var password: String = ""
        var lastMatchResultSuccessful: Bool?
        // Password delay logic
        var passwordDelay: TimeInterval = 0
        var passwordDelayInt: Int {
            Int(ceil(passwordDelay))
        }

        var passwordDelayIsActive: Bool {
            passwordDelayInt > 0
        }

        var showUnsuccessfulAttemptMessage: Bool {
            !(lastMatchResultSuccessful ?? true) || passwordDelayIsActive
        }

        var unsuccessfulAttemptMessage: String {
            switch (lastMatchResultSuccessful ?? true, passwordDelayIsActive) {
            case (true, true):
                return L10n.authTxtPleaseRetryWithDelay(passwordDelayInt).text
            case (false, true):
                return L10n.authTxtPasswordFailurePleaseRetryWithDelay(passwordDelayInt).text
            case (false, false):
                return L10n.authTxtPasswordFailure.text
            case (true, false):
                return ""
            }
        }
    }

    enum Action: Equatable {
        case task
        case destination(PresentationAction<Destination.Action>)
        case startAuthenticationChallenge
        case switchToPassword(Bool)
        case authenticationChallengeResponse(AuthenticationChallengeProviderResult)
        case loginButtonTapped
        case setPassword(String)
        case passwordVerificationReceived(Bool)
        // Password delay actions
        case currentPasswordDelayReceived(TimeInterval?)
        case passwordDelayTimerTick
    }

    enum CancelID { case passWordDelayTimer }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { send in
                // Password delay listener
                let delay = try? appSecurityManager.currentPasswordDelay()
                await send(.currentPasswordDelayReceived(delay))
            }
        case .startAuthenticationChallenge:
            return .publisher(
                authenticationChallengeProvider
                    .startAuthenticationChallenge()
                    .first()
                    .map { Action.authenticationChallengeResponse($0) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .authenticationChallengeResponse(response):
            state.authenticationResult = response
            if case let .failure(error) = response {
                if error.isUserFallBack {
                    return .send(.switchToPassword(true))
                }
                state.destination = .alert(.init(for: error, title: L10n.alertErrorTitle))
            }
            return .none
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
            if isLoggedIn {
                try? appSecurityManager.resetPasswordDelay()
                return .none
            } else {
                try? appSecurityManager.registerFailedPasswordAttempt()
                let delay = try? appSecurityManager.currentPasswordDelay()
                return .run { send in
                    await send(.currentPasswordDelayReceived(delay))
                }
            }
        case let .switchToPassword(bool):
            state.showPassword = bool
            return .none
        case .destination:
            return .none
        // Password delay logic
        case let .currentPasswordDelayReceived(delay):
            guard let delay else { return .none }
            state.passwordDelay = delay
            if delay > 0 {
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.passwordDelayTimerTick)
                    }
                }
                .cancellable(id: CancelID.passWordDelayTimer, cancelInFlight: true)
            }
            return .none
        case .passwordDelayTimerTick:
            state.passwordDelay -= 1
            if state.passwordDelay <= 0 {
                return .cancel(id: CancelID.passWordDelayTimer)
            }
            return .none
        }
    }
}

extension AppAuthenticationBiometricPasswordDomain {
    enum Dummies {
        static let state = State(biometryType: .faceID, startImmediateAuthenticationChallenge: false)

        static let store = Store(initialState: state) {
            AppAuthenticationBiometricPasswordDomain()
        }
    }
}
