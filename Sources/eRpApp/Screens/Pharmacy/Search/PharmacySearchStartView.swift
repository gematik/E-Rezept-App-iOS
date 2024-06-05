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

import ComposableArchitecture
import ComposableCoreLocation
import eRpStyleKit
import MapKit
import Perception
import SwiftUI

struct PharmacySearchStartView: View {
    @Perception.Bindable var store: StoreOf<PharmacySearchDomain>

    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        // 193 is the standard height for the Mini-Map Display
        193 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    init(store: StoreOf<PharmacySearchDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.phaSearchMapHeader)
                        .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtMapHeader)
                },
                content: {
                    VStack {
                        MapViewWithClustering(
                            region: Binding(
                                get: { .manual(store.mapLocation) },
                                set: { _ in }
                            ),
                            disableUserInteraction: true,
                            onAnnotationTapped: { _ in },
                            onClusterTapped: { _ in }
                        )
                        .onTapGesture { store.send(.showMap) }
                        .frame(maxWidth: nil, maxHeight: Self.height)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        ))
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchMap)
                }
            )
            .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchMapSection)

            SectionContainer(
                header: {
                    Text(L10n.phaSearchTxtQuickFilterSectionTitle)
                        .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtQuickFilterTitle)
                },
                content: {
                    Button {
                        store.send(
                            .quickSearch(
                                filters: [.open, .currentLocation]
                            ), animation: .default
                        )
                    } label: {
                        Label(L10n.phaSearchTxtQuickFilterNearbyAndOpen, systemImage: SFSymbolName.location)
                    }
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterNearby)

                    Button {
                        store.send(
                            .quickSearch(
                                filters: [.delivery]
                            ), animation: .default
                        )
                    } label: {
                        Label(L10n.phaSearchTxtQuickFilterDelivery, systemImage: SFSymbolName.bicycle)
                    }
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterDelivery)

                    Button {
                        store.send(
                            .quickSearch(
                                filters: [.shipment]
                            ), animation: .default
                        )
                    } label: {
                        Label(L10n.phaSearchTxtQuickFilterShipment, systemImage: SFSymbolName.shippingbox)
                    }
                    .buttonStyle(.navigation)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterShipment)

                    Button {
                        store.send(.showPharmacyFilter, animation: .default)
                    } label: {
                        Label(L10n.phaSearchTxtQuickFilterOpenFilters, systemImage: SFSymbolName.sliderHorizontal3)
                    }
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterOpen)
                    .buttonStyle(.navigation)
                }
            )
            .sectionContainerStyle(.bordered)
            .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchQuickFilterSection)

            if !store.localPharmacies.isEmpty {
                SingleElementSectionContainer(
                    header: {
                        Text(L10n.phaSearchTxtLocalPharmTitle)
                            .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtLocalPharmTitle)
                    }, content: {
                        let isLoading = store.searchState.isStartViewLoading
                        ForEach(store.localPharmacies) { pharmacyViewModel in
                            Button(
                                action: {
                                    store
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
                            .disabled(isLoading)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibility(identifier: A11y.pharmacySearchStart.phaSearchTxtLocalPharmEntry)
                            .buttonStyle(.navigation(showSeparator: true))
                            .modifier(SectionContainerCellModifier())
                        }
                        .redacted(reason: isLoading ? .placeholder : .init())
                    }
                )
                .sectionContainerStyle(.bordered)
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchLocalPharmSection)
            }
        }
    }
}
