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
import CoreLocationUI
import eRpStyleKit
import MapKit
import Perception
import SwiftUI

struct PharmacySearchMapView: View {
    @Perception.Bindable var store: StoreOf<PharmacySearchMapDomain>
    /// Workaround for navigationbar visible on Map after Search for iPhone 12 Mini with iOS 17.0+
    @State var navigationBarHidden = false

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ZStack(alignment: .top) {
                    MapViewWithClustering(
                        region: $store.mapLocation,
                        annotations: store.pharmacies.compactMap { pharmacy in
                            guard let pharmacyCoordinate = pharmacy.position?.coordinate else { return nil }
                            return PlaceholderAnnotation(
                                pharmacy: pharmacy,
                                coordinate: pharmacyCoordinate
                            )
                        },
                        onAnnotationTapped: { annotation in
                            store.send(.showDetails(annotation.pharmacy))
                        },
                        onClusterTapped: { clusterAnnotation in
                            store.send(.showClusterSheet(clusterAnnotation))
                        }
                    ).ignoresSafeArea(.all, edges: .vertical)
                        .accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapMap)
                    VStack {
                        HStack {
                            Button(
                                action: {
                                    store
                                        .send(.delegate(.closeMap(location: store.currentUserLocation)))
                                },
                                label: {
                                    Image(systemName: SFSymbolName.crossIconPlain)
                                        .font(Font.caption.weight(.bold))
                                        .foregroundColor(Colors.primary)
                                        .padding(12)
                                        .background(Circle().foregroundColor(Colors.systemColorWhite))
                                        .padding(.all, 12)
                                        .shadow(color: Colors.separator, radius: 4)
                                }
                            ).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnClose)

                            Spacer()

                            Button(
                                action: { store.send(.showPharmacyFilter) },
                                label: {
                                    Image(systemName: SFSymbolName.sliderHorizontal3)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Colors.primary)
                                        .padding(16)
                                        .background(Circle().foregroundColor(Colors.systemColorWhite))
                                        .padding(.all, 16)
                                        .shadow(color: Colors.separator, radius: 4)
                                }
                            ).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnFilter)
                        }

                        Spacer()

                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button(action: { store.send(.goToUser) }, label: {
                                    Image(systemName: store.pharmacyFilterOptions
                                        .contains(.currentLocation) ? SFSymbolName.locationFill : SFSymbolName.location)
                                                                            .font(.system(size: 16, weight: .bold))
                                                                            .foregroundColor(store.pharmacyFilterOptions
                                                                                .contains(.currentLocation) ? Colors
                                                                                .primary700 : Colors.systemGray)
                                                                            .padding(16)
                                                                            .background(Circle()
                                                                                .foregroundColor(Colors
                                                                                    .systemColorWhite))
                                                                            .padding(.all, 16)
                                                                            .shadow(color: Colors.separator, radius: 4)
                                }).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnGoToUser)
                            }
                            Button {
                                store.send(.performSearch)
                            } label: {
                                Text(L10n.phaSearchMapBtnSearchHere)
                            }
                            .buttonStyle(.primaryHugging)
                            .accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnSearchHere)
                        }.padding(.bottom, 24)
                    }
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.redeemViaAVS,
                        action: \.destination.redeemViaAVS
                    )
                ) { store in
                    PharmacyRedeemView(store: store)
                }

                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.redeemViaErxTaskRepository,
                        action: \.destination.redeemViaErxTaskRepository
                    )
                ) { store in
                    PharmacyRedeemView(store: store)
                }
                .alert($store.scope(
                    state: \.destination?.alert?.alert,
                    action: \.destination.alert
                ))
                .task {
                    await store.send(.onAppear).finish()
                    UIApplication.shared.dismissKeyboard()
                }
            }
            .sheet(item: $store.scope(state: \.destination?.clusterSheet,
                                      action: \.destination.clusterSheet)) { store in
                ClusterView(store: store)
                    .presentationDetents([.fraction(0.45), .fraction(0.85), .large])
            }
            .smallSheet($store.scope(
                state: \.destination?.filter,
                action: \.destination.filter
            )) { store in
                PharmacySearchFilterView(store: store)
                    .accentColor(Colors.primary600)
            }
            .sheet(item: $store.scope(
                state: \.destination?.pharmacy,
                action: \.destination.pharmacy
            )) { store in
                if #available(iOS 16, *) {
                    PharmacyDetailView(store: store)
                        .presentationDetents([.fraction(0.45), .fraction(0.85), .large])
                } else {
                    PharmacyDetailView(store: store)
                }
            }
        }
        /// Workaround for navigationbar visible on Map after Search for iPhone 12 Mini
        .onAppear { navigationBarHidden = true }
        .navigationBarHidden(navigationBarHidden)
    }
}

extension PharmacySearchMapView {
    struct ClusterView: View {
        @Perception.Bindable var store: StoreOf<PharmacySearchClusterDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()

                            Button(action: { store.send(.closeSheet) }, label: {
                                Image(systemName: SFSymbolName.crossIconPlain)
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(Colors.primary)
                                    .padding(12)
                                    .background(Circle().foregroundColor(Colors.systemFillTertiary))
                            })
                                .accessibilityIdentifier(A11y.pharmacySearchMap.phaSearchMapBtnClusterClose)
                        }

                        Text("\(store.clusterPharmacies.count) \(L10n.phaSearchMapTxtClusterHeader.text)")
                            .font(.title2)
                            .accessibilityIdentifier(A11y.pharmacySearchMap.phaSearchMapTxtClusterHeader)
                    }.padding()

                    ScrollView {
                        SingleElementSectionContainer {
                            ForEach(store.clusterPharmacies) { pharmacyViewModel in
                                WithPerceptionTracking {
                                    Button(
                                        action: {
                                            store.send(.delegate(.showDetails(pharmacyViewModel)))
                                        },
                                        label: {
                                            Label(title: {
                                                      PharmacySearchCell(
                                                          pharmacy: pharmacyViewModel,
                                                          isFavorite: pharmacyViewModel
                                                              .isFavorite,
                                                          showDistance: true
                                                      )
                                                  },
                                                  icon: {})
                                        }
                                    )
                                    .buttonStyle(
                                        .navigation(showSeparator: pharmacyViewModel !=
                                            store.clusterPharmacies
                                            .last)
                                    )
                                    .modifier(SectionContainerCellModifier())
                                    .accessibilityIdentifier(A11y.pharmacySearchMap
                                        .phaSearchMapBtnClusterPharmacy)
                                }
                            }
                        }.sectionContainerStyle(.inline)
                    }
                }.navigationBarHidden(true)
            }
        }
    }
}
