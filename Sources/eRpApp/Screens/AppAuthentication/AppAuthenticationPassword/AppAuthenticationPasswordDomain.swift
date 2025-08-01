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

import ComposableArchitecture
import Foundation

// [REQ:BSI-eRp-ePA:O.Auth_7#2] Domain handling App Authentication
@Reducer
struct AppAuthenticationPasswordDomain {
    @ObservableState
    struct State: Equatable {
        var password: String = ""
        var lastMatchResultSuccessful = true
        var passwordDelay: TimeInterval = 0

        var passwordDelayInt: Int {
            // Int(number) would truncate the decimal part, so we use ceil to round up
            Int(ceil(passwordDelay))
        }

        var passwordDelayIsActive: Bool {
            passwordDelayInt > 0
        }

        var showUnsuccessfulAttemptMessage: Bool {
            !lastMatchResultSuccessful || passwordDelayIsActive
        }

        var unsuccessfulAttemptMessage: String {
            switch (lastMatchResultSuccessful, passwordDelayIsActive) {
            case (true, true):
                return L10n.authTxtPleaseRetryWithDelay(passwordDelayInt).text
            case (false, true):
                return L10n.authTxtPasswordFailurePleaseRetryWithDelay(passwordDelayInt).text
            case (false, false):
                return L10n.authTxtPasswordFailure.text
            case (true, false):
                // should not be displayed (showUnsuccessfulAttemptMessage is false)
                return ""
            }
        }
    }

    enum Action: Equatable {
        case task
        case currentPasswordDelayReceived(TimeInterval?)
        case setPassword(String)
        case loginButtonTapped
        case passwordVerificationReceived(Bool)
        case passwordDelayTimerTick
    }

    enum CancelID { case passWordDelayTimer }

    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { send in
                // Password delay listener
                let delay = try? appSecurityManager.currentPasswordDelay()
                await send(.currentPasswordDelayReceived(delay))
            }
        case let .currentPasswordDelayReceived(delay):
            // Update the password delay state
            guard let delay else { return .none }
            // Add 1 second to begin with, because we won't wait during the 0th second at the end.
            state.passwordDelay = delay
            if delay > 0 {
                // Start a timer that fires after the delay
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.passwordDelayTimerTick)
                    }
                }
                .cancellable(id: CancelID.passWordDelayTimer, cancelInFlight: true)
            }
            return .none
        case .passwordDelayTimerTick:
            // Decrease the remaining delay time
            state.passwordDelay -= 1
            if state.passwordDelay <= 0 {
                return .cancel(id: CancelID.passWordDelayTimer)
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
                // Reset the password delay on successful login
                try? appSecurityManager.resetPasswordDelay()
                return .none

            } else {
                // If password does not match, we need to register a failed attempt
                try? appSecurityManager.registerFailedPasswordAttempt()
                let delay = try? appSecurityManager.currentPasswordDelay()
                return .run { send in
                    // Password delay listener
                    await send(.currentPasswordDelayReceived(delay))
                }
            }
        }
    }
}

extension AppAuthenticationPasswordDomain {}

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
