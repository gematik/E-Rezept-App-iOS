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

extension Data {
    func decodeBase64URLEncoded(options: Data.Base64DecodingOptions = []) -> Data? {
        // Foundation.Data(base64Encoded:)-necessary character replacement is more ergonomic in terms of String
        String(bytes: self, encoding: .utf8)?.decodeBase64URLEncoded(options: options)
    }
}

extension Data {
    // Note: Data.base64EncodedString() returns an honest string.
    // We only return Optional<Data> because of (de-)"casting" to Data and have to handle it on the caller side.
    func encodeBase64UrlSafe() -> Data? {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .data(using: .utf8)
    }
}
