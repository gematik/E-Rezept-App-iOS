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

import eRpStyleKit
import SnapshotTesting
import SwiftUI
import XCTest

final class ListsSnapshotTests: ERPSnapshotTestCase {
    struct SnapshotExampleView: View {
        var body: some View {
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
                        .buttonStyle(.plain)

                        Toggle(isOn: .constant(true)) {
                            Label("Impressum", systemImage: SFSymbolName.info)
                        }
                        .toggleStyle(.radio)
                        .buttonStyle(.plain)

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

                        Button(action: {}, label: {
                            SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: "PZN Rezept")
                        })
                            .buttonStyle(.navigation)

                        Button(action: {}, label: {
                            SubTitle(title: "Impressum", description: "Noch 12 Tage gültig", details: "PZN Rezept")
                                .subTitleStyle(.info)
                        })
                            .buttonStyle(.navigation)

                        Toggle(isOn: .constant(false)) {
                            Label(title: { Text("Impressum") }, icon: {})
                        }
                        .toggleStyle(.radio)
                        .buttonStyle(.plain)

                        Toggle(isOn: .constant(true)) {
                            Label(title: { Text("Impressum") }, icon: {})
                        }
                    }
                }
            }
        }
    }

    func testSimpleGroupedList() {
        let sut = NavigationStack {
            SnapshotExampleView()
                .navigationBarTitle("Lists")
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testBorderedGroupedListStyle() {
        let sut = NavigationStack {
            SnapshotExampleView()
                .sectionContainerStyle(BorderSectionContainerStyle())
                .navigationBarTitle("Lists")
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testInlineListStyle() {
        let sut = NavigationStack {
            SnapshotExampleView()
                .sectionContainerStyle(.inline)
                .navigationBarTitle("Lists")
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(of: sut, as: snapshotModi())
    }
}
