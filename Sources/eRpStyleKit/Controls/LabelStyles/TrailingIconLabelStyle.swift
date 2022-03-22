//
//  Copyright (c) 2022 gematik GmbH
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

/// `LabelStyle` applying font and color for full width action buttons within `SectionContainer`s. This style is applied
/// automatically within `SectionContainer`.
public struct TrailingIconLabelStyle: LabelStyle {
    @Environment(\.sectionContainerIsLastElement)
    var isLastElement: Bool

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                configuration.title
                    .foregroundColor(Color(.label))
                    .frame(maxWidth: .infinity, alignment: .leading)

                configuration.icon
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(width: 22, height: 22, alignment: .center)
                    .font(.body.weight(.semibold))
            }
            .padding([.bottom, .trailing, .top])

            if !isLastElement {
                Divider()
            }
        }

        .subTitleStyle(PlainSectionContainerSubTitleStyle())
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .padding([.leading])
    }
}

extension LabelStyle where Self == SectionContainerLabelStyle {
    /// A label style that applies standard border artwork based on the
    /// button's context.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    public static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

struct TrailingIconLabelStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SectionContainer {
                    Label("Simple Label", systemImage: SFSymbolName.ant)
                        .labelStyle(.trailingIcon)

                    Label("Simple Label", systemImage: SFSymbolName.ant)
                        .labelStyle(.trailingIcon)

                    Label("Simple Label", systemImage: SFSymbolName.ant)
                        .labelStyle(.trailingIcon)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
