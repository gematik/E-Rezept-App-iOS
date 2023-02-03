//
//  Copyright (c) 2023 gematik GmbH
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

import SwiftUI

internal struct StringAsset {
    internal private(set) var rawKey: String

    // swiftlint:disable discouraged_optional_collection
    internal private(set) var arguments: [CVarArg]?

    private let bundle = BundleToken.bundle

    init(_ rawKey: String, arguments: [CVarArg]? = nil) {
        self.rawKey = rawKey
        self.arguments = arguments
    }

    // swiftlint:enable discouraged_optional_collection

    internal var text: String {
        guard let arguments = arguments, !arguments.isEmpty else {
            return NSLocalizedString(rawKey, bundle: bundle, comment: "")
        }

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
