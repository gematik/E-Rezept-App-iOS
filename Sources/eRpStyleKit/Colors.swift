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
    public static let gifBackground: Color = Asset.Colors.gifBackground.swiftUIColor
    public static let tabViewToolBarBackground: Color = Asset.Colors.tabViewToolBarBackground.swiftUIColor
    // disabled
    public static let disabled: Color = Asset.Colors.disabled.swiftUIColor
    // primary == blue
    public static let primary900: Color = Asset.Colors.primary900.swiftUIColor
    public static let primary800: Color = Asset.Colors.primary800.swiftUIColor
    public static let primary700: Color = Asset.Colors.primary700.swiftUIColor
    public static let primary600: Color = Asset.Colors.primary600.swiftUIColor
    public static let primary500: Color = Asset.Colors.primary500.swiftUIColor
    public static let primary400: Color = Asset.Colors.primary400.swiftUIColor
    public static let primary300: Color = Asset.Colors.primary300.swiftUIColor
    public static let primary200: Color = Asset.Colors.primary200.swiftUIColor
    public static let primary100: Color = Asset.Colors.primary100.swiftUIColor
    // secondary == green
    public static let secondary900: Color = Asset.Colors.secondary900.swiftUIColor
    public static let secondary800: Color = Asset.Colors.secondary800.swiftUIColor
    public static let secondary700: Color = Asset.Colors.secondary700.swiftUIColor
    public static let secondary600: Color = Asset.Colors.secondary600.swiftUIColor
    public static let secondary500: Color = Asset.Colors.secondary500.swiftUIColor
    public static let secondary400: Color = Asset.Colors.secondary400.swiftUIColor
    public static let secondary300: Color = Asset.Colors.secondary300.swiftUIColor
    public static let secondary200: Color = Asset.Colors.secondary200.swiftUIColor
    public static let secondary100: Color = Asset.Colors.secondary100.swiftUIColor
    // red
    public static let red900: Color = Asset.Colors.red900.swiftUIColor
    public static let red800: Color = Asset.Colors.red800.swiftUIColor
    public static let red700: Color = Asset.Colors.red700.swiftUIColor
    public static let red600: Color = Asset.Colors.red600.swiftUIColor
    public static let red500: Color = Asset.Colors.red500.swiftUIColor
    public static let red400: Color = Asset.Colors.red400.swiftUIColor
    public static let red300: Color = Asset.Colors.red300.swiftUIColor
    public static let red200: Color = Asset.Colors.red200.swiftUIColor
    public static let red100: Color = Asset.Colors.red100.swiftUIColor
    // yellow
    public static let yellow900: Color = Asset.Colors.yellow900.swiftUIColor
    public static let yellow800: Color = Asset.Colors.yellow800.swiftUIColor
    public static let yellow700: Color = Asset.Colors.yellow700.swiftUIColor
    public static let yellow600: Color = Asset.Colors.yellow600.swiftUIColor
    public static let yellow500: Color = Asset.Colors.yellow500.swiftUIColor
    public static let yellow400: Color = Asset.Colors.yellow400.swiftUIColor
    public static let yellow300: Color = Asset.Colors.yellow300.swiftUIColor
    public static let yellow200: Color = Asset.Colors.yellow200.swiftUIColor
    public static let yellow100: Color = Asset.Colors.yellow100.swiftUIColor
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
