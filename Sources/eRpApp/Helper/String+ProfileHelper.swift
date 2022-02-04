//
//  Copyright (c) 2022 gematik GmbH
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

extension String {
    func acronym() -> String {
        let components = self.components(separatedBy: .whitespaces)

        if components.count > 1 {
            return String(components.first?.capitalized.prefix(1) ?? "") +
                String(components.last?.capitalized.prefix(1) ?? "")
        }
        return String(capitalized.prefix(1))
    }

    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
