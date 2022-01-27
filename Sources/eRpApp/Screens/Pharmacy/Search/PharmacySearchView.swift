//
//  Copyright (c) 2022 gematik GmbH
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
import Pharmacy
import SwiftUI

struct PharmacySearchView: View {
    let store: PharmacySearchDomain.Store

    init(store: PharmacySearchDomain.Store) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                SearchBarView(store: store)
                    .padding(8)

                if viewStore.state.locationHintState {
                    LocalizationHintView(
                        textAction: { viewStore.send(.locationButtonTapped) },
                        closeAction: { viewStore.send(.closeLocationHint) }
                    )
                    .padding([.top, .horizontal, .bottom])
                }

                PharmacySearchResultView(store: store)

                Spacer()

                PharmacyDetailViewNavigation(store: store)

                // Search-Filter sheet presentation
                EmptyView()
                    .sheet(isPresented: viewStore.binding(
                        get: { $0.pharmacyFilterState != nil },
                        send: PharmacySearchDomain.Action.dismissFilterSheetView
                    )) {
                        IfLetStore(
                            store.scope(
                                state: \.pharmacyFilterState,
                                action: PharmacySearchDomain.Action.pharmacyFilterView(action:)
                            ),
                            then: PharmacySearchFilterView.init(store:)
                        )
                    }
            }
            .padding(8)
            .alert(
                store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .navigationTitle(L10n.phaSearchTxtTitle)
            .navigationBarItems(
                trailing: NavigationBarCloseItem { viewStore.send(.close) }
            )
            .navigationBarTitleDisplayMode(.inline)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
        }
    }

    private struct SearchBarView: View {
        let store: PharmacySearchDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                HStack {
                    Group {
                        Image(systemName: SFSymbolName.magnifyingGlas).padding()
                        TextField(
                            L10n.phaSearchTxtSearchHint,
                            text: viewStore.binding(
                                get: { $0.searchText },
                                send: PharmacySearchDomain.Action.searchTextChanged
                            ),
                            onEditingChanged: { _ in },
                            onCommit: { viewStore.send(.performSearch) }
                        )
                        .accessibility(identifier: A11y.pharmacySearch.phaSearchTxtSearchField)
                        .introspectTextField { textField in
                            textField.returnKeyType = .go
                        }
                        .foregroundColor(
                            viewStore.state.searchText.count > 2 ? Colors.systemLabel : Colors.systemLabelTertiary
                        )
                    }
                    .accessibilityElement(children: .combine)
                    .accessibility(label: Text(L10n.phaSearchTxtSearchHint))
                    .accessibility(hint: Text(L10n.phaSearchTxtHintStartSearch))

                    Button(action: {
                        viewStore.send(.locationButtonTapped)
                    }, label: {
                        Image(systemName: viewStore.state.currentLocation != nil ?
                            SFSymbolName.locationFill : SFSymbolName.location).padding()
                    })
                }
                .foregroundColor(Colors.systemLabelSecondary)
                .background(RoundedRectangle(cornerRadius: 16).fill(Colors.systemFillTertiary))
            }
        }
    }

    private struct LocalizationHintView: View {
        let textAction: () -> Void
        let closeAction: () -> Void

        var body: some View {
            HintView(
                hint: Hint<PharmacySearchDomain.Action>(
                    id: A11y.prescriptionDetails.prscDtlHntNoctuFeeWaiver,
                    title: NSLocalizedString("pha_search_txt_location_hint_title", comment: ""),
                    message: NSLocalizedString("pha_search_txt_location_hint_message", comment: ""),
                    actionText: L10n.phaSearchBtnLocationHintAction,
                    imageName: Asset.Prescriptions.Details.apothekerin.name,
                    closeAction: .closeLocationHint,
                    style: .neutral,
                    buttonStyle: .tertiary,
                    imageStyle: .topAligned
                ),
                textAction: textAction,
                closeAction: closeAction
            )
        }
    }

    private struct PharmacyDetailViewNavigation: View {
        let store: PharmacySearchDomain.Store
        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: { $0.pharmacyDetailState },
                            action: PharmacySearchDomain.Action.pharmacyDetailView(action:)
                        )
                    ) { scopedStore in
                        PharmacyDetailView(store: scopedStore)
                    },
                    isActive: viewStore.binding(
                        get: { $0.pharmacyDetailState != nil },
                        send: PharmacySearchDomain.Action.dismissPharmacyDetailView
                    )
                ) {
                    EmptyView()
                }.accessibility(hidden: true)
            }
        }
    }
}

struct PharmacySearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Search with result
            NavigationView {
                PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
            }
            // Search term insufficient
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateSearchTermInsufficient
                    )
                )
            }
            // Search with empty Result
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateEmpty
                    )
                )
            }
            // Search running
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateSearchRunning
                    )
                )
            }
            // Search with result dark mode
            NavigationView {
                PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
            }
            .preferredColorScheme(.dark)

            // Search with filtered elements
            NavigationView {
                PharmacySearchView(
                    store: PharmacySearchDomain.Dummies.storeFor(
                        PharmacySearchDomain.Dummies.stateFilterItems
                    )
                )
            }
        }
    }
}
