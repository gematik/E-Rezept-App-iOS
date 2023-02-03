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

import Combine
import CryptoKit
import DataKit
import Foundation
import OpenSSL

protocol VAUCryptoProvider {
    func provide(for message: String, vauCertificate: VAUCertificate, bearerToken: BearerToken) throws -> VAUCrypto
}

protocol VAUCrypto {
    /// Perform encryption of the data that the implementing instance has been initialized with
    /// in order to send it to a VAU service endpoint. See: gemSpec_Krypt A_20161-01
    ///
    /// [REQ:gemSpec_Krypt:A_20161-01]
    ///
    /// - Returns: Encrypted HTTPRequest as specified to be sent to a VAU endpoint
    /// - Throws: `VAUError` in case of encryption failure
    func encrypt() throws -> Data

    /// Perform decryption and validation of given data with the secret key material the implementing instance holds.
    ///
    /// [REQ:gemSpec_Krypt:A_20163]
    ///
    /// - Parameter data: Data to be decrypted
    /// - Returns: Decrypted UTF8 string representation of the given data
    /// - Throws: `VAUError` in case of decryption failure or when the decrypted data could not be validated
    func decrypt(data: Data) throws -> String
}

class EciesVAUCryptoProvider: VAUCryptoProvider {
    func provide(
        for message: String,
        vauCertificate: VAUCertificate,
        bearerToken: BearerToken
    ) throws -> VAUCrypto {
        guard let vauPublicKey = vauCertificate.brainpoolP256r1KeyExchangePublicKey else {
            throw VAUError.certificateDecoding
        }
        let requestIdGenerator = { try VAURandom.generateSecureRandom(length: 16).hexStringLowerCase }
        let symmetricKeyGenerator = { SymmetricKey(size: SymmetricKeySize(bitCount: 128)) }
        let eciesSpec = Ecies.Spec.v1

        return try EciesVAUCrypto(
            message: message,
            vauPublicKey: vauPublicKey,
            bearerToken: bearerToken,
            requestIdGenerator: requestIdGenerator,
            symmetricKeyGenerator: symmetricKeyGenerator,
            eciesSpec: eciesSpec
        )
    }
}

class EciesVAUCrypto: VAUCrypto {
    private let message: String
    private let vauPublicKey: BrainpoolP256r1.KeyExchange.PublicKey
    private let bearerToken: BearerToken
    private let requestId: String
    private let symmetricKey: SymmetricKey
    private let eciesSpec: Ecies.Spec

    init(
        message: String,
        vauPublicKey: BrainpoolP256r1.KeyExchange.PublicKey,
        bearerToken: BearerToken,
        requestIdGenerator: () throws -> String,
        symmetricKeyGenerator: () throws -> SymmetricKey,
        eciesSpec: Ecies.Spec = Ecies.Spec.v1
    ) throws {
        self.message = message
        self.vauPublicKey = vauPublicKey
        self.bearerToken = bearerToken
        requestId = try requestIdGenerator()
        symmetricKey = try symmetricKeyGenerator()
        self.eciesSpec = eciesSpec
    }

    func encrypt() throws -> Data {
        // Build payload message
        let symKeyHex = symmetricKey.withUnsafeBytes { Data(Array($0)) }.hexStringLowerCase
        // [REQ:gemSpec_Krypt:A_20161-01:5]
        guard let payload = "1 \(bearerToken) \(requestId) \(symKeyHex) \(message)".data(using: .utf8) else {
            throw VAUError.internalCryptoError
        }
        let nonceGenerator = { try VAURandom.generateSecureRandom(length: self.eciesSpec.ivSize) }
        // [REQ:gemSpec_Krypt:GS-A_4357] Key pair generation delegated to OpenSSL with BrainpoolP256r1 parameters
        let keyPairGenerator = { try BrainpoolP256r1.KeyExchange.generateKey() }

        return try Ecies.encrypt(
            payload: payload,
            vauPubKey: vauPublicKey,
            spec: eciesSpec,
            nonceDataGenerator: nonceGenerator,
            keyPairGenerator: keyPairGenerator
        )
    }

    func decrypt(data: Data) throws -> String {
        // Steps according to gemSpec_Krypt A_20174
        // [REQ:gemSpec_Krypt:A_20174:3] Decrypt using AES symmetric key
        guard let sealed = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(sealed, using: symmetricKey),
              let utf8 = decrypted.utf8string
        else {
            throw VAUError.responseValidation
        }

        // [REQ:gemSpec_Krypt:A_20174:4,5] Verify decrypted message. Expect: "1 <request id> <response header and body>"
        let separated = utf8.split(separator: " ", maxSplits: 2).map { String($0) }
        guard separated.count == 3,
              separated[0] == "1",
              separated[1] == requestId
        else {
            throw VAUError.responseValidation
        }

        return separated[2]
    }
}

enum Ecies {
    /// Perform Elliptic Curve Integrated Encryption Scheme [SEC1-2009] on some payload
    /// [REQ:gemSpec_Krypt:A_20161-01:6a-g]
    static func encrypt(
        payload: Data,
        vauPubKey: BrainpoolP256r1.KeyExchange.PublicKey,
        spec: Spec,
        nonceDataGenerator: () throws -> Data,
        keyPairGenerator: () throws -> BrainpoolP256r1.KeyExchange.PrivateKey
    ) throws -> Data {
        // a) Create an ephemeral key pair and derive shared secret with key from the VAU certificate
        let privateKey = try keyPairGenerator()
        let sharedSecret = try privateKey.sharedSecret(with: vauPubKey)
        let secretKey = SymmetricKey(data: sharedSecret)

        // b-d) HKDF
        #if os(iOS)
        let cek = HKDF<SHA256>.deriveKey(inputKeyMaterial: secretKey,
                                         info: spec.info,
                                         outputByteCount: spec.hkdfOutputCount)
        #else
        // TODO: HKDF not available in macOS 10.15, see also VAUCryptoTests // swiftlint:disable:this todo
        let cek = SymmetricKey(data: Data())
        #endif

        // e) Generate nonce
        let nonceData = try nonceDataGenerator()
        let nonce = try AES.GCM.Nonce(data: nonceData)

        // f) Encrypt
        let sealedBox = try AES.GCM.seal(payload, using: cek, nonce: nonce)

        // g) Encode
        return try Data(
            [spec.version] +
                privateKey.publicKey.x962Value().dropFirst() + // drop first 0x04 byte from uncompressed representation
                sealedBox.nonce +
                sealedBox.ciphertext +
                sealedBox.tag
        )
    }

    struct Spec {
        let version: UInt8
        let ivSize: Int
        let info: Data
        let hkdfOutputCount: Int

        static let v1 = Spec( // swiftlint:disable:this identifier_name
            version: 0x1,
            ivSize: 12,
            info: "ecies-vau-transport".data(using: .utf8)!, // swiftlint:disable:this force_unwrapping
            hkdfOutputCount: 16
        )
    }
}

extension Data {
    var hexStringLowerCase: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
