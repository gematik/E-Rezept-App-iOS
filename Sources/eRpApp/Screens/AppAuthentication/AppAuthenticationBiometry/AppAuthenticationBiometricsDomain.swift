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
import LocalAuthentication

enum AppAuthenticationBiometricsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    typealias AuthenticationResult = Result<Bool, Error>

    struct State: Equatable {
        let biometryType: BiometryType
        let startImmediateAuthenticationChallenge: Bool
        var authenticationResult: AuthenticationResult?
        var errorToDisplay: Error?
    }

    enum Action: Equatable {
        case startAuthenticationChallenge
        case authenticationChallengeResponse(Result<Bool, Error>)
        case dismissError
    }

    struct Environment {
        var schedulers: Schedulers
        var authenticationChallengeProvider: AuthenticationChallengeProvider
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case .startAuthenticationChallenge:
            return environment
                .authenticationChallengeProvider
                .startAuthenticationChallenge()
                .first()
                .map { Action.authenticationChallengeResponse($0) }
                .receive(on: environment.schedulers.main.animation())
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
    enum Error: Swift.Error, LocalizedError, Equatable {
        case cannotEvaluatePolicy(NSError?)
        case failedEvaluatingPolicy(NSError?)

        var errorDescription: String? {
            switch self {
            case let .cannotEvaluatePolicy(error):
                guard let error = error else {
                    return NSLocalizedString("auth_txt_biometrics_failed_default", comment: "")
                }
                if LAError.Code(rawValue: error.code) == LAError.biometryLockout {
                    return NSLocalizedString("auth_txt_biometrics_lockout", comment: "")
                } else {
                    return error.localizedDescription
                }
            case let .failedEvaluatingPolicy(error):
                guard let error = error else {
                    return NSLocalizedString("auth_txt_biometrics_failed_default",
                                             comment: "")
                }
                switch LAError.Code(rawValue: error.code) {
                case LAError.authenticationFailed:
                    return NSLocalizedString("auth_txt_biometrics_failed_authentication_failed",
                                             comment: "")
                case LAError.userFallback:
                    return NSLocalizedString("auth_txt_biometrics_failed_user_fallback",
                                             comment: "")
                case LAError.biometryNotEnrolled:
                    return NSLocalizedString("auth_txt_biometrics_failed_not_enrolled",
                                             comment: "")
                default:
                    return NSLocalizedString("auth_txt_biometrics_failed_default",
                                             comment: "")
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
