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
struct HealthCardPasswordOldPinDomain {
    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordDomainMode

        var can = ""
        var oldPin = ""

        @Presents var destination: Destination.State?

        var oldPinMayAdvance: Bool {
            6 ... 8 ~= oldPin.count &&
                oldPin.allSatisfy(Set("0123456789").contains)
        }
    }

    enum Action: Equatable {
        case updateOldPin(String)

        case advance
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        enum Delegate {
            case navigateToSettings
            case navigateToCanScreen
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = healthCardPassword_pin
        case pin(HealthCardPasswordPinDomain)
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .updateOldPin(oldPin):
            state.oldPin = oldPin
            return .none

        case .advance:
            state.destination = .pin(.init(mode: state.mode, can: state.can, oldPin: state.oldPin))
            return .none

        case let .destination(.presented(.pin(.delegate(pinDelegateAction)))):
            switch pinDelegateAction {
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            case .navigateToCanScreen:
                return Effect.send(.delegate(.navigateToCanScreen))
            case .navigateToOldPinScreen:
                state.destination = nil
                return .none
            case .navigateToPukScreen:
                // inconsistent
                return .none
            }
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension HealthCardPasswordOldPinDomain {
    enum Dummies {
        static let state = State(mode: .setCustomPin)

        static let store = Store(initialState: state) {
            HealthCardPasswordOldPinDomain()
        }
    }
}
