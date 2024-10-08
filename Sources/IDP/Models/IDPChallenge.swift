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

import Foundation

/// IDPChallenge
public struct IDPChallenge: Codable, Equatable {
    public struct Claim: Claims, Equatable {
        public let exp: Date?
        public let iat: Date?
        public let nbf: Date?

        public init(exp: Date? = nil, iat: Date? = nil, nbf: Date? = nil) {
            self.exp = exp
            self.iat = iat
            self.nbf = nbf
        }
    }

    public let challenge: JWT
    public let userConsent: UserConsent?
    private let claims: Claim

    public init(challenge: JWT, consent: UserConsent? = nil) throws {
        self.challenge = challenge
        claims = try challenge.decodePayload(type: Claim.self)
        userConsent = consent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            challenge: container.decode(JWT.self, forKey: .challenge),
            consent: container.decode(UserConsent.self, forKey: .userConsent)
        )
    }

    enum CodingKeys: String, CodingKey {
        case challenge
        case userConsent = "user_consent"
    }

    public struct UserConsent: Codable, Equatable {
        let requestedScopes: [String: String]
        let requestedClaims: [String: String]
    }
}

extension IDPChallenge.UserConsent {
    /// Initializer for decoding UserContent
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            requestedScopes: container.decode([String: String].self, forKey: .requestedScopes),
            requestedClaims: container.decode([String: String].self, forKey: .requestedClaims)
        )
    }

    enum CodingKeys: String, CodingKey {
        case requestedScopes = "requested_scopes"
        case requestedClaims = "requested_claims"
    }
}

extension IDPChallenge: Claims {
    public var exp: Date? {
        claims.exp
    }

    public var iat: Date? {
        claims.iat
    }

    public var nbf: Date? {
        claims.nbf
    }
}
