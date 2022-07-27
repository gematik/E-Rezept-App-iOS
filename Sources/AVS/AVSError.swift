//
//  Copyright (c) 2022 gematik GmbH
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

// sourcery: CodedError = "540"
public enum AVSError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPError)
    // sourcery: errorCode = "02"
    /// When failed to create an AVSMessage
    case invalidAVSMessageInput
    // sourcery: errorCode = "03"
    /// When an X509 certificate was of unexpected format
    case invalidX509Input
    // sourcery: errorCode = "04"
    /// Conversion error when trying to cast to `AVSError` but error type was different
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "05"
    /// Internal error
    case `internal`(error: InternalError)

    // sourcery: CodedError = "541"
    public enum InternalError: Swift.Error {
        // sourcery: errorCode = "01"
        case cmsContentCreation
    }
}

extension Swift.Error {
    /// Map any Error to an AVSError
    public func asAVSError() -> AVSError {
        if let error = self as? HTTPError {
            return AVSError.network(error: error)
        } else if let error = self as? AVSError {
            return error
        } else {
            return AVSError.unspecified(error: self)
        }
    }
}

extension AVSError: Equatable {
    public static func ==(lhs: AVSError, rhs: AVSError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(error: lhsError), .network(error: rhsError)):
            return lhsError == rhsError
        case (.invalidAVSMessageInput, .invalidAVSMessageInput): return true
        case (.invalidX509Input, .invalidX509Input): return true
        case let (.unspecified(error: lhsError), .unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.internal(error: lhsError), .internal(error: rhsError)): return lhsError == rhsError
        default: return false
        }
    }
}
