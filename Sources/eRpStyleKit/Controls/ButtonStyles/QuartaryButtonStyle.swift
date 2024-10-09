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

/// A button style that applies fg and bg color, as well as a border.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.Quartary)`` modifier.
public struct QuartaryButtonStyle: ButtonStyle {
    var isEnabled: Bool

    public init(enabled: Bool = true) {
        isEnabled = enabled
    }

    var foregroundColor: Color {
        isEnabled ? Colors.primary : Color(.systemGray)
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(foregroundColor)
            .opacity(configuration.isPressed ? 0.25 : 1)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Colors.systemBackgroundTertiary)
            .border(Colors.separator, width: 0.5, cornerRadius: 8)
    }
}

extension ButtonStyle where Self == QuartaryButtonStyle {
    /// A button style that applies fg and bg color, as well as a border.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.quartary)`` modifier.
    public static var quartary: QuartaryButtonStyle { QuartaryButtonStyle() }

    /// A button style that applies fg and bg color, as well as a border.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.quartary(isEnabled:))`` modifier.
    public static func quartary(isEnabled: Bool = true) -> QuartaryButtonStyle {
        QuartaryButtonStyle(enabled: isEnabled)
    }
}

struct QuartaryButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Quartary Plain")
                        .font(.title)
                        .padding(.horizontal)

                    Button(action: {}, label: { Text("Simple") })
                        .buttonStyle(QuartaryButtonStyle(enabled: true))
                        .disabled(true)

                    Button(action: {}, label: { Text("Simple") })
                        .environment(\.isEnabled, false)
                        .buttonStyle(QuartaryButtonStyle(enabled: false))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(QuartaryButtonStyle(enabled: true))

                    Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                        .buttonStyle(QuartaryButtonStyle(enabled: false))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        //        .preferredColorScheme(.dark)
        .background(Color(.secondarySystemBackground))
    }
}
