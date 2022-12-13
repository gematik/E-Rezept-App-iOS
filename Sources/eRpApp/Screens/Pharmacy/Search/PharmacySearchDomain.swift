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

import CasePaths
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
        case loadLocalPharmacies
        case updateLocalPharmacy
        case deleteAndLoad
        case delete
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
        case startView(loading: Bool)
        case searchRunning
        case searchResultEmpty
        case searchResultOk
        case searchAfterLocalizationWasAuthorized
        case localizingDevice
        case error

        var isStartView: Bool {
            if case .startView(loading: _) = self {
                return true
            }
            return false
        }

        var isStartViewLoading: Bool {
            if case let .startView(loading: isLoading) = self {
                return isLoading
            }
            return false
        }
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
        /// Store for the remote search result
        var pharmacies: [PharmacyLocationViewModel] = []
        /// Store for the local pharmacies
        var localPharmacies: [PharmacyLocationViewModel] = []
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
        var searchState: SearchState = .startView(loading: false)

        var route: Route?

        var searchHistory: [String] = []

        var selectedPharmacy: PharmacyLocation?
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
        case loadLocalPharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
        case loadAndNavigateToPharmacy(PharmacyLocation)
        case loadAndNavigateToPharmacyReceived(Result<PharmacyLocation, PharmacyRepositoryError>)
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
            return environment.pharmacyRepository.loadLocal(count: 5)
                .first()
                .receive(on: environment.schedulers.main.animation())
                .catchToEffect()
                .map(PharmacySearchDomain.Action.loadLocalPharmaciesReceived)
                .cancellable(id: Token.loadLocalPharmacies, cancelInFlight: true)

        case let .loadLocalPharmaciesReceived(.success(pharmacies)):
            state.localPharmacies = pharmacies.map {
                PharmacyLocationViewModel(
                    pharmacy: $0,
                    referenceLocation: state.currentLocation,
                    referenceDate: environment.referenceDateForOpenHours,
                    timeOnlyFormatter: environment.timeOnlyFormatter
                )
            }
            return .none
        case let .loadLocalPharmaciesReceived(.failure(error)):
            state.route = .alert(AlertState(for: error))
            return .none
        // Search
        case let .searchTextChanged(changedText):
            state.searchText = changedText
            if changedText.lengthOfBytes(using: .utf8) == 0 {
                state.searchState = .startView(loading: false)
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

        case let .loadAndNavigateToPharmacy(pharmacyLocation):
            state.searchState = .startView(loading: true)
            state.selectedPharmacy = pharmacyLocation
            return environment.pharmacyRepository.updateFromRemote(by: pharmacyLocation.telematikID)
                .first()
                .receive(on: environment.schedulers.main)
                .catchToEffect()
                .map(PharmacySearchDomain.Action.loadAndNavigateToPharmacyReceived)
                .cancellable(id: Token.updateLocalPharmacy, cancelInFlight: true)
        case let .loadAndNavigateToPharmacyReceived(result):
            state.searchState = .startView(loading: false)
            switch result {
            case let .success(pharmacy):
                let viewModel = PharmacyLocationViewModel(pharmacy: pharmacy,
                                                          referenceLocation: state.currentLocation,
                                                          referenceDate: environment.referenceDateForOpenHours,
                                                          timeOnlyFormatter: environment.timeOnlyFormatter)
                state.route = .pharmacy(
                    PharmacyDetailDomain.State(erxTasks: state.erxTasks, pharmacyViewModel: viewModel)
                )
            case let .failure(error):
                state.route = .alert(AlertStates.alert(for: error))
                if PharmacyRepositoryError.remote(.notFound) == error,
                   let pharmacyLocation = state.selectedPharmacy {
                    if let index = state.localPharmacies
                        .firstIndex(where: { $0.telematikID == pharmacyLocation.telematikID }) {
                        state.localPharmacies.remove(at: index)
                    }
                    state.selectedPharmacy = nil
                    return environment.pharmacyRepository.delete(pharmacy: pharmacyLocation)
                        .first()
                        .receive(on: environment.schedulers.main.animation())
                        .eraseToEffect()
                        .fireAndForget()
                        .cancellable(id: Token.delete, cancelInFlight: true)
                }
            }
            state.selectedPharmacy = nil
            return .none
        // Details
        case let .showDetails(viewModel):
            state.route = .pharmacy(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: viewModel
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
            return .none
        case .pharmacyFilterView(.toggleFilter):
            state.searchState = .searchRunning

            if let filterState = (/PharmacySearchDomain.Route.filter).extract(from: state.route) {
                return .init(value: .quickSearch(filters: filterState.pharmacyFilterOptions))
                    .delay(for: 0.5, scheduler: environment.schedulers.main.animation())
                    .eraseToEffect()
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

    enum AlertStates {
        static func alert(for error: PharmacyRepositoryError) -> AlertState<Action> {
            guard let message = error.recoverySuggestion else {
                return AlertState(for: error)
            }
            return AlertState(
                title: TextState(error.localizedDescription),
                message: TextState(message),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: .none)))
            )
        }
    }
}

extension PharmacySearchDomain.Environment {
    func loadLocalPharmacies() -> Effect<PharmacySearchDomain.Action, Never> {
        pharmacyRepository.loadLocal(count: 5)
            .first()
            .receive(on: schedulers.main.animation())
            .catchToEffect()
            .map(PharmacySearchDomain.Action.loadLocalPharmaciesReceived)
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url, [:], nil)
        }
    }

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
                userSessionProvider: environment.userSessionProvider,
                pharmacyRepository: environment.pharmacyRepository
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
