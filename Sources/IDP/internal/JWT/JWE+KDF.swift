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

import Combine
import CryptoKit
import Foundation
import OpenSSL

extension JWE {
    struct EncryptionContext {
        let symmetricKey: SymmetricKey

        let ephemeralPublicKey: JWK
    }

    enum Algorithm {
        // swiftlint:disable:next identifier_name
        case ecdh_es(KeyExchangeContext)

        func encryptionContext() throws -> EncryptionContext {
            switch self {
            case let .ecdh_es(curve):
                return try curve.encryptionContext()
            }
        }

        enum KeyExchangeContext {
            // [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
            case bpp256r1(BrainpoolP256r1.KeyExchange.PublicKey,
                          keyPairGenerator: () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
                              = { try BrainpoolP256r1.KeyExchange.generateKey(compactRepresentable: true) })

            func encryptionContext() throws -> EncryptionContext {
                switch self {
                case let .bpp256r1(staticPublicKey, keyPairGenerator: keyPairGenerator):
                    let ephemeralPrivate = try keyPairGenerator()
                    let ephemeralPublic = ephemeralPrivate.publicKey

                    let sharedSecret = try ephemeralPrivate.sharedSecret(with: staticPublicKey)

                    // Concat KDF as described in
                    // https://tools.ietf.org/html/rfc5084
                    // and
                    // https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-56Ar2.pdf
                    // We might need to replace this with a corresponding openssl method
                    let part1 = try Data(hex: "00000001")
                    let part2 = try Data(hex: "000000074132353647434d000000000000000000000100")

                    let digest = SHA256.hash(data: part1 + sharedSecret + part2)
                    let symmetricKey = SymmetricKey(data: digest)

                    return EncryptionContext(
                        symmetricKey: symmetricKey,
                        ephemeralPublicKey: try JWK.from(brainpoolP256r1: ephemeralPublic)
                    )
                }
            }
        }
    }
}

extension JWE {
    enum DecryptionAlgorithm {
        case plain(SymmetricKey)
    }
}
