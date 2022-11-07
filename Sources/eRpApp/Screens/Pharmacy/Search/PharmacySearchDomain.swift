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
import IDP
import Pharmacy
import SwiftUI

// body will be shorter with ne ReducerProtocol
// swiftlint:disable type_body_length
enum PharmacySearchDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.concatenate(
            PharmacyDetailDomain.cleanup(),
            Effect.cancel(token: Token.self)
        )
    }

    /// Tokens for Cancellables
    enum Token: CaseIterable, Hashable {
        case search
    }

    enum Route: Equatable {
        case selectProfile
        case pharmacy(PharmacyDetailDomain.State)
        case filter(PharmacySearchFilterDomain.State)
        case alert(AlertState<Action>)

        enum Tag: Int {
            case selectProfile
            case pharmacy
            case filter
            case alert
        }

        var tag: Tag {
            switch self {
            case .selectProfile:
                return .selectProfile
            case .pharmacy:
                return .pharmacy
            case .filter:
                return .filter
            case .alert:
                return .alert
            }
        }
    }

    /// Same screen shows different UI elements based on the current state of the search
    enum SearchState: Equatable {
        case startView
        case searchRunning
        case searchResultEmpty
        case searchResultOk
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
        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption] = []
        /// The current state the search is at
        var searchState: SearchState = .startView

        var route: Route?

        var searchHistory: [String] = []
    }

    enum Action: Equatable {
        case close
        case onAppear
        // Search
        case searchTextChanged(String)
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        case pharmacyDetailView(action: PharmacyDetailDomain.Action)
        // Filter
        case removeFilterOption(PharmacySearchFilterDomain.PharmacyFilterOption)
        case pharmacyFilterView(action: PharmacySearchFilterDomain.Action)
        // Device location
        case requestLocation
        case locationManager(LocationManager.Action)

        case setNavigation(tag: Route.Tag?)
        case openAppSpecificSettings
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
        let openURL: (URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?) -> Void
        var searchHistory: SearchHistory = DefaultSearchHistory.pharmacySearch
        let signatureProvider: SecureEnclaveSignatureProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
        let userSessionProvider: UserSessionProvider
        var timeOnlyFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            if let preferredLang = Locale.preferredLanguages.first,
               preferredLang.starts(with: "de") {
                dateFormatter.dateFormat = "HH:mm 'Uhr'"
            } else {
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .none
            }
            return dateFormatter
        }()
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .close:
            state.route = nil
            return cleanup()
        case .onAppear:
            state.searchHistory = environment.searchHistory.historyItems()

            if state.searchState == .searchAfterLocalizationWasAuthorized {
                return .init(value: .requestLocation)
            }

            return .none
        // Search
        case let .searchTextChanged(changedText):
            state.searchText = changedText
            if changedText.lengthOfBytes(using: .utf8) == 0 {
                state.searchState = .startView
            }
            return .none
        case .performSearch:
            // append history item
            environment.searchHistory.addHistoryItem(state.searchText)
            state.searchHistory = environment.searchHistory.historyItems()

            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            state.searchState = .searchRunning
            return environment.searchPharmacies(
                searchTerm: state.searchText,
                location: state.currentLocation,
                filter: state.pharmacyFilterOptions
            )
            .cancellable(id: Token.search, cancelInFlight: true)
        case let .pharmaciesReceived(result):
            switch result {
            case let .success(pharmacies):
                state.pharmacies = pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0,
                        referenceLocation: state.currentLocation,
                        referenceDate: environment.referenceDateForOpenHours,
                        timeOnlyFormatter: environment.timeOnlyFormatter
                    )
                }
                .filter(by: state.pharmacyFilterOptions)

                state.searchState = pharmacies.isEmpty ? .searchResultEmpty : .searchResultOk
            case let .failure(error):
                state.searchState = .error
            }
            return .none

        // Details
        case let .showDetails(pharmacyLocation):
            state.route = .pharmacy(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: pharmacyLocation
            ))
            return .none
        case .pharmacyDetailView(action: .close):
            state.route = nil
            return Effect(value: .close)
                // swiftlint:disable:next todo
                // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                .delay(for: .seconds(0.1), scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .pharmacyDetailView:
            return .none
        case let .removeFilterOption(filterOption):
            if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                state.pharmacyFilterOptions.remove(at: index)
            }
            return .init(value: .performSearch)
                .eraseToEffect()
        case let .quickSearch(filterOptions):
            state.pharmacyFilterOptions = filterOptions

            if filterOptions.contains(.currentLocation) {
                state.searchState = .searchAfterLocalizationWasAuthorized

                return .init(value: .requestLocation)
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToEffect()
            }
            return .init(value: .performSearch)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
        case let .pharmacyFilterView(.close(filterOptions)):
            state.route = nil
            state.searchState = .searchRunning

            return .init(value: .quickSearch(filters: filterOptions))
                .delay(for: 0.5, scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
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
            if state.searchState == .searchAfterLocalizationWasAuthorized {
                state.route = .alert(locationPermissionAlertState)
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
        case .setNavigation(tag: .filter):
            state.route = .filter(.init(pharmacyFilterOptions: state.pharmacyFilterOptions))
            return .none
        case .setNavigation(tag: nil):
            state.route = nil
            return .none
        case .setNavigation:
            return .none
        case .openAppSpecificSettings:
            environment.openSettings()
            return .none
        }
    }
}

extension PharmacySearchDomain.Environment {
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url, [:], nil)
        }
    }
}

extension PharmacySearchDomain {
    static let reducer: Reducer = .combine(
        pharmacyFilterPullbackReducer,
        pharmacyDetailPullbackReducer,
        domainReducer
    )

    static let pharmacyFilterPullbackReducer: Reducer =
        PharmacySearchFilterDomain.reducer._pullback(
            state: (\State.route).appending(path: /PharmacySearchDomain.Route.filter),
            action: /PharmacySearchDomain.Action.pharmacyFilterView(action:)
        ) { environment in
            PharmacySearchFilterDomain.Environment(schedulers: environment.schedulers)
        }

    static let pharmacyDetailPullbackReducer: Reducer =
        PharmacyDetailDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.pharmacy),
            action: /Action.pharmacyDetailView(action:)
        ) { environment in
            PharmacyDetailDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession,
                signatureProvider: environment.signatureProvider,
                accessibilityAnnouncementReceiver: environment.accessibilityAnnouncementReceiver,
                userSessionProvider: environment.userSessionProvider
            )
        }

    static var locationPermissionAlertState: AlertState<Action> = {
        AlertState(
            title: TextState(L10n.phaSearchTxtLocationAlertTitle),
            message: TextState(L10n.phaSearchTxtLocationAlertMessage),
            primaryButton: .default(
                TextState(L10n.alertBtnOk),
                action: .send(.removeFilterOption(.currentLocation), animation: .default)
            ),
            secondaryButton: .default(TextState("Settings"), action: .send(.openAppSpecificSettings))
        )
    }()
}

extension PharmacySearchDomain.Environment {
    func searchPharmacies(
        searchTerm: String,
        location: ComposableCoreLocation.Location?,
        filter: [PharmacySearchFilterDomain.PharmacyFilterOption]
    )
        -> Effect<PharmacySearchDomain.Action, Never> {
        var position: Position?
        if let latitude = location?.coordinate.latitude,
           let longitude = location?.coordinate.longitude {
            position = Position(lat: latitude, lon: longitude)
        }
        return pharmacyRepository.searchRemote(
            searchTerm: searchTerm,
            position: position,
            filter: filter.asPharmacyRepositoryFilters
        )
        .first()
        .catchToEffect()
        .map(PharmacySearchDomain.Action.pharmaciesReceived)
        .receive(on: schedulers.main.animation())
        .eraseToEffect()
    }
}

extension Array where Element == PharmacyLocationViewModel {
    func filter(by filterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption]) -> [PharmacyLocationViewModel] {
        // Filter Pharmacies that are closed
        if filterOptions.contains(.open) {
            return filter { location in
                switch location.todayOpeningState {
                case .open:
                    return true
                default:
                    return false
                }
            }
        }
        return self
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
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "Apothekesdfwerwerasdf",
            pharmacies: [],
            searchState: .searchResultEmpty
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
        static let state = State(
            erxTasks: [ErxTask.Demo.erxTaskReady],
            searchText: "",
            pharmacies: pharmaciesLocationViewModel,
            searchState: .startView // .searchResultOk(pharmaciesLocationViewModel)
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
            pharmacyRepository: DummySessionContainer().pharmacyRepository,
            locationManager: .live,
            fhirDateFormatter: FHIRDateFormatter.shared,
            openHoursCalculator: PharmacyOpenHoursCalculator(),
            referenceDateForOpenHours: openHoursReferenceDate,
            userSession: DummySessionContainer(),
            openURL: UIApplication.shared.open(_:options:completionHandler:),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            accessibilityAnnouncementReceiver: { _ in },
            userSessionProvider: DummyUserSessionProvider()
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
