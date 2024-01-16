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
import IDP
import UIKit
import ZXingObjC

struct RedeemMethodsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var erxTasks: [ErxTask]
        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        case closeButtonTapped
        case destination(PresentationAction<Destinations.Action>)
        case setNavigation(tag: Destinations.State.Tag?)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = redeem_matrixCode
            case matrixCode(MatrixCodeDomain.State)
            // sourcery: AnalyticsScreen = pharmacySearch
            case pharmacySearch(PharmacySearchDomain.State)
        }

        enum Action: Equatable {
            case redeemMatrixCodeAction(action: MatrixCodeDomain.Action)
            case pharmacySearchAction(action: PharmacySearchDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.matrixCode,
                action: /Action.redeemMatrixCodeAction
            ) {
                MatrixCodeDomain()
            }
            Scope(
                state: /State.pharmacySearch,
                action: /Action.pharmacySearchAction
            ) {
                PharmacySearchDomain(
                    referenceDateForOpenHours: nil
                )
            }
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return EffectTask.send(.delegate(.close))
            case let .destination(.presented(.pharmacySearchAction(action: .delegate(action)))):
                switch action {
                case .close:
                    state.destination = nil
                    return .run { send in
                        try await schedulers.main.sleep(for: 0.1)
                        await send(.delegate(.close))
                    }
                }
            case let .setNavigation(tag: tag):
                switch tag {
                case .matrixCode:
                    state.destination = .matrixCode(
                        MatrixCodeDomain.State(
                            type: .erxTask,
                            erxTasks: state.erxTasks
                        )
                    )
                case .pharmacySearch:
                    state.destination = .pharmacySearch(PharmacySearchDomain.State(erxTasks: state.erxTasks))
                case .none:
                    state.destination = nil
                    return .none
                }
                return .none
            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destinations()
        }
    }
}

extension RedeemMethodsDomain {
    enum Dummies {
        static let state = State(
            erxTasks: ErxTask.Demo.erxTasks
        )

        static let store = Store(
            initialState: state
        ) {
            RedeemMethodsDomain()
        }
    }
}
