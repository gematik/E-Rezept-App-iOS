//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
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

extension String {
    static let pharmacySearchFilterOptions = "pharmacySearchFilterOptions"
}

extension SharedReaderKey
    where Self == InMemoryKey<[PharmacySearchFilterDomain.PharmacyFilterOption]>.Default {
    static var pharmacyFilterOptions: Self {
        Self[.inMemory("pharmacySearchFilterOptions"), default: []]
    }
}

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
        /// A storage for the prescriptions that have been selected to be redeemed
        @Shared var selectedPrescriptions: [Prescription]
        /// View can be called within the redeeming process or from the tab-bar.
        /// Boolean is true when called within redeeming process
        var inRedeemProcess: Bool
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
        @Shared(.pharmacyFilterOptions) var pharmacyFilterOptions
        /// The current state the search is at
        var searchState: SearchState = .startView(loading: false)

        @Presents var destination: Destination.State?

        var searchHistory: [String] = []
        /// Stores the local (favorite) pharmacy
        var selectedPharmacy: PharmacyLocation?
        /// Stores the pharmacy used for the detail view so it can be displayed again when going back to the redeem view
        var detailsPharmacy: PharmacyLocationViewModel?

        var lastSearchCriteria: SearchCriteria?

        struct SearchCriteria: Equatable {
            var searchTerm: String
            var location: ComposableCoreLocation.Location?
            var filter: [PharmacySearchFilterDomain.PharmacyFilterOption]

            static func isEqualOrVerySimilar(lhs: SearchCriteria, rhs: SearchCriteria) -> Bool {
                if let lhsLocation = lhs.location,
                   let rhsLocation = rhs.location {
                    return lhs.searchTerm == rhs.searchTerm &&
                        lhs.filter == rhs.filter &&
                        lhsLocation.rawValue.distance(from: rhsLocation.rawValue) < 200
                }
                guard lhs.location == nil, rhs.location == nil else {
                    return false
                }
                return lhs.searchTerm == rhs.searchTerm &&
                    lhs.filter == rhs.filter
            }
        }

        func asSearchCriteria() -> SearchCriteria {
            .init(
                searchTerm: searchText,
                // When adding an location to request, near me filter is used
                // This prevents sending an location when near me filter is not used
                location: pharmacyFilterOptions.contains(.currentLocation) ? currentLocation : nil,
                filter: pharmacyFilterOptions
            )
        }

        var searchCriteriaChanged: Bool {
            if let lastSearchCriteria = lastSearchCriteria {
                return !SearchCriteria.isEqualOrVerySimilar(lhs: lastSearchCriteria, rhs: asSearchCriteria())
            }
            return false
        }
    }

    enum Action: BindableAction, Equatable {
        case nothing(Bool)
        case task
        case onAppear
        case binding(BindingAction<State>)
        // Search
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        case loadAndNavigateToPharmacy(PharmacyLocation)
        case switchToMapView
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

        @CasePathable
        enum Delegate: Equatable {
            case close
        }

        @CasePathable
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
    @Dependency(\.uiDateFormatter) var uiDateFormatter: UIDateFormatter

    // Control the current time for opening/closing determination. When not set current device time is used.
    let referenceDateForOpenHours: Date?

    init(referenceDateForOpenHours: Date? = nil) {
        self.referenceDateForOpenHours = referenceDateForOpenHours
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .nothing:
            return .none
        case .showMap:
            state.destination = .pharmacyMapSearch(.init(
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                currentUserLocation: state.currentLocation,
                mapLocation: .manual(state.mapLocation),
                searchText: state.searchText
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
            case let .closeMap(location):
                state.currentLocation = location
                state.destination = nil
                if state.searchCriteriaChanged {
                    return .send(.performSearch)
                }
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
        case .switchToMapView:
            let centerLocation = state.currentLocation ?? calculateCenter(pharmacies: state.pharmacies)

            let pharmacies = state.pharmacies.map {
                PharmacyLocationViewModel(
                    pharmacy: $0.pharmacyLocation,
                    referenceLocation: centerLocation,
                    referenceDate: referenceDateForOpenHours,
                    timeOnlyFormatter: uiDateFormatter.timeOnlyFormatter
                )
            }

            let mapLocation: MKCoordinateRegionContainer = .manual(.init(
                center: centerLocation.rawValue.coordinate,
                span: calculateSpan(
                    pharmacies: pharmacies,
                    currentLocation: centerLocation.rawValue.coordinate
                )
            ))

            state.destination = .pharmacyMapSearch(.init(
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                currentUserLocation: state.currentLocation,
                mapLocation: mapLocation,
                pharmacies: pharmacies,
                showOnlyTextSearchResult: true,
                searchText: state.searchText
            ))
            return .none
        case .task:
            state.searchHistory = searchHistory.historyItems()
            return .merge(
                .publisher { state.$pharmacyFilterOptions.publisher.dropFirst().map(Action.quickSearch) },
                .publisher(
                    pharmacyRepository.loadLocal(count: 5)
                        .first()
                        .map { [currentLocation = state.currentLocation] elements in
                            elements.map { element in
                                PharmacyLocationViewModel(
                                    pharmacy: element,
                                    referenceLocation: currentLocation,
                                    referenceDate: referenceDateForOpenHours,
                                    timeOnlyFormatter: uiDateFormatter.timeOnlyFormatter
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
            return .run { [state] send in
                if state.searchState.isNotStartView, state.searchCriteriaChanged {
                    await send(.quickSearch(filters: state.pharmacyFilterOptions))
                }
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
        case .binding(\.searchText):
            if state.searchText.lengthOfBytes(using: .utf8) == 0 {
                state.searchState = .startView(loading: false)
            }
            return .none
        case .performSearch:
            // append history item
            searchHistory.addHistoryItem(state.searchText)
            state.searchHistory = searchHistory.historyItems()

            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            state.searchState = .searchRunning

            let searchCriteria = state.asSearchCriteria()
            state.lastSearchCriteria = searchCriteria
            return searchPharmacies(searchCriteria)
        case let .response(.pharmaciesReceived(result)):
            switch result {
            case let .success(pharmacies):
                // [REQ:gemSpec_eRp_FdV:A_20285] pharmacy order is resolved on server side
                state.pharmacies = pharmacies
                    .filter(by: state.pharmacyFilterOptions)

                // sort pharmacies for distance if available
                if state.pharmacies.first?.distanceInM != nil {
                    state.pharmacies.sort { $0.distanceInM ?? 0 < $1.distanceInM ?? 0 }
                }

                state.searchState = pharmacies.isEmpty ? .searchResultEmpty : .searchResultOk
            case .failure:
                state.searchState = .error
            }
            return .none

        case let .loadAndNavigateToPharmacy(pharmacyLocation):
            state.searchState = .startView(loading: true)
            state.selectedPharmacy = pharmacyLocation
            return .publisher(
                pharmacyRepository.updateFromRemote(
                    by: pharmacyLocation.telematikID
                )
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
                    timeOnlyFormatter: uiDateFormatter.timeOnlyFormatter
                )
                state.detailsPharmacy = viewModel

                state.destination = .pharmacyDetail(
                    PharmacyDetailDomain.State(
                        prescriptions: Shared<[Prescription]>(value: []),
                        selectedPrescriptions: state.$selectedPrescriptions,
                        inRedeemProcess: state.inRedeemProcess,
                        pharmacyViewModel: viewModel,
                        hasRedeemableTasks: !state.selectedPrescriptions.isEmpty
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
            state.detailsPharmacy = viewModel

            state.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared<[Prescription]>(value: []),
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                pharmacyViewModel: viewModel,
                hasRedeemableTasks: !state.selectedPrescriptions.isEmpty
            ))
            return .none
        case .destination(.presented(.pharmacyDetail(action: .delegate(.changePharmacy)))):
            guard let viewModel = state.detailsPharmacy else { return .none }

            state.destination = .pharmacyDetail(PharmacyDetailDomain.State(
                prescriptions: Shared<[Prescription]>(value: []),
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                pharmacyViewModel: viewModel,
                hasRedeemableTasks: !state.selectedPrescriptions.isEmpty
            ))
            return .none
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
                state.$pharmacyFilterOptions.withLock { _ = $0.remove(at: index) }
            }
            return .send(.performSearch)
        case let .quickSearch(filterOptions):
            guard state.destination == nil || state.destination?.pharmacyFilter != nil else {
                return .none
            }
            if filterOptions != state.pharmacyFilterOptions {
                state.$pharmacyFilterOptions.withLock { $0 = filterOptions }
            }

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
        case .destination(.presented(.pharmacyDetail(.delegate(.redeem)))):
            state.destination = nil
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
            state.destination = .pharmacyFilter(.init(
                pharmacyFilterOptions: state.$pharmacyFilterOptions
            ))
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
        case .destination, .binding:
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

    func searchPharmacies(_ searchCriteria: State.SearchCriteria) -> Effect<PharmacySearchDomain.Action> {
        var position: Position?
        if let latitude = searchCriteria.location?.coordinate.latitude,
           let longitude = searchCriteria.location?.coordinate.longitude {
            position = Position(lat: latitude, lon: longitude)
        }
        return .publisher(
            pharmacyRepository.searchRemote(
                searchTerm: searchCriteria.searchTerm,
                position: position,
                filter: searchCriteria.filter.asPharmacyRepositoryFilters
            )
            .first()
            .map { elements in
                elements.map { element in
                    PharmacyLocationViewModel(
                        pharmacy: element,
                        referenceLocation: searchCriteria.location,
                        referenceDate: referenceDateForOpenHours,
                        timeOnlyFormatter: uiDateFormatter.timeOnlyFormatter
                    )
                }
            }
            .catchToPublisher()
            .map { .response(.pharmaciesReceived($0)) }
            .receive(on: schedulers.main.animation())
            .eraseToAnyPublisher
        )
    }

    /// This function calculates the span needed to display up to the seventh (or last) pharmacy on the Map.
    func calculateSpan(pharmacies: [PharmacyLocationViewModel],
                       currentLocation: CLLocationCoordinate2D) -> MKCoordinateSpan {
        /// First filtering and sorting all pharmacies by distance from the current Location
        let filteredAndSorted = pharmacies.sorted { first, second in
            guard let first = first.distanceInM else {
                return second.distanceInM != nil
            }
            guard let second = second.distanceInM else {
                return true
            }
            return first < second
        }
        .filter { $0.distanceInM != nil }

        guard !filteredAndSorted.isEmpty else {
            return MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }

        let seventhOrLast = min(filteredAndSorted.count, 7)
        if let seventhLocation = filteredAndSorted[seventhOrLast - 1].position?.coordinate {
            /// Now calculating lat/long - delta by subtracting the seventhLocation from the currentLocation
            /// and multiplying by 2 for adjusting the zoom level
            let latitudeDelta = 2 * abs(currentLocation.latitude - seventhLocation.latitude)
            let longitudeDelta = 2 * abs(currentLocation.longitude - seventhLocation.longitude)
            return MKCoordinateSpan(
                latitudeDelta: max(latitudeDelta, 0.01),
                longitudeDelta: max(longitudeDelta, 0.01)
            )
        }
        return MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }

    /// The function calculates the center position of all pharmacies.
    /// This is needed to properly display the pharmacies from the text search result to map feature.
    func calculateCenter(pharmacies: [PharmacyLocationViewModel]) -> Location {
        var totalLatitude = 0.0
        var totalLongitude = 0.0

        for pharmacy in pharmacies {
            if let coordinates = pharmacy.pharmacyLocation.position?.coordinate {
                totalLatitude += coordinates.latitude
                totalLongitude += coordinates.longitude
            }
        }

        let avgLatitude = totalLatitude / Double(pharmacies.count)
        let avgLongitude = totalLongitude / Double(pharmacies.count)

        return Location(rawValue: .init(latitude: avgLatitude, longitude: avgLongitude))
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
