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

/// Protocol for FHIR response handler that parses it into its associated type
public protocol FHIRResponseHandler {
    /// Parsed type
    associatedtype Value

    /// the accepted format that self can handle
    var acceptFormat: FHIRAcceptFormat { get }

    /// Handle the FHIR response and parse it into `Value`
    ///
    /// - Parameter response: FHIR response
    /// - Returns: parsed `Value`
    /// - Throws: `FHIRClient.Error` when unable to parse/handle the given `FHIRClient.Response`.
    func handle(response: FHIRClient.Response) throws -> Value
}

/// Request the task(s) in a certain format
public enum FHIRAcceptFormat {
    /// Header value with "fhir+json"
    case fhirJson
    /// Header value with "json"
    case json

    /// Default http header value for FHIR requests
    public var httpHeaderValue: String {
        switch self {
        case .fhirJson:
            return "application/fhir+json"
        case .json:
            return "application/json"
        }
    }
}
