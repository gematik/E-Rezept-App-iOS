//
//  Copyright (c) 2023 gematik GmbH
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
/// the ``View.buttonStyle(.primary)`` modifier.
public struct PrimaryButtonStyle: ButtonStyle {
    private var isDestructive: Bool

    var isEnabled: Bool
    var isHuggingContent: Bool

    public init(enabled: Bool = true, destructive: Bool = false, hugging: Bool = false) {
        isEnabled = enabled
        isDestructive = destructive
        isHuggingContent = hugging
    }

    var backgroundColor: Color {
        switch (isDestructive, isEnabled) {
        case (false, true):
            return Colors.primary
        case (false, false):
            return Color(.systemGray5)
        case (true, true):
            return Colors.red600
        case (true, false):
            return Color(.systemGray5)
        }
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(isEnabled ? Color.white : Color(.systemGray))
            .opacity(configuration.isPressed ? 0.25 : 1)
            .padding(.horizontal, 32)
            .frame(maxWidth: isHuggingContent ? nil : .infinity, minHeight: 52, alignment: .center)
            .background(backgroundColor)
            .cornerRadius(16)
            .padding(isHuggingContent ? [] : .horizontal)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius, defaulting to max available width.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.primary)`` modifier.
    public static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }

    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.primary(isEnabled:,isDestructive: false))`` modifier.
    public static func primary(isEnabled: Bool = true, isDestructive: Bool = false) -> PrimaryButtonStyle {
        PrimaryButtonStyle(enabled: isEnabled, destructive: isDestructive)
    }

    /// A button style that applies fg and bg color, as well as border radius, hugging its contents.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.primary)`` modifier.
    public static var primaryHugging: PrimaryButtonStyle { PrimaryButtonStyle() }
}

struct PrimaryButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Primary Plain")
                            .font(.title)
                            .padding(.horizontal)

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false))
                            .disabled(true)

                        Button(action: {}, label: { Text("Simple") })
                            .environment(\.isEnabled, false)
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false))
                    }

                    Group {
                        Text("Primary Hugging")
                            .font(.title)
                            .padding(.horizontal)

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false, hugging: true))
                            .disabled(true)

                        Button(action: {}, label: { Text("Simple") })
                            .environment(\.isEnabled, false)
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false, hugging: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false, hugging: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false, hugging: true))
                    }

                    Group {
                        Text("Primary Destructive")
                            .font(.title)
                            .padding(.horizontal)

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: true))

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: true))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .preferredColorScheme(.dark)
            .background(Color(.secondarySystemBackground))

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Primary Plain")
                            .font(.title)
                            .padding(.horizontal)

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false))
                            .disabled(true)

                        Button(action: {}, label: { Text("Simple") })
                            .environment(\.isEnabled, false)
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: false))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false))
                    }

                    Group {
                        Text("Primary Destructive")
                            .font(.title)
                            .padding(.horizontal)

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: true))

                        Button(action: {}, label: { Text("Simple") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: true, destructive: true))

                        Button(action: {}, label: { Label("Label and Icon", systemImage: "qrcode") })
                            .buttonStyle(PrimaryButtonStyle(enabled: false, destructive: false))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .preferredColorScheme(.light)
//            .background(Color(.secondarySystemBackground))
        }
    }
}
