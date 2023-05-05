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

struct AppAuthenticationBiometricsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    typealias AuthenticationResult = Result<Bool, Error>

    struct State: Equatable {
        let biometryType: BiometryType
        let startImmediateAuthenticationChallenge: Bool
        var authenticationResult: AuthenticationResult?
        var errorToDisplay: Error?
    }

    enum Action: Equatable {
        case startAuthenticationChallenge
        case dismissError

        case authenticationChallengeResponse(Result<Bool, Error>)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .startAuthenticationChallenge:
            return authenticationChallengeProvider
                .startAuthenticationChallenge()
                .first()
                .map { Action.authenticationChallengeResponse($0) }
                .receive(on: schedulers.main.animation())
                .eraseToEffect()
        case let .authenticationChallengeResponse(response):
            state.authenticationResult = response
            if case let .failure(error) = response {
                state.errorToDisplay = error
            }
            return .none
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        }
    }
}

extension AppAuthenticationBiometricsDomain {
    // sourcery: CodedError = "003"
    enum Error: Swift.Error, LocalizedError, Equatable {
        // sourcery: errorCode = "01"
        case cannotEvaluatePolicy(NSError?)
        // sourcery: errorCode = "02"
        case failedEvaluatingPolicy(NSError?)

        var errorDescription: String? {
            switch self {
            case let .cannotEvaluatePolicy(error):
                guard let error = error else {
                    return L10n.authTxtBiometricsFailedDefault.text
                }
                if LAError.Code(rawValue: error.code) == LAError.biometryLockout {
                    return L10n.authTxtBiometricsLockout.text
                } else {
                    return error.localizedDescription
                }
            case let .failedEvaluatingPolicy(error):
                guard let error = error else {
                    return L10n.authTxtBiometricsFailedDefault.text
                }
                switch LAError.Code(rawValue: error.code) {
                case LAError.authenticationFailed:
                    return L10n.authTxtBiometricsFailedAuthenticationFailed.text
                case LAError.userFallback:
                    return L10n.authTxtBiometricsFailedUserFallback.text
                case LAError.biometryNotEnrolled:
                    return L10n.authTxtBiometricsFailedNotEnrolled.text
                default:
                    return L10n.authTxtBiometricsFailedDefault.text
                }
            }
        }

        static func ==(lhs: Error,
                       rhs: Error) -> Bool {
            switch (lhs, rhs) {
            case let (.cannotEvaluatePolicy(lError),
                      .cannotEvaluatePolicy(rError)):
                return lError?.code == rError?.code
            case let (.failedEvaluatingPolicy(lError),
                      .failedEvaluatingPolicy(rError)):
                return lError?.localizedDescription == rError?.localizedDescription
            default:
                return false
            }
        }
    }
}

extension AppAuthenticationBiometricsDomain {
    enum Dummies {
        static let state = State(biometryType: .faceID, startImmediateAuthenticationChallenge: false)
    }
}

protocol AuthenticationChallengeProvider {
    func startAuthenticationChallenge() -> AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never>
}
