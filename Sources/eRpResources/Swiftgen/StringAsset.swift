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

/// Argument type that conforms to both CVarArg and Hashable for use in StringAsset.
public typealias EquatableCVarArg = (CVarArg & Hashable)

/// Represents a localized string asset with optional formatting arguments.
public struct StringAsset {
    /// The bundle containing the localized string.
    public let bundle: Bundle
    /// The raw localization key.
    public private(set) var rawKey: String

    // swiftlint:disable discouraged_optional_collection
    /// Arguments for string formatting.
    public private(set) var arguments: [any EquatableCVarArg]?

    /// Initializes a `StringAsset` with a key, optional arguments, and a bundle.
    public init(
        _ rawKey: String,
        arguments: [any EquatableCVarArg]? = nil,
        bundle: Bundle
    ) {
        self.rawKey = rawKey
        self.arguments = arguments
        self.bundle = bundle
    }

    // swiftlint:enable discouraged_optional_collection

    /// The localized and formatted string value.
    public var text: String {
        let arguments = self.arguments ?? []

        // We still need to format, to correctly escape possible %%
        return String(format: NSLocalizedString(rawKey, bundle: bundle, comment: ""), arguments: arguments)
    }

    /// The localized string as a `LocalizedStringKey` for SwiftUI.
    public var key: LocalizedStringKey {
        guard let arguments = arguments, !arguments.isEmpty else {
            return LocalizedStringKey(rawKey)
        }

        let formattedKey = bundle.localizedString(forKey: rawKey, value: nil, table: nil)
        let stringKey = String(format: formattedKey, arguments: arguments)
        return LocalizedStringKey(stringLiteral: stringKey)
    }
}

extension StringAsset: Equatable {
    /// Manual Equatable implementation
    public static func ==(lhs: StringAsset, rhs: StringAsset) -> Bool {
        // Compare bundle, rawKey first
        guard lhs.bundle == rhs.bundle, lhs.rawKey == rhs.rawKey else {
            return false
        }

        // Compare arguments arrays
        switch (lhs.arguments, rhs.arguments) {
        case (nil, nil):
            return true
        case let (lhsArgs?, rhsArgs?):
            guard lhsArgs.count == rhsArgs.count else { return false }

            // Compare each argument by converting to AnyHashable
            for (lhsArg, rhsArg) in zip(lhsArgs, rhsArgs) {
                let lhsHashable = AnyHashable(lhsArg)
                let rhsHashable = AnyHashable(rhsArg)
                if lhsHashable != rhsHashable {
                    return false
                }
            }
            return true
        default:
            return false // One is nil, the other isn't
        }
    }
}
