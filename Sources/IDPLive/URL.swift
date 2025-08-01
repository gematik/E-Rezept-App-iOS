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

extension URL {
    func domainReplacingOccurrences(of find: String, with replace: String) -> URL {
        // swiftlint:disable force_unwrapping
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        components.host = components.host!.replacingOccurrences(of: find, with: replace)
        return components.url!
        // swiftlint:enable force_unwrapping
    }

    func correct() -> URL {
        domainReplacingOccurrences(of: ".zentral.idp.splitdns.ti-dienste.de", with: ".app.ti-dienste.de")
    }
}
