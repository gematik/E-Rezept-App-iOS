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
import IDP
import UIKit
import ZXingObjC

struct RedeemMethodsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        .concatenate(
            cleanupSubDomains(),
            EffectTask<T>.cancel(ids: Token.allCases)
        )
    }

    static func cleanupSubDomains<T>() -> EffectTask<T> {
        .concatenate(
            RedeemMatrixCodeDomain.cleanup(),
            PharmacySearchDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        var erxTasks: [ErxTask]
        var destination: Destinations.State?
    }

    enum Action: Equatable {
        case closeButtonTapped
        case destination(Destinations.Action)
        case setNavigation(tag: Destinations.State.Tag?)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = redeem_matrixCode
            case matrixCode(RedeemMatrixCodeDomain.State)
            // sourcery: AnalyticsScreen = pharmacySearch
            case pharmacySearch(PharmacySearchDomain.State)
        }

        enum Action: Equatable {
            case redeemMatrixCodeAction(action: RedeemMatrixCodeDomain.Action)
            case pharmacySearchAction(action: PharmacySearchDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.matrixCode,
                action: /Action.redeemMatrixCodeAction
            ) {
                RedeemMatrixCodeDomain()
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
                return EffectTask(value: .delegate(.close))
            case .destination(.redeemMatrixCodeAction(.closeButtonTapped)):
                state.destination = nil
                // Cleanup of child & running close action on parent reducer
                return .concatenate(
                    RedeemMatrixCodeDomain.cleanup(),
                    EffectTask(value: .delegate(.close)).delay(for: 0.1, scheduler: schedulers.main).eraseToEffect()
                )
            case let .destination(.pharmacySearchAction(action: .delegate(action))):
                switch action {
                case .close:
                    state.destination = nil
                    return .concatenate(
                        PharmacySearchDomain.cleanup(),
                        EffectTask(value: .delegate(.close)).delay(for: 0.1, scheduler: schedulers.main).eraseToEffect()
                    )
                }
            case let .setNavigation(tag: tag):
                switch tag {
                case .matrixCode:
                    state.destination = .matrixCode(RedeemMatrixCodeDomain.State(erxTasks: state.erxTasks))
                case .pharmacySearch:
                    state.destination = .pharmacySearch(PharmacySearchDomain.State(erxTasks: state.erxTasks))
                case .none:
                    state.destination = nil
                    return Self.cleanupSubDomains()
                }
                return .none
            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.destination, action: /Action.destination) {
            Destinations()
        }
    }
}

extension RedeemMethodsDomain {
    enum Dummies {
        static let state = State(
            erxTasks: ErxTask.Demo.erxTasks
        )

        static let store = Store(initialState: state, reducer: RedeemMethodsDomain())
    }
}
