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

enum ResetRetryCounterDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: ResetRetryCounterDomain.Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            ResetRetryCounterReadCardDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case introduction
        case can
        case puk
        case pin
        case readCard(ResetRetryCounterReadCardDomain.State)

        enum Tag: Int {
            case introduction
            case can
            case puk
            case pin
            case readCard
        }

        var tag: Tag {
            switch self {
            case .introduction: return .introduction
            case .can: return .can
            case .puk: return .puk
            case .pin: return .pin
            case .readCard: return .readCard
            }
        }
    }

    struct State: Equatable {
        let withNewPin: Bool

        var can = ""
        var puk = ""
        var newPin1 = ""
        var newPin2 = ""

        var route: Route = .introduction

        init(withNewPin: Bool) {
            self.withNewPin = withNewPin
        }
    }

    enum Action: Equatable {
        case canUpdateCan(String)
        case canDismissScannerView
        case pukUpdatePuk(String)
        case pinUpdateNewPin1(String)
        case pinUpdateNewPin2(String)

        case readCard(action: ResetRetryCounterReadCardDomain.Action)

        case advance
        case setNavigation(tag: Route.Tag)
    }

    struct Environment {
        let schedulers: Schedulers
        let nfcSessionController: NFCResetRetryCounterController
    }

    static let domainReducer = Reducer { state, action, _ in
        switch action {
        case let .canUpdateCan(can):
            state.can = can
            return .none
        case .canDismissScannerView:
            return .none
        case let .pukUpdatePuk(puk):
            state.puk = puk
            return .none
        case let .pinUpdateNewPin1(newPin1):
            state.newPin1 = newPin1
            return .none
        case let .pinUpdateNewPin2(newPin2):
            state.newPin2 = newPin2
            return .none

        case .readCard(.close):
            state.route = state.withNewPin ? .pin : .puk
            return cleanupSubDomains()
        case .readCard(.navigateToSettings):
            state.route = .introduction
            return .none
        case .readCard:
            return .none

        case .advance:
            switch state.route {
            case .introduction:
                state.route = .can
                return .none
            case .can:
                state.route = .puk
                return .none
            case .puk:
                state.route = state.withNewPin ?
                    .pin :
                    .readCard(
                        .init(withNewPin: state.withNewPin, can: state.can, puk: state.puk, newPin: state.newPin1)
                    )
                return .none
            case .pin:
                state.route = .readCard(
                    .init(withNewPin: state.withNewPin, can: state.can, puk: state.puk, newPin: state.newPin1)
                )
                return .none
            case .readCard:
                return .none
            }

        case .setNavigation(tag: .introduction):
            state.route = .introduction
            return .none
        case .setNavigation(tag: .can):
            state.route = .can
            return .none
        case .setNavigation(tag: .puk):
            state.route = .puk
            return .none
        case .setNavigation(tag: .pin):
            state.route = .pin
            return .none
        case .setNavigation(tag: .readCard):
            state.route =
                .readCard(.init(withNewPin: state.withNewPin, can: state.can, puk: state.puk, newPin: state.newPin1))
            return .none
        case .setNavigation:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        readCardPullbackReducer,
        domainReducer
    )

    private static let readCardPullbackReducer: Reducer =
        ResetRetryCounterReadCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.readCard),
            action: /ResetRetryCounterDomain.Action.readCard(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcSessionController
            )
        }
}

extension ResetRetryCounterDomain.State {
    var canMayAdvance: Bool {
        can.count == 6 &&
            can.allSatisfy(Set("0123456789").contains)
    }

    var pukMayAdvance: Bool {
        puk.count == 8 &&
            puk.allSatisfy(Set("0123456789").contains)
    }

    var pinMayAdvance: Bool {
        6 ... 8 ~= newPin1.count &&
            newPin1 == newPin2 &&
            newPin1.allSatisfy(Set("0123456789").contains)
    }

    var pinShowWarning: Bool {
        !newPin2.isEmpty && newPin1 != newPin2
    }
}

extension ResetRetryCounterDomain {
    enum Dummies {
        static let state = State(withNewPin: false)
        static let environment = Environment(
            schedulers: Schedulers(),
            nfcSessionController: DummyResetRetryCounterController()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
