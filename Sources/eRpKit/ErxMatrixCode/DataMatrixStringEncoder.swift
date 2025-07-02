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

/// Use `DefaultDataMatrixStringEncoder`to encode an array of `ErxTaskMatrixCode`  into a representive json string
public protocol DataMatrixStringEncoder {
    /// Creates a json string representable for an instance that conforms  to the`ErxTaskMatrixCode` protocol
    /// - Parameter tasks: objects conforming to `ErxTaskMatrixCode` protocol
    /// - Throws: an `DefaultDataMatrixStringEncoderError` that illustrates that string conversion failed
    /// - Returns: a json string with the `ErxTaskMatrixCode`s information
    func stringEncode(tasks: [ErxTaskMatrixCode]) throws -> String

    /// Creates a json string representable for an instance that conforms  to the`ErxChargeItemMatrixCode` protocol
    /// - Parameter chargeItem: objects conforming to `ErxChargeItemMatrixCode` protocol
    /// - Throws: an error if the access code is missing or the string conversion failed
    /// - Returns: a  string with the `ErxChargeItemMatrixCode`s information
    func stringEncode(chargeItem: ErxChargeItemMatrixCode) throws -> String
}

// sourcery: CodedError = "202"
/// Errors corersponding to `DataMatrixStringEncode`
public enum DefaultDataMatrixStringEncoderError: Swift.Error {
    // sourcery: errorCode = "01"
    /// Generic error while encoding the string.
    case stringEncoding(String)
    // sourcery: errorCode = "02"
    /// Access code is missing
    case missingAccessCode
}
