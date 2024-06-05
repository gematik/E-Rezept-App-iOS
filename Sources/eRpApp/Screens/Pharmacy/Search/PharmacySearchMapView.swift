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
    let isRedeemRecipe: Bool

    init(
        store: StoreOf<PharmacySearchMapDomain>,
        isRedeemRecipe: Bool
    ) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
    }

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
                            Button(action: { store.send(.delegate(.closeMap)) }, label: {
                                Image(systemName: SFSymbolName.crossIconPlain)
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(Colors.primary)
                                    .padding(12)
                                    .background(Circle().foregroundColor(Colors.systemColorWhite))
                                    .padding(.all, 12)
                                    .shadow(color: Colors.separator, radius: 4)
                            }).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnClose)

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
                                    Image(systemName: SFSymbolName.location)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Colors.primary)
                                        .padding(16)
                                        .background(Circle().foregroundColor(Colors.systemColorWhite))
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

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .sheet(item: $store.scope(state: \.destination?.clusterSheet,
                                                  action: \.destination.clusterSheet)) { store in
                            if #available(iOS 16, *) {
                                ClusterView(store: store)
                                    .presentationDetents([.fraction(0.45), .fraction(0.85), .large])
                            } else {
                                ClusterView(store: store)
                            }
                        }
                        .accessibility(hidden: true)

                    Rectangle()
                        .frame(width: 0, height: 0, alignment: .center)
                        .smallSheet($store.scope(
                            state: \.destination?.filter,
                            action: \.destination.filter
                        )) { store in
                            PharmacySearchFilterView(store: store)
                                .accentColor(Colors.primary600)
                        }
                        .accessibility(hidden: true)

                    NavigationLink(
                        item: $store.scope(
                            state: \.destination?.pharmacy,
                            action: \.destination.pharmacy
                        )
                    ) { store in
                        PharmacyDetailView(store: store, isRedeemRecipe: isRedeemRecipe)
                            .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
                    } label: {
                        EmptyView()
                    }
                    .accessibility(hidden: true)
                }
                .alert($store.scope(
                    state: \.destination?.alert?.alert,
                    action: \.destination.alert
                ))
                .task {
                    await store.send(.onAppear).finish()
                }
            }
        }.navigationBarHidden(true)
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
                                    .background(Circle().foregroundColor(Colors.systemGray6))
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
