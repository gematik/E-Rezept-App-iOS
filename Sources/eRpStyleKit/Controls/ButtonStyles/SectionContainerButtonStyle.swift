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

/// `ButtonStyle` for `Button`s within `SectionContainer`. This style is applied automatically when creating buttons
/// within a `SectionContainer`.
public struct SectionContainerButtonStyle: ButtonStyle {
    let showSeparator: Bool

    public init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .keyValuePairStyle(PlainKeyValuePairStyle())
            .labelStyle(SectionContainerButtonLabelStyle(showSeparator: showSeparator))
            .foregroundColor(configuration.isPressed ? Colors.primary.opacity(0.5) : Colors.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(configuration.isPressed ? Color(.systemGray5) : Color(.tertiarySystemBackground))
    }
}

extension ButtonStyle where Self == SectionContainerButtonStyle {
    /// A button style that applies colors according to figma as well as paddings and wraps it with a divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    public static var simple: SectionContainerButtonStyle { SectionContainerButtonStyle(showSeparator: true) }

    /// A button style that applies colors according to figma as well as paddings and wraps it with a divider.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(.plain(showSeparator:))`` modifier.
    public static func simple(showSeparator: Bool = true) -> SectionContainerButtonStyle {
        SectionContainerButtonStyle(showSeparator: showSeparator)
    }
}

struct SectionContainerButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SectionContainer(header: {
                    Text("Simple Button examples")
                }, content: {
                    Button(action: {}, label: {
                        Label(title: { Text("Simple Label without icon") }, icon: {})
                    })

                    Button(action: {}, label: {
                        Label("Simple Label", systemImage: "qrcode")
                    })

                    Button(action: {}, label: {
                        Text("Simple Text without icon needs manual padding!")
                            .padding()
                    })
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
