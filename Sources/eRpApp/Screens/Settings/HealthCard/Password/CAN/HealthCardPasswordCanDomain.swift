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

import ComposableArchitecture
import Foundation

@Reducer
struct HealthCardPasswordCanDomain {
    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordDomainMode

        var can = ""

        @Presents var destination: Destination.State?

        var canMayAdvance: Bool {
            can.count == 6 &&
                can.allSatisfy(Set("0123456789").contains)
        }
    }

    enum Action: Equatable {
        case updateCan(String)
        case showScannerView

        case advance
        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        enum Delegate {
            case navigateToSettings
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = healthCardPassword_puk
        case puk(HealthCardPasswordPukDomain)
        // sourcery: AnalyticsScreen = healthCardPassword_oldPin
        case oldPin(HealthCardPasswordOldPinDomain)
        // sourcery: AnalyticsScreen = healthCardPassword_scanner
        case scanner
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .updateCan(can):
            state.can = can
            return .none
        case .showScannerView:
            state.destination = .scanner
            return .none

        case .advance:
            switch state.mode {
            case .forgotPin,
                 .unlockCard:
                state.destination = .puk(.init(mode: state.mode, can: state.can))
            case .setCustomPin:
                state.destination = .oldPin(.init(mode: state.mode, can: state.can))
            }
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .destination(.presented(.puk(.delegate(pukDelegateAction)))):
            switch pukDelegateAction {
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            case .navigateToCanScreen:
                state.destination = nil
                return .none
            }
        case let .destination(.presented(.oldPin(.delegate(oldPinDelegateAction)))):
            switch oldPinDelegateAction {
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            case .navigateToCanScreen:
                state.destination = nil
                return .none
            }
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension HealthCardPasswordCanDomain {
    enum Dummies {
        static let state = State(mode: .setCustomPin)

        static let store = Store(initialState: state) {
            HealthCardPasswordCanDomain()
        }
    }
}
