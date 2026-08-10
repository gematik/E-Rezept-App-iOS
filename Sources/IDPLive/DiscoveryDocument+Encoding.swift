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
import IDP
import OpenSSL

extension DiscoveryDocument {
    /// Initialize a DiscoveryDocument from a JWT and the corresponding JWKs for encryption and signing
    public init(jwt: JWT, encryptPuks: JWK, signingPuks: JWK, createdOn: Date = Date()) throws {
        let backing = jwt
        // Get from every set the first key we encounter and use/set it accordingly
        guard let signingX5C = signingPuks.x5c?.first else {
            throw IDPError.noCertificateFound
        }
        let signingCert = try X509(der: signingX5C)
        let encryptionPublicKey: BrainpoolP256r1.KeyExchange.PublicKey

        if let encryptX5c = encryptPuks.x5c?.first,
           let certPublicKey = try X509(der: encryptX5c).brainpoolP256r1KeyExchangePublicKey() {
            encryptionPublicKey = certPublicKey
        } else {
            do {
                guard let pubKeyX962 = encryptPuks.publicKeyX962UncompressedRepresentation() else {
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
        let discKey = try X509(der: discHeaderX5C)
        let payload = try jwt.decodePayload(type: DiscoveryDocumentPayload.self)
        let createdOn = createdOn

        self.init(
            createdOn: createdOn,
            backing: backing,
            payload: payload,
            discKey: discKey,
            encryptionPublicKey: encryptionPublicKey,
            signingCert: signingCert
        )
    }
}

extension DiscoveryDocument: Codable {
    /// Initialize as Decodable
    ///
    /// - Parameter decoder: the decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let backing = try container.decode(JWT.self, forKey: .payload)
        let payload = try backing.decodePayload(type: DiscoveryDocumentPayload.self)
        let encryptionPublicKey = try BrainpoolP256r1.KeyExchange
            .PublicKey(x962: container.decode(Data.self, forKey: .encryptionPublicKey))
        let signingCert = try X509(der: container.decode(Data.self, forKey: .tokenKey))
        guard let discHeaderX5C = backing.header.x5c?.first else {
            throw IDPError.noCertificateFound
        }
        let discKey = try X509(der: discHeaderX5C)
        let createdOn = try container.decode(Date.self, forKey: .createdOn)

        self.init(
            createdOn: createdOn,
            backing: backing,
            payload: payload,
            discKey: discKey,
            encryptionPublicKey: encryptionPublicKey,
            signingCert: signingCert
        )
    }

    /// Encode the DiscoveryDocument according to the Encodable protocol
    ///
    /// - Parameter encoder: the encoder
    /// - Throws:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backing, forKey: .payload)
        try container.encode(encryptionPublicKey.x962Value(), forKey: .encryptionPublicKey)
        try container.encode(signingCert.derBytes, forKey: .tokenKey)
        try container.encode(createdOn, forKey: .createdOn)
    }

    private enum CodingKeys: String, CodingKey {
        case payload
        case authKey = "puk_auth"
        case tokenKey = "puk_token"
        case encryptionPublicKey
        case createdOn
    }
}

extension JWK {
    /// Creates a `x962` representation of the x and y values of the JWK.  The format follows the ANSI X9.62 standard
    /// using a byte string of 04 || X || Y . Hexadecimal representation should start with 0x04.
    /// see: https://www.secg.org/SEC1-Ver-1.0.pdf 2.3.3 EllipticCurvePoint-to-OctetString Conversion
    public func publicKeyX962UncompressedRepresentation(padToByteCount: Int = 32) -> Data? {
        if let xBase64Decoded = x?.decodeBase64URLEncoded(),
           let yBase64Decoded = y?.decodeBase64URLEncoded() {
            return Data([0x04] +
                xBase64Decoded.dropLeadingZeroByte.padWithLeadingZeroes(totalLength: padToByteCount) +
                yBase64Decoded.dropLeadingZeroByte.padWithLeadingZeroes(totalLength: padToByteCount))
        } else {
            return nil
        }
    }
}
