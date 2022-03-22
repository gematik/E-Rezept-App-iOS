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

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import Pharmacy
import SwiftUI

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

    enum Route: Equatable {
        case selectProfile

        enum Tag: Int {
            case selectProfile
        }

        var tag: Tag {
            switch self {
            case .selectProfile:
                return .selectProfile
            }
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
        case error
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
        /// Visibility of location hint
        var isLocationServiceAuthorized = false
        var hintDismissButtonTapped = false
        var showLocationHint: Bool {
            !hintDismissButtonTapped && !isLocationServiceAuthorized
        }

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
        /// Used to navigate into filter details sheet
        var pharmacyFilterState: PharmacySearchFilterDomain.State?
        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption] = []
        /// The current state the search is at
        var searchState: SearchState = .startView

        var route: Route?
    }

    enum Action: Equatable {
        case close
        case onAppear
        // Alert
        case alertDismissButtonTapped
        // Search
        case searchTextChanged(String)
        case performSearch
        case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
        // Hint
        case hintButtonTapped
        case hintDismissButtonTapped
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        case dismissPharmacyDetailView
        case pharmacyDetailView(action: PharmacyDetailDomain.Action)
        // Filter
        case showPharmacyFilterView
        case dismissFilterSheetView
        case removeFilterOption(PharmacySearchFilterDomain.PharmacyFilterOption)
        case pharmacyFilterView(action: PharmacySearchFilterDomain.Action)
        // Device location
        case requestLocation
        case locationManager(LocationManager.Action)

        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        var schedulers: Schedulers
        var pharmacyRepository: PharmacyRepository
        var locationManager: LocationManager = .live
        let fhirDateFormatter: FHIRDateFormatter
        let openHoursCalculator: PharmacyOpenHoursCalculator
        // Control the current time for opening/closing determination. When not set current device time is used.
        let referenceDateForOpenHours: Date?
        let userSession: UserSession
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .close:
            return cleanup()
        case .onAppear:
            state.isLocationServiceAuthorized = environment.locationManager.isLocationServiceAuthorized
            if state.isLocationServiceAuthorized, state.searchState == .startView {
                state.searchState = .searchAfterLocalizationWasAuthorized
                return .init(value: .requestLocation)
            } else {
                return .none
            }

        // Alert
        case .alertDismissButtonTapped:
            state.alertState = nil
            return .none

        // Search
        case let .searchTextChanged(changedText):
            state.searchText = changedText
            return .none
        case .performSearch:
            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            state.searchState = .searchRunning
            return environment.searchPharmacies(
                searchTerm: state.searchText,
                location: state.currentLocation
            )
            .cancellable(id: Token.search, cancelInFlight: true)
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
            case let .failure(error):
                state.searchState = .error
            }
            return .none

        // Hint
        case .hintButtonTapped:
            state.searchState = .searchAfterLocalizationWasAuthorized
            return .init(value: .requestLocation)
        case .hintDismissButtonTapped:
            state.hintDismissButtonTapped = true
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
        case .requestLocation:
            return .merge(
                environment.locationManager
                    .create(id: LocationManagerId())
                    .map(PharmacySearchDomain.Action.locationManager),
                environment.locationManager
                    .requestWhenInUseAuthorization(id: LocationManagerId())
                    .fireAndForget()
            )
        case .locationManager(.didChangeAuthorization(.authorizedAlways)),
             .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
            state.isLocationServiceAuthorized = true
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
            state.isLocationServiceAuthorized = true
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
        case .setNavigation(tag: .selectProfile):
            state.route = .selectProfile
            return .none
        case .setNavigation(tag: nil):
            state.route = nil
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        pharmacyFilterPullbackReducer,
        pharmacyDetailPullbackReducer,
        domainReducer
    )
}

extension PharmacySearchDomain {
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
            PharmacyDetailDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession
            )
        }

    static var locationPermissionAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaSearchTxtLocationAlertTitle),
            message: TextState(L10n.phaSearchTxtLocationAlertMessage),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
        )
    }()
}

extension PharmacySearchDomain.Environment {
    func searchPharmacies(searchTerm: String, location: ComposableCoreLocation.Location?)
        -> Effect<PharmacySearchDomain.Action, Never> {
        var position: Position?
        if let latitude = location?.coordinate.latitude,
           let longitude = location?.coordinate.longitude {
            position = Position(lat: latitude, lon: longitude)
        }
        return pharmacyRepository.searchPharmacies(searchTerm: searchTerm, position: position)
            .first()
            .catchToEffect()
            .map(PharmacySearchDomain.Action.pharmaciesReceived)
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }
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
            erxTasks: [ErxTask.Dummies.erxTaskReady],
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: [],
            searchState: .searchResultEmpty
        )
        static let stateSearchRunning = State(
            erxTasks: [ErxTask.Dummies.erxTaskReady],
            searchText: "Apotheke",
            pharmacies: [],
            searchState: .searchRunning
        )
        static let stateFilterItems = State(
            erxTasks: [ErxTask.Dummies.erxTaskReady],
            pharmacies: [],
            pharmacyFilterOptions: [
                PharmacySearchFilterDomain.PharmacyFilterOption.messenger,
            ]
        )
        static let stateError = State(
            erxTasks: [ErxTask.Dummies.erxTaskReady],
            pharmacies: [],
            searchState: .error
        )
        static let state = State(
            erxTasks: [ErxTask.Dummies.erxTaskReady],
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
            pharmacyRepository: DemoSessionContainer().pharmacyRepository,
            locationManager: .live,
            fhirDateFormatter: FHIRDateFormatter.shared,
            openHoursCalculator: PharmacyOpenHoursCalculator(),
            referenceDateForOpenHours: openHoursReferenceDate,
            userSession: DemoSessionContainer()
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

extension LocationManager {
    var isLocationServiceAuthorized: Bool {
        if !locationServicesEnabled() {
            return false
        }
        switch authorizationStatus() {
        case .notDetermined, .restricted, .denied: return false
        case .authorizedAlways, .authorizedWhenInUse: return true
        @unknown default: return false
        }
    }
}
