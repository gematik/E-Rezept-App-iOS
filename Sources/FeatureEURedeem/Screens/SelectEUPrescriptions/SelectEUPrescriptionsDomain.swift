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

/// Domain for selecting EU prescriptions for redemption
@Reducer
public struct SelectEUPrescriptionsDomain {
    /// State for prescription selection
    @ObservableState
    public struct State: Equatable {
        /// Available prescriptions for selection
        public var prescriptions = [EUPrescription]()
        /// Patient name
        public var patientName = ""
        /// Whether select all is enabled
        public var selectAllEnabled = false

        public init(
            prescriptions: [EUPrescription] = SelectEUPrescriptionsDomain.Dummies.prescriptions,
            patientName: String = "",
            selectAllEnabled: Bool = false
        ) {
            self.prescriptions = prescriptions
            self.patientName = patientName
            self.selectAllEnabled = selectAllEnabled
        }
    }

    /// Actions for prescription selection
    public enum Action: Equatable {
        /// Toggle selection of a specific prescription
        case togglePrescription(EUPrescription)
        /// Toggle select all prescriptions
        case toggleSelectAll
        /// Update the select all state
        case updateSelectAllState
        /// Delegate actions to parent
        case delegate(Delegate)

        /// Delegate actions
        public enum Delegate: Equatable {
            /// Selected prescriptions changed
            case didSelectPrescriptions([EUPrescription])
        }
    }

    /// Initialize the domain
    public init() {}

    /// Reducer function
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .togglePrescription(prescription):
            if let index = state.prescriptions.firstIndex(where: { $0.id == prescription.id }) {
                // Only allow toggling if the prescription is redeemable in EU
                if state.prescriptions[index].isRedeemableInEU {
                    state.prescriptions[index].isSelected.toggle()
                    return .send(.updateSelectAllState)
                }
            }
            return .none

        case .toggleSelectAll:
            let newSelectAllState = !state.selectAllEnabled
            state.selectAllEnabled = newSelectAllState

            // Update all redeemable prescriptions to match the new selectAll state
            for index in state.prescriptions.indices where state.prescriptions[index].isRedeemableInEU {
                state.prescriptions[index].isSelected = newSelectAllState
            }

            return .none

        case .updateSelectAllState:
            let redeemablePrescriptions = state.prescriptions.filter(\.isRedeemableInEU)
            let selectedRedeemablePrescriptions = redeemablePrescriptions.filter(\.isSelected)

            // "Select All" is enabled only if all redeemable prescriptions are selected
            state.selectAllEnabled = !redeemablePrescriptions.isEmpty &&
                selectedRedeemablePrescriptions.count == redeemablePrescriptions.count

            return .send(.delegate(.didSelectPrescriptions(
                state.prescriptions.filter(\.isSelected)
            )))
        case .delegate:
            return .none
        }
    }
}

// MARK: - Dummies

extension SelectEUPrescriptionsDomain {
    /// Mock data for testing and previews
    public enum Dummies {
        /// Sample prescriptions for testing
        public static let prescriptions: [EUPrescription] = [
            EUPrescription(
                id: "1",
                name: "Acaimoum",
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180),
                isRedeemableInEU: true,
                isSelected: true
            ),
            EUPrescription(
                id: "2",
                name: "Acaimoum",
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180),
                isRedeemableInEU: true
            ),
            EUPrescription(
                id: "3",
                name: "Acaimoum",
                isRedeemableInEU: false,
                notRedeemableReason: "Nicht im EU Ausland einlösbar"
            ),
            EUPrescription(
                id: "4",
                name: "MeinMedikament",
                isRedeemableInEU: false,
                notRedeemableReason: "Freitextverordnungen können nicht im Ausland eingelöst werden"
            ),
            EUPrescription(
                id: "5",
                name: "Wirkstoff Ibu",
                isRedeemableInEU: false,
                notRedeemableReason: "Wirkstoffverordnungen können nicht im Ausland eingelöst werden"
            ),
            EUPrescription(
                id: "6",
                name: "Medikament 2",
                isRedeemableInEU: false,
                notRedeemableReason: "Gescannte Rezepte können nicht im Ausland eingelöst werden"
            ),
            EUPrescription(
                id: "7",
                name: "Benzos",
                isRedeemableInEU: false,
                notRedeemableReason: "Betäubungsmittel können nicht im Ausland eingelöst werden"
            ),
        ]

        /// Sample state for testing
        static let state = State(
            prescriptions: prescriptions,
            patientName: "Ada Muster",
            selectAllEnabled: false
        )

        /// Sample store for testing
        static let store = Store(initialState: state) {
            SelectEUPrescriptionsDomain()
        }
    }
}
