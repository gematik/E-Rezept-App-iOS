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

/// `LabelStyle` applying font and color for full width action buttons within `SectionContainer`s.
public struct SectionContainerButtonLabelStyle: LabelStyle {
    let showSeparator: Bool

    public init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            configuration.icon
                .frame(width: 22, height: 22, alignment: .center)

            VStack(alignment: .leading, spacing: 0) {
                configuration.title
                    .padding([.bottom, .trailing, .top])
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showSeparator {
                    Divider()
                }
            }
        }
        .font(.body.weight(.semibold))
        .foregroundColor(Colors.primary)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .subTitleStyle(PlainSectionContainerSubTitleStyle())
    }
}

struct SectionContainerButtonLabelStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                SectionContainer {
                    Label("Manual usage", systemImage: SFSymbolName.ant)
                        .labelStyle(SectionContainerButtonLabelStyle(showSeparator: true))

                    Button(action: {}, label: {
                        Label("Automatic usage usage within a button", systemImage: SFSymbolName.ant)
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
