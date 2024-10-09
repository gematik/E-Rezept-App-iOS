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

/// LabelStyle applying basic font and color modifiers without any padding
public struct SectionContainerColoredIconLabelStyle: LabelStyle {
    var padding = false

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            configuration.icon
                .foregroundColor(Colors.primary)
                .frame(width: 22, height: 22, alignment: .center)
                .font(.body.weight(.semibold))
            configuration.title
                .foregroundColor(Color(.label))
        }
        .padding(.leading, padding ? 16 : 0)
    }
}

// swiftlint:disable:next type_name
struct SectionContainerColoredIconLabelStyle_Preview: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Label("Simple Label", systemImage: SFSymbolName.ant)
                    .labelStyle(SectionContainerColoredIconLabelStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Color(.secondarySystemBackground))
    }
}
