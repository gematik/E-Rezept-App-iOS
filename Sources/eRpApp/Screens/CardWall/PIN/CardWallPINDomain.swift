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

enum CardWallPINDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        let isDemoModus: Bool
        var pin: String = ""
        var wrongPinEntered = false

        var showNextScreen = false
        var doneButtonPressed = false
        let pinPassRange = (6 ... 8)
    }

    enum Action: Equatable {
        case update(pin: String)
        case reset
        case close

        case advance
    }

    struct Environment {
        let userSession: UserSession

        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case let .update(pin: pin):
            state.pin = pin
            state.doneButtonPressed = false
            if state.showWarning {
                environment.accessibilityAnnouncementReceiver(state.warningMessage)
            }
            return .none
        case .reset:
            state.pin = ""
            state.showNextScreen = false
            return .none
        case .close:
            return .none
        case .advance:
            if state.enteredPINValid {
                state.showNextScreen = true
                return .none
            } else {
                state.doneButtonPressed = true
            }
            if state.showWarning {
                environment.accessibilityAnnouncementReceiver(state.warningMessage)
            }
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
        static let state = State(isDemoModus: false, pin: "")
        static let environment = Environment(userSession: DemoSessionContainer()) { _ in }

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
