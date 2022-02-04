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
    let isModalView: Bool

    init(store: PharmacySearchDomain.Store, isModalView: Bool = true) {
        self.store = store
        self.isModalView = isModalView
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                SearchBarView(store: store)
                    .padding()

                GreyDivider(topPadding: 0)

                if viewStore.state.showLocationHint {
                    LocalizationHintView(
                        textAction: { viewStore.send(.hintButtonTapped) },
                        closeAction: { viewStore.send(.hintDismissButtonTapped) }
                    )
                    .padding(.horizontal)
                    .padding(.top)
                }

                PharmacySearchResultView(store: store)
                    .frame(maxHeight: .infinity)

                PharmacyDetailViewNavigation(store: store, isModalView: isModalView)

                Spacer(minLength: 0)

                // Search-Filter sheet presentation
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
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
                    .hidden()
                    .accessibility(hidden: true)
            }
            .alert(
                store.scope(state: \.alertState),
                dismiss: .alertDismissButtonTapped
            )
            .navigationBarItems(
                trailing: trailingNavigationBarItem()
            )
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    // TODO: rebuild view structure,  // swiftlint:disable:this todo
    // also `trailingNavigationBarItem` and alike are deprecating (Use `toolbar(content:)`)
    @ViewBuilder
    private func trailingNavigationBarItem() -> some View {
        WithViewStore(store) { viewStore in
            if isModalView {
                NavigationBarCloseItem {
                    viewStore.send(.close)
                }
            } else {
                EmptyView()
            }
        }
    }

    private struct SearchBarView: View {
        let store: PharmacySearchDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                HStack {
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
                .foregroundColor(Colors.systemLabelSecondary)
                .background(RoundedRectangle(cornerRadius: 8).fill(Colors.systemFillTertiary))
                .accessibilityElement(children: .combine)
                .accessibility(label: Text(L10n.phaSearchTxtSearchHint))
                .accessibility(hint: Text(L10n.phaSearchTxtHintStartSearch))
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
                    title: L10n.phaSearchTxtLocationHintTitle.text,
                    message: L10n.phaSearchTxtLocationHintMessage.text,
                    actionText: L10n.phaSearchBtnLocationHintAction,
                    imageName: Asset.Prescriptions.Details.apothekerin.name,
                    closeAction: .hintDismissButtonTapped,
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
        let isModalView: Bool

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: { $0.pharmacyDetailState },
                            action: PharmacySearchDomain.Action.pharmacyDetailView(action:)
                        )
                    ) { scopedStore in
                        PharmacyDetailView(store: scopedStore, isModalView: isModalView)
                            .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
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
