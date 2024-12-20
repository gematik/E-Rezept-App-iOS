//
//  Copyright (c) 2024 gematik GmbH
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

// swiftlint:disable missing_docs

public enum Colors {
    // accent colors
    public static let primary: Color = primary600
    public static let secondary = Color(.systemGray6)
    public static let tertiary: Color = primary100

    // colors used for text
    public static let text = Color(.label)
    public static let textSecondary = Color(.secondaryLabel)
    public static let textTertiary = Color(.white)

    // colors used for screen backgrounds
    public static let backgroundNeutral = Color(.systemBackground)
    public static let backgroundSecondary = Color(.secondarySystemBackground)

    public static let alertNegativ = red600
    public static let alertPositiv = secondary600

    public static let starYellow = Color.yellow

    public static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    public static let separator = Color(UIColor.separator)
    public static let blurOverlayColor = Color.black.opacity(0.6)
}

extension Colors {
    public static let gifBackground = Color(.gifBackground)
    public static let tabViewToolBarBackground: Color = Asset.Colors.tabViewToolBarBackground.swiftUIColor
    // disabled
    public static let disabled: Color = Asset.Colors.disabled.swiftUIColor
    // primary == blue
    public static let primary900 = Color(.primary900)
    public static let primary800 = Color(.primary800)
    public static let primary700 = Color(.primary700)
    public static let primary600 = Color(.primary600)
    public static let primary500 = Color(.primary500)
    public static let primary400 = Color(.primary400)
    public static let primary300 = Color(.primary300)
    public static let primary200 = Color(.primary200)
    public static let primary100 = Color(.primary100)
    // secondary == green
    public static let secondary900 = Color(.secondary900)
    public static let secondary800 = Color(.secondary800)
    public static let secondary700 = Color(.secondary700)
    public static let secondary600 = Color(.secondary600)
    public static let secondary500 = Color(.secondary500)
    public static let secondary400 = Color(.secondary400)
    public static let secondary300 = Color(.secondary300)
    public static let secondary200 = Color(.secondary200)
    public static let secondary100 = Color(.secondary100)
    // red
    public static let red900 = Color(.red900)
    public static let red800 = Color(.red800)
    public static let red700 = Color(.red700)
    public static let red600 = Color(.red600)
    public static let red500 = Color(.red500)
    public static let red400 = Color(.red400)
    public static let red300 = Color(.red300)
    public static let red200 = Color(.red200)
    public static let red100 = Color(.red100)
    // yellow
    public static let yellow900 = Color(.yellow900)
    public static let yellow800 = Color(.yellow800)
    public static let yellow700 = Color(.yellow700)
    public static let yellow600 = Color(.yellow600)
    public static let yellow500 = Color(.yellow500)
    public static let yellow400 = Color(.yellow400)
    public static let yellow300 = Color(.yellow300)
    public static let yellow200 = Color(.yellow200)
    public static let yellow100 = Color(.yellow100)
}

extension Colors {
    // system gray colors
    public static let systemGray = Color(UIColor.systemGray)
    public static let systemGray2 = Color(UIColor.systemGray2)
    public static let systemGray3 = Color(UIColor.systemGray3)
    public static let systemGray4 = Color(UIColor.systemGray4)
    public static let systemGray5 = Color(UIColor.systemGray5)
    public static let systemGray6 = Color(UIColor.systemGray6)
    // system background colors
    public static let systemBackground = Color(UIColor.systemBackground)
    public static let systemBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    public static let systemBackgroundTertiary = Color(UIColor.tertiarySystemBackground)
    // system fill colors
    public static let systemFill = Color(UIColor.systemFill)
    public static let systemFillSecondary = Color(UIColor.secondarySystemFill)
    public static let systemFillTertiary = Color(UIColor.tertiarySystemFill)
    public static let systemFillQuarternary = Color(UIColor.quaternarySystemFill)
    // label colors
    public static let systemLabel = Color(UIColor.label)
    public static let systemLabelSecondary = Color(UIColor.secondaryLabel)
    public static let systemLabelTertiary = Color(UIColor.tertiaryLabel)
    public static let systemLabelQuarternary = Color(UIColor.quaternaryLabel)
    // colors that are not dynamic
    public static let systemColorWhite = Color.white
    public static let systemColorBlack = Color.black
    public static let systemColorClear = Color.clear
}

// swiftlint:enable missing_docs
