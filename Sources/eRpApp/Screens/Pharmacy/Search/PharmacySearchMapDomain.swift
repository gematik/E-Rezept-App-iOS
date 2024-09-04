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
struct PharmacySearchMapDomain {
    enum CancelID: Int {
        case locationManager
    }

    @ObservableState
    struct State: Equatable {
        /// A storage for the prescriptions that have been selected to be redeemed
        @Shared var selectedPrescriptions: [Prescription]
        /// View can be called within the redeeming process or from the tab-bar.
        /// Boolean is true when called within redeeming process
        var inRedeemProcess: Bool
        /// Stores the current device location when determined by Core-Location
        var currentUserLocation: Location?
        /// Map-Location for MapView with the standard value if location is not active
        var mapLocation: MKCoordinateRegionContainer
        /// Store for the remote search result
        var pharmacies: [PharmacyLocationViewModel] = []
        /// Store for the active filter options the user has chosen
        @Shared(.pharmacyFilterOptions) var pharmacyFilterOptions

        @Presents var destination: Destination.State?
        /// Stores the pharmacy used for the detail view so it can be displayed again when going back to the redeem view
        var detailsPharmacy: PharmacyLocationViewModel?

        var pharmacyRedeemState: PharmacyRedeemDomain.State?
        /// Boolean for searching after location got authorized
        var searchAfterAuthorized = false
        /// Boolean for only displaying the result from the text search result and not from the map
        var showOnlyTextSearchResult = false
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = pharmacySearch_detail
        case pharmacy(PharmacyDetailDomain)
        // sourcery: AnalyticsScreen = pharmacySearch_filter
        case filter(PharmacySearchFilterDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = redeem_viaAVS
        case redeemViaAVS(PharmacyRedeemDomain)
        // sourcery: AnalyticsScreen = redeem_viaTI
        case redeemViaErxTaskRepository(PharmacyRedeemDomain)

        case clusterSheet(PharmacySearchClusterDomain)

        enum Alert {
            case openAppSpecificSettings
            case performSearch
            case close
        }

        static var body: some ReducerOf<Self> {
            @Dependency(\.avsMessageValidator) var avsMessageValidator
            @Dependency(\.avsRedeemService) var avsRedeemService

            Scope(state: \.redeemViaAVS, action: \.redeemViaAVS) {
                PharmacyRedeemDomain()
                    .dependency(\.redeemInputValidator, avsMessageValidator)
                    .dependency(\.redeemService, avsRedeemService())
            }

            @Dependency(\.erxTaskOrderValidator) var erxTaskOrderValidator
            @Dependency(\.erxTaskRepositoryRedeemService) var erxTaskRepositoryRedeemService

            Scope(state: \.redeemViaErxTaskRepository, action: \.redeemViaErxTaskRepository) {
                PharmacyRedeemDomain()
                    .dependency(\.redeemInputValidator, erxTaskOrderValidator)
                    .dependency(\.redeemService, erxTaskRepositoryRedeemService())
            }

            Scope(state: \.pharmacy, action: \.pharmacy) {
                PharmacyDetailDomain()
            }

            Scope(state: \.filter, action: \.filter) {
                PharmacySearchFilterDomain()
            }

            Scope(state: \.clusterSheet, action: \.clusterSheet) {
                PharmacySearchClusterDomain()
            }
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        // Search
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        // Map
        case searchWithMap
        case goToUser
        case showClusterSheet([PlaceholderAnnotation])
        case setMapAfterLocationUpdate
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        // Device location
        case requestLocation
        case locationManager(LocationManager.Action)
        // Pharmacy filter
        case showPharmacyFilter

        case destination(PresentationAction<Destination.Action>)
        case resetNavigation
        case response(Response)
        case delegate(Delegate)
        case setAlert(ErpAlertState<Destination.Alert>)

        @CasePathable
        enum Delegate: Equatable {
            case closeMap(location: Location?)
            case close
        }

        @CasePathable
        enum Response: Equatable {
            case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>, CLLocationCoordinate2D)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.locationManager) var locationManager: LocationManager
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.dateProvider) var date: () -> Date

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
        BindingReducer()

        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .searchWithMap:
            // swiftlint:disable closure_parameter_position
            return .run { [
                center = state.mapLocation.region.center,
                filter = state.pharmacyFilterOptions,
                pharmacies = state.pharmacies
            ] send in
            let locationStatus = await locationManager.authorizationStatus()
            if locationStatus == .notDetermined {
                await send(.requestLocation)
            } else if pharmacies.isEmpty {
                guard let action = try? await searchPharmacies(
                    location: Location(rawValue: .init(latitude: center.latitude, longitude: center.longitude)),
                    filter: filter.filter { $0 != .currentLocation }
                ) else {
                    return
                }
                await send(action)
            }
            }
        // swiftlint:enable closure_parameter_position
        case .setMapAfterLocationUpdate:
            guard let currentUserLocation = state.currentUserLocation else { return .none }
            if state.searchAfterAuthorized, !state.showOnlyTextSearchResult {
                state.searchAfterAuthorized = false
                return .run { [filter = state.pharmacyFilterOptions] send in
                    guard let action = try? await searchPharmacies(
                        location: currentUserLocation,
                        filter: filter.filter { $0 != .currentLocation }
                    ) else {
                        return
                    }

                    await send(action)
                }
            } else if state.showOnlyTextSearchResult {
                let centerLocation = state.currentUserLocation ?? calculateCenter(pharmacies: state.pharmacies)

                state.pharmacies = state.pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0.pharmacyLocation,
                        referenceLocation: centerLocation,
                        referenceDate: date(),
                        timeOnlyFormatter: timeOnlyFormatter
                    )
                }

                state.mapLocation = .manual(.init(
                    center: centerLocation.rawValue.coordinate,
                    span: calculateSpan(
                        pharmacies: state.pharmacies,
                        currentLocation: centerLocation.rawValue.coordinate
                    )
                ))
            }
            return .none
        case .goToUser:
            guard let currentUserLocation = state.currentUserLocation else {
                return Effect.send(.requestLocation)
            }
            return .run { [filter = state.pharmacyFilterOptions] send in
                guard let action = try? await searchPharmacies(
                    location: currentUserLocation,
                    filter: filter.filter { $0 != .currentLocation }
                ) else {
                    return
                }

                await send(action)
            }
        case let .showClusterSheet(cluster):
            let pharmacyArray = cluster.map(\.pharmacy)
            state.destination = .clusterSheet(.init(clusterPharmacies: pharmacyArray))
            return .none
        case let .destination(.presented(.clusterSheet(.delegate(.showDetails(viewModel))))):
            state.destination = nil
            state.detailsPharmacy = viewModel
            return .run { send in
                await send(.showDetails(viewModel))
            }
        case .performSearch:
            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            return .run { [center = state.mapLocation.region.center, filter = state.pharmacyFilterOptions] send in
                guard let action = try? await searchPharmacies(
                    location: Location(rawValue: .init(latitude: center.latitude, longitude: center.longitude)),
                    filter: filter.filter { $0 != .currentLocation }
                ) else {
                    return
                }

                await send(action)
            }
        case let .response(.pharmaciesReceived(result, location)):
            switch result {
            case let .success(pharmacies):
                // [REQ:gemSpec_eRp_FdV:A_20285] pharmacy order is resolved on server side
                state.pharmacies = pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0,
                        referenceLocation: Location(rawValue: .init(latitude: location.latitude,
                                                                    longitude: location.longitude)),
                        referenceDate: date(),
                        timeOnlyFormatter: timeOnlyFormatter
                    )
                }
                .filter(by: state.pharmacyFilterOptions.filter { $0 != .currentLocation })

                state.mapLocation = .manual(.init(
                    center: location,
                    span: calculateSpan(
                        pharmacies: state.pharmacies,
                        currentLocation: location
                    )
                ))
            case .failure:
                state.destination = .alert(Self.serverErrorAlertState)
            }
            return .none
        case let .showDetails(viewModel):
            state.detailsPharmacy = viewModel

            state.destination = .pharmacy(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                pharmacyViewModel: viewModel,
                hasRedeemableTasks: !state.selectedPrescriptions.isEmpty,
                onMapView: true,
                pharmacyRedeemState: Shared(nil)
            ))
            return .none
        case .onAppear:
            return
                .merge(
                    .publisher { state.$pharmacyFilterOptions.publisher.map(Action.quickSearch) },
                    .send(.searchWithMap),
                    .run { send in
                        await withTaskCancellation(id: CancelID.locationManager, cancelInFlight: true) {
                            for await action in await locationManager.delegate() {
                                await send(.locationManager(action), animation: .default)
                            }
                        }
                    }
                )
        case .destination(.presented(.pharmacy(.delegate(.close)))):
            state.destination = nil
            return .run { send in
                // swiftlint:disable:next todo
                // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                try await schedulers.main.sleep(for: 0.1)
                await send(.delegate(.close))
            }
        case .destination(.presented(.alert(.performSearch))):
            return Effect.send(.performSearch)
        case .destination(.presented(.alert(.close))):
            state.destination = nil
            return .none
        case .quickSearch:
            return .run { send in
                await send(.performSearch)
            }
        case .destination(.presented(.filter(.delegate(.close)))):
            state.destination = nil
            return .none
        case let .destination(.presented(.pharmacy(.response(.toggleIsFavoriteReceived(.success(pharmacy)))))):
            if let index = state.pharmacies.firstIndex(where: { $0.telematikID == pharmacy.telematikID }) {
                state.pharmacies[index] = pharmacy
            }
            return .none
        case let .destination(.presented(.pharmacy(.delegate(
            .showPharmacyRedeemView(service: service,
                                    option: option,
                                    prescriptions: prescriptions,
                                    selectedPrescriptions: selectedPrescriptions)
        )))):
            guard let pharmacy = state.detailsPharmacy else { return .none }

            // An set of prescriptions that represents the selected prescriptions.
            let setOfPrescriptions: Set<Prescription>
            if let redeemPrescriptions = state.pharmacyRedeemState?.selectedPrescriptions {
                // If the user has already selected prescription from the current redeeming process,
                // these will be used first
                setOfPrescriptions = redeemPrescriptions
            } else if state.inRedeemProcess {
                // If the user has started the redeeming process from the main view, we select these prescriptions.
                setOfPrescriptions = Set(selectedPrescriptions)
            } else {
                // If neither case applies, no prescription is selected.
                setOfPrescriptions = Set()
            }

            let redeemState = PharmacyRedeemDomain.State(
                redeemOption: option,
                prescriptions: Shared(state.pharmacyRedeemState?.prescriptions ?? prescriptions),
                pharmacy: pharmacy.pharmacyLocation,
                selectedPrescriptions: Shared(setOfPrescriptions)
            )
            state.destination = destination(service: service, state: redeemState)
            state.pharmacyRedeemState = nil
            return .none
        case .destination(.presented(.redeemViaErxTaskRepository(.delegate(.closeRedeemView)))),
             .destination(.presented(.redeemViaAVS(.delegate(.closeRedeemView)))):
            guard let viewModel = state.detailsPharmacy else { return .none }

            state.destination = .pharmacy(PharmacyDetailDomain.State(
                prescriptions: Shared([]),
                selectedPrescriptions: state.$selectedPrescriptions,
                inRedeemProcess: state.inRedeemProcess,
                pharmacyViewModel: viewModel,
                hasRedeemableTasks: !state.selectedPrescriptions.isEmpty,
                onMapView: true,
                pharmacyRedeemState: Shared(nil)
            ))
            return .none
        case .destination(.presented(.redeemViaErxTaskRepository(.delegate(.close)))),
             .destination(.presented(.redeemViaAVS(.delegate(.close)))):
            state.destination = nil
            return .run { send in
                // swiftlint:disable:next todo
                // TODO: this is workaround to avoid `onAppear` of the the child view getting called
                try await schedulers.main.sleep(for: 0.1)
                await send(.delegate(.close))
            }
        case let .destination(.presented(.redeemViaAVS(.delegate(.changePharmacy(saveState))))),
             let .destination(.presented(.redeemViaErxTaskRepository(.delegate(.changePharmacy(saveState))))):
            state.destination = nil
            state.pharmacyRedeemState = saveState
            return .none
        // Location
        case .requestLocation:
            state.currentUserLocation = nil
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
        case .locationManager(.didChangeAuthorization(.authorizedAlways)),
             .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
            state.searchAfterAuthorized = true
            return .run { _ in
                await locationManager.requestLocation()
            }
        case .locationManager(.didChangeAuthorization(.notDetermined)):
            state.currentUserLocation = nil
            return .none
        case .locationManager(.didChangeAuthorization(.denied)),
             .locationManager(.didChangeAuthorization(.restricted)):
            state.currentUserLocation = nil
            state.destination = .alert(Self.locationPermissionAlertState)
            return .none
        case let .locationManager(.didUpdateLocations(locations)):
            state.currentUserLocation = locations.first
            return .run(operation: { send in
                await send(.setMapAfterLocationUpdate)
                await locationManager.stopUpdatingLocation()
            })
        case .showPharmacyFilter:
            state.destination = .filter(.init(
                pharmacyFilterOptions: state.$pharmacyFilterOptions,
                pharmacyFilterShow: [.open, .delivery, .shipment]
            ))
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .setAlert(alert):
            state.destination = .alert(alert)
            return .none
        case .destination(.presented(.alert(.openAppSpecificSettings))):
            openSettings()
            return .none
        case .destination, .locationManager, .delegate, .binding:
            return .none
        }
    }
}

extension PharmacySearchMapDomain {
    static var locationPermissionAlertState: ErpAlertState<Destination.Alert> = {
        .init(
            title: L10n.phaSearchTxtLocationAlertTitle,
            actions: {
                ButtonState(role: .cancel, action: .close) {
                    .init(L10n.alertBtnOk)
                }
                ButtonState(action: .openAppSpecificSettings) {
                    .init(L10n.stgTxtTitle)
                }
            },
            message: L10n.phaSearchTxtLocationAlertMessage
        )
    }()

    static var serverErrorAlertState: ErpAlertState<Destination.Alert> = {
        .init(
            title: L10n.phaSearchTxtErrorNoServerResponseHeadline,
            actions: {
                ButtonState(role: .cancel, action: .close) {
                    .init(L10n.phaSearchMapBtnErrorCancel)
                }
                ButtonState(action: .performSearch) {
                    .init(L10n.phaSearchBtnErrorNoServerResponse)
                }
            },
            message: L10n.phaSearchTxtErrorNoServerResponseSubheadline
        )
    }()

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            resourceHandler.open(url)
        }
    }

    func searchPharmacies(
        location: ComposableCoreLocation.Location,
        filter: [PharmacySearchFilterDomain.PharmacyFilterOption]
    ) async throws -> PharmacySearchMapDomain.Action {
        let position = Position(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        return try await pharmacyRepository.searchRemote(
            searchTerm: "",
            position: position,
            filter: filter.asPharmacyRepositoryFilters
        )
        .first()
        .catchToPublisher()
        .map { .response(.pharmaciesReceived($0, location.coordinate)) }
        .receive(on: schedulers.main.animation())
        .eraseToAnyPublisher()
        .async()
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

    func destination(service: RedeemServiceOption, state: PharmacyRedeemDomain.State) -> PharmacySearchMapDomain
        .Destination.State? {
        switch service {
        case .avs:
            return .redeemViaAVS(state)
        case .erxTaskRepository, .erxTaskRepositoryAvailable:
            return .redeemViaErxTaskRepository(state)
        case .noService:
            return nil
        }
    }
}

extension MKCoordinateRegion: Equatable {
    public static func ==(lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }

    public static let gematikHQRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.52291, longitude: 13.38757),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == lhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == lhs.longitudeDelta
    }
}

// swiftlint:enable type_body_length
