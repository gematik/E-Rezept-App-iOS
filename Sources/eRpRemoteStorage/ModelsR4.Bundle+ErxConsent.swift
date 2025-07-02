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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Bundle {
    /// Parse and extract a ErxConsent from `Self`
    ///
    /// - Returns: A ErxConsent or nil
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxConsents() throws -> [ErxConsent] {
        try entry?.compactMap {
            guard let consent = $0.resource?.get(if: ModelsR4.Consent.self) else {
                return nil
            }
            return try Self.parse(consent, from: self)
        } ?? []
    }

    static func parse(_ consent: ModelsR4.Consent,
                      from _: ModelsR4.Bundle) throws -> ErxConsent? {
        try consent.parseErxConsent()
    }
}
