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
    struct EncryptionContext {
        let symmetricKey: SymmetricKey

        let ephemeralPublicKey: JWK
    }

    /// JWE Algorithm for key exchange and encryption
    public enum Algorithm {
        /// ECDH-ES algorithm with specified key exchange context
        case ecdh_es(KeyExchangeContext) // swiftlint:disable:this identifier_name

        func encryptionContext() throws -> EncryptionContext {
            switch self {
            case let .ecdh_es(curve):
                return try curve.encryptionContext()
            }
        }

        /// Key exchange context for different cryptographic curves
        public enum KeyExchangeContext {
            // [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
            // [REQ:gemSpec_Krypt:GS-A_4367] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
            /// BrainpoolP256r1 key exchange context
            case bpp256r1(BrainpoolP256r1.KeyExchange.PublicKey,
                          keyPairGenerator: () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
                              // [REQ:BSI-eRp-ePA:O.Cryp_3#4] Brainpool key generator
                              // [REQ:gemSpec_eRp_FdV:A_19179#4] Key pair generation delegated to OpenSSL
                              = { try BrainpoolP256r1.KeyExchange.generateKey() })

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
    /// Decryption algorithm for JWE
    enum DecryptionAlgorithm {
        case plain(SymmetricKey)
    }
}
