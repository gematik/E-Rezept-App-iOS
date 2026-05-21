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
import eRpResources
import FeatureHelpers
import IDP
import SwiftUI

/// Domain for handling PIN input during card wall flow
@Reducer
public struct CardWallPINDomain {
    /// Initializes a new CardWallPINDomain
    public init() {}

    /// State for the PIN input screen
    @ObservableState
    public struct State: Equatable {
        init(
            profileId: UUID,
            pin: String = "",
            wrongPinEntered: Bool = false,
            doneButtonPressed: Bool = false,
            transition: CardWallPINDomain.TransitionMode,
            destination: CardWallPINDomain.Destination.State? = nil
        ) {
            self.profileId = profileId
            self.pin = pin
            self.wrongPinEntered = wrongPinEntered
            self.doneButtonPressed = doneButtonPressed
            self.transition = transition
            self.destination = destination
        }

        /// Initializes the PIN domain state
        /// - Parameters:
        ///   - profileId: The profile identifier
        ///   - wrongPinEntered: Whether a wrong PIN was previously entered
        ///   - transition: The transition mode for navigation
        public init(profileId: UUID, wrongPinEntered: Bool = false, transition: TransitionMode) {
            self.profileId = profileId
            self.wrongPinEntered = wrongPinEntered
            self.transition = transition
        }

        @Shared(.isDemoMode) var isDemoMode

        let profileId: UUID
        public var pin: String = ""
        var wrongPinEntered: Bool
        var doneButtonPressed = false
        let pinPassRange = (6 ... 8)
        var transition: TransitionMode
        @Presents public var destination: Destination.State?

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

    /// Destination states for navigation from PIN screen
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = cardWall_saveLogin
        /// Navigate to login options
        case login(CardWallLoginOptionDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        /// Navigate to health card ordering
        case egk(OrderHealthCardDomain)
    }

    /// Actions that can be performed in the PIN domain
    public indirect enum Action: Equatable {
        case update(pin: String)
        case advance(TransitionMode)

        case resetNavigation
        case egkButtonTapped
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        /// Delegate actions that can be sent to parent domains
        public enum Delegate: Equatable {
            case close
            case wrongCanClose
            case navigateToIntro
            case unlockCardClose
        }
    }

    /// Transition modes for navigation
    public enum TransitionMode: Equatable {
        case none
        case push
        case fullScreenCover
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.accessibilityAnnouncementReceiver) var receiver: AccessibilityAnnouncementReceiver

    /// The reducer body that handles state transitions and effects
    public var body: some Reducer<State, Action> {
        Reduce(core)
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
                    .init(profileId: state.profileId, pin: state.pin)
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
        static let state = State(profileId: UUID(), transition: .push)

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<CardWallPINDomain> {
            Store(initialState: state) {
                CardWallPINDomain()
            }
        }
    }
}

extension CardWallPINDomain.Destination.State: Equatable {}
extension CardWallPINDomain.Destination.Action: Equatable {}
