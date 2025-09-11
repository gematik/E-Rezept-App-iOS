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
import Foundation

// MARK: - EURedeemSelectionDomain

/// Domain for EU prescription redemption selection screen
@Reducer
public struct EURedeemSelectionDomain {
    /// State for EU redemption selection
    @ObservableState
    public struct State: Equatable {
        /// Available prescriptions for redemption
        public var prescriptions: [EUPrescription] = []
        /// Currently selected prescriptions
        public var selectedPrescriptions: [EUPrescription] = []
        /// Currently selected country
        public var selectedCountry: Country?
        /// Destination for navigation and modals
        @Presents public var destination: Destination.State? = .consent(.init())
        /// Consent status - true = accepted, false = declined, nil = not decided
        public var consentGiven: Bool?

        public init(
            prescriptions: [EUPrescription] = [],
            selectedPrescriptions: [EUPrescription] = [],
            selectedCountry: Country? = nil,
            consentGiven: Bool? = nil
        ) {
            self.prescriptions = prescriptions
            self.selectedPrescriptions = selectedPrescriptions
            self.selectedCountry = selectedCountry
            self.consentGiven = consentGiven
        }
    }

    /// Actions for EU redemption selection
    public enum Action: Equatable {
        /// Select country button was tapped
        case selectCountryButtonTapped
        /// Select prescriptions button was tapped
        case selectPrescriptionsButtonTapped
        /// Select instruction button was tapped
        case selectInstructionButtonTapped
        /// Redeem button was tapped
        case redeemButtonTapped
        /// Set the selected prescriptions
        case setSelectedPrescriptions([EUPrescription])
        /// Destination actions
        case destination(PresentationAction<Destination.Action>)
    }

    /// Navigation and modal destinations
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        /// Consent screen
        case consent(ConsentDomain)
        /// SelectEUPrescription screen
        case selectPrescription(SelectEUPrescriptionsDomain)
        /// CountrySelection screen
        case selectCountry(CountrySelectionDomain)
    }

    /// Initialize the domain
    public init() {}

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .selectCountryButtonTapped:
            return .none

        case .selectPrescriptionsButtonTapped:
            state
                .destination = .selectPrescription(.init(
                    prescriptions: state.prescriptions,
                    patientName: "Profile 1",
                    selectAllEnabled: false
                ))
            return .none
        case .selectInstructionButtonTapped:
            state.destination = .selectCountry(.init(countries: [], selectedCountry: state.selectedCountry))
            return .none
        case .redeemButtonTapped:
            // show introduction view
            return .none
        case let .setSelectedPrescriptions(selectedPrescriptions):
            state.selectedPrescriptions = selectedPrescriptions
            return .none
        case let .destination(.presented(.consent(.delegate(action)))):
            switch action {
            case .consentAccepted:
                state.consentGiven = true
            case .consentDeclined:
                state.consentGiven = false
            case .consentCancelled,
                 .backTapped:
                break
            }
            state.destination = nil
            return .none

        case .destination:
            return .none
        }
    }
}

// MARK: - Dummies

extension EURedeemSelectionDomain {
    /// Mock data for testing and previews
    enum Dummies {
        /// Sample prescriptions for testing
        static let prescriptions: [EUPrescription] = [
            EUPrescription(
                id: "1",
                name: "Ibuprofen 600",
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180),
                isRedeemableInEU: true
            ),
            EUPrescription(
                id: "2",
                name: "Acnatac Lösung 3mg/g",
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180),
                isRedeemableInEU: true
            ),
        ]

        /// Sample selected prescriptions for testing
        static let selectedPrescriptions: [EUPrescription] = [
            prescriptions[0],
        ]

        /// Sample countries for testing
        static let countries = [
            Country(id: "DE", name: "Deutschland"),
            Country(id: "ES", name: "Spanien"),
            Country(id: "FR", name: "Frankreich"),
        ]

        /// Sample state for testing
        static let state = EURedeemSelectionDomain.State(
            prescriptions: prescriptions,
            selectedPrescriptions: selectedPrescriptions,
            selectedCountry: countries[1]
        )

        /// Sample store for testing
        static let store = Store(initialState: state) {
            EURedeemSelectionDomain()
        }
    }
}
