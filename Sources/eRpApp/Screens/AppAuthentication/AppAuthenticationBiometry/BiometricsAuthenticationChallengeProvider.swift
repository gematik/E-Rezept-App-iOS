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
import Dependencies
import Foundation
import LocalAuthentication

// swiftlint:disable:next type_name
struct BiometricsAuthenticationChallengeProvider: AuthenticationChallengeProvider {
    func startAuthenticationChallenge() -> AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never> {
        Deferred {
            Future { promise in
                startAuthenticationChallenge {
                    promise(.success($0))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func startAuthenticationChallenge(completion: @escaping (AppAuthenticationBiometricsDomain
            .AuthenticationResult) -> Void) {
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
