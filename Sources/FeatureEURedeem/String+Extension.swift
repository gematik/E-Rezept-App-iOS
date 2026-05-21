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
    /// Localizes a raw localization key for a specific country code if supported, otherwise returns nil
    public func localizedStringFor(countryCode: String?) -> String? {
        guard let bundlePath = Bundle.resourceBundle.path(
            forResource: findPrimaryLocale(for: countryCode),
            ofType: "lproj"
        ),
            let bundle = Bundle(path: bundlePath)
        else { return nil }
        return String(format: NSLocalizedString(self, bundle: bundle, comment: ""), arguments: [])
    }

    /// Finds the closest local for a given country code in all app supported localizations,
    /// otherwise returns current local
    private func findPrimaryLocale(for countryCode: String?) -> String {
        let defaultLocal = Locale.autoupdatingCurrent.identifier
        guard let countryCode else { return defaultLocal }
        let bestMatch = Bundle.main.localizations.first { identifier in
            let locale = Locale(identifier: identifier)
            let isLanguageMatch = locale.language.languageCode?.identifier.lowercased() == countryCode.lowercased()
            let isRegionMatch = locale.region?.identifier.uppercased() == countryCode.uppercased()

            return isLanguageMatch || isRegionMatch
        }
        return bestMatch ?? defaultLocal
    }
}
