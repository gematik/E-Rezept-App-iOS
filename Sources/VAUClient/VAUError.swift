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

import CodedError
import Foundation
import HTTPClient

@CodedError("550")
public enum VAUError: Swift.Error {
    /// In case of HTTP/Connection error
    @ErrorCode("01")
    case network(error: HTTPClientError)
    /// When failed to extract a X.509 VAU certificate information
    @ErrorCode("02")
    case certificateDecoding
    /// When internal cryptographic operations fail
    @ErrorCode("03")
    case internalCryptoError
    /// In case a response (or request) could not be (cryptographically) verified
    @ErrorCode("04")
    case responseValidation
    /// Other error cases
    @ErrorCode("05")
    case unspecified(error: Swift.Error)
    /// Internal error
    @ErrorCode("06")
    case internalError(String)
}

extension Swift.Error {
    /// Map any Error to an VAUError
    public func asVAUError() -> VAUError {
        if let error = self as? HTTPClientError {
            return VAUError.network(error: error)
        } else if let error = self as? VAUError {
            return error
        } else {
            return VAUError.unspecified(error: self)
        }
    }
}
