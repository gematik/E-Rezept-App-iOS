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

import CasePaths
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import IDP
import Pharmacy
import SwiftUI

// swiftlint:disable type_body_length
struct PharmacySearchDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    private static func cleanupSubDomains<T>() -> EffectTask<T> {
        .concatenate(
            PharmacyDetailDomain.cleanup()
        )
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

        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption] = []
        /// The current state the search is at
        var searchState: SearchState = .startView(loading: false)

        var destination: Destinations.State?

        var searchHistory: [String] = []

        var selectedPharmacy: PharmacyLocation?
    }

    enum Action: Equatable {
        case onAppear
        // Search
        case searchTextChanged(String)
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        case loadAndNavigateToPharmacy(PharmacyLocation)
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)

        // Filter
        case removeFilterOption(PharmacySearchFilterDomain.PharmacyFilterOption)
        // Device location
        case requestLocation
        case locationManager(LocationManager.Action)
        case closeButtonTouched

        case openAppSpecificSettings
        case destination(PharmacySearchDomain.Destinations.Action)
        case setNavigation(tag: Destinations.State.Tag?)
        case delegate(Delegate)
        case response(Response)

        enum Delegate: Equatable {
            case close
        }

        enum Response: Equatable {
            case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
            case loadLocalPharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>)
            case loadAndNavigateToPharmacyReceived(Result<PharmacyLocation, PharmacyRepositoryError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.locationManager) var locationManager: LocationManager
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.searchHistory) var searchHistory: SearchHistory

    // Control the current time for opening/closing determination. When not set current device time is used.
    let referenceDateForOpenHours: Date?

    // swiftlint:disable:next todo
    // TODO: move to UIDateFormatter and add dependency within the model where it's used
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

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTouched:
            return EffectTask(value: .delegate(.close))
        case let .delegate(action):
            switch action {
            case .close:
                state.destination = nil
                return Self.cleanupSubDomains()
            }
        case .onAppear:
            state.searchHistory = searchHistory.historyItems()
            return pharmacyRepository.loadLocal(count: 5)
                .first()
                .receive(on: schedulers.main.animation())
                .catchToEffect()
                .map { .response(.loadLocalPharmaciesReceived($0)) }
                .cancellable(id: Token.loadLocalPharmacies, cancelInFlight: true)

        case let .response(.loadLocalPharmaciesReceived(.success(pharmacies))):
            state.localPharmacies = pharmacies.map {
                PharmacyLocationViewModel(
                    pharmacy: $0,
                    referenceLocation: state.currentLocation,
                    referenceDate: referenceDateForOpenHours,
                    timeOnlyFormatter: timeOnlyFormatter
                )
            }
            return .none
        case let .response(.loadLocalPharmaciesReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
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
            searchHistory.addHistoryItem(state.searchText)
            state.searchHistory = searchHistory.historyItems()

            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            state.searchState = .searchRunning
            return searchPharmacies(
                searchTerm: state.searchText,
                location: state.currentLocation,
                filter: state.pharmacyFilterOptions
            )
            .cancellable(id: Token.search, cancelInFlight: true)
        case let .response(.pharmaciesReceived(result)):
            switch result {
            case let .success(pharmacies):
                // [REQ:gemSpec_eRp_FdV:A_20285] pharmacy order is resolved on server side
                state.pharmacies = pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0,
                        referenceLocation: state.currentLocation,
                        referenceDate: referenceDateForOpenHours,
                        timeOnlyFormatter: timeOnlyFormatter
                    )
                }
                .filter(by: state.pharmacyFilterOptions)

                state.searchState = pharmacies.isEmpty ? .searchResultEmpty : .searchResultOk
            case .failure:
                state.searchState = .error
            }
            return .none

        case let .loadAndNavigateToPharmacy(pharmacyLocation):
            state.searchState = .startView(loading: true)
            state.selectedPharmacy = pharmacyLocation
            return pharmacyRepository.updateFromRemote(by: pharmacyLocation.telematikID)
                .first()
                .receive(on: schedulers.main)
                .catchToEffect()
                .map { .response(.loadAndNavigateToPharmacyReceived($0)) }
                .cancellable(id: Token.updateLocalPharmacy, cancelInFlight: true)
        case let .response(.loadAndNavigateToPharmacyReceived(result)):
            state.searchState = .startView(loading: false)
            switch result {
            case let .success(pharmacy):
                let viewModel = PharmacyLocationViewModel(pharmacy: pharmacy,
                                                          referenceLocation: state.currentLocation,
                                                          referenceDate: referenceDateForOpenHours,
                                                          timeOnlyFormatter: timeOnlyFormatter)
                state.destination = .pharmacy(
                    PharmacyDetailDomain.State(erxTasks: state.erxTasks, pharmacyViewModel: viewModel)
                )
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                if PharmacyRepositoryError.remote(.notFound) == error,
                   let pharmacyLocation = state.selectedPharmacy {
                    if let index = state.localPharmacies
                        .firstIndex(where: { $0.telematikID == pharmacyLocation.telematikID }) {
                        state.localPharmacies.remove(at: index)
                    }
                    state.selectedPharmacy = nil
                    return pharmacyRepository.delete(pharmacy: pharmacyLocation)
                        .first()
                        .receive(on: schedulers.main.animation())
                        .eraseToEffect()
                        .fireAndForget()
                        .cancellable(id: Token.delete, cancelInFlight: true)
                }
            }
            state.selectedPharmacy = nil
            return .none
        // Details
        case let .showDetails(viewModel):
            state.destination = .pharmacy(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: viewModel
            ))
            return .none
        case let .destination(.pharmacyDetailView(action: .delegate(action))):
            switch action {
            case .close:
                state.destination = nil
                return EffectTask(value: .delegate(.close))
                    // swiftlint:disable:next todo
                    // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                    .delay(for: .seconds(0.1), scheduler: schedulers.main)
                    .eraseToEffect()
            }
        case let .removeFilterOption(filterOption):
            if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                state.pharmacyFilterOptions.remove(at: index)
            }
            return .init(value: .performSearch)
                .eraseToEffect()
        case let .quickSearch(filterOptions):
            state.pharmacyFilterOptions = filterOptions

            // [REQ:gemSpec_eRp_APOVZD:A_21154] If user defined filters contain location element, ask for permission
            if filterOptions.contains(.currentLocation) {
                state.searchState = .searchAfterLocalizationWasAuthorized

                return .init(value: .requestLocation)
                    .receive(on: schedulers.main.animation())
                    .eraseToEffect()
            }
            return .init(value: .performSearch)
                .receive(on: schedulers.main.animation())
                .eraseToEffect()
        case .destination(.pharmacyFilterView(.delegate(.close))):
            state.destination = nil
            return .none
        case .destination(.pharmacyFilterView(.toggleFilter)):
            state.searchState = .searchRunning

            if let filterState = (/PharmacySearchDomain.Destinations.State.filter).extract(from: state.destination) {
                return .init(value: .quickSearch(filters: filterState.pharmacyFilterOptions))
                    .delay(for: 0.5, scheduler: schedulers.main.animation())
                    .eraseToEffect()
            }

            return .none
        // Location
        case .requestLocation:
            return .merge(
                locationManager
                    .create(id: LocationManagerId())
                    .map(PharmacySearchDomain.Action.locationManager),
                locationManager
                    .requestWhenInUseAuthorization(id: LocationManagerId())
                    .fireAndForget()
            )
        case .locationManager(.didChangeAuthorization(.authorizedAlways)),
             .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
            if state.searchState == .searchAfterLocalizationWasAuthorized {
                if state.currentLocation != nil {
                    return EffectTask(value: .performSearch)
                } else {
                    return locationManager.startUpdatingLocation(id: LocationManagerId()).fireAndForget()
                }
            }
            return .none
        case .locationManager(.didChangeAuthorization(.notDetermined)):
            return .none
        case .locationManager(.didChangeAuthorization(.denied)),
             .locationManager(.didChangeAuthorization(.restricted)):
            if state.searchState == .searchAfterLocalizationWasAuthorized {
                state.destination = .alert(Self.locationPermissionAlertState)
            }
            return .none
        case let .locationManager(.didUpdateLocations(locations)):
            state.currentLocation = locations.first
            return .concatenate(
                locationManager.stopUpdatingLocation(id: LocationManagerId())
                    .fireAndForget(),
                EffectTask(value: .performSearch)
            )
        case let .setNavigation(tag: tag):
            switch tag {
            case .filter:
                state.destination = .filter(.init(pharmacyFilterOptions: state.pharmacyFilterOptions))
            case .pharmacy, .alert:
                break
            case .none:
                state.destination = nil
            }
            return .none
        case .openAppSpecificSettings:
            openSettings()
            return .none
        case .destination, .locationManager:
            return .none
        }
    }
}

extension PharmacySearchDomain {
    func loadLocalPharmacies() -> EffectTask<PharmacySearchDomain.Action> {
        pharmacyRepository.loadLocal(count: 5)
            .first()
            .receive(on: schedulers.main.animation())
            .catchToEffect()
            .map { .response(.loadLocalPharmaciesReceived($0)) }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            resourceHandler.open(url)
        }
    }

    func searchPharmacies(
        searchTerm: String,
        location: ComposableCoreLocation.Location?,
        filter: [PharmacySearchFilterDomain.PharmacyFilterOption]
    )
        -> EffectTask<PharmacySearchDomain.Action> {
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
        .map { .response(.pharmaciesReceived($0)) }
        .receive(on: schedulers.main.animation())
        .eraseToEffect()
    }
}

extension PharmacySearchDomain {
    static var locationPermissionAlertState: ErpAlertState<Action> = {
        .init(
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
