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
import eRpKit
import Pharmacy

/// Domain for country selection in EU prescription redemption
@Reducer
public struct CountrySelectionDomain {
    /// State for country selection
    @ObservableState
    public struct State: Equatable {
        /// Available countries for selection
        public var countries: [Country] = []
        /// Currently selected country
        public var selectedCountry: Country?
        /// Search for countries in list
        public var searchText: String = ""

        public init(
            countries: [Country],
            selectedCountry: Country? = nil
        ) {
            self.countries = countries
            self.selectedCountry = selectedCountry
        }
    }

    /// Actions for country selection
    public enum Action: Equatable, BindableAction {
        case loadAllCountries
        /// Select a specific country
        case selectCountry(Country)
        /// Serach for a specific country in result list
        case serachList
        /// Toggle location search on/off
        case toggleLocation

        case recievedCountriesResult(Result<[Country], PharmacyRepositoryError>)

        case binding(BindingAction<State>)
    }

    /// Initialize the domain
    public init() {}
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository

    /// Reducers
    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(self.core)
    }

    /// Core Reducer function
    public func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadAllCountries:
            return .run { send in
                do {
                    let response = try await pharmacyRepository.fetchEuCountries()
                    await send(.recievedCountriesResult(.success(response)))
                } catch let error as PharmacyRepositoryError {
                    await send(.recievedCountriesResult(.failure(error)))
                }
            }
        case let .recievedCountriesResult(result):
            switch result {
            case let .success(countries):
                state.countries = countries
                return .none
            case .failure:
                return .none
            }
        case let .selectCountry(country):
            state.selectedCountry = country
            return .none
        case .serachList:
            return .none
        case .toggleLocation:
            return .none
        case .binding:
            return .none
        }
    }
}
