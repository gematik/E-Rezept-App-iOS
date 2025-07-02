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
import Foundation
import OpenSSL

/// This struct combines AuthenticationData, the IDPChallengeSession and a signer to create a signature for using while
/// authentication against the idp.
public struct BiometricAuthenticationSession {
    /// Initializer
    /// - Parameters:
    ///   - authenticationData: Wrapped `AuthenticationData`
    ///   - originalChallenge: Wrapped `IDPChallengeSession`
    public init(authenticationData: AuthenticationData, originalChallenge: IDPChallengeSession) {
        self.authenticationData = authenticationData
        self.originalChallenge = originalChallenge
    }

    let authenticationData: AuthenticationData
    let originalChallenge: IDPChallengeSession

    /// Create the signed IDPChallenge response JWT
    ///
    /// - Parameter signer: JWT Signature provider
    /// - Parameter alg: signature algorithm. Default: "secp256r1"
    /// - Returns: signed JWT
    public func sign(
        with signer: JWTSigner,
        alg: JWT.Algorithm = .secp256r1,
        jsonEncoder _: JSONEncoder = JSONEncoder()
    ) -> AnyPublisher<SignedAuthenticationData, Swift.Error> {
        Deferred { () -> AnyPublisher<SignedAuthenticationData, Swift.Error> in
            let header = JWT.Header(alg: alg, typ: "JWT")
            do {
                return try JWT(header: header, payload: authenticationData)
                    .sign(with: signer)
                    .map { jwt in
                        SignedAuthenticationData(originalChallenge: originalChallenge, signedAuthenticationData: jwt)
                    }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}
