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

import Foundation

/// JSON Web Key(s) - https://tools.ietf.org/html/rfc7517
public struct JWKS: Codable {
    /// Key set
    public let keys: [JWK]
}

/// JSON Web Key(s) - https://tools.ietf.org/html/rfc7517
public struct JWK: Codable {
    // swiftlint:disable identifier_name

    /// Key type (e.g. EC, RSA)
    public let kty: String
    /// EC Curve name - when kty = EC
    public let crv: String?
    /// X coordinate - when kty = EC
    public let x: String?
    /// Y coordinate - when kty = EC
    public let y: String?
    /// Key usage (sig|enc)
    public let use: Use?
    /// Key ID
    public let kid: String?
    /// N param - when kty = RSA
    public let n: String?
    /// Exponent param - when kty = RSA
    public let e: String?
    /// Symmetric key - when kty = oct
    public let k: String?
    /// Algorithm (e.g. RS256)
    public let alg: String?
    /// X.509 Certificate
    public let x5c: [Data]? // swiftlint:disable:this discouraged_optional_collection

    public init(
        kty: String,
        crv: String? = nil,
        x: String? = nil,
        y: String? = nil,
        x5c: [Data]? = nil // swiftlint:disable:this discouraged_optional_collection
    ) {
        self.kty = kty
        self.crv = crv
        self.x = x
        self.y = y
        use = nil
        kid = nil
        n = nil
        e = nil
        k = nil
        alg = nil
        self.x5c = x5c
    }

    // swiftlint:enable identifier_name
}

extension JWKS: Equatable {}

extension JWK: Equatable {}

extension JWK {
    public enum Use: String, Codable {
        case signature = "sig"
        case encryption = "enc"
    }
}
