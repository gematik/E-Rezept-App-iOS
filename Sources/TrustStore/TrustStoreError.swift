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

public enum TrustStoreError: Swift.Error {
    /// In case of HTTP/Connection error
    case network(error: HTTPError)
    /// When failed to extract a certificate from the CertList
    case noCertificateFound
    /// When one (or more) OCSP response(s) can not be parsed or do not meet expiry conditions
    case invalidOCSPResponse
    /// When one (or more) end entity certificate cannot be status verified by given OCSP responses
    case eeCertificateOCSPStatusVerification
    /// Other error cases
    case unspecified(error: Swift.Error)
    /// Internal error
    case internalError(String)
}

extension Swift.Error {
    /// Map any Error to an VAUError
    public func asTrustStoreError() -> TrustStoreError {
        if let error = self as? HTTPError {
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
        case let (.internalError(lhsError), .internalError(rhsError)): return lhsError == rhsError
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
        case let .internalError(string): return "TrustStoreError.internalError method \(String(describing: string))"
        }
    }
}
