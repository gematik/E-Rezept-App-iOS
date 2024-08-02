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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

@Reducer
struct PharmacyPrescriptionSelectionDomain {
    @ObservableState
    struct State: Equatable {
        var prescriptions: [Prescription]
        var selectedPrescriptions: Set<Prescription> = []
        var profile: Profile?
    }

    enum Action: Equatable {
        case didSelect(String)
        case saveSelection(Set<Prescription>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .didSelect(taskID):
            if let prescriptions = state.prescriptions.first(where: { $0.id == taskID }) {
                if state.selectedPrescriptions.contains(prescriptions) {
                    state.selectedPrescriptions.remove(prescriptions)
                } else {
                    state.selectedPrescriptions.insert(prescriptions)
                }
            }
            return .none
        case .saveSelection:
            return .none
        }
    }
}

extension PharmacyPrescriptionSelectionDomain {
    enum Dummies {
        static let state = State(
            prescriptions: [Prescription.Dummies.prescriptionReady]
        )

        static let store = Store(
            initialState: state
        ) {
            PharmacyPrescriptionSelectionDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<PharmacyPrescriptionSelectionDomain> {
            Store(
                initialState: state
            ) {
                PharmacyPrescriptionSelectionDomain()
            }
        }
    }
}
