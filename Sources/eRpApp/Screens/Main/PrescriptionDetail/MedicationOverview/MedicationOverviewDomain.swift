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

import Combine
import ComposableArchitecture
import Dependencies
import eRpKit
import SwiftUI

@Reducer
struct MedicationOverviewDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail_medication
        case medication(MedicationDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_epaMedication
        case epaMedication(EpaMedicationDomain)
    }

    @ObservableState
    struct State: Equatable {
        let subscribed: ErxMedication
        let dispensed: [ErxMedicationDispense]
        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case showSubscribedMedication
        case showDispensedMedication(ErxMedicationDispense)
        case resetNavigation
    }

    @Dependency(\.uiDateFormatter) var uiDateFormatter

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showSubscribedMedication:
                let medicationState = MedicationDomain.State(subscribed: state.subscribed)
                state.destination = .medication(medicationState)
                return .none
            case let .showDispensedMedication(medicationDispense):
                if medicationDispense.medication != nil {
                    // `MedicationDispenses` of gem Workflows of FHIR versions < 1.4
                    //  use the KBV profiled `Medication` resources
                    let medicationState = MedicationDomain.State(
                        dispensed: medicationDispense,
                        dateFormatter: uiDateFormatter
                    )
                    state.destination = .medication(medicationState)
                } else {
                    // `MedicationDispenses` of gem Workflows of FHIR versions >= 1.4
                    //  use the gematik profiled (EPA)-`Medication` resources
                    let epaMedicationState = EpaMedicationDomain.State(
                        dispensed: medicationDispense,
                        dateFormatter: uiDateFormatter
                    )
                    state.destination = .epaMedication(epaMedicationState)
                }
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ErxMedicationDispense {
    enum Dummies {
        static let epaMedicationDispenseRezeptur = ErxMedicationDispense(
            identifier: "unique id",
            taskId: "task_id",
            insuranceId: "patient_kvnr_id",
            dosageInstruction: "Nach dem Essen einnehmen!",
            telematikId: "telematik_id",
            whenHandedOver: "2021-07-23T10:55:04+02:00",
            quantity: .init(value: "10", unit: "TL"),
            noteText: "Nicht mit anderen Medikamenten mischen",
            medication: nil,
            epaMedication: ErxEpaMedication.Dummies.medicinalProductPackage,
            diGaDispense: nil
        )

        static let epaMedicationDispenseKombipackung = ErxMedicationDispense(
            identifier: "unique id",
            taskId: "task_id",
            insuranceId: "patient_kvnr_id",
            dosageInstruction: "Nach dem Essen einnehmen!",
            telematikId: "telematik_id",
            whenHandedOver: "2021-07-23T10:55:04+02:00",
            quantity: .init(value: "10", unit: "TL"),
            noteText: "Nicht mit anderen Medikamenten mischen",
            medication: nil,
            epaMedication: ErxEpaMedication.Dummies.extemporaneousPreparation,
            diGaDispense: nil
        )
    }
}
