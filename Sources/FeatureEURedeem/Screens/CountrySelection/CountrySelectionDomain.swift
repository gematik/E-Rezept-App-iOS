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

import ComposableArchitecture
import ComposableCoreLocation
import eRpKit
import eRpResources
import FeatureHelpers
import Pharmacy

/// Domain for country selection in EU prescription redemption
@Reducer
public struct CountrySelectionDomain {
    enum CancelID: Int {
        case locationManager
    }

    enum CurrentRegion {
        case germany
        case europeanUnion(countryName: String)
        case international(countryName: String)

        var locationSearchEmpty: String {
            switch self {
            case .germany:
                return L10n.euredeemCountrySelectionTxtLocationEmptyGermany.text
            case let .europeanUnion(countryName: name):
                return L10n.euredeemCountrySelectionTxtLocationEmptyEu(name, name).text
            case let .international(countryName: name):
                return L10n.euredeemCountrySelectionTxtLocationEmptyInternational(name, name).text
            }
        }
    }

    /// State for country selection
    @ObservableState
    public struct State: Equatable {
        /// Available countries for selection
        public var countries: [Country] = []
        /// Currently selected country
        public var selectedCountry: Country?
        /// Search for countries in list
        public var searchText: String = ""
        /// Current device country code  location when determined by Core-Location
        public var isoCountryCode: String?
        /// Destination for navigation and modals
        @Presents public var destination: Destination.State?

        var filteredCountries: [Country] = []
        var locationFilterIsEnabled: Bool = false

        var isCountryLoading: Bool = true

        var currentRegion: CurrentRegion? {
            if isoCountryCode == "DE" {
                return .germany
            }
            if let isoCountryCode, Country.europeanCountryCodes.contains(isoCountryCode),
               let name = Locale.current.localizedString(forRegionCode: isoCountryCode) {
                return .europeanUnion(countryName: name)
            }
            if let isoCountryCode, let name = Locale.current.localizedString(forRegionCode: isoCountryCode) {
                return .international(countryName: name)
            }
            return nil
        }

        public init(
            countries: [Country] = [],
            selectedCountry: Country? = nil
        ) {
            self.countries = countries
            self.selectedCountry = selectedCountry
        }
    }

    /// Actions for country selection
    public enum Action: Equatable, BindableAction {
        case task

        case loadAllCountries
        /// Select a specific country
        case selectCountry(Country)
        /// Toggle location search on/off
        case toggleLocation
        case locationManager(LocationManager.Action)

        case setAlert(ErpAlertState<Destination.Alert>)

        case binding(BindingAction<State>)
        case response(Response)
        case destination(PresentationAction<Destination.Action>)
    }

    /// Navigation and modal destinations
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = alert
        /// alert destination
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        public enum Alert: Equatable {
            case openAppSpecificSettings
            case close
        }
    }

    public enum Response: Equatable {
        case countriesReceived(Result<[Country], PharmacyRepositoryError>)
        case isoCountryCodeReceived(String?)
    }

    /// Initialize the domain
    public init() {}

    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository
    @Dependency(\.locationManager) var locationManager: LocationManager

    /// Reducers
    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
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
        case .loadAllCountries:
            return .run { send in
                do {
                    let response = try await pharmacyRepository.fetchEuCountries()
                    await send(.response(.countriesReceived(.success(response))))
                } catch let error as PharmacyRepositoryError {
                    await send(.response(.countriesReceived((.failure(error)))))
                }
            }
        case let .response(.countriesReceived(result)):
            switch result {
            case let .success(countries):
                state.countries = countries
                state.filteredCountries = countries
                state.isCountryLoading = false
                return .none
            case let .failure(error):
                state.destination = .alert(ErpAlertState(for: error))
                return .none
            }
        case let .response(.isoCountryCodeReceived(countryCode)):
            state.isoCountryCode = countryCode
            state.filteredCountries = state.countries.filter {
                $0.countryCode == state.isoCountryCode
            }
            return .none
        case let .selectCountry(country):
            state.selectedCountry = country
            return .none
        case .binding(\.searchText):
            if state.searchText.lengthOfBytes(using: .utf8) == 0 {
                state.locationFilterIsEnabled = false
                state.filteredCountries = state.countries
            } else {
                state.filteredCountries = state.countries.filter {
                    let name = $0.displayName ?? $0.name
                    return name.contains(state.searchText)
                }
            }
            return .none
        case .toggleLocation:
            state.locationFilterIsEnabled.toggle()
            guard state.locationFilterIsEnabled else {
                state.filteredCountries = state.countries
                return .none
            }

            state.isoCountryCode = nil
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
            return .run { _ in
                await locationManager.requestLocation()
            }
        case .locationManager(.didChangeAuthorization(.notDetermined)):
            state.isoCountryCode = nil
            return .none
        case .locationManager(.didChangeAuthorization(.denied)),
             .locationManager(.didChangeAuthorization(.restricted)):
            state.isoCountryCode = nil
            state.destination = .alert(Self.locationPermissionAlertState)
            return .none
        case let .locationManager(.didUpdateLocations(locations)):
            guard let location = locations.first
            else { return .none }

            return .run { send in
                await locationManager.stopUpdatingLocation()
                await send(isoCountryCode(location))
            }
        case let .setAlert(alert):
            state.destination = .alert(alert)
            return .none
        case .locationManager:
            return .none
        case .binding,
             .destination:
            return .none
        }
    }
}

extension CountrySelectionDomain {
    func isoCountryCode(
        _ location: Location,
        geoCoder: CLGeocoder = CLGeocoder()
    ) async -> CountrySelectionDomain.Action {
        let geoLocation = try? await geoCoder.reverseGeocodeLocation(
            CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        )
        return .response(.isoCountryCodeReceived(geoLocation?.first?.isoCountryCode))
    }

    static var locationPermissionAlertState: ErpAlertState<Destination.Alert> = .init(
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
}

extension Country {
    var displayName: String? {
        guard let countryCode else { return nil }
        return Locale.current.localizedString(forRegionCode: countryCode)
    }
}

extension CountrySelectionDomain.Destination.State: Equatable {}
extension CountrySelectionDomain.Destination.Action: Equatable {}
