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
import Foundation
import IDP

struct CardWallCANDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID

        var can: String
        var wrongCANEntered = false
        var scannedCAN: String?
        var isFlashOn = false
        var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardwallPIN
            case pin(CardWallPINDomain.State)
            // sourcery: AnalyticsScreen = cardwallContactInsuranceCompany
            case egk(OrderHealthCardDomain.State)
            // sourcery: AnalyticsScreen = cardwallScanCAN
            case scanner
        }

        enum Action: Equatable {
            case pinAction(action: CardWallPINDomain.Action)
            case egkAction(action: OrderHealthCardDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.pin,
                action: /Action.pinAction
            ) {
                CardWallPINDomain()
            }

            Scope(
                state: /State.egk,
                action: /Action.egkAction(action:)
            ) {
                OrderHealthCardDomain()
            }
        }
    }

    enum Action: Equatable {
        case update(can: String)
        case advance
        case showScannerView
        case toggleFlashLight
        case flashLightOff

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
            case navigateToIntro
        }
    }

    @Dependency(\.profileBasedSessionProvider) var sessionProvider: ProfileBasedSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .update(can: can):
            state.can = can
            return .none
        case .advance:
            guard state.can.lengthOfBytes(using: .utf8) == 6 else {
                return .none
            }
            sessionProvider.userDataStore(for: state.profileId).set(can: state.can)
            state.destination = .pin(CardWallPINDomain.State(isDemoModus: state.isDemoModus, transition: .push))
            return .none
        case .setNavigation(tag: .egk):
            state.destination = .egk(.init())
            return .none
        case .toggleFlashLight:
            state.isFlashOn.toggle()
            return .none
        case .showScannerView:
            state.destination = .scanner
            return .none
        case .setNavigation(tag: .none),
             .destination(.egkAction(action: .delegate(.close))):
            state.destination = nil
            return .none
        case let .destination(.pinAction(.delegate(delegateAction))):
            switch delegateAction {
            case .close:
                return Effect(value: .delegate(.close))
            case .wrongCanClose:
                state.destination = nil
                return .none
            case .navigateToIntro:
                state.destination = nil
                return Effect(value: .delegate(.navigateToIntro))
                    // Delay for the switch to CardWallExthView, Workaround for TCA pullback problem
                    .delay(for: 0.05, scheduler: schedulers.main)
                    .eraseToEffect()
            }
        case .setNavigation,
             .delegate,
             .destination:
            return .none
        case .flashLightOff:
            state.isFlashOn = false
            return .none
        }
    }
}

extension CardWallCANDomain {
    enum Dummies {
        static let state = State(isDemoModus: true, profileId: UUID(), can: "")

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state, reducer: CardWallCANDomain())
        }
    }
}
