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

import ASN1Kit
import CodedError
import Combine
import eRpKit
import Foundation
import IDP

/// Result type for login operations
public typealias LoginResult = Result<Bool, LoginHandlerError>

/// Handler for managing user authentication flow
public protocol LoginHandler {
    /// Checks if user is currently authenticated
    /// - Returns: Publisher with login result
    func isAuthenticated() -> AnyPublisher<LoginResult, Never>

    /// Checks authentication status and authenticates if needed
    /// - Returns: Publisher with login result
    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never>
}

/// Errors that can occur during login handling
@CodedError("013")
public enum LoginHandlerError: Swift.Error, Equatable, LocalizedError {
    @ErrorCode("01")
    case biometrieFailed // TODO: case is unused //swiftlint:disable:this todo
    @ErrorCode("02")
    case biometrieFatal // TODO: case is unused //swiftlint:disable:this todo
    @ErrorCode("03")
    case ssoFailed // TODO: case is unused //swiftlint:disable:this todo
    @ErrorCode("04")
    case ssoExpired // TODO: case is unused //swiftlint:disable:this todo
    @ErrorCode("05")
    case idpError(IDPError)
    @ErrorCode("06")
    case network(Swift.Error)

    public var errorDescription: String? {
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

    public static func ==(lhs: LoginHandlerError, rhs: LoginHandlerError) -> Bool {
        switch (lhs, rhs) {
        case (.biometrieFailed, .biometrieFailed),
             (.biometrieFatal, .biometrieFatal),
             (.ssoFailed, .ssoFailed),
             (.ssoExpired, .ssoExpired):
            return true
        case let (.network(lhsError), .network(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.idpError(lhsError), .idpError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

import CasePaths

extension LoginHandlerError: Codable {
    enum CodingKeys: String, CodingKey {
        case biometrieFailed
        case biometrieFatal
        case ssoFailed
        case ssoExpired
        case idpError
        case network
    }

    public enum LoadingError: Swift.Error {
        case message(String?)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.biometrieFailed) {
            self = .biometrieFailed
        } else if container.contains(.biometrieFatal) {
            self = .biometrieFatal
        } else if container.contains(.ssoFailed) {
            self = .ssoFailed
        } else if container.contains(.ssoExpired) {
            self = .ssoExpired
        } else if container.contains(.idpError) {
            self = .idpError(try container.decode(IDPError.self, forKey: .idpError))
        } else if container.contains(.network) {
            self = .network(LoadingError.message(try container.decode(String.self, forKey: .network)))
        } else {
            throw DecodingError.dataCorruptedError(forKey: .idpError, in: container, debugDescription: "No error found")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .biometrieFailed:
            try container.encode(true, forKey: .biometrieFailed)
        case .biometrieFatal:
            try container.encode(true, forKey: .biometrieFatal)
        case .ssoFailed:
            try container.encode(true, forKey: .ssoFailed)
        case .ssoExpired:
            try container.encode(true, forKey: .ssoExpired)
        case let .idpError(idpError):
            try container.encode(idpError, forKey: .idpError)
        case let .network(error):
            try container.encode(error.localizedDescription, forKey: .network)
        }
    }
}

public class DefaultLoginHandler: LoginHandler {
    let idpSession: IDPSession
    let signatureProvider: SecureEnclaveSignatureProvider

    public init(idpSession: IDPSession, signatureProvider: SecureEnclaveSignatureProvider) {
        self.idpSession = idpSession
        self.signatureProvider = signatureProvider
    }

    public func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        // TODO: implement and use instead of userSession.isAuthenticated  swiftlint:disable:this todo
        idpSession
            .isLoggedIn
            .first()
            .map { value -> LoginResult in
                LoginResult.success(value)
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

    public func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
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

    public func authenticateWithBiometrics() -> AnyPublisher<LoginResult, Never> {
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
