//
//  Copyright (c) 2025 gematik GmbH
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
import IDP

/// FHIRVZD access token
public struct FHIRVZDToken: Codable, Hashable, Equatable {
    /// Access token
    public let accessToken: String
    /// Expiry date
    public var expires: Date {
        let expDate = try? JWT(from: accessToken).decodePayload(type: TokenPayload.AccessTokenPayload.self).exp
        return expDate ?? Date()
    }

    public init(string: String) {
        accessToken = string
    }

    private enum CodingKeys: String, CodingKey {
        case accessToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}
