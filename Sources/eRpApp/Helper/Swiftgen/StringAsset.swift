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

import SwiftUI

internal struct StringAsset {
    internal let bundle: Bundle
    internal private(set) var rawKey: String

    // swiftlint:disable discouraged_optional_collection
    internal private(set) var arguments: [CVarArg]?

    init(
        _ rawKey: String,
        arguments: [CVarArg]? = nil,
        bundle: Bundle
    ) {
        self.rawKey = rawKey
        self.arguments = arguments
        self.bundle = bundle
    }

    // swiftlint:enable discouraged_optional_collection

    internal var text: String {
        let arguments = self.arguments ?? []

        // We still need to format, to correctly escape possible %%
        return String(format: NSLocalizedString(rawKey, bundle: bundle, comment: ""), arguments: arguments)
    }

    internal var key: LocalizedStringKey {
        guard let arguments = arguments, !arguments.isEmpty else {
            return LocalizedStringKey(rawKey)
        }

        let formattedKey = bundle.localizedString(forKey: rawKey, value: nil, table: nil)
        let stringKey = String(format: formattedKey, arguments: arguments)
        return LocalizedStringKey(stringLiteral: stringKey)
    }
}
