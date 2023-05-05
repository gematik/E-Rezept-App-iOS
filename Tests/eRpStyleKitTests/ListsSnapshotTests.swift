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

import eRpStyleKit
import SnapshotTesting
import SwiftUI
import XCTest

final class ListsSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        diffTool = "open"
    }

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
        let sut = NavigationView {
            SnapshotExampleView()
                .navigationBarTitle("Lists")
                .background(Color(.secondarySystemBackground).ignoresSafeArea())
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testBorderedGroupedListStyle() {
        let sut = NavigationView {
            SnapshotExampleView()
                .sectionContainerStyle(BorderSectionContainerStyle())
                .navigationBarTitle("Lists")
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testInlineListStyle() {
        let sut = NavigationView {
            SnapshotExampleView()
                .sectionContainerStyle(.inline)
                .navigationBarTitle("Lists")
        }
        .frame(width: 375, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}

/// The default `precision` to use if a specific value is not provided.
private let defaultPrecision: Float = 0.99
/// The default `perceptualPrecision` to use if a specific value is not provided.
private let defaultPerceptualPrecision: Float = 0.97

extension XCTestCase {
    func snapshotModi<T>() -> [String: Snapshotting<T, UIImage>] where T: SwiftUI.View {
        [
            "light": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision
            ),
            "dark": .image(
                precision: defaultPrecision,
                perceptualPrecision: defaultPerceptualPrecision,
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
        ]
    }
}
