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
import Combine
import CryptoKit
import Foundation

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
    public init(header: Header,
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

        guard
            let header = elements[0].decodeBase64URLEncoded(),
            let wrappedKey = elements[1].decodeBase64URLEncoded(),
            let iv = elements[2].decodeBase64URLEncoded(), // swiftlint:disable:this identifier_name
            let ciphertext = elements[3].decodeBase64URLEncoded(),
            let tag = elements[4].decodeBase64URLEncoded()
        else {
            throw Error.encodingError
        }

        let backing = Backing(
            header: header,
            wrappedKey: wrappedKey,
            iv: iv,
            ciphertext: ciphertext,
            tag: tag
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
    @CodedError("103")
    public enum Error: Swift.Error {
        @ErrorCode("01")
        case invalidJWE // Must contain 5 parts (4 dots)
        @ErrorCode("02")
        case encodingError
    }
}

extension JWE {
    public struct Header: Encodable {
        /// algorithm used for encrypting the JWE
        public var alg: String
        /// Encryption type
        var enc: String {
            switch encryption {
            case .a256gcm:
                return "A256GCM"
            }
        }

        /// expiry date of the payload (the original challenge)
        public let exp: Date?
        /// Content type of the JWE (e.g. JWT, NJWT)
        public let cty: String
        /// Token Type, e.g. JWT
        public let typ: String?
        /// Ephemeral public key that is used by the server for decryption
        var epk: JWK {
            encryptionContext.ephemeralPublicKey
        }

        /// Encryption object which performs the actual encryption
        public let encryption: Encryption
        /// Key material used for encryption
        public let encryptionContext: EncryptionContext

        public init(
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

        public func encode(to encoder: Encoder) throws {
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

extension JWE {
    private static let delimiter = UInt8(0x2E)

    /// Encode the JWE to its compact serialization format
    /// - Returns: Data containing the encoded JWE
    public func encoded() -> Data {
        backing.encoded()
    }
}

extension JWE.Backing {
    private static let dot = Data([0x2E]) // "."

    /// Encode the JWE backing data to compact serialization format
    /// - Returns: Data containing the encoded JWE components
    func encoded() -> Data {
        let encodedHeader = header.encodeBase64UrlSafe() ?? Data()
        let encodedWrappedKey = wrappedKey.encodeBase64UrlSafe() ?? Data()
        let encodedIV = iv.encodeBase64UrlSafe() ?? Data()
        let encodedCiphertext = ciphertext.encodeBase64UrlSafe() ?? Data()
        let encodedTag = tag.encodeBase64UrlSafe() ?? Data()
        return encodedHeader + Self.dot +
            encodedWrappedKey + Self.dot +
            encodedIV + Self.dot +
            encodedCiphertext + Self.dot +
            encodedTag
    }
}

extension JWE {
    /// Decryption algorithm for JWE
    enum DecryptionAlgorithm {
        case plain(SymmetricKey)
    }
}
