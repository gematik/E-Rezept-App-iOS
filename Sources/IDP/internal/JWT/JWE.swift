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
import DataKit
import Foundation
import OpenSSL

/// JSON Web Encryption (JWE) - Container format holding a payload and the corresponding
/// ciphertext along with encryption information.
///
/// A JWE represents these logical values
///   - JOSE Header
///   - JWE Encrypted Key (not used)
///   - JWE Initialization Vector (IV)
///   - JWE AAD (not implemented)
///   - JWE Ciphertext
///   - JWE Authentication Tag
///
/// Construct using a payload `JWE(withPayload:algorithm:encryption:nonceGenerator:)`
/// or a ciphertext `JWE.from(:with:)`.
///
/// https://tools.ietf.org/html/rfc7516
public struct JWE {
    /// Structure for the actual JWE header, wrapped key, iv, ciphertext and tag as specified in rfc7516.
    struct Backing {
        let header: Data
        let wrappedKey: Data
        let iv: Data // swiftlint:disable:this identifier_name
        let ciphertext: Data
        let tag: Data
    }

    private let backing: Backing
    let payload: Data

    /// Default initializer to create a JWE by encrypting the passed payload with the
    /// algorithm and encryption defined in the header
    /// - Parameters:
    ///   - header: Header of the JWE with information about the encryption
    ///   - payload: The payload of the JWE that will be encrypted
    ///   - nonceGenerator: Nonce used for generating the shared secret
    /// - Throws: If JWE encryption fails
    init(header: Header,
         payload: Data,
         nonceGenerator: () throws -> Data) throws {
        self.payload = payload
        backing = try header.encryption.encrypt(payload: payload,
                                                header: header,
                                                nonceGenerator: nonceGenerator)
    }

    /// Initializes a JWE container struct with already calculated data.
    ///
    /// If you want to encrypt a payload see `init(withPayload:algorithm:encryption)`, if you want to decrypt an
    /// existing JWE see `JWE.from(encrypted:with:)`
    ///
    /// - Parameters:
    ///   - backing: The Backing data containing the JWE and the encrypted payload
    ///   - payload: The unencrypted payload
    private init(with backing: Backing, decryptedPayload payload: Data) {
        self.backing = backing
        self.payload = payload
    }

    /// Use this initializer to create a JWE struct from the passed  data with an encrypted payload.
    /// For decrypting the payload `DecryptionAlgorithm` is used.
    ///
    /// - Parameters:
    ///   - encryptedData: a JWE data blob with an encrypted payload
    ///   - decryptionAlgorithm: specifies the description algorithm that will be used to decrypt the JWE payload
    /// - Throws: If JWE is invalid or encryption fails
    /// - Returns: A JWE structure containing the 5 elements with the payload already decrypted
    static func from(_ encryptedData: Data, with decryptionAlgorithm: DecryptionAlgorithm) throws -> Self {
        let elements = encryptedData.split(separator: JWE.delimiter, omittingEmptySubsequences: false)

        guard elements.count == 5 else {
            throw Error.invalidJWE
        }

        let backing = Backing(
            header: try elements[0].decodeBase64URLEncoded(),
            wrappedKey: try elements[1].decodeBase64URLEncoded(),
            iv: try elements[2].decodeBase64URLEncoded(),
            ciphertext: try elements[3].decodeBase64URLEncoded(),
            tag: try elements[4].decodeBase64URLEncoded()
        )

        let payload: Data

        switch decryptionAlgorithm {
        case let .plain(symmetricKey):
            payload = try Decryption.a256gcm(symmetricKey).decrypt(jwe: backing)
        }

        return JWE(with: backing, decryptedPayload: payload)
    }
}

extension JWE {
    enum Error: Swift.Error {
        case invalidJWE // Must contain 5 parts (4 dots)
        case encodingError
    }
}

extension JWE {
    struct Header: Encodable {
        /// algorithm used for encrypting the JWE
        var alg: String
        /// Encryption type
        var enc: String {
            switch encryption {
            case .a256gcm:
                return "A256GCM"
            }
        }

        /// expiry date of the payload (the original challenge)
        let exp: Date?
        /// Content type of the JWE (e.g. JWT, NJWT)
        let cty: String
        /// Token Type, e.g. JWT
        let typ: String?
        /// Ephemeral public key that is used by the server for decryption
        var epk: JWK {
            encryptionContext.ephemeralPublicKey
        }

        /// Encryption object which performs the actual encryption
        let encryption: Encryption
        /// Key material used for encryption
        let encryptionContext: EncryptionContext

        init(
            algorithm: Algorithm,
            encryption: Encryption,
            expiry: Date? = nil,
            contentType: String,
            type: String? = nil
        ) throws {
            self.encryption = encryption
            encryptionContext = try algorithm.encryptionContext()
            exp = expiry
            cty = contentType
            typ = type
            switch algorithm {
            case .ecdh_es:
                alg = "ECDH-ES"
            }
        }

        init(
            encryptionContext: EncryptionContext,
            alg: String,
            encryption: Encryption,
            expiry: Date? = nil,
            contentType: String,
            type: String? = nil
        ) {
            self.encryptionContext = encryptionContext
            self.alg = alg
            self.encryption = encryption
            exp = expiry
            cty = contentType
            typ = type
        }

        enum CodingKeys: CodingKey {
            case alg
            case enc
            case cty
            case typ
            case exp
            case epk
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(enc, forKey: .enc)
            try container.encode(alg, forKey: .alg)
            try container.encode(cty, forKey: .cty)
            try container.encodeIfPresent(exp, forKey: .exp)
            try container.encodeIfPresent(typ, forKey: .typ)
            try container.encode(epk, forKey: .epk)
        }
    }
}

extension JWK {
    /// Initializer for creating a  JWK (JSON web key) from a brainpool curve's public key
    /// - Parameter publicKey: A brainpoolP256r1 public key
    /// - Throws: When encoding the coordinates from the public key falis
    /// - Returns: A JWK
    static func from(brainpoolP256r1 publicKey: BrainpoolP256r1.KeyExchange.PublicKey) throws -> Self {
        // Contains  04 || x || y
        let raw = publicKey.x962Value

        // index 0 contains 04, representing `uncompressed`
        let rangeX: Range<Data.Index> = 1 ..< 33
        let rangeY: Range<Data.Index> = 33 ..< 65

        guard let xCoordinate = raw.subdata(in: rangeX).encodeBase64urlsafe().utf8string,
              let yCoordinate = raw.subdata(in: rangeY).encodeBase64urlsafe().utf8string else {
            throw JWE.Error.encodingError
        }

        return JWK(kty: "EC", crv: "BP-256", x: xCoordinate, y: yCoordinate)
    }
}

enum IDPRandom {
    /// Generate random Data with given length
    ///
    /// - Parameters:
    ///   - length: the number of bytes to generate
    ///   - randomizer: the randomizer to be used. Default: kSecRandomDefault
    /// - Returns: the random initialized Data
    /// - Throws: `VAUError`
    static func generateSecureRandom(length: Int, randomizer: SecRandomRef? = kSecRandomDefault) throws -> Data {
        var randomBytesBuffer = [UInt8](repeating: 0x0, count: length)
        let rcStatus: OSStatus = try randomBytesBuffer
            .withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
                guard let ptr = buffer.baseAddress else {
                    throw IDPError.internalError("Invalid byte buffer")
                }
                return SecRandomCopyBytes(randomizer, length, ptr)
            }
        guard rcStatus == errSecSuccess else {
            throw IDPError.internalError("Could not generate Random bytes. [Count: \(length)]")
        }
        return Data(randomBytesBuffer)
    }
}

extension JWE {
    private static let delimiter = UInt8(0x2E)

    func encoded() -> Data {
        backing.encoded()
    }
}

extension Data {
    // TODO: Workaround for bug in DataKit swiftlint:disable:this todo
    func safeEncodeBase64urlsafe() -> Data {
        if count > 2 {
            return encodeBase64urlsafe()
        }
        return self
    }
}

extension JWE.Backing {
    private static let dot = Data([0x2E]) // "."

    func encoded() -> Data {
        header.safeEncodeBase64urlsafe() + Self.dot +
            wrappedKey.safeEncodeBase64urlsafe() + Self.dot +
            iv.safeEncodeBase64urlsafe() + Self.dot +
            ciphertext.safeEncodeBase64urlsafe() + Self.dot +
            tag.safeEncodeBase64urlsafe()
    }
}
