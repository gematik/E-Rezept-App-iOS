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

extension String {
    func prefix(upTo key: String, isKeyIncluded: Bool = false) -> String {
        guard let range = self.range(of: key) else { return self }
        let endIndex = isKeyIncluded ? range.upperBound : range.lowerBound
        return String(self[..<endIndex])
    }

    func first(upTo key: String) -> String {
        prefix(upTo: key)
    }

    func suffix(from key: String, isKeyIncluded: Bool = false) -> String {
        guard let range = self.range(of: key) else { return self }
        let startIndex = isKeyIncluded ? range.lowerBound : range.upperBound
        return String(self[startIndex...])
    }

    func starting(after key: String) -> String {
        suffix(from: key)
    }
}
