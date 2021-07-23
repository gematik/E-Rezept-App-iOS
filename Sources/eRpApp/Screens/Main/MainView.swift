//
//  Copyright (c) 2021 gematik GmbH
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

import ComposableArchitecture
import Introspect
import SwiftUI

struct MainView: View {
    let store: MainDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, MainDomain.Action>

    init(store: MainDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isSettingsViewPresented: Bool
        let isScannerViewPresented: Bool
        let isDemoModeEnabled: Bool

        init(state: MainDomain.State) {
            isSettingsViewPresented = state.settingsState != nil
            isScannerViewPresented = state.scannerState != nil
            isDemoModeEnabled = state.isDemoMode
        }
    }

    var body: some View {
        NavigationView {
            Group {
                GroupedPrescriptionListView(store: store.scope(
                    state: \.prescriptionListState,
                    action: MainDomain.Action.prescriptionList(action:)
                ))
                    // Workaround to get correct accessibility while activating voice over *after* presentation of
                    // settings dialog. As soon as we can use multiple `fullScreenCover` (drop iOS <= ~14.4) we may omit
                    // this modifier and the `EmptyView()`.
                .accessibility(hidden: viewStore.isSettingsViewPresented || viewStore.isScannerViewPresented)

                // Settings sheet presentation; Work around not being able to use multiple `fullScreenCover` modifier
                // at once. As soon as we drop iOS <= ~14.4, we may omit this.
                EmptyView()
                    .fullScreenCover(isPresented: viewStore.binding(
                        get: \.isSettingsViewPresented,
                        send: MainDomain.Action.dismissSettingsView
                    )) {
                        IfLetStore(
                            store.scope(
                                state: { $0.settingsState },
                                action: MainDomain.Action.settings(action:)
                            ),
                            then: SettingsView.init(store:)
                        )
                    }

                // ScannerView sheet presentation; Work around not being able to use multiple `fullScreenCover` modifier
                // at once. As soon as we drop iOS <= ~14.4, we may omit this.
                EmptyView()
                    .fullScreenCover(isPresented: viewStore.binding(
                        get: \.isScannerViewPresented,
                        send: MainDomain.Action.dismissScannerView
                    )) {
                        IfLetStore(
                            store.scope(
                                state: { $0.scannerState },
                                action: MainDomain.Action.scanner(action:)
                            ),
                            then: ErxTaskScannerView.init(store:)
                        )
                    }
            }
            .navigationTitle(Text(L10n.erxTitle))
            .navigationBarTitleDisplayMode(viewStore.isDemoModeEnabled ? .inline : .automatic)
            .navigationBarItems(
                leading: SettingsItem { viewStore.send(.showSettingsView) },
                trailing: ScanItem { viewStore.send(.showScannerView) }
            )
            .demoBanner(isPresented: viewStore.isDemoModeEnabled) {
                viewStore.send(MainDomain.Action.turnOffDemoMode)
            }
            .onAppear {
                viewStore.send(.subscribeToDemoModeChange)
            }
            .onDisappear {
                viewStore.send(.unsubscribeFromDemoModeChange)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// swiftlint:disable no_extension_access_modifier
private extension MainView {
    // MARK: - screen related views

    struct SettingsItem: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.settings)
                    .font(Font.title3.weight(.bold))
                    .foregroundColor(Colors.primary700)
                    .padding(.trailing)
                    .padding(.vertical)
            }
            .accessibility(identifier: A18n.mainScreen.erxBtnShowSettings)
            .accessibility(label: Text(L10n.erxBtnShowSettings))
        }
    }

    struct ScanItem: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: SFSymbolName.camera)
                    .font(Font.title3.weight(.bold))
                    .foregroundColor(Colors.primary700)
                    .padding(.leading)
                    .padding(.vertical)
            }
            .accessibility(identifier: A18n.mainScreen.erxBtnScnPrescription)
            .accessibility(label: Text(L10n.erxBtnScnPrescription))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.Dummies.state
                    )
                )
            )
            .preferredColorScheme(.light)

            MainView(
                store: MainDomain.Dummies.storeFor(
                    MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(
                            groupedPrescriptions: Array(
                                repeating: GroupedPrescription.Dummies.twoPrescriptions,
                                count: 2
                            )
                        ),
                        debug: DebugDomain.Dummies.state
                    )
                )
            )
            .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store)
                .preferredColorScheme(.light)

            MainView(store: MainDomain.Dummies.store)
                .previewDevice("iPod touch (7th generation)")
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
        }
    }
}
