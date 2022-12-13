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
import eRpStyleKit
import SwiftUI

struct PharmacySearchStartView: View {
    var store: Store<PharmacySearchDomain.State, PharmacySearchDomain.Action>
    @ObservedObject
    var viewStore: ViewStore<ViewState, PharmacySearchDomain.Action>

    init(store: Store<PharmacySearchDomain.State, PharmacySearchDomain.Action>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let isLoading: Bool
        let localPharmacies: [PharmacyLocationViewModel]
        init(_ state: PharmacySearchDomain.State) {
            isLoading = state.searchState.isStartViewLoading
            localPharmacies = state.localPharmacies
        }
    }

    var body: some View {
        SectionContainer(
            header: {
                Text(L10n.phaSearchTxtQuickFilterSectionTitle)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtQuickFilterTitle)
            },
            content: {
                Button {
                    viewStore.send(
                        .quickSearch(
                            filters: [.open, .currentLocation, .ready]
                        ), animation: .default
                    )
                } label: {
                    Label(L10n.phaSearchTxtQuickFilterNearbyAndOpen, systemImage: SFSymbolName.location)
                }
                .buttonStyle(.navigation)
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterNearby)

                Button {
                    viewStore.send(
                        .quickSearch(
                            filters: [.delivery, .ready]
                        ), animation: .default
                    )
                } label: {
                    Label(L10n.phaSearchTxtQuickFilterDelivery, systemImage: SFSymbolName.bicycle)
                }
                .buttonStyle(.navigation)
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterDelivery)

                Button {
                    viewStore.send(
                        .quickSearch(
                            filters: [.shipment, .ready]
                        ), animation: .default
                    )
                } label: {
                    Label(L10n.phaSearchTxtQuickFilterShipment, systemImage: SFSymbolName.shippingbox)
                }
                .buttonStyle(.navigation)
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterShipment)

                Button {
                    viewStore.send(.setNavigation(tag: .filter), animation: .default)
                } label: {
                    Label(L10n.phaSearchTxtQuickFilterOpenFilters, systemImage: SFSymbolName.sliderHorizontal3)
                }
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterOpen)
                .buttonStyle(.navigation)
            }
        )
        .sectionContainerStyle(.bordered)
        .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchQuickFilterSection)

        if !viewStore.localPharmacies.isEmpty {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.phaSearchTxtLocalPharmTitle)
                        .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtLocalPharmTitle)
                }, content: {
                    ForEach(viewStore.localPharmacies) { pharmacyViewModel in
                        Button(
                            action: {
                                viewStore
                                    .send(.loadAndNavigateToPharmacy(pharmacyViewModel.pharmacyLocation))
                            },
                            label: {
                                Label(title: {
                                          PharmacySearchCell(pharmacy: pharmacyViewModel,
                                                             isFavorite: pharmacyViewModel.isFavorite,
                                                             showDistance: false)
                                      },
                                      icon: {})
                            }
                        )
                        .disabled(viewStore.isLoading)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibility(identifier: A11y.pharmacySearchStart.phaSearchTxtLocalPharmEntry)
                        .buttonStyle(.navigation(showSeparator: true))
                        .modifier(SectionContainerCellModifier())
                    }
                    .redacted(reason: viewStore.isLoading ? .placeholder : .init())
                }
            )
            .sectionContainerStyle(.bordered)
            .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchLocalPharmSection)
        }
    }
}
