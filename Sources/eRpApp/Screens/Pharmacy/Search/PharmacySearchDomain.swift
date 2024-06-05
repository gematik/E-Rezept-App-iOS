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

import CasePaths
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocationUI
import eRpKit
import IDP
import MapKit
import Pharmacy
import SwiftUI

// swiftlint:disable type_body_length file_length
@Reducer
struct PharmacySearchDomain {
    enum CancelID: Int {
        case locationManager
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = pharmacySearch_detail
        case pharmacyDetail(PharmacyDetailDomain)
        // sourcery: AnalyticsScreen = pharmacySearch_filter
        case pharmacyFilter(PharmacySearchFilterDomain)
        // sourcery: AnalyticsScreen = pharmacySearch_map
        case pharmacyMapSearch(PharmacySearchMapDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)

        enum Alert {
            case removeFilterCurrentLocation
            case openAppSpecificSettings
        }
    }

    @ObservableState
    struct State: Equatable {
        /// A storage for the prescriptions hat have been selected to be redeemed
        var erxTasks: [ErxTask]
        /// The value of the search text field
        var searchText = ""
        /// Stores the current device location when determined by Core-Location
        var currentLocation: Location?
        /// Map-Location for MapView with the standard value if location is not active
        var mapLocation = MKCoordinateRegion.gematikHQRegion
        /// Store for the remote search result
        var pharmacies: [PharmacyLocationViewModel] = []
        /// Store for the local pharmacies
        var localPharmacies: [PharmacyLocationViewModel] = []
        /// A valid search terms should at least consist of 3 chars
        var searchTextValid: Bool {
            searchText.count > 2
        }

        var pharmacyRedeemState: PharmacyRedeemDomain.State?
        var pharmacySearchMapState: PharmacySearchMapDomain.State?

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

        @Presents var destination: Destination.State?

        var searchHistory: [String] = []

        var selectedPharmacy: PharmacyLocation?
    }

    enum Action: Equatable {
        case task
        case onAppear
        // Search
        case searchTextChanged(String)
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        case loadAndNavigateToPharmacy(PharmacyLocation)
        // Map
        case mapSetUp
        case mapSetUpReceived(Location?)
        case showMap
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        // Filter
        case showPharmacyFilter
        case removeFilterOption(PharmacySearchFilterDomain.PharmacyFilterOption)
        // Device location
        case requestLocation
        case startRequestingCurrentLocation
        case locationManager(LocationManager.Action)
        case closeButtonTouched

        case destination(PresentationAction<Destination.Action>)
        case resetNavigation
        case delegate(Delegate)
        case response(Response)
        case setAlert(ErpAlertState<Destination.Alert>)

        enum Delegate: Equatable {
            case close
        }

        enum Response: Equatable {
            case pharmaciesReceived(Result<[PharmacyLocationViewModel], PharmacyRepositoryError>)
            case loadLocalPharmaciesReceived(Result<[PharmacyLocationViewModel], PharmacyRepositoryError>)
            case loadAndNavigateToPharmacyReceived(Result<PharmacyLocation, PharmacyRepositoryError>)
        }

        case universalLink(URL)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.locationManager) var locationManager: LocationManager
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.searchHistory) var searchHistory: SearchHistory

    // Control the current time for opening/closing determination. When not set current device time is used.
    let referenceDateForOpenHours: Date?

    init(referenceDateForOpenHours: Date? = nil) {
        self.referenceDateForOpenHours = referenceDateForOpenHours
    }

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

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .showMap:
            state.destination = .pharmacyMapSearch(.init(
                erxTasks: state.erxTasks,
                currentUserLocation: state.currentLocation,
                mapLocation: .manual(state.mapLocation)
            ))
            return .none
        case .mapSetUp:
            guard state.destination == nil else { return .none }

            return .run { send in
                await send(.mapSetUpReceived(await locationManager.location()))
            }
        case let .mapSetUpReceived(location):
            guard let location = location else {
                state.mapLocation = MKCoordinateRegion.gematikHQRegion
                return .none
            }
            state.currentLocation = location
            state.mapLocation = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            return .none
        case let .destination(.presented(.pharmacyMapSearch(action: .delegate(action)))):
            switch action {
            case .closeMap:
                state.destination = nil
                state.searchState = .startView(loading: false)
                return .none
            case .close:
                state.destination = nil
                return .run { send in
                    // swiftlint:disable:next todo
                    // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                    try await schedulers.main.sleep(for: 0.1)
                    await send(.delegate(.close))
                }
            }
        case .closeButtonTouched:
            return Effect.send(.delegate(.close))
        case let .delegate(action):
            switch action {
            case .close:
                state.destination = nil
                return .none
            }
        case .task:
            state.searchHistory = searchHistory.historyItems()
            return .merge(
                .publisher(
                    pharmacyRepository.loadLocal(count: 5)
                        .first()
                        .map { [currentLocation = state.currentLocation] elements in
                            elements.map { element in
                                PharmacyLocationViewModel(
                                    pharmacy: element,
                                    referenceLocation: currentLocation,
                                    referenceDate: referenceDateForOpenHours,
                                    timeOnlyFormatter: timeOnlyFormatter
                                )
                            }
                        }
                        .catchToPublisher()
                        .map { .response(.loadLocalPharmaciesReceived($0)) }
                        .receive(on: schedulers.main.animation())
                        .eraseToAnyPublisher
                ), Effect.send(.mapSetUp)
            )
        case .onAppear:
            return .run { send in
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await withTaskCancellation(id: CancelID.locationManager, cancelInFlight: true) {
                            for await action in await locationManager.delegate() {
                                await send(.locationManager(action), animation: .default)
                            }
                        }
                    }
                }
            }
        case let .response(.loadLocalPharmaciesReceived(.success(pharmacies))):
            state.localPharmacies = pharmacies
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
        case let .response(.pharmaciesReceived(result)):
            switch result {
            case let .success(pharmacies):
                // [REQ:gemSpec_eRp_FdV:A_20285] pharmacy order is resolved on server side
                state.pharmacies = pharmacies
                    .filter(by: state.pharmacyFilterOptions)

                state.searchState = pharmacies.isEmpty ? .searchResultEmpty : .searchResultOk
            case .failure:
                state.searchState = .error
            }
            return .none

        case let .loadAndNavigateToPharmacy(pharmacyLocation):
            state.searchState = .startView(loading: true)
            state.selectedPharmacy = pharmacyLocation
            return .publisher(
                pharmacyRepository.updateFromRemote(by: pharmacyLocation.telematikID)
                    .first()
                    .receive(on: schedulers.main)
                    .catchToPublisher()
                    .map { .response(.loadAndNavigateToPharmacyReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .response(.loadAndNavigateToPharmacyReceived(result)):
            state.searchState = .startView(loading: false)
            switch result {
            case let .success(pharmacy):
                let viewModel = PharmacyLocationViewModel(
                    pharmacy: pharmacy,
                    referenceLocation: state.currentLocation,
                    referenceDate: referenceDateForOpenHours,
                    timeOnlyFormatter: timeOnlyFormatter
                )
                state.destination = .pharmacyDetail(
                    PharmacyDetailDomain.State(
                        erxTasks: state.erxTasks,
                        pharmacyViewModel: viewModel,
                        pharmacyRedeemState: state.pharmacyRedeemState
                    )
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
                    return .run { _ in
                        _ = try await pharmacyRepository.delete(pharmacy: pharmacyLocation).async()
                    }
                }
            }
            state.selectedPharmacy = nil
            return .none
        // Details
        case let .showDetails(viewModel):
            state.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: viewModel,
                pharmacyRedeemState: state.pharmacyRedeemState
            ))
            return .none
        case let .destination(.presented(.pharmacyDetail(action: .delegate(action)))):
            switch action {
            case .close:
                state.destination = nil
                return .run { send in
                    // swiftlint:disable:next todo
                    // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                    try await schedulers.main.sleep(for: 0.1)
                    await send(.delegate(.close))
                }
            case let .changePharmacy(saveState):
                state.destination = nil
                state.pharmacyRedeemState = saveState
                return .none
            }
        case let .destination(
            .presented(.pharmacyDetail(action: .response(.toggleIsFavoriteReceived(.success(pharmacy)))))
        ):
            if let index = state.pharmacies.firstIndex(where: { $0.telematikID == pharmacy.telematikID }) {
                state.pharmacies[index] = pharmacy
            }
            return .none
        case .destination(.presented(.alert(.removeFilterCurrentLocation))):
            return .send(.removeFilterOption(.currentLocation))
        case let .removeFilterOption(filterOption):
            if let index = state.pharmacyFilterOptions.firstIndex(of: filterOption) {
                state.pharmacyFilterOptions.remove(at: index)
            }
            return .send(.performSearch)
        case let .quickSearch(filterOptions):
            state.pharmacyFilterOptions = filterOptions

            // [REQ:gemSpec_eRp_APOVZD:A_21154] If user defined filters contain location element, ask for permission
            if filterOptions.contains(.currentLocation) {
                state.searchState = .searchAfterLocalizationWasAuthorized

                return .send(.requestLocation)
                    .animation()
            }
            return .send(.performSearch)
                .animation()
        case .destination(.presented(.pharmacyFilter(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.pharmacyFilter(.toggleFilter))):
            state.searchState = .searchRunning

            if let filterState = (/PharmacySearchDomain.Destination.State.pharmacyFilter)
                .extract(from: state.destination) {
                return .run { send in
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.quickSearch(filters: filterState.pharmacyFilterOptions))
                }
                .animation()
            }

            return .none
        // Location
        case .requestLocation:
            return .run { send in
                guard await locationManager.locationServicesEnabled() else {
                    await send(.setAlert(Self.locationPermissionAlertState))
                    return
                }

                switch await locationManager.authorizationStatus() {
                case .notDetermined:
                    await locationManager.requestWhenInUseAuthorization()

                case .restricted, .denied:
                    await send(.setAlert(Self.locationPermissionAlertState))

                case .authorizedAlways, .authorizedWhenInUse:
                    await locationManager.requestLocation()

                @unknown default:
                    break
                }
            }
        case .startRequestingCurrentLocation:
            return .run { _ in
                await locationManager.requestWhenInUseAuthorization()
            }
        case let .setAlert(alert):
            state.destination = .alert(alert)
            return .none
        case let .locationManager(action):
            // Suppress updates if any destination but the filter is shown (e.g. map)
            guard state.destination == nil || state.destination?.pharmacyFilter != nil else {
                return .none
            }
            switch action {
            case .didChangeAuthorization(.authorizedAlways),
                 .didChangeAuthorization(.authorizedWhenInUse):
                if state.searchState == .searchAfterLocalizationWasAuthorized {
                    return .run { _ in
                        await locationManager.requestLocation()
                    }
                }
                return Effect.send(.mapSetUp)
            case .didChangeAuthorization(.notDetermined):
                state.currentLocation = nil
                return Effect.send(.mapSetUp)
            case .didChangeAuthorization(.denied),
                 .didChangeAuthorization(.restricted):
                state.currentLocation = nil
                if state.searchState == .searchAfterLocalizationWasAuthorized {
                    state.destination = .alert(Self.locationPermissionAlertState)
                }
                return Effect.send(.mapSetUp)
            case let .didUpdateLocations(locations):
                state.currentLocation = locations.first
                return .run(operation: { send in
                    await locationManager.stopUpdatingLocation()
                    await send(.performSearch)
                })
            default:
                return .none
            }
        case .showPharmacyFilter:
            state.destination = .pharmacyFilter(.init(pharmacyFilterOptions: state.pharmacyFilterOptions))
            return .none
        case let .universalLink(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let identifier = components.fragmentAsQueryItems()["tiid"],
                  identifier.lengthOfBytes(using: .utf8) > 0
            else {
                return .none
            }

            state.searchState = .startView(loading: true)
            return .run(operation: { send in
                let pharmacy = try await pharmacyRepository.loadCached(by: identifier)
                    .first()
                    .catchToPublisher()
                    .async()

                let value = pharmacy.flatMap { location -> Result<PharmacyLocation, PharmacyRepositoryError> in
                    guard let location = location else {
                        return .failure(.remote(.notFound))
                    }
                    return .success(location)
                }
                await send(.response(.loadAndNavigateToPharmacyReceived(value)))

                // Let all transitions finish before toggling the favorite.
                try? await schedulers.main.sleep(for: .seconds(1))

                await send(.destination(.presented(.pharmacyDetail(.setIsFavorite(true)))))
            })
        case .destination(.presented(.alert(.openAppSpecificSettings))):
            openSettings()
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case .destination:
            return .none
        }
    }
}

extension URLComponents {
    /// Parses a urls fragment with the GET parameters syntax.
    ///
    /// E.g. parsing `https://erezept.gematik.de#keyA=valueA&keyB=valueB` would result in a dictionary
    /// ["keyA": "valueA", "keyB": "valueB"]. Missing "=" or empty values are allowed and result in an empty dictionary
    /// entry
    /// - Returns: A dictionary with key value pairs for all parameters.
    func fragmentAsQueryItems() -> [String: String] {
        guard let fragment = fragment else { return [:] }
        let fragmentPairs: [(String, String)] = fragment
            .components(separatedBy: "&")
            .compactMap { value -> (String, String)? in
                let pair = value.components(separatedBy: "=")
                guard let key = pair.first else {
                    return nil
                }
                guard pair.count == 2 else {
                    return (key, "")
                }
                return (key, pair.last ?? "")
            }

        return Dictionary(uniqueKeysWithValues: fragmentPairs)
    }
}

extension PharmacySearchDomain {
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
        -> Effect<PharmacySearchDomain.Action> {
        var position: Position?
        if let latitude = location?.coordinate.latitude,
           let longitude = location?.coordinate.longitude {
            position = Position(lat: latitude, lon: longitude)
        }
        return .publisher(
            pharmacyRepository.searchRemote(
                searchTerm: searchTerm,
                position: position,
                filter: filter.asPharmacyRepositoryFilters
            )
            .first()
            .map { elements in
                elements.map { element in
                    PharmacyLocationViewModel(
                        pharmacy: element,
                        referenceLocation: location,
                        referenceDate: referenceDateForOpenHours,
                        timeOnlyFormatter: timeOnlyFormatter
                    )
                }
            }
            .catchToPublisher()
            .map { .response(.pharmaciesReceived($0)) }
            .receive(on: schedulers.main.animation())
            .eraseToAnyPublisher
        )
    }
}

extension PharmacySearchDomain {
    static let locationPermissionAlertState = ErpAlertState<Destination.Alert>(
        title: L10n.phaSearchTxtLocationAlertTitle,
        actions: {
            ButtonState(role: .cancel, action: .removeFilterCurrentLocation) {
                .init(L10n.alertBtnOk)
            }
            ButtonState(action: .openAppSpecificSettings) {
                .init(L10n.stgTxtTitle)
            }
        },
        message: L10n.phaSearchTxtLocationAlertMessage
    )
}

// swiftlint:enable type_body_length
