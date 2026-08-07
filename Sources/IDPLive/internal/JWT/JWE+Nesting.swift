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
import CryptoKit
import Foundation
import IDP
import OpenSSL

extension JWE {
    /// Nest a JWT inside a JWE for secure transport
    /// - Parameters:
    ///   - jwt: JWT to be nested
    ///   - publicKey: BrainpoolP256r1 public key for encryption
    ///   - cryptoBox: IDPCrypto instance containing encryption parameters
    ///   - expiry: Optional expiry date for the JWE
    /// - Returns: JWE containing the nested JWT
    /// - Throws: IDPError if nesting fails
    public static func nest(
        jwt: JWT,
        with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
        using cryptoBox: IDPCrypto,
        expiry: Date? = nil
    ) throws -> Self {
        // [REQ:BSI-eRp-ePA:O.Cryp_1#5] Signature via ecdh ephemeral-static
        // [REQ:BSI-eRp-ePA:O.Cryp_4#6] one time usage for JWE ECDH-ES Encryption
        let algorithm = JWE.EncryptionContext.Algorithm
            .ecdh_es(JWE.EncryptionContext.Algorithm.KeyExchangeContext.bpp256r1(
                publicKey,
                keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
            ))
        let serialized = NestedJWT(njwt: jwt.serialize())
        guard let jweHeader = try? JWE.Header(algorithm: algorithm,
                                              encryption: .a256gcm,
                                              expiry: expiry,
                                              contentType: "NJWT"),
            let jwePayload = try? Self.defaultEncoder.encode(serialized),
            let jwe = try? JWE(header: jweHeader, payload: jwePayload, nonceGenerator: cryptoBox.aesNonceGenerator)
        else {
            throw IDPError.internal(error: .nestJwtInJwePayloadEncryption)
        }

        return jwe
    }

    private static let defaultEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()
}
