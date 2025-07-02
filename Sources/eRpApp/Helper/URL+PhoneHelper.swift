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

// swiftlint:disable line_length
extension URL {
    /// Sanitize provided phone number string before creating a URL instance from it.
    ///
    /// This initializer returns nil if the string doesn’t represent a valid phone number.
    /// For example, an empty string or one containing only non numeric characters produces nil.
    ///
    /// - note: For more information, see:
    /// [Apple URL Scheme Reference](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/PhoneLinks/PhoneLinks.html)
    init?(phoneNumber: String) {
        let number = phoneNumber.filter { $0.isWholeNumber || $0 == "+" }
        if !number.isEmpty,
           let url = URL(string: "tel:\(number)") {
            self = url
        } else {
            return nil
        }
    }
}

// swiftlint:enable line_length
