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

/// `VerticalLabeledContentStyle` defines a label style where the label is below the content
public struct VerticalLabeledContentStyle: LabeledContentStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.content
            configuration.label
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Colors.textSecondary)
        }
    }
}

@available(iOS 16.0, *)
extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    /// A labeledContent style that applies the label vertical below the content.
    ///
    /// To apply this style to a labeledContent, or to a view that contains a label, use
    /// the ``View/labeledContentStyle(_:)`` modifier.
    public static var vertical: VerticalLabeledContentStyle { .init() }
}

public struct SectionContainerLabeledContentStyle: LabeledContentStyle {
    let showSeparator: Bool

    init(showSeparator: Bool) {
        self.showSeparator = showSeparator
    }

    @Environment(\.sectionContainerIsLastElement) var isLastElement: Bool

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration.content

            configuration.label
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Colors.textSecondary)
        }
        .padding(.leading)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .bottomDivider(showSeparator: showSeparator)
    }
}

struct LabeledContentStyle_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            if #available(iOS 16.0, *) {
                LabeledContent("Label", value: "Content")
                    .labeledContentStyle(.vertical)
            } else {
                Text("only available with iOS 16.0 or later")
            }
        }
    }
}
