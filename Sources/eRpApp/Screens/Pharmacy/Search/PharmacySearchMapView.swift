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
import SwiftUI

struct PharmacySearchMapView: View {
    var store: Store<PharmacySearchMapDomain.State, PharmacySearchMapDomain.Action>
    @ObservedObject var viewStore: ViewStore<ViewState, PharmacySearchMapDomain.Action>
    let isRedeemRecipe: Bool

    init(
        store: PharmacySearchMapDomain.Store,
        isRedeemRecipe: Bool
    ) {
        self.store = store
        self.isRedeemRecipe = isRedeemRecipe
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let pharmacies: [PharmacyLocationViewModel]
        let mapLocation: MKCoordinateRegion
        let destinationTag: PharmacySearchMapDomain.Destinations.State.Tag?
        init(_ state: PharmacySearchMapDomain.State) {
            pharmacies = state.pharmacies
            mapLocation = state.mapLocation
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .top) {
                    #if targetEnvironment(simulator)
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .ignoresSafeArea()
                    #else
                    MapViewWithClustering(
                        region: viewStore.binding(
                            get: \.mapLocation,
                            send: PharmacySearchMapDomain.Action.setCurrentLocation
                        ),
                        annotations: viewStore.pharmacies.compactMap { pharmacy in
                            guard let pharmacyCoordinate = pharmacy.position?.coordinate else { return nil }
                            return PlaceholderAnnotation(
                                pharmacy: pharmacy,
                                coordinate: pharmacyCoordinate
                            )
                        },
                        onAnnotationTapped: { annotation in
                            viewStore.send(.showDetails(annotation.pharmacy))
                        },
                        onClusterTapped: { clusterAnnotation in
                            viewStore.send(.showCluster(clusterAnnotation))
                        }
                    ).ignoresSafeArea(.all, edges: .vertical)
                        .accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapMap)
                    #endif
                    VStack {
                        HStack {
                            Button(action: { viewStore.send(.delegate(.closeMap)) }, label: {
                                Image(systemName: SFSymbolName.crossIconPlain)
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(Colors.primary)
                                    .padding(12)
                                    .background(Circle().foregroundColor(Colors.systemColorWhite))
                                    .padding(.all, 12)
                                    .shadow(color: Colors.separator, radius: 4)
                            }).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnClose)

                            Spacer()

                            Button(action: { viewStore.send(.setNavigation(tag: .filter)) }, label: {
                                Image(systemName: SFSymbolName.sliderHorizontal3)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Colors.primary)
                                    .padding(16)
                                    .background(Circle().foregroundColor(Colors.systemColorWhite))
                                    .padding(.all, 16)
                                    .shadow(color: Colors.separator, radius: 4)

                            }).accessibility(identifier: A11y.pharmacySearchMap.phaSearchMapBtnFilter)
                        }

                        Spacer()

                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button(action: { viewStore.send(.goToUser) }, label: {
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
                        .smallSheet(isPresented: Binding<Bool>(get: {
                            viewStore.destinationTag == .filter
                        }, set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                            }
                        }),
                        onDismiss: {},
                        content: {
                            IfLetStore(
                                store.scope(state: \.$destination, action: PharmacySearchMapDomain.Action.destination),
                                state: /PharmacySearchMapDomain.Destinations.State.filter,
                                action: PharmacySearchMapDomain.Destinations.Action.pharmacyFilterView(action:),
                                then: PharmacySearchFilterView.init(store:)
                            )
                            .accentColor(Colors.primary600)
                        })
                        .accessibility(hidden: true)

                    NavigationLinkStore(
                        store.scope(state: \.$destination, action: PharmacySearchMapDomain.Action.destination),
                        state: /PharmacySearchMapDomain.Destinations.State.pharmacy,
                        action: PharmacySearchMapDomain.Destinations.Action.pharmacyDetailView(action:),
                        onTap: { viewStore.send(.setNavigation(tag: .pharmacy)) },
                        destination: { scopedStore in
                            PharmacyDetailView(store: scopedStore, isRedeemRecipe: isRedeemRecipe)
                                .navigationBarTitle(L10n.phaDetailTxtTitle, displayMode: .inline)
                        },
                        label: {}
                    )
                    .hidden()
                    .accessibility(hidden: true)
                }
                .alert(
                    store.scope(state: \.$destination, action: PharmacySearchMapDomain.Action.destination),
                    state: /PharmacySearchMapDomain.Destinations.State.alert,
                    action: PharmacySearchMapDomain.Destinations.Action.alert
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }.navigationBarHidden(true)
    }
}
