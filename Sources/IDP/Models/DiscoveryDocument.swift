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
import OpenSSL

/// IDP Endpoint
public protocol IDPEndpoint {
    /// Endpoint URL
    var url: URL { get }
    /// Certificate that can validate responses from `url`
    var cert: IDPX509 { get }
}

/// IDP Discovery document
public struct DiscoveryDocument {
    /// The date on which this discovery document was created/fetched
    public let createdOn: Date
    /// The raw JWT backing this discovery document
    public let backing: JWT
    /// The decoded payload of the discovery document JWT
    public let payload: DiscoveryDocumentPayload
    /// The IDP X.509 certificate used to validate the discovery document
    public let discKey: IDPX509
    /// The IDP Authentication endpoint public key, used to derivce the encryption key to encrypt the JWE‘s
    public let encryptionPublicKey: BrainpoolP256r1.KeyExchange.PublicKey
    /// The IDP X.509 certificate that is used to check signatures
    public let signingCert: IDPX509

    /// Creates a new `DiscoveryDocument`
    /// - Parameters:
    ///   - createdOn: The date on which this document was created/fetched
    ///   - backing: The raw JWT backing this document
    ///   - payload: The decoded payload of the discovery document JWT
    ///   - discKey: The X.509 certificate used to validate this discovery document
    ///   - encryptionPublicKey: The public key used to derive the JWE encryption key
    ///   - signingCert: The X.509 certificate used to verify signatures
    public init(
        createdOn: Date,
        backing: JWT,
        payload: DiscoveryDocumentPayload,
        discKey: IDPX509,
        encryptionPublicKey: BrainpoolP256r1.KeyExchange.PublicKey,
        signingCert: IDPX509
    ) {
        self.createdOn = createdOn
        self.backing = backing
        self.payload = payload
        self.discKey = discKey
        self.encryptionPublicKey = encryptionPublicKey
        self.signingCert = signingCert
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

    /// IDP Pairing endpoint
    public var pairing: IDPEndpoint {
        Endpoint(url: payload.pairing, cert: signingCert)
    }

    /// IDP Authentication endpoint for paired devices
    public var authenticationPaired: IDPEndpoint {
        Endpoint(url: payload.authenticationPair.correct(), cert: signingCert)
    }

    /// IDP KK app directory endpoint
    @available(*, deprecated, renamed: "directoryKKAppsgId", message: "Not allowed anymore by 01.01.2024")
    public var directoryKKApps: IDPEndpoint? {
        guard let url = payload.kkAppList else {
            return nil
        }
        return Endpoint(url: url.correct(), cert: signingCert)
    }

    /// IDP KK app directory endpoint using gId
    public var directoryKKAppsgId: IDPEndpoint? {
        guard let url = payload.kkAppListgId else {
            return nil
        }
        return Endpoint(url: url.correct(), cert: signingCert)
    }

    /// IDP third-party authentication endpoint, if supported by this IDP
    public var thirdPartyAuth: IDPEndpoint? {
        guard let url = payload.thirdPartyAuth else {
            return nil
        }
        return Endpoint(url: url.correct(), cert: signingCert)
    }

    /// IDP federation authentication endpoint, if supported by this IDP
    public var federationAuth: IDPEndpoint? {
        guard let url = payload.federationAuth else {
            return nil
        }
        return Endpoint(url: url.correct(), cert: signingCert)
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

extension DiscoveryDocument {
    struct Endpoint: IDPEndpoint {
        let url: URL
        let cert: IDPX509
    }
}

extension DiscoveryDocument {
    // [REQ:gemSpec_IDP_Frontend:A_20512#2|5] Validation by expiration date checking + maximum of 24h window
    /// Check if the discovery document is valid on the given date
    /// - Parameter date: Date to check validity against
    /// - Returns: Boolean indicating if the document is valid
    public func isValid(on date: Date) -> Bool {
        date <= expiresOn &&
            date >= createdOn &&
            date <= createdOn.addingTimeInterval(60 * 60 * 24)
    }
}
