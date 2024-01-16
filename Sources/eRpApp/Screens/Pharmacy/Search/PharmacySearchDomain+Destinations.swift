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
import Foundation

extension PharmacySearchDomain {
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = pharmacySearch_detail
            case pharmacy(PharmacyDetailDomain.State)
            // sourcery: AnalyticsScreen = pharmacySearch_filter
            case filter(PharmacySearchFilterDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case pharmacyDetailView(action: PharmacyDetailDomain.Action)
            case pharmacyFilterView(action: PharmacySearchFilterDomain.Action)

            case alert(Alert)

            enum Alert: Equatable {
                case removeFilterCurrentLocation
                case openAppSpecificSettings
            }
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.pharmacy,
                action: /Action.pharmacyDetailView
            ) {
                PharmacyDetailDomain()
            }
            Scope(
                state: /State.filter,
                action: /Action.pharmacyFilterView
            ) {
                PharmacySearchFilterDomain()
            }
        }
    }
}
