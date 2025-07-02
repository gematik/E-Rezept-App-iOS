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

/// A button style that applies fg and bg color, as well as border radius.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.secondary)`` modifier.
public struct SecondaryButtonStyle: ButtonStyle {
    private var isDestructive: Bool
    private var isEnabled: Bool

    public init(enabled: Bool) {
        isEnabled = enabled
        isDestructive = false
    }

    public init(enabled: Bool = true, destructive: Bool = false) {
        isEnabled = enabled
        isDestructive = destructive
    }

    var foregroundColor: Color {
        switch (isDestructive, isEnabled) {
        case (false, true):
            return Colors.primary
        case (false, false):
            return Color(.systemGray)
        case (true, true):
            return Colors.red600
        case (true, false):
            return Color(.systemGray)
        }
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .center)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(Color(.systemGray5))
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .padding(.horizontal)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.secondary)`` modifier.
    public static var secondary: SecondaryButtonStyle { SecondaryButtonStyle(enabled: true) }

    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.secondary(isEnabled:,isDestructive: false))`` modifier.
    public static func secondary(isEnabled: Bool = true, isDestructive: Bool = false) -> SecondaryButtonStyle {
        SecondaryButtonStyle(enabled: isEnabled, destructive: isDestructive)
    }
}

/// A button style that applies fg and bg color, as well as border radius.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.secondary)`` modifier.
public struct SecondaryAltButtonStyle: ButtonStyle {
    private var isDestructive: Bool
    private var isEnabled: Bool

    public init(enabled: Bool = true, destructive: Bool = false) {
        isEnabled = enabled
        isDestructive = destructive
    }

    var foregroundColor: Color {
        switch (isDestructive, isEnabled) {
        case (false, true):
            return Colors.primary
        case (false, false):
            return Color(.systemGray)
        case (true, true):
            return Colors.red600
        case (true, false):
            return Color(.systemGray)
        }
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .center)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .background(Colors.systemBackgroundSecondary)
            .foregroundColor(foregroundColor)
            .cornerRadius(16)
            .padding(.horizontal)
    }
}

extension ButtonStyle where Self == SecondaryAltButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.secondary)`` modifier.
    public static var secondaryAlt: SecondaryAltButtonStyle { SecondaryAltButtonStyle() }

    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.secondaryAlt(isEnabled:,isDestructive: false))`` modifier.
    public static func secondaryAlt(isEnabled: Bool = true, isDestructive: Bool = false) -> SecondaryAltButtonStyle {
        SecondaryAltButtonStyle(enabled: isEnabled, destructive: isDestructive)
    }
}

struct SecondaryButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Group {
                    Text("Secondary Plain")
                        .font(.title)
                        .padding(.horizontal)

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(SecondaryButtonStyle(enabled: true, destructive: false))

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(SecondaryButtonStyle(enabled: false, destructive: false))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(SecondaryButtonStyle(enabled: true, destructive: false))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(SecondaryButtonStyle(enabled: false, destructive: false))
                }

                Group {
                    Text("Secondary Destructive")
                        .font(.title)
                        .padding(.horizontal)

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(SecondaryButtonStyle(enabled: true, destructive: true))

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(SecondaryButtonStyle(enabled: false, destructive: true))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(SecondaryButtonStyle(enabled: true, destructive: true))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(SecondaryButtonStyle(enabled: false, destructive: true))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
