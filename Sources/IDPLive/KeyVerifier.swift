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

import CodedError
import CryptoKit
import Foundation
import IDP
import OpenSSL

// [REQ:gemSpec_IDP_Frontend:A_21324#2] Token-key and code-verifier are encoded into KeyVerifier.
public struct KeyVerifier: Codable {
    /// data string key that is used by the server to encrypt the access token response
    let tokenKey: String
    ///  random generated verifier code that was created and sent with the request challenge API call
    let verifierCode: VerifierCode

    public init(with key: SymmetricKey, codeVerifier: String) throws {
        guard let encoded = key.withUnsafeBytes({ Data(Array($0)) }).encodeBase64UrlSafe(),
              let keyDataString = String(bytes: encoded, encoding: .utf8) else {
            throw Error.stringConversion
        }
        tokenKey = keyDataString
        verifierCode = codeVerifier
    }

    enum CodingKeys: String, CodingKey {
        case tokenKey = "token_key"
        case verifierCode = "code_verifier"
    }

    @CodedError("105")
    public enum Error: Swift.Error {
        @ErrorCode("01")
        case stringConversion
    }

    public func encrypted(with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
                          using cryptoBox: IDPCrypto) throws -> JWE {
        // [REQ:gemSpec_IDP_Frontend:A_21323#2] Encode into JSON object
        // [REQ:gemSpec_IDP_Frontend:A_21324#3] Encode into JSON object
        guard let keyVerifierEncoded = try? KeyVerifier.jsonEncoder.encode(self) else {
            throw IDPError.internal(error: .keyVerifierEncoding)
        }

        let keyExchangeContext = JWE.EncryptionContext.Algorithm.KeyExchangeContext.bpp256r1(
            publicKey,
            keyPairGenerator: cryptoBox.brainpoolKeyPairGenerator
        )

        // [REQ:BSI-eRp-ePA:O.Cryp_1#6] Signature via ecdh ephemeral-static
        // [REQ:BSI-eRp-ePA:O.Cryp_4#2] one time usage for JWE ECDH-ES Encryption
        guard let jweHeader = try? JWE.Header(algorithm: JWE.EncryptionContext.Algorithm.ecdh_es(keyExchangeContext),
                                              encryption: .a256gcm,
                                              contentType: "JWT") else {
            throw IDPError.internal(error: .keyVerifierJweHeaderEncryption)
        }

        guard let jwe = try? JWE(header: jweHeader,
                                 payload: keyVerifierEncoded,
                                 nonceGenerator: cryptoBox.aesNonceGenerator) else {
            throw IDPError.internal(error: .keyVerifierJwePayloadEncryption)
        }

        return jwe
    }

    private static var jsonEncoder: JSONEncoder = {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dataEncodingStrategy = .base64
        return jsonEncoder
    }()
}
