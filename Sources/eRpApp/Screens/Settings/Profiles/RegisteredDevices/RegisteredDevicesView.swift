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

import CasePaths
import ComposableArchitecture
import eRpStyleKit
import IDP
import SwiftUI

struct RegisteredDevicesView: View {
    let store: RegisteredDevicesDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, RegisteredDevicesDomain.Action>

    init(store: RegisteredDevicesDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let destinationTag: RegisteredDevicesDomain.Destinations.State.Tag?
        let content: RegisteredDevicesDomain.State.Content
        let thisDeviceKeyIdentifier: String?

        init(with state: RegisteredDevicesDomain.State) {
            destinationTag = state.destination?.tag
            content = state.content
            thisDeviceKeyIdentifier = state.thisDeviceKeyIdentifier
        }
    }

    func delete(at offsets: IndexSet) {
        let deviceKeysToDelete: [String] = offsets.compactMap { offset in
            if let entries = (/RegisteredDevicesDomain.State.Content.loaded)
                .extract(from: viewStore.content),
                entries.count > offset {
                return entries[offset].keyIdentifier
            }
            return nil
        }

        for key in deviceKeysToDelete {
            viewStore.send(.deleteDevice(key))
        }
    }

    func description(for entry: RegisteredDevicesDomain.State.Entry) -> String {
        if viewStore.thisDeviceKeyIdentifier != nil,
           entry.keyIdentifier == viewStore.thisDeviceKeyIdentifier {
            return L10n.stgTxtRegDevicesRegisteredSinceThisDevice(entry.date).text
        } else {
            return L10n.stgTxtRegDevicesRegisteredSince(entry.date).text
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewStore.content {
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
                        viewStore.send(.loadDevices)
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
            await viewStore.send(.task).finish()
        }
        .fullScreenCover(
            store: store.scope(state: \.$destination, action: RegisteredDevicesDomain.Action.destination),
            state: /RegisteredDevicesDomain.Destinations.State.cardWallCAN,
            action: RegisteredDevicesDomain.Destinations.Action.cardWallCAN
        ) { store in
            NavigationView {
                CardWallCANView(store: store)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .subTitleStyle(PlainSectionContainerSubTitleStyle())
        .alert(
            store.scope(
                state: \.$destination,
                action: RegisteredDevicesDomain.Action.destination
            ),
            state: /RegisteredDevicesDomain.Destinations.State.alert,
            action: RegisteredDevicesDomain.Destinations.Action.alert
        )
        .navigationTitle(L10n.stgTxtRegDevicesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.secondarySystemBackground)
            .ignoresSafeArea())
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
        NavigationView {
            RegisteredDevicesView(
                store: RegisteredDevicesDomain.Dummies.store(
                    for: RegisteredDevicesDomain.Dummies.devicesState
                )
            )
        }
    }
}
