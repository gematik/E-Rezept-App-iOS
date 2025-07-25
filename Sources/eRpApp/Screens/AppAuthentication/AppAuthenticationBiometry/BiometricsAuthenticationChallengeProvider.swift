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
import Dependencies
import Foundation
import LocalAuthentication

typealias AuthenticationChallengeProviderResult = Result<Bool, AuthenticationChallengeProviderError>

protocol AuthenticationChallengeProvider {
    func startAuthenticationChallenge()
        -> AnyPublisher<AuthenticationChallengeProviderResult, Never>
}

// sourcery: CodedError = "003"
enum AuthenticationChallengeProviderError: Swift.Error, LocalizedError, Equatable {
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

    var isUserFallBack: Bool {
        if case let .failedEvaluatingPolicy(error) = self,
           let laError = error as? LAError, laError.code == .userFallback {
            return true
        }
        return false
    }

    static func ==(lhs: AuthenticationChallengeProviderError,
                   rhs: AuthenticationChallengeProviderError) -> Bool {
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

struct BiometricsAuthenticationChallengeProvider: AuthenticationChallengeProvider {
    // swiftlint:disable:previous type_name
    func startAuthenticationChallenge() -> AnyPublisher<AuthenticationChallengeProviderResult, Never> {
        Deferred {
            Future { promise in
                startAuthenticationChallenge {
                    promise(.success($0))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func startAuthenticationChallenge(completion: @escaping (AuthenticationChallengeProviderResult) -> Void) {
        var error: NSError?
        let authenticationContext = LAContext()

        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                      error: &error) else {
            completion(.failure(.cannotEvaluatePolicy(error)))
            return
        }

        var localizedReason = ""
        switch authenticationContext.biometryType {
        case .faceID: localizedReason = "Face ID"
        case .touchID: localizedReason = "Touch ID"
        default:
            break
        }

        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                             localizedReason: L10n.authTxtBiometricsReason(localizedReason)
                                                 .text) { success, error in
            if success {
                completion(.success(true))
            } else {
                guard let nsError = error as NSError? else {
                    return
                }
                let laCode = LAError.Code(rawValue: nsError.code)
                if laCode == .userCancel || laCode == .appCancel || laCode == .systemCancel {
                    completion(.success(false))
                } else {
                    completion(.failure(.failedEvaluatingPolicy(nsError)))
                }
            }
        }
    }
}

// MARK: TCA Dependency

// swiftlint:disable:next type_name
struct AuthenticationChallengeProviderDependency: DependencyKey {
    static let liveValue: AuthenticationChallengeProvider = BiometricsAuthenticationChallengeProvider()

    static let previewValue: AuthenticationChallengeProvider = BiometricsAuthenticationChallengeProvider()

    static let testValue: AuthenticationChallengeProvider = UnimplementedAuthenticationChallengeProvider()
}

extension DependencyValues {
    var authenticationChallengeProvider: AuthenticationChallengeProvider {
        get { self[AuthenticationChallengeProviderDependency.self] }
        set { self[AuthenticationChallengeProviderDependency.self] = newValue }
    }
}
