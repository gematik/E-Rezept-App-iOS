//
//  Copyright (c) 2023 gematik GmbH
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
import Foundation

struct PrescriptionArchiveDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        .concatenate(
            cleanupSubDomains(),
            EffectTask<T>.cancel(ids: Token.allCases)
        )
    }

    enum Token: CaseIterable, Hashable {
        case loadLocalPrescriptionId
    }

    private static func cleanupSubDomains<T>() -> EffectTask<T> {
        .concatenate(
            PrescriptionDetailDomain.cleanup()
        )
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = prescriptionDetail
            case prescriptionDetail(PrescriptionDetailDomain.State)
        }

        enum Action: Equatable {
            case prescriptionDetail(PrescriptionDetailDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.prescriptionDetail, action: /Action.prescriptionDetail) {
                PrescriptionDetailDomain()
            }
        }
    }

    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle
        var prescriptions: [Prescription] = []

        var destination: Destinations.State?
    }

    enum Action: Equatable {
        /// Loads locally stored Prescriptions
        case loadLocalPrescriptions
        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: Prescription)

        case response(Response)
        case delegate(Delegate)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

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

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return prescriptionRepository.loadLocal()
                .receive(on: schedulers.main)
                .catchToLoadingStateEffect()
                .map { Action.response(.loadLocalPrescriptionsReceived($0)) }
                .cancellable(id: Token.loadLocalPrescriptionId, cancelInFlight: true)
        case let .response(.loadLocalPrescriptionsReceived(loadingState)):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value?.filter(\.isArchived) ?? []
            return .none
        case .delegate(.close):
            return Self.cleanup()
        case let .prescriptionDetailViewTapped(prescription):
            state.destination = .prescriptionDetail(PrescriptionDetailDomain.State(
                prescription: prescription,
                isArchived: prescription.isArchived
            ))
            return .none
        case .setNavigation(tag: .none),
             .destination(.prescriptionDetail(.delegate(.close))):
            state.destination = nil
            return Self.cleanupSubDomains()
        case .setNavigation,
             .destination:
            return .none
        }
    }
}

extension PrescriptionArchiveDomain {
    enum Dummies {
        static let state = State(prescriptions: Prescription.Dummies.prescriptions)

        static let store = Store(initialState: state,
                                 reducer: PrescriptionArchiveDomain())
    }
}
