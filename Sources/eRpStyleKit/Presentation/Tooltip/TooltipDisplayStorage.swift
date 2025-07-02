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

/// Stores the visibility of tooltips.
public struct TooltipDisplayStorage {
    private(set) var tooltipHidden: (String) -> Bool
    private(set) var setTooltipHidden: (String, Bool) -> Void

    /// Initialize a TooltipDisplayStorage with methods to decide wether a tooltip should be shown `tooltipHidden` and
    /// with a method to set the visibility `setTooltipHidden`.
    public init(tooltipHidden: @escaping (String) -> Bool,
                setTooltipHidden: @escaping (String, Bool) -> Void) {
        self.tooltipHidden = tooltipHidden
        self.setTooltipHidden = setTooltipHidden
    }
}

extension TooltipDisplayStorage {
    static func live() -> Self {
        Self { tooltipId in
            UserDefaults.standard.dictionary(forKey: "TOOLTIPS")?[tooltipId] as? Bool ?? false
        } setTooltipHidden: { tooltipId, value in
            var tooltips = UserDefaults.standard.dictionary(forKey: "TOOLTIPS") ?? [:]
            tooltips[tooltipId] = value
            UserDefaults.standard.setValue(tooltips, forKey: "TOOLTIPS")
        }
    }

    static var dictionary: [String: Bool] = [:]

    static func test() -> Self {
        Self {
            dictionary[$0] ?? false
        } setTooltipHidden: {
            dictionary[$0] = $1
        }
    }
}

private struct TooltipDisplayStorageKey: EnvironmentKey {
    // change to `.test()` to enforce Tooltips every time
    static let defaultValue: TooltipDisplayStorage = .live()
}

extension EnvironmentValues {
    /// Environment value to store and restore Tooltips.
    public var tooltipDisplayStorage: TooltipDisplayStorage {
        get { self[TooltipDisplayStorageKey.self] }
        set { self[TooltipDisplayStorageKey.self] = newValue }
    }
}
