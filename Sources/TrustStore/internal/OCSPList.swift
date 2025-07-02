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

/// [REQ:gemSpec_Krypt:A_21217]
/// Data structure according to */OCSPList* endpoint
public struct OCSPList: Codable, Equatable {
    let responses: [Data]

    /// Initialize from json encoded string
    static func from(string: String) throws -> Self {
        try from(data: Data(string.utf8))
    }

    /// Initialize from json encoded data
    static func from(data: Data) throws -> Self {
        let ocspListBase64 = try Base64.from(data: data)
        let responses = ocspListBase64.responses.compactMap { Data(base64Encoded: $0) }
        return OCSPList(responses: responses)
    }

    /// Intermediate helper structure for processing/decoding /OCSPList HTTP responses
    /// When decoding a CertList received from the service we expect the following json structure
    /// `{ OCSP Responses: [ "base64-encoded-OCSP-response-1", ... ] }`
    struct Base64: Decodable {
        let responses: [String]

        private enum CodingKeys: String, CodingKey {
            case responses = "OCSP Responses"
        }

        /// Initialize from json encoded string
        static func from(string: String) throws -> Self {
            try from(data: Data(string.utf8))
        }

        /// Initialize from json encoded data
        static func from(data: Data) throws -> Self {
            try Self.jsonDecoder.decode(Base64.self, from: data)
        }

        private static var jsonDecoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            return decoder
        }
    }
}
