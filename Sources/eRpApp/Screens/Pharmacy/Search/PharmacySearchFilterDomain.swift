//
//  Copyright (c) 2023 gematik GmbH
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

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import Pharmacy
import SwiftUI

struct PharmacySearchFilterDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// All filter options used with pharmacies search
    enum PharmacyFilterOption: String, CaseIterable, Hashable, Identifiable {
        case open
        case ready
        case delivery
        case shipment
        case currentLocation

        private static let openIdentifier = UUID()
        private static let readyIdentifier = UUID()
        private static let deliveryIdentifier = UUID()
        private static let shipmentIdentifier = UUID()
        private static let currentLocationIdentifier = UUID()

        var id: UUID {
            switch self {
            case .open:
                return Self.openIdentifier
            case .ready:
                return Self.readyIdentifier
            case .delivery:
                return Self.deliveryIdentifier
            case .shipment:
                return Self.shipmentIdentifier
            case .currentLocation:
                return Self.currentLocationIdentifier
            }
        }

        var localizedStringKey: LocalizedStringKey {
            switch self {
            case .open:
                return L10n.phaSearchTxtFilterOpen.key
            case .ready:
                return L10n.phaSearchTxtFilterReady.key
            case .delivery:
                return L10n.phaSearchTxtFilterDelivery.key
            case .shipment:
                return L10n.phaSearchTxtFilterShipment.key
            case .currentLocation:
                return L10n.phaSearchTxtFilterCurrentLocation.key
            }
        }
    }

    struct State: Equatable {
        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacyFilterOption] = []
    }

    enum Action: Equatable {
        case delegate(Delegate)
        case toggleFilter(PharmacyFilterOption)

        enum Delegate: Equatable {
            case close
        }
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .delegate(.close):
            return .none
        case let .toggleFilter(filterOption):
            if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                state.pharmacyFilterOptions.remove(at: index)
            } else {
                state.pharmacyFilterOptions.append(filterOption)
            }
            return .none
        }
    }
}

extension Collection where Element == PharmacySearchFilterDomain.PharmacyFilterOption {
    var asPharmacyRepositoryFilters: [PharmacyRepositoryFilter] {
        compactMap { option in
            switch option {
            case .ready:
                return PharmacyRepositoryFilter.ready
            case .shipment:
                return PharmacyRepositoryFilter.shipment
            case .delivery:
                return PharmacyRepositoryFilter.delivery
            case .open,
                 .currentLocation:
                return nil
            }
        }
    }
}

extension PharmacySearchFilterDomain {
    enum Dummies {
        static let state = State(
            pharmacyFilterOptions: [.open, .ready]
        )

        static let store = Store(
            initialState: state,
            reducer: PharmacySearchFilterDomain()
        )
    }
}
