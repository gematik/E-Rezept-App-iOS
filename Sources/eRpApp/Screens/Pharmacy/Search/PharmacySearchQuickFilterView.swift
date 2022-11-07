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

struct PharmacySearchQuickFilterView: View {
    var store: Store<Void, PharmacySearchDomain.Action>

    @ObservedObject
    var viewStore: ViewStore<Void, PharmacySearchDomain.Action>

    init(store: Store<Void, PharmacySearchDomain.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        SectionContainer(
            header: {
                Text(L10n.phaSearchTxtQuickFilterSectionTitle)
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

                Button {
                    viewStore.send(.setNavigation(tag: .filter), animation: .default)
                } label: {
                    Label(L10n.phaSearchTxtQuickFilterOpenFilters, systemImage: SFSymbolName.sliderHorizontal3)
                }
                .buttonStyle(.navigation)
            }
        )
        .sectionContainerStyle(.bordered)
    }
}
