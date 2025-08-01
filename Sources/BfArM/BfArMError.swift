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
import HTTPClient

// sourcery: CodedError = "301"
/// The specific error types for the IDP module
public enum BfArMError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPClientError)
    // sourcery: errorCode = "02"
    /// Message failed to decode/parse
    case decoding(error: Swift.Error)
    // sourcery: errorCode = "03"
    /// When the asset link from bfarm endpoint is invalid
    case invalidAssetLink
    // sourcery: errorCode = "04"
    /// Other error cases
    case unspecified(error: Swift.Error)
}

extension BfArMError: Equatable {
    public static func ==(lhs: BfArMError, rhs: BfArMError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)):
            return lhsError == rhsError
        case let (.decoding(error: lhsError), .decoding(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case (.invalidAssetLink, .invalidAssetLink):
            return true
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        default: return false
        }
    }
}

extension BfArMError: Codable {
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
        case .invalidAssetLink:
            try container.encode("invalidAssetLink", forKey: .type)
        }
    }
}
