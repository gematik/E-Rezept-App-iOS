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
// swiftlint:disable type_body_length
struct PharmacySearchMapDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        /// A storage for the prescriptions hat have been selected to be redeemed
        var erxTasks: [ErxTask]
        /// Stores the current device location when determined by Core-Location
        var currentUserLocation: Location?
        /// Map-Location for MapView with the standard value if location is not active
        var mapLocation: MKCoordinateRegionContainer
        /// Store for the remote search result
        var pharmacies: [PharmacyLocationViewModel] = []
        /// Store for the active filter options the user has chosen
        var pharmacyFilterOptions: [PharmacySearchFilterDomain.PharmacyFilterOption] = []

        @PresentationState var destination: Destinations.State?

        var selectedPharmacy: PharmacyLocation?

        var pharmacyRedeemState: PharmacyRedeemDomain.State?

        var searchAfterAuthorized = false
    }

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
                case openAppSpecificSettings
                case performSearch
                case close
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

    enum Action: Equatable {
        case onAppear
        // Search
        case performSearch
        case quickSearch(filters: [PharmacySearchFilterDomain.PharmacyFilterOption])
        // Map
        case searchWithMap
        case setCurrentLocation(MKCoordinateRegionContainer)
        case goToUser
        case showCluster(MKClusterAnnotation)
        case setMapAfterLocationUpdate
        // Pharmacy details
        case showDetails(PharmacyLocationViewModel)
        // Device location
        case requestLocation
        case locationManager(LocationManager.Action)

        case destination(PresentationAction<Destinations.Action>)
        case setNavigation(tag: Destinations.State.Tag?)
        case response(Response)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case closeMap
            case close
        }

        enum Response: Equatable {
            case pharmaciesReceived(Result<[PharmacyLocation], PharmacyRepositoryError>, CLLocationCoordinate2D)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.locationManager) var locationManager: LocationManager
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

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
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .searchWithMap:
            let locationStatus = locationManager.authorizationStatus()
            if locationStatus == .notDetermined {
                return Effect.send(.requestLocation)
            } else {
                return searchPharmacies(
                    location: Location(rawValue: .init(latitude: state.mapLocation.region.center.latitude,
                                                       longitude: state.mapLocation.region.center.longitude)),
                    filter: state.pharmacyFilterOptions
                )
            }
        case .setMapAfterLocationUpdate:
            guard let currentUserLocation = state.currentUserLocation else { return .none }
            if state.searchAfterAuthorized {
                state.searchAfterAuthorized = false
                return searchPharmacies(
                    location: currentUserLocation,
                    filter: state.pharmacyFilterOptions
                )
            }
            return .none
        case let .setCurrentLocation(newLocation):
            state.mapLocation = newLocation
            return .none
        case .goToUser:
            guard let currentUserLocation = state.currentUserLocation else {
                return Effect.send(.requestLocation)
            }
            return searchPharmacies(
                location: currentUserLocation,
                filter: state.pharmacyFilterOptions
            )
        case let .showCluster(cluster):
            state.mapLocation = .manual(
                .init(center: cluster.coordinate,
                      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            )
            return .none
        case .performSearch:
            // [REQ:gemSpec_eRp_FdV:A_20183] search results mirrored verbatim, no sorting, no highlighting
            return searchPharmacies(
                location: Location(rawValue: .init(latitude: state.mapLocation.region.center.latitude,
                                                   longitude: state.mapLocation.region.center.longitude)),
                filter: state.pharmacyFilterOptions
            )
        case let .response(.pharmaciesReceived(result, location)):
            switch result {
            case let .success(pharmacies):
                // [REQ:gemSpec_eRp_FdV:A_20285] pharmacy order is resolved on server side
                state.pharmacies = pharmacies.map {
                    PharmacyLocationViewModel(
                        pharmacy: $0,
                        referenceLocation: Location(rawValue: .init(latitude: location.latitude,
                                                                    longitude: location.longitude)),
                        referenceDate: referenceDateForOpenHours,
                        timeOnlyFormatter: timeOnlyFormatter
                    )
                }
                .filter(by: state.pharmacyFilterOptions)

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
            state.destination = .pharmacy(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: viewModel,
                pharmacyRedeemState: state.pharmacyRedeemState
            ))
            return .none
        case .onAppear:
            return .merge(
                locationManager
                    .delegate()
                    .map(PharmacySearchMapDomain.Action.locationManager),
                Effect.send(.searchWithMap)
            )
        case let .destination(.presented(.pharmacyDetailView(action: .delegate(action)))):
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
        case .destination(.presented(.alert(.performSearch))):
            return Effect.send(.performSearch)
        case .destination(.presented(.alert(.close))):
            state.destination = nil
            return .none
        case let .quickSearch(filterOptions):
            state.pharmacyFilterOptions = filterOptions
            let locationStatus = locationManager.authorizationStatus()
            // [REQ:gemSpec_eRp_APOVZD:A_21154] If user defined filters contain location element, ask for permission
            if filterOptions.contains(.currentLocation),
               !(locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse) {
                return .send(.requestLocation)
                    .animation()
            }
            return .send(.performSearch)
                .animation()
        case .destination(.presented(.pharmacyFilterView(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.pharmacyFilterView(.toggleFilter))):
            if let filterState = (/PharmacySearchMapDomain.Destinations.State.filter).extract(from: state.destination) {
                return .run { send in
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.quickSearch(filters: filterState.pharmacyFilterOptions))
                }
                .animation()
            }
            return .none
        // Location
        case .requestLocation:
            switch locationManager.authorizationStatus() {
            case .authorizedAlways,
                 .authorizedWhenInUse:
                return locationManager.startUpdatingLocation().fireAndForget()
            case .notDetermined:
                state.currentUserLocation = nil
                return locationManager.requestWhenInUseAuthorization().fireAndForget()
            case .restricted, .denied:
                state.currentUserLocation = nil
                state.destination = .alert(Self.locationPermissionAlertState)
                return .none
            @unknown default:
                return .none
            }
        case .locationManager(.didChangeAuthorization(.authorizedAlways)),
             .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
            state.searchAfterAuthorized = true
            return locationManager.startUpdatingLocation().fireAndForget()
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
            return .merge(
                EffectTask.send(.setMapAfterLocationUpdate),
                locationManager.stopUpdatingLocation().fireAndForget()
            )
        case let .setNavigation(tag: tag):
            switch tag {
            case .filter:
                state.destination = .filter(.init(pharmacyFilterOptions: state.pharmacyFilterOptions,
                                                  pharmacyFilterShow: [.open, .delivery, .shipment]))
            case .pharmacy, .alert:
                break
            case .none:
                state.destination = nil
            }
            return .none
        case .destination(.presented(.alert(.openAppSpecificSettings))):
            openSettings()
            return .none
        case .destination, .locationManager, .delegate:
            return .none
        }
    }
}

extension PharmacySearchMapDomain {
    static var locationPermissionAlertState: ErpAlertState<Destinations.Action.Alert> = {
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

    static var serverErrorAlertState: ErpAlertState<Destinations.Action.Alert> = {
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
    )
        -> EffectTask<PharmacySearchMapDomain.Action> {
        var position = Position(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        return .publisher(
            pharmacyRepository.searchRemote(
                searchTerm: "",
                position: position,
                filter: filter.asPharmacyRepositoryFilters
            )
            .first()
            .catchToPublisher()
            .map { .response(.pharmaciesReceived($0, location.coordinate)) }
            .receive(on: schedulers.main.animation())
            .eraseToAnyPublisher
        )
    }

    func calculateSpan(pharmacies: [PharmacyLocationViewModel],
                       currentLocation: CLLocationCoordinate2D) -> MKCoordinateSpan {
        if let seventhLocation = pharmacies.count >= 7 ? pharmacies[7].position?.coordinate : pharmacies.last?.position?
            .coordinate {
            return MKCoordinateSpan(
                latitudeDelta: 2 * abs(currentLocation.latitude - seventhLocation.latitude),
                longitudeDelta: 2 * abs(currentLocation.longitude - seventhLocation.longitude)
            )
        }
        return MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
