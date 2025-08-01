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

import CommonCrypto
import CryptoKit
import Foundation
import OpenSSL

/// Key-pair generator type based on BrainpoolP256r1
///
/// [REQ:gemSpec_Krypt:GS-A_4357,GS-A_4367] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
public typealias BrainpoolKeyGenerator = () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
/// AES nonce generator type
public typealias AESNonceGenerator = () throws -> Data
/// AES Symmetric key type
public typealias AESSymmetricKey = SymmetricKey

/// Container that holds all relevant crypto generators that are used by the IDP
public struct IDPCrypto {
    /// The size of the verifier in bytes. Default 32 bytes.
    let verifierLength: Int
    /// The size of the nonce in bytes. Default is 16 bytes (which is equal to the api definition of max. 32 character).
    let nonceLength: Int
    /// The size of the state in bytes. Default 16 bytes (which is equal to the api definition of max. 32 character).
    let stateLength: Int
    /// (Pseudo) random byte generator. Default uses `generateSecureRandom()` with `kSecRandomDefault`
    let randomGenerator: Random<Data>
    /// Private key for key exchange that can be used to generate a BrainpoolP256r1 key pair
    public let brainpoolKeyPairGenerator: BrainpoolKeyGenerator
    /// Secure random generator for aes nonce
    public let aesNonceGenerator: AESNonceGenerator
    /// AES symmetric key
    public let aesKey: SymmetricKey

    /// Initialize IDPCrypto with custom or default cryptographic parameters
    /// - Parameters:
    ///   - verifierLength: Length of the verifier in bytes (default: 32)
    ///   - nonceLength: Length of the nonce in bytes (default: 16)
    ///   - stateLength: Length of the state in bytes (default: 16)
    ///   - randomGenerator: Random byte generator function
    ///   - brainpoolKeyPairGenerator: BrainpoolP256r1 key pair generator
    ///   - aesNonceGenerator: AES nonce generator
    ///   - aesKey: AES symmetric key
    public init(
        verifierLength: Int = 32,
        nonceLength: Int = 16,
        stateLength: Int = 16,
        randomGenerator: @escaping Random<Data> = { try generateSecureRandom(length: $0) },
        brainpoolKeyPairGenerator: @escaping BrainpoolKeyGenerator = {
            // [REQ:gemSpec_eRp_FdV:A_19179#2] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
            // [REQ:BSI-eRp-ePA:O.Cryp_3#3] Brainpool key generator
            try BrainpoolP256r1.KeyExchange.generateKey()
        },
        aesNonceGenerator: @escaping AESNonceGenerator = {
            // [REQ:gemSpec_Krypt:GS-A_4389:2] IVs must not be reused, IVs bit length must be larger or equal to 96
            try generateSecureRandom(length: IDPCrypto.AES256GCMSpec.nonceBytes)
        },
        // [REQ:gemSpec_Krypt:GS-A_4389:1] 256bit GCM symmetric key
        // [REQ:gemSpec_eRp_FdV:A_19179#3] AES key generation via CryptoKit
        // [REQ:gemSpec_Krypt:GS-A_4368] AES key generation via CryptoKit
        // [REQ:gemSpec_IDP_Frontend:A_21323#4] AES key generation via CryptoKit
        aesKey: SymmetricKey = SymmetricKey(size: SymmetricKeySize(bitCount: 256))
    ) {
        self.verifierLength = verifierLength
        self.nonceLength = nonceLength
        self.stateLength = stateLength
        self.randomGenerator = randomGenerator
        self.brainpoolKeyPairGenerator = brainpoolKeyPairGenerator
        self.aesNonceGenerator = aesNonceGenerator
        self.aesKey = aesKey
    }

    /// Generate a random verifier string
    /// - Returns: Base64 URL-safe encoded verifier string
    /// - Throws: If random generation or encoding fails
    public func generateRandomVerifier() throws -> String? {
        // [REQ:gemSpec_IDP_Frontend:A_20309] verifierLength is 32 bytes, encoded to base64 this results in 43 chars
        // (32 * 4 / 3 = 42,6)
        guard let encoded = try randomGenerator(verifierLength).encodeBase64UrlSafe() else {
            return nil
        }
        return String(data: encoded, encoding: .utf8)
    }

    /// Generate a random nonce string
    /// - Returns: Hex-encoded nonce string
    /// - Throws: If random generation fails
    public func generateRandomNonce() throws -> String? {
        try Self.hexString(from: randomGenerator(nonceLength))
    }

    /// Generate a random state string
    /// - Returns: Hex-encoded state string
    /// - Throws: If random generation fails
    public func generateRandomState() throws -> String? {
        try Self.hexString(from: randomGenerator(stateLength))
    }

    /// AES-256-GCM specification constants
    public static let AES256GCMSpec = Spec(nonceBytes: 12)

    /// Specification for AES encryption parameters
    public struct Spec {
        /// Number of bytes for the nonce
        public let nonceBytes: Int
    }

    static func hexString(from data: Data) -> String {
        data.map { .init(format: "%02X", $0) }.joined()
    }
}
