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
import ErxTaskRepository
import FeatureHelpers
import Foundation
import Profiles

/// Domain for selecting EU prescriptions for redemption
@Reducer
public struct SelectEUPrescriptionsDomain {
    /// State for prescription selection
    @ObservableState
    public struct State: Equatable {
        /// Available prescriptions for selection
        @Shared public var prescriptions: [EUPrescription]
        /// Profile
        public var profile: Profile?

        @Shared(.selectedProfileId) var profileId

        @Presents public var destination: Destination.State?

        public init(
            prescriptions: Shared<[EUPrescription]> = Shared(value: []),
            profile: Profile? = nil
        ) {
            _prescriptions = prescriptions
            self.profile = profile
        }
    }

    /// Actions for prescription selection
    public enum Action: Equatable {
        /// Loading patient and prescription data
        case task
        /// Toggle selection of a specific prescription
        case togglePrescription(EUPrescription)
        case response(Response)
        case destination(PresentationAction<Destination.Action>)

        public enum Response: Equatable {
            case prescriptionReceived(Result<[EUPrescription], ErxRepositoryError>)
            case profileReceived(Result<Profile?, LocalStoreError>)
            case markedPrescriptionReceived(Result<ErxTask?, ErxRepositoryError>)
        }
    }

    /// Initialize the domain
    public init() {}

    /// Navigation and modal destinations
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = alert
        /// alert destination
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        /// all alert screens
        public enum Alert: Equatable {}
    }

    @Dependency(\.euRedeemService) var euRedeemService: EuRedeemService
    @Dependency(\.profilesStore) var profileStore: ProfilesStore
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .run { [profileId = state.profileId] send in
                do {
                    let profile = try await profileStore.fetchProfile(identifier: profileId).async()
                    await send(.response(.profileReceived(.success(profile))))
                    let prescriptions = try await erxTaskRepository.loadLocalAllTasks(profileId: profileId).async()
                    await send(.response(.prescriptionReceived(.success(
                        prescriptions.filter { $0.status == .ready }
                            .map { EUPrescription(erxTask: $0) }
                    ))))
                } catch let error as LocalStoreError {
                    await send(.response(.profileReceived(.failure(error))))
                } catch let error as ErxRepositoryError {
                    await send(.response(.prescriptionReceived(.failure(error))))
                }
            }
        case let .togglePrescription(prescription):
            if let index = state.prescriptions.firstIndex(where: { $0.id == prescription.id }) {
                // Only allow toggling if the prescription is redeemable in EU
                if state.prescriptions[index].isEURedeemable {
                    return .run { [prescription = state.prescriptions[index], profileId = state.profileId] send in
                        do {
                            try await euRedeemService.markTaskEURedeemable(
                                taskId: prescription.id,
                                byPatientAuthorization: !prescription.isSetEURedeemableByPatient,
                                profileId: profileId
                            )
                            await send(.response(.markedPrescriptionReceived(.success(prescription.erxTask))))
                        } catch let error as ErxRepositoryError {
                            await send(.response(.markedPrescriptionReceived(.failure(error))))
                        }
                    }
                }
            }
            return .none
        case let .response(.markedPrescriptionReceived(.success(prescription))):
            guard let isSetEURedeemableByPatient = prescription?.isSetEURedeemableByPatient,
                  let index = state.prescriptions.firstIndex(where: { $0.id == prescription?.id })
            else {
                return .none
            }
            state.$prescriptions[index].withLock { $0.erxTask.isSetEURedeemableByPatient = !isSetEURedeemableByPatient }
            return .none
        case let .response(.markedPrescriptionReceived(.failure(error))):
            state.destination = .alert(ErpAlertState(for: error))
            return .none
        case let .response(.prescriptionReceived(.success(euPrescriptions))):
            state.$prescriptions.withLock { $0 = euPrescriptions }
            return .none
        case let .response(.prescriptionReceived(.failure(error))):
            state.destination = .alert(ErpAlertState(for: error))
            return .none
        case let .response(.profileReceived(.success(profile))):
            state.profile = profile
            return .none
        case let .response(.profileReceived(.failure(error))):
            state.destination = .alert(ErpAlertState(for: error))
            return .none
        case .destination:
            return .none
        }
    }
}

extension SelectEUPrescriptionsDomain.Destination.State: Equatable {}
extension SelectEUPrescriptionsDomain.Destination.Action: Equatable {}

// MARK: - Dummies

extension SelectEUPrescriptionsDomain {
    /// Mock data for testing and previews
    public enum Dummies {
        /// Sample prescriptions for testing
        public static let prescriptions: [EUPrescription] = [
            EUPrescription(erxTask: ErxTask(
                identifier: "1",
                status: .ready,
                flowType: .tPrescription,
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180).ISO8601Format(.iso8601),
                medication: ErxMedication(name: "Acaimoum"),
                isEURedeemable: true
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "2",
                status: .ready,
                flowType: .tPrescription,
                expiresOn: Date(timeIntervalSinceNow: 60 * 60 * 24 * 180).ISO8601Format(.iso8601),
                medication: ErxMedication(name: "Acaimoum"),
                isEURedeemable: true
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "3",
                status: .ready,
                flowType: .tPrescription,
                medication: ErxMedication(name: "Acaimoum"),
                isEURedeemable: false
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "4",
                status: .ready,
                flowType: .tPrescription,
                medication: ErxMedication(name: "Freitext", profile: .freeText),
                isEURedeemable: false
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "5",
                status: .ready,
                flowType: .tPrescription,
                medication: ErxMedication(name: "Wirkstoff Ibu", profile: .ingredient),
                isEURedeemable: false
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "6",
                status: .ready,
                flowType: .tPrescription,
                source: .scanner,
                medication: ErxMedication(name: "Scanned Prescription"),
                isEURedeemable: false
            )),
            EUPrescription(erxTask: ErxTask(
                identifier: "7",
                status: .ready,
                flowType: .narcotic,
                medication: ErxMedication(name: "Betäubungsmittel"),
                isEURedeemable: false
            )),
        ]

        /// Sample state for testing
        static let state = State(
            prescriptions: Shared(value: prescriptions),
            profile: Profile(name: "Anna Vetter",
                             identifier: UUID(),
                             insuranceId: "X123456789",
                             insuranceType: .gKV,
                             color: .red,
                             lastAuthenticated: Date(),
                             erxTasks: [])
        )

        /// Sample store for testing
        static let store = Store(initialState: state) {
            SelectEUPrescriptionsDomain()
        }
    }
}
