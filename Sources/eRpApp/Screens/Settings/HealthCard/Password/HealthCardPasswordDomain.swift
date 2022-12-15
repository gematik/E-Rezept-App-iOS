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

enum HealthCardPasswordDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: HealthCardPasswordDomain.Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            HealthCardPasswordReadCardDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case introduction
        case can
        case puk
        case oldPin
        case pin
        case readCard(HealthCardPasswordReadCardDomain.State)
        case scanner
    }

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

        var route: Route = .introduction

        init(mode: HealthCardPasswordDomain.Mode) {
            self.mode = mode
        }
    }

    enum Action: Equatable {
        case canUpdateCan(String)
        case canDismissScannerView
        case pukUpdatePuk(String)
        case oldPinUpdateOldPin(String)
        case pinUpdateNewPin1(String)
        case pinUpdateNewPin2(String)
        case pinAlertOkButtonTapped

        case readCard(action: HealthCardPasswordReadCardDomain.Action)

        case advance
        case setNavigation(tag: Route.Tag)
        case nothing
    }

    struct Environment {
        let schedulers: Schedulers
        let nfcSessionController: NFCHealthCardPasswordController
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

        case .readCard(.close):
            switch state.mode {
            case .forgotPin:
                state.route = .pin
            case .setCustomPin:
                state.route = .pin
            case .unlockCard:
                state.route = .puk
            }
            return cleanupSubDomains()
        case .readCard(.navigateToCanScreen):
            state.route = .can
            return cleanupSubDomains()
        case .readCard(.navigateToOldPinScreen):
            state.route = .oldPin
            return cleanupSubDomains()
        case .readCard(.navigateToPukScreen):
            state.route = .puk
            return cleanupSubDomains()
        case .readCard:
            return .none

        case .advance:
            switch state.route {
            case .introduction:
                state.route = .can
                return .none
            case .can:
                switch state.mode {
                case .forgotPin:
                    state.route = .puk
                case .setCustomPin:
                    state.route = .oldPin
                case .unlockCard:
                    state.route = .puk
                }
                return .none
            case .puk:
                switch state.mode {
                case .forgotPin:
                    state.route = .pin
                case .setCustomPin:
                    // inconsistent state
                    break
                case .unlockCard:
                    state.route =
                        .readCard(.init(mode: .healthCardResetPinCounterNoNewSecret(can: state.can, puk: state.puk)))
                }
                return .none
            case .oldPin:
                state.route = .pin
                return .none
            case .pin:
                switch state.mode {
                case .forgotPin:
                    state.route = .readCard(.init(
                        mode: .healthCardResetPinCounterWithNewSecret(
                            can: state.can,
                            puk: state.puk,
                            newPin: state.newPin1
                        )
                    ))
                case .setCustomPin:
                    state.route = .readCard(.init(
                        mode: .healthCardSetNewPinSecret(
                            can: state.can,
                            oldPin: state.oldPin,
                            newPin: state.newPin1
                        )
                    ))
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
            state.route = .introduction
            return .none
        case .setNavigation(tag: .can):
            state.route = .can
            return .none
        case .setNavigation(tag: .puk):
            state.route = .puk
            return .none
        case .setNavigation(tag: .oldPin):
            state.route = .oldPin
            return .none
        case .setNavigation(tag: .pin):
            state.route = .pin
            return .none
        case .setNavigation(tag: .readCard):
            switch state.mode {
            case .forgotPin:
                state.route = .readCard(.init(
                    mode: .healthCardResetPinCounterWithNewSecret(
                        can: state.can,
                        puk: state.puk,
                        newPin: state.newPin1
                    )
                ))
            case .setCustomPin:
                state.route = .readCard(
                    .init(mode: .healthCardSetNewPinSecret(can: state.can, oldPin: state.oldPin, newPin: state.newPin1))
                )
            case .unlockCard:
                state.route = .readCard(
                    .init(mode: .healthCardResetPinCounterNoNewSecret(can: state.can, puk: state.puk))
                )
            }
            return .none
        case .setNavigation(tag: .scanner):
            state.route = .scanner
            return .none
        case .setNavigation:
            return .none
        case .nothing:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        readCardPullbackReducer,
        domainReducer
    )

    private static let readCardPullbackReducer: Reducer =
        HealthCardPasswordReadCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.readCard),
            action: /HealthCardPasswordDomain.Action.readCard(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                nfcSessionController: $0.nfcSessionController
            )
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
        static let environment = Environment(
            schedulers: Schedulers(),
            nfcSessionController: DummyNFCHealthCardPasswordController()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
