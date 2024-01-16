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

/// A button style that applies fg and bg color, as well as border radius.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.tertiaryFilled)`` modifier.
public struct TertiaryFilledButtonStyle: ButtonStyle {
    private var isDestructive: Bool

    var isEnabled: Bool

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
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .foregroundColor(Color(.white))
            .background(foregroundColor)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .cornerRadius(8)
    }
}

extension ButtonStyle where Self == TertiaryFilledButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.tertiaryFilled)`` modifier.
    public static var tertiaryFilled: TertiaryFilledButtonStyle { TertiaryFilledButtonStyle() }

    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.tertiary(isEnabled:,isDestructive: false))`` modifier.
    public static func tertiaryFilled(isEnabled: Bool = true,
                                      isDestructive: Bool = false) -> TertiaryFilledButtonStyle {
        TertiaryFilledButtonStyle(enabled: isEnabled, destructive: isDestructive)
    }
}

struct TertiaryFilledButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Tertiary Plain")
                        .font(.title)
                        .padding(.horizontal)

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: true, destructive: false))
                        .disabled(true)

                    Button(action: {}, label: { Text("Simple") })
                        .environment(\.isEnabled, false)
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: false, destructive: false))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: true, destructive: false))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: false, destructive: false))
                }

                Group {
                    Text("Tertiary Destructive")
                        .font(.title)
                        .padding(.horizontal)

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: true, destructive: true))

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: false, destructive: true))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: true, destructive: true))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(TertiaryFilledButtonStyle(enabled: false, destructive: true))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
//        .preferredColorScheme(.dark)
        .background(Color(.secondarySystemBackground))
    }
}
