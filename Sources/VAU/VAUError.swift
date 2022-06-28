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

// sourcery: CodedError = "550"
public enum VAUError: Swift.Error {
    // sourcery: errorCode = "01"
    /// In case of HTTP/Connection error
    case network(error: HTTPError)
    // sourcery: errorCode = "02"
    /// When failed to extract a X.509 VAU certificate information
    case certificateDecoding
    // sourcery: errorCode = "03"
    /// When internal cryptographic operations fail
    case internalCryptoError
    // sourcery: errorCode = "04"
    /// In case a response (or request) could not be (cryptographically) verified
    case responseValidation
    // sourcery: errorCode = "05"
    /// Other error cases
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "06"
    /// Internal error
    case internalError(String)
}

extension Swift.Error {
    /// Map any Error to an VAUError
    public func asVAUError() -> VAUError {
        if let error = self as? HTTPError {
            return VAUError.network(error: error)
        } else if let error = self as? VAUError {
            return error
        } else {
            return VAUError.unspecified(error: self)
        }
    }
}
