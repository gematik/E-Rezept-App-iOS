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

import Foundation
import HTTPClient
import TrustStore

/// The specific error types for the IDP module
public enum IDPError: Swift.Error {
    /// In case of HTTP/Connection error
    case network(error: HTTPError)
    /// In case a response (or request) could not be (cryptographically) verified
    case validation(error: Swift.Error)
    /// When a token is being requested, but none can be found
    case tokenUnavailable
    /// Other error cases
    case unspecified(error: Swift.Error)
    /// Message failed to decode/parse
    case decoding(error: Swift.Error)
    /// When failed to extract a X.509 certificate from the DiscoveryDocument
    case noCertificateFound
    /// When the discovery document has expired or the trust anchors could not be verified
    case invalidDiscoveryDocument
    /// When the state parameter received from the server is not equal to the one sent
    case invalidStateParameter
    /// When the nonce received from the server is not equal to the one sent
    case invalidNonce
    /// When a method/algorithm is unsupported
    case unsupported(String?)
    /// When encryption fails
    case encryption
    /// When decryption fails
    case decryption
    /// Internal error
    case internalError(String)
    /// Issues related to Building or Verifying the trust store
    case trustStore(error: TrustStoreError)

    case pairing(Swift.Error)

    case invalidSignature(String)

    /// Server responded with an error
    case serverError(ServerResponse)

    /// Any biometrics related error
    case biometrics(SecureEnclaveSignatureProviderError)
    /// External authentication failed due to missing or invalid original request
    case extAuthOriginalRequestMissing

    public struct ServerResponse: Codable, CustomStringConvertible, Equatable {
        let error: String
        let errorText: String
        let timestamp: Int
        let uuid: String
        let code: String

        // [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Error formatting
        public var description: String {
            "\nError: \(code)\n\(error): \(errorText)\nError-ID: \(uuid)"
        }

        enum CodingKeys: String, CodingKey {
            case error
            case errorText = "gematik_error_text"
            case timestamp = "gematik_timestamp"
            case uuid = "gematik_uuid"
            case code = "gematik_code"
        }
    }
}

extension IDPError: Equatable, LocalizedError {
    public static func ==(lhs: IDPError, rhs: IDPError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.validation(error: lhsError), .validation(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case let (.decoding(error: lhsError), .decoding(error: rhsError)): return lhsError
            .localizedDescription == rhsError.localizedDescription
        case (.tokenUnavailable, .tokenUnavailable),
             (.noCertificateFound, .noCertificateFound),
             (.invalidDiscoveryDocument, .invalidDiscoveryDocument),
             (.extAuthOriginalRequestMissing, .extAuthOriginalRequestMissing): return true
        case let (.internalError(lhsText), .internalError(rhsText)),
             let (.invalidSignature(lhsText), .invalidSignature(rhsText)): return lhsText == rhsText
        case let (.serverError(lhsError), .serverError(rhsError)): return lhsError == rhsError
        case let (.trustStore(lhsError), .trustStore(rhsError)): return lhsError == rhsError
        case let (.biometrics(lhsError), .biometrics(rhsError)):
            return lhsError == rhsError
        default: return false
        }
    }

    public var errorDescription: String? {
        // [REQ:gemSpec_IDP_Frontend:A_20085] Error localization is not done yet, this is the place to localize
        // accordingly.
        switch self {
        case let .network(error: error): return error.localizedDescription
        case let .validation(error: error): return error.localizedDescription
        case .tokenUnavailable: return "IDPError.tokenUnavailable"
        case let .unspecified(error: error): return error.localizedDescription
        case let .decoding(error: error): return error.localizedDescription
        case .noCertificateFound: return "IDPError.noCertificateFound"
        case .invalidDiscoveryDocument: return "IDPError.invalidDiscoveryDocument"
        case let .unsupported(string): return "IDPError.unsupported method \(String(describing: string))"
        // [REQ:gemSpec_IDP_Frontend:A_19937,A_20605,A_20085] Localized description of server errors
        case let .internalError(string): return "IDPError.internalError method \(String(describing: string))"
        case let .serverError(error): return "IDPError.serverError '\(error)'"
        case .invalidStateParameter:
            return "IDPError.invalidStateParameter"
        case let .invalidSignature(text):
            return "IDPError.invalidSignature \(text)"
        case .invalidNonce:
            return "IDPError.invalidNonce"
        case .encryption:
            return "IDPError.encryption"
        case .decryption:
            return "IDPError.decryption"
        case let .trustStore(error: error):
            return "Trust store error: \(error)"
        case let .pairing(error):
            return "Pairing error: \(error)"
        case let .biometrics(error):
            return "Error running biometrics \(error)"
        case .extAuthOriginalRequestMissing:
            return "Error while processing external authentication: original request not found."
        }
    }
}
