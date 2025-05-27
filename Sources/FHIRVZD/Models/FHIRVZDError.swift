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
import HTTPClient

// sourcery: CodedError = "300"
/// The specific error types for the IDP module
public enum FHIRVZDError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPClientError)
    // sourcery: errorCode = "02"
    /// When a token is being requested, but none can be found
    case tokenUnavailable
    // sourcery: errorCode = "03"
    /// Message failed to decode/parse
    case decoding(error: Swift.Error)
    // sourcery: errorCode = "04"
    /// Other error cases
    case unspecified(error: Swift.Error)
}

extension FHIRVZDError: Equatable {
    public static func ==(lhs: FHIRVZDError, rhs: FHIRVZDError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case (.tokenUnavailable, .tokenUnavailable):
            return true
        case let (.decoding(error: lhsError), .decoding(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        default: return false
        }
    }
}

extension FHIRVZDError: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public enum LoadingError: Swift.Error {
        case message(String?)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let value = try? container.decode(String.self, forKey: .value)
        switch type {
        case "network":
            self = .network(error: .unknown(LoadingError.message(value)))
        case "tokenUnavailable":
            self = .tokenUnavailable
        case "decoding":
            self = .decoding(error: LoadingError.message(value))
        default:
            self = .unspecified(error: LoadingError.message(value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .network(error):
            try container.encode("network", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .unspecified(error):
            try container.encode("unspecified", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case let .decoding(error):
            try container.encode("decoding", forKey: .type)
            try container.encode(error.localizedDescription, forKey: .value)
        case .tokenUnavailable:
            try container.encode("tokenUnavailable", forKey: .type)
        }
    }
}
