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

struct HealthCardPasswordDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        .concatenate(
            .cancel(id: HealthCardPasswordDomain.Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> EffectTask<T> {
        .concatenate(
            HealthCardPasswordReadCardDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    enum Mode {
        case forgotPin
        case setCustomPin
        case unlockCard
    }

    struct State: Equatable {
        let mode: HealthCardPasswordDomain.Mode

        var can = ""
        var puk = ""
        var oldPin = ""
        var newPin1 = ""
        var newPin2 = ""

        var pinAlertState: AlertState<Action>?

        var destination: Destinations.State = .introduction
    }

    enum Action: Equatable {
        case canUpdateCan(String)
        case canDismissScannerView
        case pukUpdatePuk(String)
        case oldPinUpdateOldPin(String)
        case pinUpdateNewPin1(String)
        case pinUpdateNewPin2(String)
        case pinAlertOkButtonTapped

        case advance
        case setNavigation(tag: Destinations.State.Tag)

        case destination(action: Destinations.Action)
        case delegate(Delegate)
        case nothing

        enum Delegate {
            case navigateToSettings
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = healthCardPassword_introduction
            case introduction
            // sourcery: AnalyticsScreen = healthCardPassword_can
            case can
            // sourcery: AnalyticsScreen = healthCardPassword_puk
            case puk
            // sourcery: AnalyticsScreen = healthCardPassword_oldPin
            case oldPin
            // sourcery: AnalyticsScreen = healthCardPassword_pin
            case pin
            // sourcery: AnalyticsScreen = healthCardPassword_readCard
            case readCard(HealthCardPasswordReadCardDomain.State)
            // sourcery: AnalyticsScreen = healthCardPassword_scanner
            case scanner
        }

        enum Action: Equatable {
            case readCard(action: HealthCardPasswordReadCardDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.readCard, action: /Action.readCard) {
                HealthCardPasswordReadCardDomain()
            }
        }
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.destination, action: /Action.destination) {
            Destinations()
        }

        Reduce(core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .canUpdateCan(can):
            state.can = can
            return .none
        case .canDismissScannerView:
            return .none
        case let .pukUpdatePuk(puk):
            state.puk = puk
            return .none
        case let .oldPinUpdateOldPin(oldPin):
            state.oldPin = oldPin
            return .none
        case let .pinUpdateNewPin1(newPin1):
            if newPin1.count > 8 {
                state.pinAlertState = AlertStates.pinTooLong
            }
            state.newPin1 = newPin1
            return .none
        case let .pinUpdateNewPin2(newPin2):
            if newPin2.count > 8 {
                state.pinAlertState = AlertStates.pinTooLong
            }
            state.newPin2 = newPin2
            return .none
        case .pinAlertOkButtonTapped:
            state.pinAlertState = nil
            return .none

        case let .destination(.readCard(.delegate(readCardDelegateAction))):
            switch readCardDelegateAction {
            case .close:
                switch state.mode {
                case .forgotPin:
                    state.destination = .pin
                case .setCustomPin:
                    state.destination = .pin
                case .unlockCard:
                    state.destination = .puk
                }
                return HealthCardPasswordDomain.cleanupSubDomains()
            case .navigateToCanScreen:
                state.destination = .can
                return HealthCardPasswordDomain.cleanupSubDomains()
            case .navigateToOldPinScreen:
                state.destination = .oldPin
                return HealthCardPasswordDomain.cleanupSubDomains()
            case .navigateToPukScreen:
                state.destination = .puk
                return HealthCardPasswordDomain.cleanupSubDomains()
            case .navigateToSettings:
                return .init(value: .delegate(.navigateToSettings))
            }

        case .advance:
            switch state.destination {
            case .introduction:
                state.destination = .can
                return .none
            case .can:
                switch state.mode {
                case .forgotPin:
                    state.destination = .puk
                case .setCustomPin:
                    state.destination = .oldPin
                case .unlockCard:
                    state.destination = .puk
                }
                return .none
            case .puk:
                switch state.mode {
                case .forgotPin:
                    state.destination = .pin
                case .setCustomPin:
                    // inconsistent state
                    break
                case .unlockCard:
                    state.destination = .readCard(
                        .init(
                            mode: .healthCardResetPinCounterNoNewSecret(
                                can: state.can,
                                puk: state.puk
                            )
                        )
                    )
                }
                return .none
            case .oldPin:
                state.destination = .pin
                return .none
            case .pin:
                switch state.mode {
                case .forgotPin:
                    state.destination = .readCard(
                        .init(
                            mode: .healthCardResetPinCounterWithNewSecret(
                                can: state.can,
                                puk: state.puk,
                                newPin: state.newPin1
                            )
                        )
                    )
                case .setCustomPin:
                    state.destination = .readCard(
                        .init(
                            mode: .healthCardSetNewPinSecret(
                                can: state.can,
                                oldPin: state.oldPin,
                                newPin: state.newPin1
                            )
                        )
                    )
                case .unlockCard:
                    // inconsistent state
                    break
                }
                return .none
            case .readCard,
                 .scanner:
                return .none
            }

        case .setNavigation(tag: .introduction):
            state.destination = .introduction
            return .none
        case .setNavigation(tag: .can):
            state.destination = .can
            return .none
        case .setNavigation(tag: .puk):
            state.destination = .puk
            return .none
        case .setNavigation(tag: .oldPin):
            state.destination = .oldPin
            return .none
        case .setNavigation(tag: .pin):
            state.destination = .pin
            return .none
        case .setNavigation(tag: .readCard):
            switch state.mode {
            case .forgotPin:
                state.destination = .readCard(
                    .init(
                        mode: .healthCardResetPinCounterWithNewSecret(
                            can: state.can,
                            puk: state.puk,
                            newPin: state.newPin1
                        )
                    )
                )
            case .setCustomPin:
                state.destination = .readCard(
                    .init(
                        mode: .healthCardSetNewPinSecret(
                            can: state.can,
                            oldPin: state.oldPin,
                            newPin: state.newPin1
                        )
                    )
                )
            case .unlockCard:
                state.destination = .readCard(
                    .init(
                        mode: .healthCardResetPinCounterNoNewSecret(
                            can: state.can,
                            puk: state.puk
                        )
                    )
                )
            }
            return .none
        case .setNavigation(tag: .scanner):
            state.destination = .scanner
            return .none
        case .setNavigation:
            return .none
        case .destination,
             .delegate,
             .nothing:
            return .none
        }
    }
}

extension HealthCardPasswordDomain.State {
    var canMayAdvance: Bool {
        can.count == 6 &&
            can.allSatisfy(Set("0123456789").contains)
    }

    var pukMayAdvance: Bool {
        puk.count == 8 &&
            puk.allSatisfy(Set("0123456789").contains)
    }

    var oldPinMayAdvance: Bool {
        6 ... 8 ~= oldPin.count &&
            oldPin.allSatisfy(Set("0123456789").contains)
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

extension HealthCardPasswordDomain {
    enum AlertStates {
        typealias Action = HealthCardPasswordDomain.Action

        static let pinTooLong: AlertState<Action> = .init(
            title: .init(L10n.stgTxtCardResetPinAlertPinTooLongTitle),
            message: .init(L10n.stgTxtCardResetPinAlertPinTooLongMessage),
            dismissButton: .default(
                .init(L10n.stgBtnCardResetPinAlertOk),
                action: .send(.pinAlertOkButtonTapped)
            )
        )
    }
}

extension HealthCardPasswordDomain {
    enum Dummies {
        static let state = State(mode: .unlockCard)

        static let store = Store(
            initialState: state,
            reducer: HealthCardPasswordDomain()
        )
    }
}
