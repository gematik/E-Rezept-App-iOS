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
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)

        case startAuthenticationChallenge
        case switchToPassword(Bool)
        case authenticationChallengeResponse(AuthenticationChallengeProviderResult)
        case loginButtonTapped
        case setPassword(String)
        case passwordVerificationReceived(Bool)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
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
            return .none
        case let .switchToPassword(bool):
            state.showPassword = bool
            return .none
        case .destination:
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
