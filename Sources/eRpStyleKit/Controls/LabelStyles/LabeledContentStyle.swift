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
    var icon: String?

    init(icon: String? = nil) {
        self.icon = icon
    }

    public func makeBody(configuration: Configuration) -> some View {
        VerticalLabeledContentBody(configuration: configuration, icon: icon)
    }
}

private struct VerticalLabeledContentBody: View {
    let configuration: LabeledContentStyleConfiguration
    var icon: String?
    let minChevronSpacing: CGFloat = 16

    @Environment(\.sectionContainerElementInformation.isRootElement) var isRootElement
    @Environment(\.sectionContainerElementInformation) var sectionContainerElementInformation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .labelStyle(.iconOnly)
                    .fixedSize(horizontal: false, vertical: true)

                configuration.content
                    .font(.body)
                    .foregroundColor(Colors.systemLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .sectionContainerElementInformation(
                sectionContainerElementInformation
                    .disableNavigationLink()
                    .disableRoot()
            )

            if let icon {
                Spacer(minLength: minChevronSpacing)

                Image(systemName: icon)
                    .foregroundColor(Colors.primary700)
                    .font(.subheadline.weight(.semibold))
            }
            if sectionContainerElementInformation.isNavigationLinkElement {
                if icon == nil {
                    Spacer(minLength: minChevronSpacing)
                }

                Image(systemName: SFSymbolName.chevronForward)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .font(.body.weight(.semibold))
            }
        }
        .bottomDividerIfNeeded()
        .padding(.leading, isRootElement ? 16 : 0)
    }
}

/// `VerticalLabeledContentStyle` defines a label style where the label is below the content
public struct HorizontalLabeledContentStyle: LabeledContentStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HorizontalLabeledContentBody(configuration: configuration)
    }
}

private struct HorizontalLabeledContentBody: View {
    let configuration: LabeledContentStyleConfiguration
    let minChevronSpacing: CGFloat = 16

    @Environment(\.sectionContainerElementInformation.isRootElement) var isRootElement
    @Environment(\.sectionContainerElementInformation) var sectionContainerElementInformation

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            configuration.label
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Colors.systemLabel)

            Spacer()

            configuration.content
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Colors.systemLabelSecondary)

            if sectionContainerElementInformation.isNavigationLinkElement {
                Spacer(minLength: minChevronSpacing)

                Image(systemName: SFSymbolName.chevronForward)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .font(.body.weight(.semibold))
            }
        }
        .rootSectionContainerElement(false)
        .sectionContainerElementInformation(
            sectionContainerElementInformation
                .disableNavigationLink()
                .disableRoot()
        )
        .padding(.leading, isRootElement ? 16 : 0)
        .bottomDividerIfNeeded()
    }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    /// A labeledContent style that applies the label vertical above the content.
    ///
    /// To apply this style to a labeledContent, or to a view that contains a label, use
    /// the ``View/labeledContentStyle(_:)`` modifier.
    public static var vertical: VerticalLabeledContentStyle {
        .init()
    }

    /// A labeledContent style that applies the label vertical above the content with an trailing icon.
    ///
    /// To apply this style to a labeledContent, or to a view that contains a label, use
    /// the ``View/labeledContentStyle(_:)`` modifier.
    public static func vertical(icon: String) -> VerticalLabeledContentStyle {
        .init(icon: icon)
    }
}

extension LabeledContentStyle where Self == HorizontalLabeledContentStyle {
    /// A labeledContent style that applies the label vertical below the content.
    ///
    /// To apply this style to a labeledContent, or to a view that contains a label, use
    /// the ``View/labeledContentStyle(_:)`` modifier.
    public static var horizontal: HorizontalLabeledContentStyle {
        .init()
    }
}

struct LabeledContentStyle_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Form {
                LabeledContent("Label", value: "Content")
                    .labeledContentStyle(.vertical)

                Section {
                    LabeledContent("Label", value: "Content")
                        .labeledContentStyle(.vertical)

                    NavigationLink {
                        Text("ABC")
                    } label: {
                        LabeledContent("Label", value: "Content")
                            .labeledContentStyle(.vertical)
                    }
                } header: {
                    Text("Labeled Content")
                }

                Section {
                    Label {
                        LabeledContent("Label", value: "Content 2")
                            .labeledContentStyle(.vertical)
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                    .labelStyle(.trailingIcon)

                    NavigationLink {
                        Text("abc")
                    } label: {
                        Label {
                            LabeledContent("Label", value: "Content 2")
                                .labeledContentStyle(.vertical)
                        } icon: {
                            Image(systemName: "star.fill")
                        }
                        .labelStyle(.trailingIcon)
                    }

                    LabeledContent {
                        Text("Ein")
                    } label: {
                        LabeledContent("Label", value: "Content 2")
                            .labeledContentStyle(.vertical)
                    }

                    NavigationLink {
                        Text("abc")
                    } label: {
                        LabeledContent {
                            Text("Ein")
                        } label: {
                            LabeledContent("Label", value: "Content 2")
                                .labeledContentStyle(.vertical)
                        }
                    }

                    LabeledContent {
                        Text("Text")
                    } label: {
                        Label("Label", systemImage: "star.fill")
                    }
                    .labeledContentStyle(.vertical)

                    LabeledContent {
                        Label("Text", systemImage: "star.fill")
                    } label: {
                        Text("Label")
                    }
                    .labeledContentStyle(.vertical)

                    LabeledContent("Label", value: "Content")
                        .labeledContentStyle(.vertical)

                    NavigationLink {
                        Text("ABC")
                    } label: {
                        LabeledContent("Label", value: "Content")
                            .labeledContentStyle(.vertical)
                    }

                } header: {
                    Text("Labeled Content With Icon")
                }
            }
        }
    }
}
