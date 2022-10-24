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
import eRpKit
import ZXingObjC

enum RedeemMethodsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.concatenate(
            RedeemMatrixCodeDomain.cleanup(),
            PharmacySearchDomain.cleanup(),
            Effect.cancel(token: Token.self)
        )
    }

    static func cleanupSubviews<T>() -> Effect<T, Never> {
        Effect.concatenate(
            RedeemMatrixCodeDomain.cleanup(),
            PharmacySearchDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case matrixCode(RedeemMatrixCodeDomain.State)
        case pharmacySearch(PharmacySearchDomain.State)

        enum Tag: Int, CaseIterable {
            case matrixCode
            case pharmacySearch
        }

        var tag: Tag {
            switch self {
            case .matrixCode:
                return .matrixCode
            case .pharmacySearch:
                return .pharmacySearch
            }
        }
    }

    struct State: Equatable {
        var erxTasks: [ErxTask]
        var route: Route?
    }

    enum Action: Equatable {
        case close
        case redeemMatrixCodeAction(action: RedeemMatrixCodeDomain.Action)
        case pharmacySearchAction(action: PharmacySearchDomain.Action)
        case setNavigation(tag: Route.Tag?)
    }

    struct Environment {
        let schedulers: Schedulers
        let userSession: UserSession
        let fhirDateFormatter: FHIRDateFormatter
    }

    static let reducer: Reducer = .combine(
        redeemMatrixCodePullbackReducer,
        pharmacySearchPullbackReducer,
        redeemReducer
    )

    static let redeemReducer = Reducer { state, action, _ in
        switch action {
        case .close:
            return .none
        case .redeemMatrixCodeAction(.close):
            state.route = nil
            // Cleanup of child & running close action on parent reducer
            return Effect.concatenate(
                RedeemMatrixCodeDomain.cleanup(),
                Effect(value: .close)
            )
        case .redeemMatrixCodeAction(action:):
            return .none
        case .pharmacySearchAction(action: .close):
            state.route = nil
            return Effect.concatenate(
                PharmacySearchDomain.cleanup(),
                Effect(value: .close)
            )
        case .pharmacySearchAction:
            return .none
        case let .setNavigation(tag: tag):
            switch tag {
            case .matrixCode:
                state.route = .matrixCode(RedeemMatrixCodeDomain.State(erxTasks: state.erxTasks))
            case .pharmacySearch:
                state.route = .pharmacySearch(PharmacySearchDomain.State(erxTasks: state.erxTasks))
            case .none:
                state.route = nil
                return cleanupSubviews()
            }
            return .none
        }
    }

    static let redeemMatrixCodePullbackReducer: Reducer =
        RedeemMatrixCodeDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.matrixCode),
            action: /Action.redeemMatrixCodeAction(action:)
        ) { redeemEnv in
            RedeemMatrixCodeDomain.Environment(
                schedulers: redeemEnv.schedulers,
                matrixCodeGenerator: DefaultErxTaskMatrixCodeGenerator(matrixCodeGenerator: ZXDataMatrixWriter()),
                taskRepository: redeemEnv.userSession.erxTaskRepository,
                fhirDateFormatter: redeemEnv.fhirDateFormatter
            )
        }

    static let pharmacySearchPullbackReducer: Reducer =
        PharmacySearchDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.pharmacySearch),
            action: /RedeemMethodsDomain.Action.pharmacySearchAction(action:)
        ) { environment in
            PharmacySearchDomain.Environment(
                schedulers: environment.schedulers,
                pharmacyRepository: environment.userSession.pharmacyRepository,
                fhirDateFormatter: environment.fhirDateFormatter,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: nil,
                userSession: environment.userSession
            )
        }
}

extension RedeemMethodsDomain {
    enum Dummies {
        static let state = State(
            erxTasks: ErxTask.Demo.erxTasks
        )
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            fhirDateFormatter: FHIRDateFormatter.shared
        )
        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: RedeemMethodsDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
