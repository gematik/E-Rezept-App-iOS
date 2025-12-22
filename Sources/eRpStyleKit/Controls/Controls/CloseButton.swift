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
import SwiftUI

/// A close button component that follows iOS design guidelines.
/// Designed to be accessible for VoiceOver users and easier to use for people with motor difficulties.
public struct CloseButton: View {
    private let action: () -> Void
    private let accessibilityLabel: String
    private let accessibilityHint: String

    /// Creates a close button
    /// - Parameters:
    ///   - accessibilityLabel: Custom accessibility label (default: localized "Close")
    ///   - accessibilityHint: Custom accessibility hint (default: "Schließt den aktuellen Bildschirm")
    ///   - action: The action to perform when the button is tapped
    public init(
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.accessibilityLabel = accessibilityLabel ?? L10n.erpstylekitCloseButtonDefaultA11yHint.text
        self.accessibilityHint = accessibilityHint ?? L10n.erpstylekitCloseButtonDefaultA11yLabel.text
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: SFSymbolName.crossIconPlain)
                .font(Font.caption.weight(.bold))
                .foregroundColor(Colors.systemLabelSecondary)
                .padding(6)
                .background(Circle().foregroundColor(Color(.systemGray6)))
//                .padding()
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Previews

#Preview("Close Button") {
    VStack(spacing: 20) {
        CloseButton {}

        Text("Basic Close Button")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}

#Preview("Close Button in Context") {
    VStack {
        HStack {
            Spacer()
            CloseButton {}
                .padding(.trailing, 16)
                .padding(.top, 8)
        }

        VStack(alignment: .leading, spacing: 16) {
            Text("Was ist eine Direktzuweisung?")
                .font(.title3)
                .fontWeight(.semibold)

            Text("""
            Bei einer Direktzuweisungen wird ein Rezept von einer Praxis oder einem \
            Krankenhaus direkt bei einer Apotheke eingelöst. Versicherte müssen \
            hierbei nicht tätig werden und können nicht in den Einlösungsprozess \
            eingreifen.
            """)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)

        Spacer()
    }
    .background(Colors.systemBackground)
}
