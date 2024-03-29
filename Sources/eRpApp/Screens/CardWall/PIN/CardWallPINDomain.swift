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
import IDP
import SwiftUI

struct CardWallPINDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String = ""
        var wrongPinEntered = false
        var doneButtonPressed = false
        let pinPassRange = (6 ... 8)
        var transition: TransitionMode
        @PresentationState var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardWall_saveLogin
            case login(CardWallLoginOptionDomain.State)
            // sourcery: AnalyticsScreen = contactInsuranceCompany
            case egk(OrderHealthCardDomain.State)
        }

        enum Action: Equatable {
            case login(action: CardWallLoginOptionDomain.Action)
            case egkAction(action: OrderHealthCardDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.login,
                action: /Action.login
            ) {
                CardWallLoginOptionDomain()
            }

            Scope(
                state: /State.egk,
                action: /Action.egkAction(action:)
            ) {
                OrderHealthCardDomain()
            }
        }
    }

    indirect enum Action: Equatable {
        case update(pin: String)
        case advance(TransitionMode)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
            case wrongCanClose
            case navigateToIntro
            case unlockCardClose
        }
    }

    enum TransitionMode: Equatable {
        case none
        case push
        case fullScreenCover
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler
    @Dependency(\.accessibilityAnnouncementReceiver) var receiver: AccessibilityAnnouncementReceiver

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .update(pin: pin):
            state.pin = pin
            state.doneButtonPressed = false
            if state.showWarning {
                receiver.accessibilityAnnouncement(state.warningMessage)
            }
            return .none
        case let .advance(mode):
            if state.enteredPINValid {
                state.transition = mode
                state.destination = .login(
                    .init(isDemoModus: state.isDemoModus, profileId: state.profileId, pin: state.pin)
                )
                return .none
            } else {
                state.doneButtonPressed = true
            }
            if state.showWarning {
                receiver.accessibilityAnnouncement(state.warningMessage)
            }
            return .none
        case .setNavigation(tag: .egk):
            state.destination = .egk(.init())
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case let .destination(.presented(.login(.delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                return EffectTask.send(.delegate(.close))
            case .wrongCanClose:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 0.01)
                    await send(.delegate(.wrongCanClose))
                }
            case .wrongPinClose:
                state.destination = nil
                return .none
            case .navigateToIntro:
                return EffectTask.send(.delegate(.navigateToIntro))
            case .unlockCardClose:
                return EffectTask.send(.delegate(.unlockCardClose))
            }
        case .destination(.presented(.egkAction(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .setNavigation,
             .destination,
             .delegate:
            return .none
        }
    }
}

extension CardWallPINDomain.State {
    var enteredPINNotNumeric: Bool {
        !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pin))
    }

    var enteredPINTooShort: Bool {
        pin.lengthOfBytes(using: .utf8) < pinPassRange.lowerBound
    }

    var enteredPINTooLong: Bool {
        pin.lengthOfBytes(using: .utf8) > pinPassRange.upperBound
    }

    var enteredPINValid: Bool {
        !(enteredPINTooShort || enteredPINTooLong || enteredPINNotNumeric)
    }

    var showWarning: Bool {
        enteredPINNotNumeric || enteredPINTooLong || (enteredPINTooShort && doneButtonPressed)
    }

    var warningMessage: String {
        if enteredPINNotNumeric {
            return L10n.cdwTxtPinWarningChar.text
        } else {
            return L10n.cdwTxtPinWarningCount("\(pin.lengthOfBytes(using: .utf8))").text
        }
    }
}

extension CardWallPINDomain {
    enum Dummies {
        static let state = State(isDemoModus: false, profileId: UUID(), pin: "", transition: .push)

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state) {
                CardWallPINDomain()
            }
        }
    }
}
