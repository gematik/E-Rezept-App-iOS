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

import CommonCrypto
import CryptoKit
import Foundation
import OpenSSL

/// Key-pair generator type based on BrainpoolP256r1
///
/// [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
public typealias BrainpoolKeyGenerator = () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
/// AES nonce generator type
public typealias AESNonceGenerator = () throws -> Data
/// AES Symmetric key type
public typealias AESSymmetricKey = SymmetricKey

/// Container that holds all relevant crypto generators that are used by the IDP
struct IDPCrypto {
    /// The size of the verifier in bytes. Default 32 bytes.
    let verifierLength: Int
    /// The size of the nonce in bytes. Default is 16 bytes (which is equal to the api definition of max. 32 character).
    let nonceLength: Int
    /// The size of the state in bytes. Default 16 bytes (which is equal to the api definition of max. 32 character).
    let stateLength: Int
    /// (Pseudo) random byte generator. Default uses `generateSecureRandom()` with `kSecRandomDefault`
    let randomGenerator: Random<Data>
    /// Private key for key exchange that can be used to generate a BrainpoolP256r1 key pair
    let brainpoolKeyPairGenerator: BrainpoolKeyGenerator
    /// Secure random generator for aes nonce
    let aesNonceGenerator: AESNonceGenerator
    /// AES symmetric key
    let aesKey: SymmetricKey

    init(
        verifierLength: Int = 32,
        nonceLength: Int = 16,
        stateLength: Int = 16,
        randomGenerator: @escaping Random<Data> = { try generateSecureRandom(length: $0) },
        brainpoolKeyPairGenerator: @escaping BrainpoolKeyGenerator = {
            try BrainpoolP256r1.KeyExchange.generateKey()
        },
        aesNonceGenerator: @escaping AESNonceGenerator = {
            // [REQ:gemSpec_Krypt:GS-A_4389:2] IVs must not be reused, IVs bit length must be larger or equal to 96
            try generateSecureRandom(length: IDPCrypto.AES256GCMSpec.nonceBytes)
        },
        // [REQ:gemSpec_Krypt:GS-A_4389:1] 256bit GCM symmetric key
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

    func generateRandomVerifier() throws -> String? {
        // [REQ:gemSpec_IDP_Frontend:A_20309] verifierLength is 32 bytes, encoded to base64 this results in 43 chars
        // (32 * 4 / 3 = 42,6)
        try randomGenerator(verifierLength).encodeBase64urlsafe().utf8string
    }

    func generateRandomNonce() throws -> String? {
        try randomGenerator(nonceLength).hexString()
    }

    func generateRandomState() throws -> String? {
        try randomGenerator(stateLength).hexString()
    }

    private static let AES256GCMSpec = Spec(nonceBytes: 12)
    private struct Spec {
        let nonceBytes: Int
    }
}
