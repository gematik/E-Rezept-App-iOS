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

import eRpStyleKit
import SwiftUI

enum MainViewTooltip: UInt, TooltipId {
    static func <(lhs: MainViewTooltip, rhs: MainViewTooltip) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var description: String { "MainViewTooltipId_\(rawValue)" }

    case rename = 900
    case addProfile = 1000
    // Use high prio to work around layout glitches within toolbar items
    case scan = 9900

    var priority: UInt { rawValue }

    var stringAsset: StringAsset {
        switch self {
        case .scan:
            return L10n.erpTxtTooltipsScan
        case .rename:
            return L10n.erpTxtTooltipsProfileRename
        case .addProfile:
            return L10n.erpTxtTooltipsAddProfile
        }
    }

    var accesssibilityIdentifier: String {
        switch self {
        case .scan:
            return A11y.mainScreen.erxTxtTooltipsScan
        case .rename:
            return A11y.mainScreen.erxTxtTooltipsProfileRename
        case .addProfile:
            return A11y.mainScreen.erxTxtTooltipsAddProfile
        }
    }
}

struct MainViewTooltipView: View {
    let tooltip: MainViewTooltip

    var body: some View {
        Text(tooltip.stringAsset)
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: 152, alignment: .leading)
            .accessibilityIdentifier(tooltip.accesssibilityIdentifier)
    }
}

extension View {
    func tooltip(tooltip: MainViewTooltip) -> some View {
        self.tooltip(id: tooltip) {
            MainViewTooltipView(tooltip: tooltip)
        }
    }
}
