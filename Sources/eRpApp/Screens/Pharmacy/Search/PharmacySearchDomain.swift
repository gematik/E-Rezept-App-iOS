//
//  Copyright (c) 2021 gematik GmbH
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

// swiftlint:disable:next type_body_length
enum PharmacySearchDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    /// Tokens for Cancellables
    enum Token: CaseIterable, Hashable {
        case search
    }

    /// Sort-Order for pharmacies search result.
    enum SortOrder: String, CaseIterable, Hashable {
        case alphabetical = "pha_search_btn_sort_alpha"
        case distance = "pha_search_btn_sort_distance"

        func localizedString() -> String {
            NSLocalizedString(rawValue, comment: "")
        }
    }

    /// Same screen shows different UI elements based on the current state of the search
    enum SearchState: Equatable {
        case startView
        case searchRunning
        case searchResultEmpty
        case searchResultOk([PharmacyLocationViewModel])
        case searchAfterLocalizationWasAuthorized
        case localizingDevice
    }

    // A unique identifier for our location manager, just in case we want to use
    // more than one in our application.
    struct LocationManagerId: Hashable {}

    struct State: Equatable {
        /// A storage for the prescriptions hat have been selected to be redeemed
        var erxTasks: [ErxTask]
        /// The value of the search text field
        var searchText = ""
        /// Stores the current device location when determined by Core-Location
        var currentLocation: Location?
        /// Store for the search result
        var pharmacies: [PharmacyLocationViewModel] = []
        /// We show an alert when the user taps the "location" icon but has not allowed to share the device location
        var alertState: AlertState<Action>?
        /// State to control visibility of location hint
        var locationHintState = true
        /// A valid search terms should at least consist of 3 chars
        var searchTextValid: Bool {
            searchText.count > 2
        }

        var isLoading: Bool {
            switch searchState {
            case .searchRunning:
                return true
            default:
                return false
            }
        }

        /// TCA Detail-State for navigation
        var pharmacyDetailState: PharmacyDetailDomain.State?
        /// The current sort order
        var sortOrder: SortOrder = .alphabetical
        /// Used to navigate into filter details sheet
        var pharmacyFilterState: PharmacySearchFilterDomain.State?
        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption] = []
        /// The current state the search is at
        var searchState: SearchState = .startView
    }

    enum Action: Equatable {
        case close
        // Alert
        case alertDismissButtonTapped
        case closeLocationHint
        // Search
        case searchTextChanged(String)
        case performSearch
        case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        case dismissPharmacyDetailView
        case pharmacyDetailView(action: PharmacyDetailDomain.Action)
        // Sorting
        case sortResult
        case sortedResultReceived([PharmacyLocationViewModel])
        // Filter
        case showPharmacyFilterView
        case dismissFilterSheetView
        case removeFilterOption(PharmacySearchFilterDomain.PharmacyFilterOption)
        case pharmacyFilterView(action: PharmacySearchFilterDomain.Action)
        // Device location
        case locationButtonTapped
        case locationManager(LocationManager.Action)
        case requestLocationPermission
    }

    struct Environment {
        var schedulers: Schedulers
        var pharmacyRepository: PharmacyRepository
        var locationManager: LocationManager
        let fhirDateFormatter: FHIRDateFormatter
        let openHoursCalculator: PharmacyOpenHoursCalculator
        // Control the current time for opening/closing determination. When not set current device time is used.
        let referenceDateForOpenHours: Date?
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .close:
            return cleanup()
        // Alert
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none
        case .closeLocationHint:
            state.locationHintState = false
            return .none

        // Search
        case let .searchTextChanged(changedText):
            state.searchText = changedText
            return .none
        case .performSearch:
            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            state.searchState = .searchRunning
            state.sortOrder = state.currentLocation != nil ? .distance : .alphabetical
            return .concatenate(
                .cancel(id: Token.search),
                environment.searchPharmacies(
                    searchTerm: state.searchText,
                    location: state.currentLocation
                )
                .cancellable(id: Token.search)
            )
        case let .pharmaciesReceived(result):
            switch result {
            case let .success(pharmacies):
                state.pharmacies = pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0,
                        referenceLocation: state.currentLocation,
                        referenceDate: environment.referenceDateForOpenHours
                    )
                }

                state.searchState = pharmacies.isEmpty ? .searchResultEmpty : .searchResultOk(state.pharmacies)
                if case .searchResultOk = state.searchState {
                    return environment.sortPharmacies(
                        pharmacyLocations: state.pharmacies,
                        sortOrder: state.sortOrder
                    )
                    .map(PharmacySearchDomain.Action.sortedResultReceived)
                }
            case let .failure(error):
                state.searchState = .searchResultEmpty
                state.alertState = searchResultErrorAlertState
            }
            return .none
        // Details
        case let .showDetails(pharmacyLocation):
            state.pharmacyDetailState = PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: pharmacyLocation
            )
            return .none
        case .dismissPharmacyDetailView:
            state.pharmacyDetailState = nil
            return .none
        case .pharmacyDetailView(action: .close):
            state.pharmacyDetailState = nil
            return Effect(value: .close)
        case .pharmacyDetailView:
            return .none

        // Sorting
        case .sortResult:
            state.sortOrder = state.sortOrder == .alphabetical ? .distance : .alphabetical
            return environment.sortPharmacies(
                pharmacyLocations: state.pharmacies,
                sortOrder: state.sortOrder
            )
            .map(PharmacySearchDomain.Action.sortedResultReceived)
        case let .sortedResultReceived(pharmaciesSorted):
            state.pharmacies = pharmaciesSorted
            return .none

        // Filter
        case .showPharmacyFilterView:
            state.pharmacyFilterState = PharmacySearchFilterDomain.State(
                pharmacyFilterOptions: state.pharmacyFilterOptions
            )
            return .none
        case let .pharmacyFilterView(.close(filterOptions)):
            state.pharmacyFilterOptions = filterOptions
            state.pharmacyFilterState = nil
            return .none
        case .dismissFilterSheetView:
            return .none
        case let .removeFilterOption(filterOption):
            if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                state.pharmacyFilterOptions.remove(at: index)
            }
            return .none
        case .pharmacyFilterView:
            return .none

        // Location
        case .locationButtonTapped:
            if state.currentLocation == nil {
                state.searchState = .searchAfterLocalizationWasAuthorized
                return Effect(value: .requestLocationPermission)
            } else {
                state.currentLocation = nil
                return .none
            }
        case .requestLocationPermission:
            return .merge(
                environment.locationManager.create(id: LocationManagerId())
                    .map(PharmacySearchDomain.Action.locationManager),
                environment.locationManager.requestWhenInUseAuthorization(id: LocationManagerId())
                    .fireAndForget()
            )
        case .locationManager(.didChangeAuthorization(.authorizedAlways)),
             .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
            state.locationHintState = false
            if state.searchState == .searchAfterLocalizationWasAuthorized {
                if state.currentLocation != nil {
                    return Effect(value: .performSearch)
                } else {
                    return environment.locationManager.startUpdatingLocation(id: LocationManagerId()).fireAndForget()
                }
            }
            return .none
        case .locationManager(.didChangeAuthorization(.notDetermined)):
            return .none
        case .locationManager(.didChangeAuthorization(.denied)),
             .locationManager(.didChangeAuthorization(.restricted)):
            state.locationHintState = false
            if state.searchState == .searchAfterLocalizationWasAuthorized {
                state.alertState = locationPermissionAlertState
            }
            return .none
        case let .locationManager(.didUpdateLocations(locations)):
            state.currentLocation = locations.first
            return .concatenate(
                environment.locationManager.stopUpdatingLocation(id: LocationManagerId())
                    .fireAndForget(),
                Effect(value: .performSearch)
            )
        case .locationManager:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacyFilterPullbackReducer,
        pharmacyDetailPullbackReducer,
        domainReducer
    )

    static let pharmacyFilterPullbackReducer: Reducer =
        PharmacySearchFilterDomain.reducer.optional().pullback(
            state: \.pharmacyFilterState,
            action: /PharmacySearchDomain.Action.pharmacyFilterView(action:)
        ) { environment in
            PharmacySearchFilterDomain.Environment(schedulers: environment.schedulers)
        }

    static let pharmacyDetailPullbackReducer: Reducer =
        PharmacyDetailDomain.reducer.optional().pullback(
            state: \.pharmacyDetailState,
            action: /PharmacySearchDomain.Action.pharmacyDetailView(action:)
        ) { environment in
            PharmacyDetailDomain.Environment(schedulers: environment.schedulers)
        }

    static var locationPermissionAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaSearchTxtLocationAlertTitle),
            message: TextState(L10n.phaSearchTxtLocationAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
        )
    }()

    static var searchResultErrorAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaSearchTxtErrorAlertTitle),
            message: TextState(L10n.phaSearchTxtErrorAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
        )
    }()
}

extension PharmacySearchDomain {
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
            erxTasks: [ErxTask.Dummies.prescription],
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: []
        )
        static let stateSearchRunning = State(
            erxTasks: [ErxTask.Dummies.prescription],
            searchText: "Apotheke",
            pharmacies: [],
            searchState: .searchRunning
        )
        static let stateSearchTermInsufficient = State(
            erxTasks: [ErxTask.Dummies.prescription],
            searchText: "Ap",
            pharmacies: []
        )
        static let stateFilterItems = State(
            erxTasks: [ErxTask.Dummies.prescription],
            pharmacies: [],
            pharmacyFilterOptions: [
                PharmacySearchFilterDomain.PharmacyFilterOption.messenger,
                PharmacySearchFilterDomain.PharmacyFilterOption.order,
            ]
        )
        static let state = State(
            erxTasks: [ErxTask.Dummies.prescription],
            searchText: "Apotheke",
            pharmacies: pharmaciesLocationViewModel,
            searchState: .searchResultOk(pharmaciesLocationViewModel)
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

        static let environment = Environment(
            schedulers: Schedulers(),
            pharmacyRepository: AppContainer.shared.userSessionSubject.pharmacyRepository,
            locationManager: .live,
            fhirDateFormatter: FHIRDateFormatter.shared,
            openHoursCalculator: PharmacyOpenHoursCalculator(),
            referenceDateForOpenHours: openHoursReferenceDate
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PharmacySearchDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
