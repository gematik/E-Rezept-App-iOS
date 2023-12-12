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
import eRpKit
import Foundation
import Pharmacy
import SwiftUI

extension PharmacySearchDomain {
    /// Same screen shows different UI elements based on the current state of the search
    enum SearchState: Equatable {
        case startView(loading: Bool)
        case searchRunning
        case searchResultEmpty
        case searchResultOk
        case searchAfterLocalizationWasAuthorized
        case localizingDevice
        case error

        var isNotStartView: Bool {
            if case .startView = self {
                return false
            }
            return true
        }

        var isStartViewLoading: Bool {
            if case let .startView(loading: isLoading) = self {
                return isLoading
            }
            return false
        }
    }

    enum Dummies {
        static let pharmaciesLocationViewModel =
            PharmacyLocation.Dummies.pharmacies.map {
                PharmacyLocationViewModel(
                    pharmacy: $0,
                    referenceLocation: nil,
                    referenceDate: openHoursReferenceDate
                )
            }

        static let stateEmpty = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: [],
            searchState: .searchResultEmpty
        )

        static let stateSearchResultOk = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "",
            pharmacies: pharmaciesLocationViewModel,
            searchState: .searchResultOk
        )

        static let stateSearchRunning = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "Apotheke",
            pharmacies: [],
            searchState: .searchRunning
        )
        static let stateFilterItems = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            pharmacies: [],
            pharmacyFilterOptions: [
                PharmacySearchFilterDomain.PharmacyFilterOption.delivery,
            ]
        )
        static let stateError = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            pharmacies: [],
            searchState: .error
        )
        static let stateStartView = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "",
            pharmacies: pharmaciesLocationViewModel,
            searchState: .startView(loading: false) // .searchResultOk(pharmaciesLocationViewModel)
        )
        static var openHoursReferenceDate: Date? {
            // Current dummy-time is set to 10:00am on 16th (WED) June 2021...
            var dateComponents = DateComponents()
            dateComponents.year = 2021
            dateComponents.month = 6
            dateComponents.day = 16
            dateComponents.timeZone = TimeZone.current
            dateComponents.hour = 10
            dateComponents.minute = 00
            let cal = Calendar(identifier: .gregorian)
            return cal.date(from: dateComponents)
        }

        static let reducer = PharmacySearchDomain(
            referenceDateForOpenHours: openHoursReferenceDate
        )

        static func storeOf(_ state: State) -> Store {
            Store(
                initialState: state
            ) {
                reducer
            }
        }

        static let store = Store(initialState: stateStartView) {
            reducer
        }
    }
}
