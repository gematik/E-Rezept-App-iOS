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

/// Signed (with `PrK_SE_AUT`) representation of `AuthenticationData`.
public struct SignedAuthenticationData {
    /// Original idp challenge session that is signed within the authentication data
    public let originalChallenge: IDPChallengeSession
    /// Signed authentication data that is encrypted and sent to the server
    public let signedAuthenticationData: JWT

    /// Serialize the signedChallenge
    ///
    /// - Returns: ASCII Encoded String
    public func serialize() -> String {
        signedAuthenticationData.serialize()
    }

    func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
                   using cryptoBox: IDPCrypto) throws -> JWE {
        // [REQ:BSI-eRp-ePA:O.Cryp_1#3] Signature via ecdh ephemeral-static
        // [REQ:BSI-eRp-ePA:O.Cryp_4#4] one time usage for JWE ECDH-ES Encryption
        let algorithm = JWE.Algorithm.ecdh_es(JWE.Algorithm.KeyExchangeContext.bpp256r1(
            publicKey,
            keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
        ))
        let signedChallengePayload = NestedJWT(njwt: serialize())
        guard let jweHeader = try? JWE.Header(algorithm: algorithm,
                                              encryption: .a256gcm,
                                              /// [REQ:gemSpec_IDP_Frontend:A_21431] exp header
                                              expiry: originalChallenge.challenge.exp,
                                              contentType: "NJWT",
                                              type: "JWT"),
            let jwePayload = try? SignedAuthenticationData.defaultEncoder.encode(signedChallengePayload),
            let signedChallengeJWE = try? JWE(header: jweHeader,
                                              payload: jwePayload,
                                              nonceGenerator: cryptoBox.aesNonceGenerator) else {
            throw IDPError.internal(error: .signedAuthenticationDataEncryption)
        }

        return signedChallengeJWE
    }

    private static let defaultEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()
}
