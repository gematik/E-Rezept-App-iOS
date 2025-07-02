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
struct HealthCardPasswordPinDomain {
    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordDomainMode

        var can = ""
        var puk = ""
        var oldPin = ""
        var pin1 = ""
        var pin2 = ""

        @Presents var destination: Destination.State?

        var pinMayAdvance: Bool {
            6 ... 8 ~= pin1.count &&
                pin1 == pin2 &&
                pin1.allSatisfy(Set("0123456789").contains)
        }

        var pinShowWarning: Bool {
            !pin2.isEmpty && pin1 != pin2
        }
    }

    enum Action: Equatable {
        case updatePin1(String)
        case updatePin2(String)

        case advance
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        enum Delegate {
            case navigateToSettings
            case navigateToCanScreen
            case navigateToOldPinScreen
            case navigateToPukScreen
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = healthCardPassword_readCard
        case readCard(HealthCardPasswordReadCardDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = healthCardPassword_pin_alert
        case pinAlert(AlertState<Alert>)

        enum Alert: Equatable {
            case dismiss
        }
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .updatePin1(pin1):
            if pin1.count > 8 {
                state.destination = .pinAlert(AlertStates.pinTooLong)
            }
            state.pin1 = pin1
            return .none
        case let .updatePin2(pin2):
            if pin2.count > 8 {
                state.destination = .pinAlert(AlertStates.pinTooLong)
            }
            state.pin2 = pin2
            return .none

        case .advance:
            switch state.mode {
            case .forgotPin:
                state.destination = .readCard(
                    .init(mode: .healthCardResetPinCounterWithNewSecret(
                        can: state.can,
                        puk: state.puk,
                        newPin: state.pin1
                    ))
                )
            case .setCustomPin:
                state.destination = .readCard(
                    .init(mode: .healthCardSetNewPinSecret(
                        can: state.can,
                        oldPin: state.oldPin,
                        newPin: state.pin1
                    ))
                )
            case .unlockCard:
                // inconsistent state
                break
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
                return Effect.send(.delegate(.navigateToOldPinScreen))
            case .navigateToPukScreen:
                return Effect.send(.delegate(.navigateToPukScreen))
            }
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension HealthCardPasswordPinDomain {
    enum AlertStates {
        typealias Action = HealthCardPasswordPinDomain.Destination.Alert

        static let pinTooLong: AlertState<Action> = .init(
            title: { .init(L10n.stgTxtCardResetPinAlertPinTooLongTitle) },
            actions: {
                ButtonState(role: .cancel, action: .dismiss) {
                    .init(L10n.stgBtnCardResetPinAlertOk)
                }
            },
            message: { .init(L10n.stgTxtCardResetPinAlertPinTooLongMessage) }
        )
    }
}

extension HealthCardPasswordPinDomain {
    enum Dummies {
        static let state = State(mode: .setCustomPin)

        static let store = Store(initialState: state) {
            HealthCardPasswordPinDomain()
        }
    }
}
