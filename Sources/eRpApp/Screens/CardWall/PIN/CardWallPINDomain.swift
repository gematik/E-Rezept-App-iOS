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

import Combine
import ComposableArchitecture
import IDP
import SwiftUI

@Reducer
struct CardWallPINDomain {
    @ObservableState
    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String = ""
        var wrongPinEntered = false
        var doneButtonPressed = false
        let pinPassRange = (6 ... 8)
        var transition: TransitionMode
        @Presents var destination: Destination.State?

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

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall_saveLogin
        case login(CardWallLoginOptionDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        case egk(OrderHealthCardDomain)
    }

    indirect enum Action: Equatable {
        case update(pin: String)
        case advance(TransitionMode)

        case resetNavigation
        case egkButtonTapped
        case destination(PresentationAction<Destination.Action>)

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

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
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
        case .egkButtonTapped:
            state.destination = .egk(.init())
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .destination(.presented(.login(.delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                return Effect.send(.delegate(.close))
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
                return Effect.send(.delegate(.navigateToIntro))
            case .unlockCardClose:
                return Effect.send(.delegate(.unlockCardClose))
            }
        case .destination(.presented(.egk(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension CardWallPINDomain {
    enum Dummies {
        static let state = State(isDemoModus: false, profileId: UUID(), pin: "", transition: .push)

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<CardWallPINDomain> {
            Store(initialState: state) {
                CardWallPINDomain()
            }
        }
    }
}
