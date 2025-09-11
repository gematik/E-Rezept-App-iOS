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
    }

    /// Actions for country selection
    public enum Action: Equatable {
        /// Select a specific country
        case selectCountry(Country)
    }

    /// Initialize the domain
    public init() {}

    /// Reducer function
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .selectCountry(country):
            state.selectedCountry = country
            return .none
        }
    }
}
