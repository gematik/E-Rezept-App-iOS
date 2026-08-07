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
import eRpKit
import SwiftUI

@Reducer
struct PharmacyPrescriptionSelectionDomain {
    @ObservableState
    struct State: Equatable {
        @Shared var prescriptions: [Prescription]
        @Shared var selectedPrescriptions: [Prescription]
        var selectedOption: RedeemOption?

        // copy to enable discarding the changes
        var selectedPrescriptionsCopy: [Prescription]
        @Shared(.selectedProfileId) var profileId
        var profile: Profile?

        init(
            prescriptions: Shared<[Prescription]>,
            selectedPrescriptions: Shared<[Prescription]>,
            profile: Profile? = nil,
            selectedOption: RedeemOption?
        ) {
            _prescriptions = prescriptions
            _selectedPrescriptions = selectedPrescriptions
            selectedPrescriptionsCopy = selectedPrescriptions.wrappedValue
            self.profile = profile
            self.selectedOption = selectedOption
        }

        var allPrescriptionsSelected: Bool {
            prescriptions.allSatisfy { prescription in
                selectedPrescriptionsCopy.contains { $0.id == prescription.id }
            }
        }
    }

    enum Action: Equatable {
        case didSelect(String)
        case selectAllPrescriptionsButtonTapped
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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateRedeemablePrescriptions:
                return .publisher(
                    prescriptionRepository.loadLocal(for: state.profileId)
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
            case .selectAllPrescriptionsButtonTapped:
                if state.allPrescriptionsSelected {
                    // Deselect all selected prescriptions
                    state.selectedPrescriptionsCopy.removeAll()
                } else {
                    // Add prescriptions to selection that are not already selected
                    let prescriptionsToSelect = state.prescriptions.filter { prescription in
                        !state.selectedPrescriptionsCopy.contains { $0.id == prescription.id }
                    }
                    state.selectedPrescriptionsCopy.append(contentsOf: prescriptionsToSelect)
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
}

extension PharmacyPrescriptionSelectionDomain {
    enum Dummies {
        static let state = State(
            prescriptions: Shared(value: [Prescription.Dummies.prescriptionReady]),
            selectedPrescriptions: Shared(value: []),
            profile: Profile(name: "Marta Maquise"),
            selectedOption: nil
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
