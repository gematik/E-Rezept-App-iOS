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

import ComposableArchitecture
import ComposableCoreLocation
import eRpStyleKit
import MapKit
import Perception
import Pharmacy
import SwiftUI

struct PharmacySearchStartView: View {
    @Bindable var store: StoreOf<PharmacySearchDomain>

    static let height: CGFloat = // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard
        // vs. Zoomed
        // 160 is the standard height for the Mini-Map Display
        160 * UIScreen.main.scale / UIScreen.main.nativeScale

    var body: some View {
        SingleElementSectionContainer(
            header: {
                Text(L10n.phaSearchMapHeader)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtMapHeader)
                    .accessibilityAddTraits(.isHeader)
            },
            content: {
                VStack {
                    Button {
                        store.send(.showMap)
                    } label: {
                        MapViewWithClustering(
                            region: Binding(
                                get: { .manual(store.mapLocation) },
                                set: { _ in }
                            ),
                            disableUserInteraction: true,
                            onAnnotationTapped: { _ in },
                            onClusterTapped: { _ in }
                        )
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(L10n.phaSearchMapAccessibilityLabel.text)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint(L10n.phaSearchMapAccessibilityHint.text)
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

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.phaSearchTxtQuickFilterPopularTitle)
                    .font(.headline)
                    .foregroundColor(Colors.systemLabel)
                    .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtQuickFilterTitle)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button {
                    store.send(.showPharmacyFilter, animation: .default)
                } label: {
                    Label(L10n.phaSearchBtnAllFilters, systemImage: SFSymbolName.sliderHorizontal3)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Colors.primary700)
                }
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterOpen)
            }

            PharmacySearchFlowLayout(spacing: 8) {
                FilterChip(
                    title: L10n.phaSearchTxtQuickFilterDelivery.key,
                    isSelected: false
                ) {
                    store.send(.quickSearch(filters: [.delivery]), animation: .default)
                }
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterDelivery)

                FilterChip(
                    title: L10n.phaSearchTxtQuickFilterShipment.key,
                    isSelected: false
                ) {
                    store.send(.quickSearch(filters: [.shipment]), animation: .default)
                }
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterShipment)

                FilterChip(
                    title: L10n.phaSearchTxtQuickFilterNearbyAndOpen.key,
                    isSelected: false
                ) {
                    store.send(.quickSearch(filters: [.open, .currentLocation]), animation: .default)
                }
                .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchBtnQuickFilterNearby)
            }
        }
        .padding(.horizontal, 16)

        if !store.localPharmacies.isEmpty {
            SingleElementSectionContainer(
                header: {
                    Text(L10n.phaSearchTxtLocalPharmTitle)
                        .accessibilityIdentifier(A11y.pharmacySearchStart.phaSearchTxtLocalPharmTitle)
                        .accessibilityAddTraits(.isHeader)
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
                        .buttonStyle(.navigation)
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

struct PharmacySearchStartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollView {
                PharmacySearchStartView(
                    store: PharmacySearchDomain.Dummies.storeOf(
                        PharmacySearchDomain.Dummies.stateStartView
                    )
                )
            }
        }
        .previewDisplayName("Start View (no local pharmacies)")

        NavigationStack {
            ScrollView {
                PharmacySearchStartView(
                    store: PharmacySearchDomain.Dummies.storeOf(
                        PharmacySearchDomain.Dummies.stateStartViewWithFavorites
                    )
                )
            }
        }
        .previewDisplayName("With Favorites")

        NavigationStack {
            ScrollView {
                PharmacySearchStartView(
                    store: PharmacySearchDomain.Dummies.storeOf(
                        PharmacySearchDomain.Dummies.stateStartViewWithRecentlyUsed
                    )
                )
            }
        }
        .previewDisplayName("With Recently Used (no favorites)")

        NavigationStack {
            ScrollView {
                PharmacySearchStartView(
                    store: PharmacySearchDomain.Dummies.storeOf(
                        PharmacySearchDomain.Dummies.stateStartViewLoading
                    )
                )
            }
        }
        .previewDisplayName("Loading")
    }
}
