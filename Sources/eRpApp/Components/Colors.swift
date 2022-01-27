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
import SwiftUI

struct Colors {
    // accent colors
    static let primary = primary600
    static let secondary = Color(.systemGray6)
    static let tertiary = primary100

    // colors used for text
    static let text = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.white)

    // colors used for screen backgrounds
    static let backgroundNeutral = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)

    static let alertNegativ = red600
    static let alertPositiv = secondary600

    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let separator = Color(UIColor.separator)
    static let blurOverlayColor = Color.black.opacity(0.6)
}

extension Colors {
    // disabled
    static let disabled = Asset.Colors.disabled.color
    // primary == blue
    static let primary900 = Asset.Colors.primary900.color
    static let primary800 = Asset.Colors.primary800.color
    static let primary700 = Asset.Colors.primary700.color
    static let primary600 = Asset.Colors.primary600.color
    static let primary500 = Asset.Colors.primary500.color
    static let primary400 = Asset.Colors.primary400.color
    static let primary300 = Asset.Colors.primary300.color
    static let primary200 = Asset.Colors.primary200.color
    static let primary100 = Asset.Colors.primary100.color
    // secondary == green
    static let secondary900 = Asset.Colors.secondary900.color
    static let secondary800 = Asset.Colors.secondary800.color
    static let secondary700 = Asset.Colors.secondary700.color
    static let secondary600 = Asset.Colors.secondary600.color
    static let secondary500 = Asset.Colors.secondary500.color
    static let secondary400 = Asset.Colors.secondary400.color
    static let secondary300 = Asset.Colors.secondary300.color
    static let secondary200 = Asset.Colors.secondary200.color
    static let secondary100 = Asset.Colors.secondary100.color
    // red
    static let red900 = Asset.Colors.red900.color
    static let red800 = Asset.Colors.red800.color
    static let red700 = Asset.Colors.red700.color
    static let red600 = Asset.Colors.red600.color
    static let red500 = Asset.Colors.red500.color
    static let red400 = Asset.Colors.red400.color
    static let red300 = Asset.Colors.red300.color
    static let red200 = Asset.Colors.red200.color
    static let red100 = Asset.Colors.red100.color
    // yellow
    static let yellow900 = Asset.Colors.yellow900.color
    static let yellow800 = Asset.Colors.yellow800.color
    static let yellow700 = Asset.Colors.yellow700.color
    static let yellow600 = Asset.Colors.yellow600.color
    static let yellow500 = Asset.Colors.yellow500.color
    static let yellow400 = Asset.Colors.yellow400.color
    static let yellow300 = Asset.Colors.yellow300.color
    static let yellow200 = Asset.Colors.yellow200.color
    static let yellow100 = Asset.Colors.yellow100.color
}

extension Colors {
    // system gray colors
    static let systemGray = Color(UIColor.systemGray)
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray6 = Color(UIColor.systemGray6)
    // system background colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let systemBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let systemBackgroundTertiary = Color(UIColor.tertiarySystemBackground)
    // system fill colors
    static let systemFill = Color(UIColor.systemFill)
    static let systemFillSecondary = Color(UIColor.secondarySystemFill)
    static let systemFillTertiary = Color(UIColor.tertiarySystemFill)
    static let systemFillQuarternary = Color(UIColor.quaternarySystemFill)
    // label colors
    static let systemLabel = Color(UIColor.label)
    static let systemLabelSecondary = Color(UIColor.secondaryLabel)
    static let systemLabelTertiary = Color(UIColor.tertiaryLabel)
    static let systemLabelQuarternary = Color(UIColor.quaternaryLabel)
    // colors that are not dynamic
    static let systemColorWhite = Color.white
    static let systemColorBlack = Color.black
    static let systemColorClear = Color.clear
}
