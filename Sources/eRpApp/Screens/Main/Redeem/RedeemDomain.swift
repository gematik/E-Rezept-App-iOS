//
//  Copyright (c) 2022 gematik GmbH
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
import ComposableCoreLocation
import eRpKit

enum RedeemDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var groupedPrescription: GroupedPrescription
        var redeemMatrixCodeState: RedeemMatrixCodeDomain.State?
        var pharmacySearchState: PharmacySearchDomain.State?
        var prescriptionsAreAllFullDetail: Bool {
            groupedPrescription.prescriptions.allSatisfy {
                $0.erxTask.source == ErxTask.Source.server
            }
        }
    }

    enum Action: Equatable {
        case close
        case dismissRedeemMatrixCodeView
        case openRedeemMatrixCodeView
        case redeemMatrixCodeAction(action: RedeemMatrixCodeDomain.Action)
        case pharmacySearchAction(action: PharmacySearchDomain.Action)
        case openPharmacySearchView
        case dismissPharmacySearchView
    }

    struct Environment {
        let schedulers: Schedulers
        let userSession: UserSession
        let fhirDateFormatter: FHIRDateFormatter
        let locationManager: LocationManager
    }

    static let reducer: Reducer = .combine(
        redeemMatrixCodePullbackReducer,
        pharmacySearchPullbackReducer,
        redeemReducer
    )

    static let redeemReducer = Reducer { state, action, environment in
        switch action {
        case .close:
            return .none
        case .dismissRedeemMatrixCodeView:
            state.redeemMatrixCodeState = nil
            return RedeemMatrixCodeDomain.cleanup()
        case .redeemMatrixCodeAction(.close):
            state.redeemMatrixCodeState = nil
            // Cleanup of child & running close action on parent reducer
            return Effect.concatenate(
                RedeemMatrixCodeDomain.cleanup(),
                Effect(value: .close)
            )
        case .openRedeemMatrixCodeView:
            state.redeemMatrixCodeState =
                RedeemMatrixCodeDomain.State(groupedPrescription: state.groupedPrescription)
            return .none
        case .redeemMatrixCodeAction(action:):
            return .none
        // Pharmacy Search
        case .openPharmacySearchView:
            var showLocationHint = true
            if environment.locationManager.locationServicesEnabled(),
               environment.locationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined {
                showLocationHint = false
            }
            state.pharmacySearchState = PharmacySearchDomain.State(
                erxTasks: state.groupedPrescription.prescriptions.map(\.erxTask),
                locationHintState: showLocationHint
            )
            return .none
        case .dismissPharmacySearchView:
            state.pharmacySearchState = nil
            return PharmacySearchDomain.cleanup()
        case .pharmacySearchAction(action: .close):
            state.pharmacySearchState = nil
            return Effect(value: .close)
        case .pharmacySearchAction:
            return .none
        }
    }

    static let redeemMatrixCodePullbackReducer: Reducer =
        RedeemMatrixCodeDomain.reducer.optional().pullback(
            state: \.redeemMatrixCodeState,
            action: /Action.redeemMatrixCodeAction(action:)
        ) { redeemEnv in
            RedeemMatrixCodeDomain.Environment(
                schedulers: redeemEnv.schedulers,
                matrixCodeGenerator: DefaultErxTaskMatrixCodeGenerator(),
                taskRepositoryAccess: redeemEnv.userSession.erxTaskRepository,
                fhirDateFormatter: redeemEnv.fhirDateFormatter
            )
        }

    static let pharmacySearchPullbackReducer: Reducer =
        PharmacySearchDomain.reducer.optional().pullback(
            state: \.pharmacySearchState,
            action: /RedeemDomain.Action.pharmacySearchAction(action:)
        ) { environment in
            PharmacySearchDomain.Environment(
                schedulers: environment.schedulers,
                pharmacyRepository: environment.userSession.pharmacyRepository,
                locationManager: .live,
                fhirDateFormatter: environment.fhirDateFormatter,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: nil,
                userSession: environment.userSession
            )
        }
}

extension RedeemDomain {
    enum Dummies {
        static let state = State(
            groupedPrescription: GroupedPrescription.Dummies.twoPrescriptions
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DemoSessionContainer(),
            fhirDateFormatter: FHIRDateFormatter.shared,
            locationManager: .live
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: RedeemDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
