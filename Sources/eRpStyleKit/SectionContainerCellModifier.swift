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

struct SectionContainerElementInformation {
    var isRootElement = false
    var isLastElement = false
    var isSectionContainerElement = false
    var isNavigationLinkElement = false

    static func defaultElement(isLastElement: Bool = false) -> Self {
        SectionContainerElementInformation(
            isRootElement: true,
            isLastElement: isLastElement,
            isSectionContainerElement: true,
            isNavigationLinkElement: false
        )
    }

    func disableRoot() -> Self {
        var copy = self
        copy.isRootElement = false
        return copy
    }

    func disableNavigationLink() -> Self {
        var copy = self
        copy.isNavigationLinkElement = false
        return copy
    }

    func enableNavigationLink() -> Self {
        guard isSectionContainerElement else { return self }

        var copy = self
        copy.isNavigationLinkElement = true
        return copy
    }

    func enableLastElement() -> Self {
        guard isSectionContainerElement else { return self }

        var copy = self
        copy.isLastElement = true
        return copy
    }

    func disableLastElement() -> Self {
        var copy = self
        copy.isLastElement = false
        return copy
    }
}

private struct SectionContainerElementInformationKey: EnvironmentKey {
    static let defaultValue = SectionContainerElementInformation()
}

extension EnvironmentValues {
    var sectionContainerElementInformation: SectionContainerElementInformation {
        get { self[SectionContainerElementInformationKey.self] }
        set { self[SectionContainerElementInformationKey.self] = newValue }
    }
}

extension View {
    func sectionContainerElementInformation(_ info: SectionContainerElementInformation) -> some View {
        environment(\.sectionContainerElementInformation, info)
    }

    /// Use on the content of a `SectionContainer` and pass `true` if the element is the last Element in list
    /// This will remove the separator from the last element in the section.
    public func sectionContainerIsLastElement(_ sectionContainerIsLastElement: Bool) -> some View {
        environment(\.sectionContainerElementInformation.isLastElement, sectionContainerIsLastElement)
    }

    /// Use on the content of a `SectionContainer` and pass `true` if the element is the root most Element in the view
    /// hierachy. Styles of elements will call this method using `false` if they "consume" the root information by
    /// applying the appropriate styling.
    public func rootSectionContainerElement(_ isRootSectionContainerElement: Bool) -> some View {
        environment(\.sectionContainerElementInformation.isRootElement, isRootSectionContainerElement)
    }
}

public struct SectionContainerCellModifier: ViewModifier {
    let last: Bool

    public init(last: Bool = false) {
        self.last = last
    }

    public func body(content: Content) -> some View {
        content
            .labelStyle(SectionContainerLabelStyle())
            .buttonStyle(SectionContainerButtonStyle())
            .toggleStyle(FormToggleStyle())
            .subTitleStyle(SectionContainerSubTitleStyle())
            .keyValuePairStyle(SeparatedKeyValuePairStyle())
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .labeledContentStyle(.vertical)
            .sectionContainerElementInformation(.defaultElement(isLastElement: last))
    }
}

struct ListsAtoms_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    SectionContainer {
                        NavigationLink(destination: Text("abc")) {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        }
                        .buttonStyle(.navigation)

                        Toggle(isOn: .constant(false)) {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        }
                        .toggleStyle(.radio)

                        Toggle(isOn: .constant(true)) {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        }
                        .toggleStyle(.radio)

                        Toggle(isOn: .constant(true)) {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        }

                        Button(action: {}, label: {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        })

                        NavigationLink(destination: Text("abc")) {
                            Label {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: nil)
                            } icon: {
                                Image(systemName: SFSymbolName.info)
                            }
                        }
                        .buttonStyle(.navigation)
                    }

                    SectionContainer {
                        NavigationLink(destination: Text("abc")) {
                            Label {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: nil)
                            } icon: {
                                InitialsImage(
                                    backgroundColor: Colors.primary200,
                                    text: "AB",
                                    statusColor: nil
                                )
                            }
                        }
                        .buttonStyle(.navigation)

                        NavigationLink(destination: Text("abc")) {
                            Label {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: nil)
                            } icon: {
                                InitialsImage(backgroundColor: Colors.primary200,
                                              text: "AB",
                                              statusColor: nil,
                                              size: .large)
                            }
                        }
                        .buttonStyle(.navigation)

                        NavigationLink(destination: Text("abc")) {
                            Label(title: {
                                KeyValuePair(key: "Impressum", value: "Detail")
                            }, icon: {})
                        }
                        .buttonStyle(.navigation)

                        NavigationLink(destination: Text("abc")) {
                            Label(title: {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig")
                            }, icon: {})
                        }
                        .buttonStyle(.navigation)

                        Toggle(isOn: .constant(false)) {
                            Label(title: { Text("Impressum") }, icon: {})
                        }
                        .toggleStyle(.radio)

                        Toggle(isOn: .constant(true)) {
                            Label(title: { Text("Impressum") }, icon: {})
                        }
                    }
                }
            }.background(Color(.secondarySystemBackground))
        }
    }
}
