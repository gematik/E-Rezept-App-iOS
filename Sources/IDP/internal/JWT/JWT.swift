//
//  Copyright (c) 2024 gematik GmbH
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
import Foundation

typealias Base64URLEncodedData = Data

/// JSON Web Token - https://tools.ietf.org/html/rfc7519
public struct JWT {
    // swiftlint:disable:next large_tuple
    private let backing: (rawHeader: Base64URLEncodedData, payload: Base64URLEncodedData, signature: Data?)

    /// The parsed Header information
    public let header: Header

    /// Raw signature bytes [when available]
    public var signature: Data? {
        backing.signature
    }

    /// Initialize a JWT from Data
    /// - Parameters:
    ///   - data: JWT data should be utf8 decodable
    /// - Throws: `JWT.Error`
    init(from data: Data) throws {
        guard let string = String(data: data, encoding: .ascii) else {
            throw Error.malformedJWT
        }
        try self.init(from: string)
    }

    /// Initialize a JWT from String
    /// - Parameters:
    ///   - string: JWT string that should be formatted according to the RFC-7519 JWT specification
    ///   - decoder: JSONDecoder needed with dateDecodingStrategy = .secondsSince1970 and dataDecodingStrategy = .base64
    /// - Throws: `JWT.Error`
    public init(from string: String, decoder: JSONDecoder = JSONDecoder.base1970DateDecoder) throws {
        /// Regex magic
        /// if we find a match we should have a parsable JWT structure.
        /// Note: the signature is not validated at this point
        let result = Self.jwtRegex.matches(in: string, range: NSRange(location: 0, length: string.count))
        guard !result.isEmpty else {
            throw Error.malformedJWT
        }
        /// We should have one match
        /// Match locations:
        /// 0: Entire string that matched
        /// 1: Header
        /// 2: Payload
        /// 3: The dot (.) between payload and signature. Is its own group since it's optional
        /// 4: The signature. The signature payload subgroup of 3. ^^
        ///
        /// Example:
        /// Regex: `^([A-Za-z0-9-_]+)\.([A-Za-z0-9-_]+)(\.([A-Za-z0-9-_]+))?$`
        /// JWT: eyAiYWxnIjogIm5vbmUiIH0.eyJwYXlsb2FkIjoidGV4dCJ9.MXUq3IrpzRL6Rc0Q8RP1987yAvUm2JoRQjvtGgJBNeg-MF6QJiuQQ
        /// 0: eyAiYWxnIjogIm5vbmUiIH0.eyJwYXlsb2FkIjoidGV4dCJ9.MXUq3IrpzRL6Rc0Q8RP1987yAvUm2JoRQjvtGgJBNeg-MF6QJiuQQ
        /// 1: eyAiYWxnIjogIm5vbmUiIH0
        /// 2:                         eyJwYXlsb2FkIjoidGV4dCJ9
        /// 3:                                                 .MXUq3IrpzRL6Rc0Q8RP1987yAvUm2JoRQjvtGgJBNeg-MF6QJiuQQ
        /// 4:                                                  MXUq3IrpzRL6Rc0Q8RP1987yAvUm2JoRQjvtGgJBNeg-MF6QJiuQQ
        guard let rawHeader = (string as NSString).substring(with: result[0].range(at: 1)).data(using: .ascii),
              let payload = (string as NSString).substring(with: result[0].range(at: 2)).data(using: .ascii) else {
            throw Error.encodingError
        }
        if result[0].range(at: 4).location != NSNotFound {
            backing = (
                rawHeader,
                payload,
                (string as NSString).substring(with: result[0].range(at: 4)).decodeBase64URLEncoded()
            )
        } else {
            // No signature
            backing = (
                rawHeader,
                payload,
                nil
            )
        }
        header = try Self.header(from: rawHeader, parser: decoder)
    }

    private static func header(from data: Base64URLEncodedData, parser: JSONDecoder) throws -> Header {
        guard let decodedData = data.decodeBase64URLEncoded() else {
            throw Error.encodingError
        }
        return try parser.decode(Header.self, from: decodedData)
    }

    /// JSON Decode the payload into a given `type`
    ///
    /// - Parameters:
    ///   - type: model type to map the payload onto
    /// - Returns: decoded instance of `type`
    /// - Throws: An error if any value throws an error during decoding.
    public func decodePayload<T: Claims>(type: T.Type) throws -> T {
        guard let decodedPayload = backing.payload.decodeBase64URLEncoded() else {
            throw Error.encodingError
        }
        return try JSONDecoder.base1970DateDecoder.decode(type, from: decodedPayload)
    }

    /// Verify the JWT by checking the signature
    public func verify(with verifier: JWTSignatureVerifier) throws -> Bool {
        guard let signature = signature else {
            throw Error.noSignature
        }
        return try verifier.verify(signature: signature, message: backing.rawHeader + Self.dot + backing.payload)
    }

    static let dot = Data([0x2E]) // .

    /// Signs the JWT with a given signer.
    ///
    /// - Parameter signer: `JWTSigner` that is used to create the signature
    /// - Returns: A stream that publishes the signed `JWT` if successful, an `Swift.Error` otherwise.
    public func sign(with signer: JWTSigner) -> AnyPublisher<JWT, Swift.Error> {
        let data = backing.rawHeader + Self.dot + backing.payload
        return Future {
            try await signer.sign(message: data)
        }
        .tryMap { (signature: Data) -> JWT in
            guard let encodedSignature = signature.encodeBase64UrlSafe()
            else { throw Error.encodingError }
            return try JWT(from: data + Self.dot + encodedSignature)
        }
        .eraseToAnyPublisher()
    }

    /// Serialize the JWT
    ///
    /// - Returns: serialized base64 urlsafe encoded string
    public func serialize() -> String {
        var data = backing.rawHeader + Self.dot + backing.payload
        if let signature = signature,
           let encodedSignature = signature.encodeBase64UrlSafe() {
            data.append(Self.dot) // .
            data.append(encodedSignature)
        }
        return String(data: data, encoding: .nonLossyASCII)! // swiftlint:disable:this force_unwrapping
    }

    private static let jwtRegex =
        try! NSRegularExpression(pattern: "^([A-Za-z0-9-_]+)\\.([A-Za-z0-9-_]+)(\\.([A-Za-z0-9-_]+))?$")
    // swiftlint:disable:previous force_try
}

extension JWT: Equatable {
    public static func ==(lhs: JWT, rhs: JWT) -> Bool {
        lhs.backing == rhs.backing
    }
}

extension JWT: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(from: container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(serialize())
    }
}

extension JWT {
    /// JOSE Header - https://tools.ietf.org/html/rfc7519#section-5.1
    public struct Header: Codable {
        /// Signature algorithm
        public let alg: Algorithm?

        /// X.509 certificate chain (DER encoded)
        public let x5c: [Data]?
        // swiftlint:disable:previous discouraged_optional_collection

        /// Type
        /// JWT: RFC-7519  | JWS: RFC-7515 | JWE: RFC-7516
        public let typ: String?

        /// Key ID
        public let kid: String?

        /// Content type
        public let cty: String?

        /// JWT ID
        public let jti: String?

        public init(
            alg: Algorithm? = nil,
            x5c: [Data]? = nil, // swiftlint:disable:this discouraged_optional_collection
            typ: String? = nil,
            kid: String? = nil,
            cty: String? = nil,
            jti: String? = nil
        ) {
            self.alg = alg
            self.x5c = x5c
            self.typ = typ
            self.kid = kid
            self.cty = cty
            self.jti = jti
        }
    }
}

extension JWT {
    /// Create a JWT from a given header with payload
    ///
    /// - Parameters:
    ///   - header: the JWT Header
    ///   - payload: JSON encodable payload
    /// - Throws: `Swift.Error` upon JSON encoding error
    public init<E: Claims>(header: Header, payload: E) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        jsonEncoder.outputFormatting = .sortedKeys

        let header = try jsonEncoder.encode(header)
        let serializedPayload = try jsonEncoder.encode(payload)
        guard let encodedHeader = header.encodeBase64UrlSafe(),
              let encodedPayload = serializedPayload.encodeBase64UrlSafe()
        else { throw Error.encodingError }
        try self.init(from: encodedHeader + JWT.dot + encodedPayload)
    }
}

extension JWT {
    public enum Algorithm: String, Codable {
        case none
        case bp256r1 = "BP256R1"
        case secp256r1 = "ES256"
    }
}

extension JWT {
    // sourcery: CodedError = "104"
    public enum Error: Swift.Error, LocalizedError {
        // sourcery: errorCode = "01"
        case malformedJWT
        // sourcery: errorCode = "02"
        case noSignature
        // sourcery: errorCode = "03"
        case encodingError
        // sourcery: errorCode = "04"
        case invalidSignature
        // sourcery: errorCode = "05"
        case invalidExpirationDate

        public var errorDescription: String? {
            switch self {
            case .malformedJWT: return "JWTError.malformedJWT"
            case .noSignature: return "JWTError.noSignature"
            case .encodingError: return "JWTError.encodingError"
            case .invalidSignature: return "JWTError.invalidSignature"
            case .invalidExpirationDate: return "JWTError.invalidExpirationDate"
            }
        }
    }
}

extension JSONDecoder {
    /// A JSONDecoder that uses .secondsSince1970 and .base64 for dateDecodingStrategy
    public static var base1970DateDecoder: JSONDecoder = {
        let jsonParser = JSONDecoder()
        jsonParser.dateDecodingStrategy = .secondsSince1970
        jsonParser.dataDecodingStrategy = .base64
        return jsonParser
    }()
}
