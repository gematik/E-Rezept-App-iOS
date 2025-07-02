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

extension FHIRClient {
    /// Wrapper for the URLResponse receiver from the FHIR service
    public struct Response {
        /// The code that the FHIR Server send processing the request
        public let status: HTTPStatusCode

        /// Response headers
        public let headers: [String: String]

        /// The data in the response body
        public let body: Data

        /// Initialize a response
        ///
        /// - Parameters:
        ///   - status: the HTTP status code
        ///   - headers: the HTTP headers
        ///   - body: the raw response body
        public init(status: HTTPStatusCode, headers: [String: String], body: Data) {
            self.status = status
            self.headers = headers
            self.body = body
        }
    }
}

extension FHIRClient.Response {
    /// Parse a FHIRClient.Response from a URLResponse
    ///
    /// - Note: only HTTPURLResponse's are supported
    ///
    /// - Parameters:
    ///   - response: the URLResponse to map to a FHIRClient.Response
    ///   - status: the parse HTTP Status code
    ///   - data: the raw body data in the response
    /// - Returns: a response
    /// - Throws: FHIRClient.Error when the URLResponse was invalid
    public static func from(response: HTTPURLResponse, status: HTTPStatusCode, data: Data) -> Self {
        let headers: [String: String] = Dictionary(uniqueKeysWithValues: response.allHeaderFields
            .compactMap { key, value in
                guard let key = key as? String, let value = value as? String else {
                    return nil
                }
                return (key, value)
            })

        return FHIRClient.Response(status: status, headers: headers, body: data)
    }
}
