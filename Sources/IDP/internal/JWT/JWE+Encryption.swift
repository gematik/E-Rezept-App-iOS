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
import OpenSSL

extension JWE {
    static func nest(
        jwt: JWT,
        with publicKey: BrainpoolP256r1.KeyExchange.PublicKey,
        using cryptoBox: IDPCrypto,
        expiry: Date? = nil
    ) throws -> Self {
        // [REQ:BSI-eRp-ePA:O.Cryp_1#5] Signature via ecdh ephemeral-static
        // [REQ:BSI-eRp-ePA:O.Cryp_4#6] one time usage for JWE ECDH-ES Encryption
        let algorithm = JWE.Algorithm.ecdh_es(JWE.Algorithm.KeyExchangeContext.bpp256r1(
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

    enum Encryption {
        case a256gcm

        func encrypt(payload: Data,
                     header: Header,
                     nonceGenerator: () throws -> Data) throws -> Backing {
            switch self {
            case .a256gcm:
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .sortedKeys
                jsonEncoder.dataEncodingStrategy = .base64
                jsonEncoder.dateEncodingStrategy = .secondsSince1970

                let headerEncoded = try jsonEncoder.encode(header)
                let wrappedKey = Data() // Key-Wrapping is not supported

                let nonceData: Data = try nonceGenerator()
                let nonce = try AES.GCM.Nonce(data: nonceData)

                guard let authenticationData = headerEncoded.encodeBase64UrlSafe()
                else { throw JWE.Error.encodingError }
                let sealedBox = try AES.GCM.seal(payload,
                                                 using: header.encryptionContext.symmetricKey,
                                                 nonce: nonce,
                                                 authenticating: authenticationData)

                return JWE.Backing(
                    header: headerEncoded,
                    wrappedKey: wrappedKey,
                    iv: sealedBox.nonce.withUnsafeBytes { Data(Array($0)) },
                    ciphertext: sealedBox.ciphertext,
                    tag: sealedBox.tag
                )
            }
        }
    }

    enum Decryption {
        case a256gcm(SymmetricKey)

        func decrypt(jwe: JWE.Backing) throws -> Data {
            switch self {
            case let .a256gcm(symmetricKey):
                return try decryptAES256GCM(jwe: jwe, key: symmetricKey)
            }
        }

        func decryptAES256GCM(jwe: JWE.Backing, key: SymmetricKey) throws -> Data {
            let sealedBox = try AES.GCM.SealedBox(
                nonce: try AES.GCM.Nonce(data: jwe.iv),
                ciphertext: jwe.ciphertext,
                tag: jwe.tag
            )

            guard let jweHeaderEncoded = jwe.header.encodeBase64UrlSafe()
            else { throw JWE.Error.encodingError }

            return try AES.GCM.open(sealedBox, using: key, authenticating: jweHeaderEncoded)
        }
    }
}
