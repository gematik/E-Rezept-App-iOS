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

/// Use `DefaultDataMatrixStringEncoder`to encode an array of `ErxTaskMatrixCode`  into a representive json string
public protocol DataMatrixStringEncoder {
    /// Creates a json string representable for an instance that conforms  to the`ErxTaskMatrixCode` protocol
    /// - Parameter tasks: objects conforming to `ErxTaskMatrixCode` protocol
    /// - Throws: an `DefaultDataMatrixStringEncoderError` that illustrates that string conversion failed
    /// - Returns: a json string with the `ErxTaskMatrixCode`s information
    func stringEncodeTasks(_ tasks: [ErxTaskMatrixCode]) throws -> String
}

/// Errors corersponding to `DataMatrixStringEncode`
public enum DefaultDataMatrixStringEncoderError: Swift.Error {
    /// Generic error while encoding the string.
    case stringEncoding(String)
}
