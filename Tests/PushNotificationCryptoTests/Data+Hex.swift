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
    init(hexEncoded string: String) {
        self.init([UInt8](hexEncoded: string))
    }

    var hexEncodedString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

extension [UInt8] {
    init(hexEncoded string: String) {
        self.init()
        var startIndex = string.startIndex
        while startIndex < string.endIndex {
            let endIndex = string.index(startIndex, offsetBy: 2)
            let hex = string[startIndex ..< endIndex]
            append(UInt8(hex, radix: 16)!)
            startIndex = endIndex
        }
    }
}
