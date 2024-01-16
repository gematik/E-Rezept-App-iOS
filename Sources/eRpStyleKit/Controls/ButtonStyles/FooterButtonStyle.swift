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

/// A button style that fits the footer style. This style is applied automatically to Buttons within a
/// ``SectionContainer`` footer.
///
/// To apply this style to a button, or to a view that contains buttons, use
/// the ``View.buttonStyle(.footer)`` modifier.
public struct FooterButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Colors.primary.opacity(0.5) : Colors.primary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

extension ButtonStyle where Self == FooterButtonStyle {
    /// A button style that fits the footer style.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View.buttonStyle(.footer)`` modifier.
    public static var footer: FooterButtonStyle { FooterButtonStyle() }
}

// swiftlint:disable:next type_name
struct SectionContainerFooterButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SingleElementSectionContainer(footer: {
                    Button("Button") {}
                }, content: {
                    Label(title: { Text("Simple footer Button example") }, icon: {})
                })

                SingleElementSectionContainer(footer: {
                    Text("Text prepending the button and explaining things in a very long manner.")
                    Button("Button") {}
                }, content: {
                    Label(title: { Text("Footer Button example") }, icon: {})
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
