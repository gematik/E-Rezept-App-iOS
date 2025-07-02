//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HealthCardPasswordPukDomain {
    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordDomainMode

        var can = ""
        var puk = ""

        @Presents var destination: Destination.State?

        var pukMayAdvance: Bool {
            puk.count == 8 &&
                puk.allSatisfy(Set("0123456789").contains)
        }
    }

    enum Action: Equatable {
        case updatePuk(String)

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
        // sourcery: AnalyticsScreen = healthCardPassword_readCard
        case readCard(HealthCardPasswordReadCardDomain)
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .updatePuk(puk):
            state.puk = puk
            return .none

        case .advance:
            switch state.mode {
            case .forgotPin:
                state.destination = .pin(.init(mode: state.mode, can: state.can, puk: state.puk))
            case .setCustomPin:
                // inconsistent state
                break
            case .unlockCard:
                state.destination = .readCard(
                    .init(mode: .healthCardResetPinCounterNoNewSecret(
                        can: state.can,
                        puk: state.puk
                    ))
                )
            }
            return .none
        case let .destination(.presented(.readCard(.delegate(readCardDelegateAction)))):
            switch readCardDelegateAction {
            case .close:
                state.destination = nil
                return .none
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            case .navigateToCanScreen:
                return Effect.send(.delegate(.navigateToCanScreen))
            case .navigateToOldPinScreen:
                // inconsistent state
                return .none
            case .navigateToPukScreen:
                state.destination = nil
                return .none
            }
        case let .destination(.presented(.pin(.delegate(pinDelegateAction)))):
            switch pinDelegateAction {
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            case .navigateToCanScreen:
                return Effect.send(.delegate(.navigateToCanScreen))
            case .navigateToOldPinScreen:
                // inconsistent state
                return .none
            case .navigateToPukScreen:
                state.destination = nil
                return .none
            }
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension HealthCardPasswordPukDomain {
    enum Dummies {
        static let state = State(mode: .setCustomPin)

        static let store = Store(initialState: state) {
            HealthCardPasswordPukDomain()
        }
    }
}
