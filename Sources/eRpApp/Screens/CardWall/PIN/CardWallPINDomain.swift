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
import IDP
import SwiftUI

enum CardWallPINDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    indirect enum Route: Equatable {
        case login(CardWallLoginOptionDomain.State)
        case egk

        enum Tag: Int {
            case login
            case egk
        }

        var tag: Tag {
            switch self {
            case .login:
                return .login
            case .egk:
                return .egk
            }
        }
    }

    struct State: Equatable {
        let isDemoModus: Bool
        var pin: String = ""
        var wrongPinEntered = false
        var doneButtonPressed = false
        let pinPassRange = (6 ... 8)

        var route: Route?
    }

    indirect enum Action: Equatable {
        case update(pin: String)
        case close
        case advance
        case showEGKOrderInfoView
        case setNavigation(tag: Route.Tag?)
        case login(action: CardWallLoginOptionDomain.Action)
        case navigateToIntro
        case wrongCanClose
    }

    enum TransitionMode: Equatable {
        case none
        case push
        case fullScreenCover
    }

    struct Environment {
        let userSession: UserSession
        var schedulers: Schedulers
        var sessionProvider: ProfileBasedSessionProvider
        let signatureProvider: SecureEnclaveSignatureProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .update(pin: pin):
            state.pin = pin
            state.doneButtonPressed = false
            if state.showWarning {
                environment.accessibilityAnnouncementReceiver(state.warningMessage)
            }
            return .none
        case .close:
            return .none
        case .advance:
            if state.enteredPINValid {
                state.route = .login(.init(isDemoModus: state.isDemoModus,
                                           pin: state.pin))
                return .none
            } else {
                state.doneButtonPressed = true
            }
            if state.showWarning {
                environment.accessibilityAnnouncementReceiver(state.warningMessage)
            }
            return .none
        case .showEGKOrderInfoView:
            state.route = .egk
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .login(.wrongCanClose):
            return Effect(value: .wrongCanClose)
                // Delay for before CardWallCanView is displayed, Workaround for TCA pullback problem
                .delay(for: 0.01, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .login(.wrongPinClose):
            state.route = nil
            return .none
        case .login(.close):
            return Effect(value: .close)
        case .login(.navigateToIntro):
            return Effect(value: .navigateToIntro)
        case .setNavigation,
             .login,
             .navigateToIntro,
             .wrongCanClose:
            return .none
        }
    }

    static let loginPullbackReducer: Reducer =
        CardWallLoginOptionDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.login),
            action: /Action.login(action:)
        ) { environment in
            CardWallLoginOptionDomain.Environment(userSession: environment.userSession,
                                                  schedulers: environment.schedulers,
                                                  sessionProvider: environment.sessionProvider,
                                                  signatureProvider: environment.signatureProvider,
                                                  openURL: UIApplication.shared.open(_:options:completionHandler:))
        }

    static let reducer = Reducer.combine(
        loginPullbackReducer,
        domainReducer
    )
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
        static let environment = Environment(
            userSession: DemoSessionContainer(schedulers: Schedulers()),
            schedulers: Schedulers(),
            sessionProvider: DummyProfileBasedSessionProvider(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        ) { _ in }

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
