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

/// A button style meant for a button with a label inside
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.picture)`` modifier.
public struct PictureButtonStyle: ButtonStyle {
    public typealias Style = PictureLabelStyle.Style

    var style: PictureLabelStyle.Style
    var isActive: Bool

    private var isLarge: Bool {
        switch style {
        case .large,
             .supplyLarge:
            return true
        default: return false
        }
    }

    public init(style: PictureLabelStyle.Style = .default, active: Bool = false) {
        self.style = style
        isActive = active
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .labelStyle(PictureLabelStyle(style: style))
            .opacity(configuration.isPressed ? 0.25 : 1)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .center)
            .padding(isLarge ? 16 : 8)
            .background(
                Colors.systemBackgroundTertiary
                    .border(
                        isActive ? Colors.primary : Colors.systemGray5,
                        width: isActive ? 2.0 : 1.0,
                        cornerRadius: 16
                    )
            )
            .cornerRadius(16)
            .shadow(color: Colors.systemColorBlack.opacity(0.25), radius: 0.0, x: 0.0, y: 0.5)
    }
}

public struct PictureLabelStyle: LabelStyle {
    public enum Style {
        case `default`
        case large
        case supply
        case supplyLarge
    }

    var style: Style

    public init(style: Style) {
        self.style = style
    }

    private var isLarge: Bool {
        switch style {
        case .large,
             .supplyLarge:
            return true
        default: return false
        }
    }

    private var color: Color {
        switch style {
        case .default,
             .large:
            return Colors.primary
        default:
            return Colors.systemLabel
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon
                .frame(width: isLarge ? 56 : 32, height: isLarge ? 56 : 32)
                .clipped()
                .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 4)

            configuration.title
                .font(.caption)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
    }
}

extension ButtonStyle where Self == PictureButtonStyle {
    /// A button style that applies fg and bg color, as well as border radius, defaulting to max available width.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.primary)`` modifier.
    public static var picture: PictureButtonStyle { PictureButtonStyle() }

    /// A button style that applies fg and bg color, as well as border radius.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.primary(isEnabled:,isDestructive: false))`` modifier.
    public static func picture(style: Self.Style = .default, isActive: Bool = false) -> PictureButtonStyle {
        PictureButtonStyle(style: style, active: isActive)
    }
}

struct PictureButtonStyle_Preview: PreviewProvider {
    struct TestButton: View {
        var style: PictureButtonStyle.Style
        var active: Bool

        var body: some View {
            Button {} label: {
                Label {
                    Text("Label")
                } icon: {
                    Image(systemName: SFSymbolName.car)
                        .resizable()
                        .padding(4)
                        .background(
                            .linearGradient(
                                Gradient(
                                    colors: [.brown, .cyan]
                                ),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                }
            }
            .buttonStyle(.picture(style: style, isActive: active))
        }
    }

    static var previews: some View {
        ScrollView {
            Section("light") {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .default, active: false)
                            TestButton(style: .default, active: true)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .large, active: false)
                            TestButton(style: .large, active: true)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .supply, active: false)
                            TestButton(style: .supply, active: true)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .supplyLarge, active: false)
                            TestButton(style: .supplyLarge, active: true)
                        }
                    }
                }
                .padding()
            }

            Section("dark") {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .default, active: false)
                            TestButton(style: .default, active: true)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .large, active: false)
                            TestButton(style: .large, active: true)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .supply, active: false)
                            TestButton(style: .supply, active: true)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            TestButton(style: .supplyLarge, active: false)
                            TestButton(style: .supplyLarge, active: true)
                        }
                    }
                }
                .padding()
                .background(Colors.systemBackground)
                .environment(\.colorScheme, .dark)
            }
        }
        .background(Colors.systemBackground)
    }
}
