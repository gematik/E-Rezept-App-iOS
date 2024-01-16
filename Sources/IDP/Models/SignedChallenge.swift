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

import Foundation
import OpenSSL

/// Model that holds a challenge and its signed counterpart
public struct SignedChallenge {
    /// Original challenge
    public let originalChallenge: IDPChallengeSession
    /// Signed challenge
    public let signedChallenge: JWT

    /// Initialize a SignedChallenge
    ///
    /// - Parameters:
    ///   - originalChallenge: original challenge
    ///   - signedChallenge: signed response
    public init(originalChallenge: IDPChallengeSession, signedChallenge: JWT) {
        self.originalChallenge = originalChallenge
        self.signedChallenge = signedChallenge
    }

    /// Serialize the signedChallenge
    ///
    /// - Returns: ASCII Encoded String
    public func serialize() -> String {
        signedChallenge.serialize()
    }

    func encrypt(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
                 using cryptoBox: IDPCrypto) throws -> JWE {
        // [REQ:BSI-eRp-ePA:O.Cryp_1#2] Signature via ecdh ephemeral-static
        // [REQ:BSI-eRp-ePA:O.Cryp_4#5] one time usage for JWE ECDH-ES Encryption
        let algorithm = JWE.Algorithm.ecdh_es(JWE.Algorithm.KeyExchangeContext.bpp256r1(
            publicKey,
            keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
        ))
        let signedChallengePayload = NestedJWT(njwt: serialize())
        guard let jweHeader = try? JWE.Header(algorithm: algorithm,
                                              encryption: .a256gcm,
                                              expiry: originalChallenge.challenge.exp,
                                              contentType: "NJWT"),
            let jwePayload = try? SignedChallenge.defaultEncoder.encode(signedChallengePayload),
            let signedChallengeJWE = try? JWE(header: jweHeader,
                                              payload: jwePayload,
                                              nonceGenerator: cryptoBox.aesNonceGenerator) else {
            throw IDPError.internal(error: .signedChallengeEncryption)
        }

        return signedChallengeJWE
    }

    private static let defaultEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()
}

extension SignedChallenge: Equatable {}
