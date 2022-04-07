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

import ASN1Kit
import Combine
import DataKit
import eRpKit
import Foundation
import IDP

typealias LoginResult = Result<Bool, LoginHandlerError>

protocol LoginHandler {
    func isAuthenticated() -> AnyPublisher<LoginResult, Never>

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never>
}

enum LoginHandlerError: Swift.Error, Equatable, LocalizedError {
    static func ==(lhs: LoginHandlerError, rhs: LoginHandlerError) -> Bool {
        switch (lhs, rhs) {
        case (.biometrieFailed, .biometrieFailed),
             (.biometrieFatal, .biometrieFatal),
             (.ssoFailed, .ssoFailed),
             (.ssoExpired, .ssoExpired):
            return true
        case let (.network(lhsError), .network(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    case biometrieFailed
    case biometrieFatal
    case ssoFailed
    case ssoExpired
    case idpError(IDPError)
    case network(Swift.Error)

    var errorDescription: String? {
        switch self {
        case .biometrieFailed:
            return "biometrieFailed"
        case .biometrieFatal:
            return "biometrieFatal"
        case .ssoFailed:
            return "ssoFailed"
        case .ssoExpired:
            return "ssoExpired"
        case let .idpError(idpError):
            return idpError.localizedDescription
        case let .network(error):
            return error.localizedDescription
        }
    }
}

class DefaultLoginHandler: LoginHandler {
    let idpSession: IDPSession
    let signatureProvider: SecureEnclaveSignatureProvider

    init(idpSession: IDPSession, signatureProvider: SecureEnclaveSignatureProvider) {
        self.idpSession = idpSession
        self.signatureProvider = signatureProvider
    }

    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        // TODO: implement and use instead of userSession.isAuthenticated  swiftlint:disable:this todo
        Just(LoginResult.success(false)).eraseToAnyPublisher()
    }

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        idpSession
            .isLoggedIn
            .first()
            .zip(
                signatureProvider
                    .isBiometrieRegistered
                    .first()
                    .setFailureType(to: IDPError.self)
                    .eraseToAnyPublisher()
            )
            .flatMap { isAuthenticated, isBiometricsRegistered -> AnyPublisher<LoginResult, IDPError> in
                if isAuthenticated {
                    return Just(Result.success(true)).setFailureType(to: IDPError.self).eraseToAnyPublisher()
                }
                if isBiometricsRegistered {
                    return self.authenticateWithBiometrics().setFailureType(to: IDPError.self).eraseToAnyPublisher()
                }

                return Just(Result.success(false)).setFailureType(to: IDPError.self).eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<LoginResult, Never> in
                switch error {
                case .network:
                    return Just(Result.failure(LoginHandlerError.network(error))).eraseToAnyPublisher()
                default:
                    return Just(Result.success(false)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func authenticateWithBiometrics() -> AnyPublisher<LoginResult, Never> {
        idpSession
            .requestChallenge()
            .flatMap { challenge -> AnyPublisher<SignedAuthenticationData, IDPError> in
                self.signatureProvider
                    .authenticationData(for: challenge)
                    .mapError(IDPError.biometrics)
                    .eraseToAnyPublisher()
            }
            .flatMap { signedAuthenticationData -> AnyPublisher<LoginResult, IDPError> in
                self.idpSession
                    .altVerify(signedAuthenticationData)
                    .flatMap { exchangeToken in
                        self.idpSession.exchange(
                            token: exchangeToken,
                            challengeSession: signedAuthenticationData.originalChallenge
                        )
                        .map { _ in
                            // Receiving any IDPToken means we are logged in
                            LoginResult.success(true)
                        }
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error in
                Just(LoginResult.failure(LoginHandlerError.idpError(error))).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
