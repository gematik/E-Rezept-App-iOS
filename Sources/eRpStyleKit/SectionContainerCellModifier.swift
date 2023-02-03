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

private struct SectionContainerCellLastElementKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var sectionContainerIsLastElement: Bool {
        get { self[SectionContainerCellLastElementKey.self] }
        set { self[SectionContainerCellLastElementKey.self] = newValue }
    }
}

extension View {
    /// Use on the content of a `SectionContainer` and pass `true` if the element is the last Element in list
    /// This will remove the separator from the last element in the section.
    public func sectionContainerIsLastElement(_ sectionContainerIsLastElement: Bool) -> some View {
        environment(\.sectionContainerIsLastElement, sectionContainerIsLastElement)
    }
}

public struct SectionContainerCellModifier: ViewModifier {
    let last: Bool

    public init(last: Bool = false) {
        self.last = last
    }

    public func body(content: Content) -> some View {
        Group {
            content
                .labelStyle(SectionContainerLabelStyle(showSeparator: !last))
                .buttonStyle(SectionContainerButtonStyle(showSeparator: !last))
                .toggleStyle(FormToggleStyle(showSeparator: !last))
                .subTitleStyle(SectionContainerSubTitleStyle(showSeparator: !last))
                .keyValuePairStyle(SeparatedKeyValuePairStyle(showSeparator: !last))
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .sectionContainerIsLastElement(last)
        }
    }
}

struct ListsAtoms_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
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
                        .buttonStyle(.navigation(showSeparator: false))
                    }

                    SectionContainer {
                        NavigationLink(destination: Text("abc")) {
                            Label {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: nil)
                            } icon: {
                                InitialsImage(backgroundColor: Colors.primary200, text: "SD", statusColor: nil)
                            }
                        }
                        .buttonStyle(.navigation)

                        NavigationLink(destination: Text("abc")) {
                            Label {
                                SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: nil)
                            } icon: {
                                InitialsImage(backgroundColor: Colors.primary200,
                                              text: "SD",
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
