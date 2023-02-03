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

enum PrescriptionArchiveDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            cleanupSubDomains(),
            Effect.cancel(id: Token.self)
        )
    }

    enum Token: CaseIterable, Hashable {
        case loadLocalPrescriptionId
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            PrescriptionDetailDomain.cleanup()
        )
    }

    enum Route: Equatable {
        case prescriptionDetail(PrescriptionDetailDomain.State)
    }

    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle
        var prescriptions: [Prescription] = []

        var route: Route?
    }

    enum Action: Equatable {
        /// Loads locally stored Prescriptions
        case loadLocalPrescriptions
        /// Response from `loadLocalPrescriptions`
        case loadLocalPrescriptionsReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: Prescription)

        case prescriptionDetailAction(action: PrescriptionDetailDomain.Action)
        case setNavigation(tag: Route.Tag?)
        case close
    }

    struct Environment {
        let schedulers: Schedulers
        let prescriptionRepository: PrescriptionRepository
        let fhirDateFormatter: FHIRDateFormatter
        var userSession: UserSession
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return environment.prescriptionRepository.loadLocal()
                .receive(on: environment.schedulers.main)
                .catchToLoadingStateEffect()
                .map(Action.loadLocalPrescriptionsReceived)
                .cancellable(id: Token.loadLocalPrescriptionId, cancelInFlight: true)
        case let .loadLocalPrescriptionsReceived(loadingState):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value?.filter(\.isArchived) ?? []
            return .none
        case .close:
            return cleanup()
        case let .prescriptionDetailViewTapped(prescription):
            state.route = .prescriptionDetail(PrescriptionDetailDomain.State(
                prescription: prescription,
                isArchived: prescription.isArchived
            ))
            return .none
        case .setNavigation(tag: .none),
             .prescriptionDetailAction(action: .close):
            state.route = nil
            return cleanupSubDomains()
        case .setNavigation,
             .prescriptionDetailAction:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        prescriptionDetailPullbackReducer,
        domainReducer
    )

    static let prescriptionDetailPullbackReducer: Reducer =
        PrescriptionDetailDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.prescriptionDetail),
            action: /PrescriptionArchiveDomain.Action.prescriptionDetailAction(action:)
        ) { environment in
            PrescriptionDetailDomain.Environment(
                schedulers: environment.schedulers,
                taskRepository: environment.userSession.erxTaskRepository,
                fhirDateFormatter: environment.fhirDateFormatter,
                userSession: environment.userSession
            )
        }
}

extension PrescriptionArchiveDomain {
    enum Dummies {
        static let state = State(prescriptions: Prescription.Dummies.prescriptions)

        static let environment = Environment(
            schedulers: Schedulers(),
            prescriptionRepository: DummyPrescriptionRepository(),
            fhirDateFormatter: globals.fhirDateFormatter,
            userSession: DummySessionContainer()
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
