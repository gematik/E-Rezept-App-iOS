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

/// Default implementation of `DefaultDataMatrixStringEncoder`to encode an array of `ErxTaskMatrixCode`  into a
/// representive json string
public struct DefaultDataMatrixStringEncoder: DataMatrixStringEncoder {
    private let jsonEncoder: JSONEncoder

    /// Default initalizer
    /// - Parameter jsonEncoder: encoder to use for doing the conversion
    public init(jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonEncoder = jsonEncoder
    }

    /// Creates a json string representable for an instance that conforms  to the`ErxTaskMatrixCode` protocol
    /// - Parameter tasks: objects conforming to `ErxTaskMatrixCode` protocol
    /// - Throws: an error that illustrates that string conversion failed
    /// - Returns: a  string with the `ErxTaskMatrixCode`s information
    public func stringEncode(tasks: [ErxTaskMatrixCode]) throws -> String {
        let jsonDict = ["urls": tasks.map { "Task/\($0.id)/$accept?ac=\($0.accessCode)" }]
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try jsonEncoder.encode(jsonDict)

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            throw DefaultDataMatrixStringEncoderError.stringEncoding("Could not create string from json data")
        }
    }

    /// Creates a json string representable for an instance that conforms  to the`ErxChargeItemMatrixCode` protocol
    /// - Parameter chargeItem: objects conforming to `ErxChargeItemMatrixCode` protocol
    /// - Throws: an error if the access code is missing or the string conversion failed
    /// - Returns: a  string with the `ErxChargeItemMatrixCode`s information
    public func stringEncode(chargeItem: ErxChargeItemMatrixCode) throws -> String {
        guard let accessCode = chargeItem.accessCode
        else { throw DefaultDataMatrixStringEncoderError.missingAccessCode }
        let jsonDict = [
            "urls": [
                "ChargeItem/\(chargeItem.id)?ac=\(accessCode)",
            ],
        ]
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try jsonEncoder.encode(jsonDict)

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            throw DefaultDataMatrixStringEncoderError.stringEncoding("Could not create string from json data")
        }
    }
}
