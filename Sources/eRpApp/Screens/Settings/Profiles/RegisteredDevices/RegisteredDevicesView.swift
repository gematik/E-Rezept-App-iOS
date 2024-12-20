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

import CasePaths
import ComposableArchitecture
import eRpStyleKit
import IDP
import SwiftUI

struct RegisteredDevicesView: View {
    @Perception.Bindable var store: StoreOf<RegisteredDevicesDomain>

    func delete(at offsets: IndexSet) {
        let deviceKeysToDelete: [String] = offsets.compactMap { offset in
            if let entries = store.content[case: \RegisteredDevicesDomain.State.Content.Cases.loaded],
               entries.count > offset {
                return entries[offset].keyIdentifier
            }
            return nil
        }

        for key in deviceKeysToDelete {
            store.send(.deleteDevice(key))
        }
    }

    func description(for entry: RegisteredDevicesDomain.State.Entry) -> String {
        if store.thisDeviceKeyIdentifier != nil,
           entry.keyIdentifier == store.thisDeviceKeyIdentifier {
            return L10n.stgTxtRegDevicesRegisteredSinceThisDevice(entry.date).text
        } else {
            return L10n.stgTxtRegDevicesRegisteredSince(entry.date).text
        }
    }

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                switch store.content {
                case let .loading(entries):
                    if !entries.isEmpty {
                        List {
                            Section(
                                content: {
                                    ForEach(entries) { entry in
                                        SubTitle(
                                            title: entry.name,
                                            description: description(for: entry)
                                        )
                                        .padding(.vertical)
                                    }
                                },
                                header: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                                }
                            )
                        }
                        .listStyle(InsetGroupedListStyle())
                    } else {
                        VStack {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                case let .loaded(entries):
                    if !entries.isEmpty {
                        List {
                            ForEach(entries) { entry in
                                SubTitle(
                                    title: entry.name,
                                    description: description(for: entry)
                                )
                                .padding(.vertical)
                                .accessibilityElement(children: .combine)
                            }
                            .onDelete(perform: delete)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .toolbar {
                            EditButton()
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text(L10n.stgTxtRegDevicesEmptyListTitle)
                                .font(.headline)

                            Text(L10n.stgTxtRegDevicesEmptyList)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                case .notLoaded:
                    VStack(spacing: 8) {
                        Text(L10n.stgTxtRegDevicesInfoTitle)
                            .font(.headline)

                        Text(L10n.stgTxtRegDevicesInfo)
                            .font(.subheadline)
                            .foregroundColor(Color(.secondaryLabel))
                            .multilineTextAlignment(.center)

                        Button(action: {
                            store.send(.loadDevices)
                        }, label: {
                            Label(title: {
                                Text(L10n.stgBtnRegDevicesLoad)
                                    .font(.subheadline)
                            }, icon: {
                                Image(systemName: SFSymbolName.refresh)
                            })
                        })
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .task {
                await store.send(.task).finish()
            }
            .fullScreenCover(item: $store.scope(state: \.destination?.cardWallCAN,
                                                action: \.destination.cardWallCAN)) { store in
                NavigationStack {
                    CardWallCANView(store: store)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .subTitleStyle(PlainSectionContainerSubTitleStyle())
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .navigationTitle(L10n.stgTxtRegDevicesTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemBackground)
                .ignoresSafeArea())
        }
    }
}

struct IDPCardWall: View {
    let store: String

    var body: some View {
        Text(store)
    }
}

struct RegisteredDevicesView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisteredDevicesView(
                store: RegisteredDevicesDomain.Dummies.store(
                    for: RegisteredDevicesDomain.Dummies.devicesState
                )
            )
        }
    }
}
