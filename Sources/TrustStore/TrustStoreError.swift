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

// sourcery: CodedError = "560"
public enum TrustStoreError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPClientError)
    // sourcery: errorCode = "02"
    /// When failed to extract a certificate from the CertList
    case noCertificateFound
    // sourcery: errorCode = "03"
    /// When one (or more) OCSP response(s) can not be parsed or do not meet expiry conditions
    case invalidOCSPResponse
    // sourcery: errorCode = "04"
    /// When one (or more) end entity certificate cannot be status verified by given OCSP responses
    case eeCertificateOCSPStatusVerification
    // sourcery: errorCode = "05"
    /// Other error cases
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "06"
    /// Internal error
    case `internal`(error: InternalError)
    // sourcery: errorCode = "07"
    /// When no valid VAU certificate can be provided by the system at the moment
    case noValidVauCertificateAvailable
    // sourcery: errorCode = "08"
    /// When a certificate is of unexpected (e.g. not parsable) format
    case malformedCertificate

    // sourcery: CodedError = "561"
    public enum InternalError: Swift.Error {
        // sourcery: errorCode = "01"
        case loadOCSPCheckedTrustStoreUnexpectedNil
        // sourcery: errorCode = "02"
        case loadCertListFromServerUnexpectedNil
        // sourcery: errorCode = "03"
        case loadOCSPListFromServerUnexpectedNil
        // sourcery: errorCode = "04"
        case trustStoreCertListUnexpectedNil
        // sourcery: errorCode = "05"
        case loadOCSPResponsesUnexpectedNil
        // sourcery: errorCode = "06"
        case missingSignerForEECertificate
        // sourcery: errorCode = "07"
        case notImplemented
        // sourcery: errorCode = "08"
        case trustAnchorUnexpectedFormat
        // sourcery: errorCode = "09"
        case vauCertificateUnexpectedFormat
        // sourcery: errorCode = "10"
        case trustStoreCreationFailed
    }
}

extension Swift.Error {
    /// Map any Error to an VAUError
    public func asTrustStoreError() -> TrustStoreError {
        if let error = self as? HTTPClientError {
            return TrustStoreError.network(error: error)
        } else if let error = self as? TrustStoreError {
            return error
        } else {
            return TrustStoreError.unspecified(error: self)
        }
    }
}

extension TrustStoreError: Equatable, LocalizedError {
    public static func ==(lhs: TrustStoreError, rhs: TrustStoreError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)):
            return lhsError == rhsError
        case (.noCertificateFound, .noCertificateFound): return true
        case (.invalidOCSPResponse, .invalidOCSPResponse): return true
        case (.eeCertificateOCSPStatusVerification, .eeCertificateOCSPStatusVerification): return true
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.internal(error: lhsError), .internal(error: rhsError)): return lhsError == rhsError
        default: return false
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .network(error: error): return error.localizedDescription
        case .noCertificateFound: return "TrustStoreError.noCertificateFound"
        case .invalidOCSPResponse: return "TrustStoreError.noCertificateFound"
        case .eeCertificateOCSPStatusVerification: return "TrustStoreError.eeCertificateOCSPStatusVerification"
        case let .unspecified(error: error): return error.localizedDescription
        case let .internal(error: error): return error.localizedDescription
        case .noValidVauCertificateAvailable: return "TrustStoreError.noValidVauCertificateAvailable"
        case .malformedCertificate: return "TrustStoreError.malformedCertificate"
        }
    }
}
