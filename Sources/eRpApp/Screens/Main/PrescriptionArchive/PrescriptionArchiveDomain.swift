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
import Foundation

@Reducer
struct PrescriptionArchiveDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail
        case prescriptionDetail(PrescriptionDetailDomain)
        case diGaDetail(DiGaDetailDomain)
    }

    @ObservableState
    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> = .idle
        var prescriptions: [Prescription] = []
        var pickerView: PickerView = .prescriptions
        var diGaPrescriptions: [Prescription] {
            prescriptions.filter(\.isDiGaPrescription)
        }

        @Presents var destination: Destination.State?
    }

    enum PickerView: String, CaseIterable, Equatable {
        case prescriptions
        case diGa

        var text: String {
            switch self {
            case .prescriptions: L10n.prscArchTxtPickerPrsc.text
            case .diGa: L10n.prscArchTxtPickerDiga.text
            }
        }

        var accessibilityIdentifier: String {
            switch self {
            case .prescriptions:
                A11y.prescriptionArchive.arcBtnSegmentedControlPrescriptions
            case .diGa:
                A11y.prescriptionArchive.arcBtnSegmentedControlDigas
            }
        }
    }

    enum Action: Equatable {
        /// Loads locally stored Prescriptions
        case loadLocalPrescriptions
        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: Prescription)
        case selectView(PickerView)
        case response(Response)
        case delegate(Delegate)

        case destination(PresentationAction<Destination.Action>)

        enum Response: Equatable {
            /// Response from `loadLocalPrescriptions`
            case loadLocalPrescriptionsReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
        }

        enum Delegate: Equatable {
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.prescriptionRepository) var prescriptionRepository: PrescriptionRepository
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return .publisher(
                prescriptionRepository.loadLocal()
                    .receive(on: schedulers.main)
                    .catchToLoadingStateEffect()
                    .map { Action.response(.loadLocalPrescriptionsReceived($0)) }
                    .eraseToAnyPublisher
            )
        case let .response(.loadLocalPrescriptionsReceived(loadingState)):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value?.filter(\.isArchived) ?? []
            if state.pickerView == .diGa,
               state.diGaPrescriptions.isEmpty {
                state.pickerView = .prescriptions
            }
            return .none
        case let .prescriptionDetailViewTapped(prescription):
            if let diGaInfo = prescription.erxTask.deviceRequest?.diGaInfo {
                state.destination = .diGaDetail(DiGaDetailDomain.State(
                    diGaTask: .init(prescription: prescription),
                    diGaInfo: diGaInfo
                ))
            } else {
                state.destination = .prescriptionDetail(PrescriptionDetailDomain.State(
                    prescription: prescription,
                    isArchived: prescription.isArchived
                ))
            }
            return .none
        case .destination(.presented(.diGaDetail(action: .delegate(.closeFromDelete)))):
            // When deleting the last Element it is still stored and need a workaround.
            if state.diGaPrescriptions.count <= 1 {
                state.pickerView = .prescriptions
            }
            state.destination = nil
            return .none
        case .destination(.presented(.prescriptionDetail(.delegate(.close)))):
            state.destination = nil
            return .none
        case let .selectView(view):
            state.pickerView = view
            return .none
        case .delegate,
             .destination:
            return .none
        }
    }
}

extension PrescriptionArchiveDomain {
    enum Dummies {
        static let prescriptions: [Prescription] = [
            ErxTask.Demo.expiredErxTask(with: .ready),
            ErxTask.Demo.expiredErxTask(with: .inProgress),
            ErxTask.Demo.expiredErxTask(with: .computed(status: .dispensed)),
            ErxTask.Demo.expiredErxTask(with: .completed),
            ErxTask.Demo.erxTask10,
        ].map {
            Prescription(erxTask: $0, dateFormatter: UIDateFormatter.previewValue)
        }

        static let state = State(prescriptions: prescriptions)

        static let store = Store(
            initialState: state
        ) {
            PrescriptionArchiveDomain()
                .dependency(\.prescriptionRepository, DummyPrescriptionRepository())
        }
    }
}
