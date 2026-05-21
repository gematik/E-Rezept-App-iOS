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

import eRpResources
import eRpStyleKit
import SwiftUI

/// A unified filter chip component matching the design system.
///
/// Displays a capsule-shaped chip with three visual styles:
/// - **selected**: Blue background (`primary200`), blue border and text (`primary900`), leading checkmark icon.
/// - **unselected**: White background, gray border and text (`systemLabelSecondary`), no icon.
/// - **dismissible**: Blue background (`primary200`), blue border and text (`primary900`), trailing ✕ icon.
struct FilterChip: View {
    /// The visual style of a `FilterChip`.
    enum Style {
        /// Toggle-on state: blue tinted with a leading checkmark.
        case selected
        /// Toggle-off state: neutral border, no icon.
        case unselected
        /// Active filter that can be removed: blue tinted with a trailing ✕.
        case dismissible
    }

    let title: LocalizedStringKey
    let style: Style
    let action: () -> Void

    /// Convenience initialiser that maps a boolean to `.selected` / `.unselected`.
    init(
        title: LocalizedStringKey,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        style = isSelected ? .selected : .unselected
        self.action = action
    }

    init(
        title: LocalizedStringKey,
        style: Style,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    // MARK: - Derived styling helpers

    private var isTinted: Bool {
        switch style {
        case .selected, .dismissible: return true
        case .unselected: return false
        }
    }

    private var foregroundColor: Color {
        isTinted ? Colors.primary900 : Colors.systemLabelSecondary
    }

    private var backgroundColor: Color {
        isTinted ? Colors.primary200 : Colors.systemBackground
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if style == .selected {
                    Image(systemName: SFSymbolName.checkmark)
                        .font(.footnote)
                }

                Text(title, bundle: .module)
                    .font(.subheadline)

                if style == .dismissible {
                    Image(systemName: SFSymbolName.crossIconPlain)
                        .font(.footnote)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(foregroundColor, lineWidth: 1)
            )
        }
        .accessibilityAddTraits({
            switch style {
            case .unselected: [.isButton, .isToggle]
            case .selected: [.isSelected, .isButton, .isToggle]
            case .dismissible: [.isSelected, .isButton]
            }
        }())
        .accessibilityHint(style == .dismissible ? L10n.psfBtnRemoveFilterHint.text : "")
    }
}

struct FilterChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Aktuell geöffnet",
                    isSelected: true
                ) {}

                FilterChip(
                    title: "In meiner Nähe",
                    isSelected: false
                ) {}

                FilterChip(
                    title: "Zuletzt genutzt",
                    isSelected: false
                ) {}
            }

            HStack(spacing: 8) {
                FilterChip(
                    title: "Versand",
                    style: .dismissible
                ) {}

                FilterChip(
                    title: "Filter Element C",
                    style: .dismissible
                ) {}
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
