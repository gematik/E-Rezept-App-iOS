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
        @Shared var prescriptions: [Prescription]
        @Shared var selectedPrescriptions: [Prescription]

        // copy to enable discarding the changes
        var selectedPrescriptionsCopy: [Prescription]
        var profile: Profile?

        init(
            prescriptions: Shared<[Prescription]>,
            selectedPrescriptions: Shared<[Prescription]>,
            profile: Profile? = nil
        ) {
            _prescriptions = prescriptions
            _selectedPrescriptions = selectedPrescriptions
            selectedPrescriptionsCopy = selectedPrescriptions.wrappedValue
            self.profile = profile
        }
    }

    enum Action: Equatable {
        case didSelect(String)
        case saveSelection([Prescription])
        case updateRedeemablePrescriptions

        /// Internal actions
        case response(Response)

        enum Response: Equatable {
            /// response of `updateRedeemablePrescriptions`
            case loadLocalPrescriptionsReceived(Result<[Prescription], PrescriptionRepositoryError>)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.prescriptionRepository) var prescriptionRepository: PrescriptionRepository
    @Dependency(\.schedulers) var schedulers

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .updateRedeemablePrescriptions:
            return .publisher(
                prescriptionRepository.loadLocal()
                    .first()
                    .receive(on: schedulers.main.animation())
                    .catchToPublisher()
                    .map { Action.response(.loadLocalPrescriptionsReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .didSelect(taskID):
            if let prescriptions = state.prescriptions.first(where: { $0.id == taskID }) {
                if let index = state.selectedPrescriptionsCopy.firstIndex(where: { $0.id == taskID }) {
                    state.selectedPrescriptionsCopy.remove(at: index)
                } else {
                    state.selectedPrescriptionsCopy.append(prescriptions)
                }
            }
            return .none
        case let .response(.loadLocalPrescriptionsReceived(.success(prescriptions))):
            state.$prescriptions.withLock { $0 = prescriptions.filter(\.isPharmacyRedeemable) }
            return .none
        case .response(.loadLocalPrescriptionsReceived(.failure)):
            return .none
        case let .saveSelection(prescriptions):
            state.$selectedPrescriptions.withLock { $0 = prescriptions }
            return .run { _ in
                await dismiss()
            }
        }
    }
}

extension PharmacyPrescriptionSelectionDomain {
    enum Dummies {
        static let state = State(
            prescriptions: Shared(value: [Prescription.Dummies.prescriptionReady]),
            selectedPrescriptions: Shared(value: [])
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
