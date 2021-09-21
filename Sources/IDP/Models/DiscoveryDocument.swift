//
//  Copyright (c) 2021 gematik GmbH
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

import DataKit
import Foundation
import OpenSSL

/// IDP Endpoint
public protocol IDPEndpoint {
    /// Endpoint URL
    var url: URL { get }
    /// Certificate that can validate responses from `url`
    var cert: X509 { get }
}

extension BrainpoolP256r1.KeyExchange.PublicKey: Equatable {
    public static func ==(lhs: BrainpoolP256r1.KeyExchange.PublicKey,
                          rhs: BrainpoolP256r1.KeyExchange.PublicKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

/// IDP Discovery document
public struct DiscoveryDocument: Codable {
    let createdOn: Date

    let backing: JWT
    let payload: DiscoveryDocumentPayload
    /// The IDP X.509 certificate used to validate the discovery document
    public let discKey: X509
    /// The IDP Authentication endpoint public key, used to derivce the encryption key to encrypt the JWE‘s
    let encryptionPublicKey: BrainpoolP256r1.KeyExchange.PublicKey
    /// The IDP X.509 certificate that is used to check signatures
    public let signingCert: X509

    /// Initialize as Decodable
    ///
    /// - Parameter decoder: the decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backing = try container.decode(JWT.self, forKey: .payload)
        payload = try backing.decodePayload(type: DiscoveryDocumentPayload.self)
        encryptionPublicKey = try BrainpoolP256r1.KeyExchange
            .PublicKey(x962: try container.decode(Data.self, forKey: .encryptionPublicKey))
        signingCert = try X509(der: container.decode(Data.self, forKey: .tokenKey))
        guard let discHeaderX5C = backing.header.x5c?.first else {
            throw IDPError.noCertificateFound
        }
        discKey = try X509(der: discHeaderX5C)
        createdOn = try container.decode(Date.self, forKey: .createdOn)
    }

    /// Encode the DiscoveryDocument according to the Encodable protocol
    ///
    /// - Parameter encoder: the encoder
    /// - Throws:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backing, forKey: .payload)
        try container.encode(encryptionPublicKey.x962Value, forKey: .encryptionPublicKey)
        try container.encode(signingCert.derBytes, forKey: .tokenKey)
        try container.encode(createdOn, forKey: .createdOn)
    }

    internal init(jwt: JWT, encryptPuks: JWK, signingPuks: JWK, createdOn: Date = Date()) throws {
        backing = jwt
        /// Get from every set the first key we encounter and use/set it accordingly
        guard let signingX5C = signingPuks.x5c?.first else {
            throw IDPError.noCertificateFound
        }
        signingCert = try X509(der: signingX5C)

        if let encryptX5c = encryptPuks.x5c?.first,
           let certPublicKey = try X509(der: encryptX5c).brainpoolP256r1KeyExchangePublicKey() {
            encryptionPublicKey = certPublicKey
        } else {
            do {
                guard let pubKeyX962 = try encryptPuks.publicKeyX962UncompressedRepresentation() else {
                    throw IDPError.noCertificateFound
                }
                encryptionPublicKey = try BrainpoolP256r1.KeyExchange.PublicKey(x962: pubKeyX962)
            } catch {
                throw IDPError.noCertificateFound
            }
        }
        guard let discHeaderX5C = jwt.header.x5c?.first else {
            throw IDPError.noCertificateFound
        }
        discKey = try X509(der: discHeaderX5C)
        payload = try jwt.decodePayload(type: DiscoveryDocumentPayload.self)
        self.createdOn = createdOn
    }

    /// IDP Authentication endpoint
    public var authentication: IDPEndpoint {
        Endpoint(url: payload.authentication.correct(), cert: signingCert)
    }

    /// IDP Authentication endpoint
    public var sso: IDPEndpoint {
        Endpoint(url: payload.sso.correct(), cert: signingCert)
    }

    /// IDP Token exchange endpoint
    public var token: IDPEndpoint {
        Endpoint(url: payload.token.correct(), cert: signingCert)
    }

    public var pairing: IDPEndpoint {
        Endpoint(url: payload.pairing, cert: signingCert)
    }

    public var authenticationPaired: IDPEndpoint {
        Endpoint(url: payload.authenticationPair.correct(), cert: signingCert)
    }

    /// Expiration date
    public var expiresOn: Date {
        payload.exp
    }

    /// Issued date
    public var issuedAt: Date {
        payload.iat
    }
}

extension DiscoveryDocument: Equatable {}

extension DiscoveryDocument {
    struct Endpoint: IDPEndpoint {
        let url: URL
        let cert: X509
    }

    private enum CodingKeys: String, CodingKey {
        case payload
        case authKey = "puk_auth"
        case tokenKey = "puk_token"
        case encryptionPublicKey
        case createdOn
    }
}

extension DiscoveryDocument {
    // [REQ:gemSpec_IDP_Frontend:A_20512]
    func isValid(on date: Date) -> Bool {
        date <= expiresOn &&
            date >= createdOn &&
            date <= createdOn.addingTimeInterval(60 * 60 * 24)
    }
}

extension URL {
    func domainReplacingOccurrences(of find: String, with replace: String) -> URL {
        // swiftlint:disable force_unwrapping
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.host = components.host!.replacingOccurrences(of: find, with: replace)
        return components.url!
        // swiftlint:enable force_unwrapping
    }

    func correct() -> URL {
        domainReplacingOccurrences(of: ".zentral.idp.splitdns.ti-dienste.de", with: ".app.ti-dienste.de")
    }
}
