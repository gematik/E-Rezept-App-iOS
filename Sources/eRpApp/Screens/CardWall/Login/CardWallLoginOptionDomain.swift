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
import LocalAuthentication
import UIKit

enum CardWallLoginOptionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        let isDemoModus: Bool
        var pin: String = ""
        var selectedLoginOption = LoginOption.notSelected
        var isSecurityWarningPresented = false
        var showNextScreen = false
        var alertState: AlertState<Action>?
    }

    enum Action: Equatable {
        case select(option: LoginOption)
        case advance
        case navigateBack
        case close
        case presentSecurityWarning
        case acceptSecurityWarning
        case dismissSecurityWarning
        case dismissAlert
        case openAppSpecificSettings
    }

    struct Environment {
        let userSession: UserSession

        let canUseBiometrics: () -> Bool = {
            var error: NSError?
            let authenticationContext = LAContext()
            return authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                           error: &error) == true
        }

        let openURL: (URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?) -> Void
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case let .select(option: option):
            if state.selectedLoginOption == option, option.hasSelection {
                return .none
            }
            if option.isWithBiometry {
                guard environment.canUseBiometrics() else {
                    state.alertState = AlertState(
                        title: TextState(L10n.cdwTxtBiometrySetupIncomplete),
                        message: nil,
                        primaryButton: .cancel(TextState(L10n.alertBtnOk)),
                        secondaryButton: .default(
                            TextState(L10n.tabTxtSettings),
                            action: .send(.openAppSpecificSettings)
                        )
                    )
                    return .none
                }
                // [REQ:gemSpec_IDP_Frontend:A_21574] Present user information
                return Effect(value: .presentSecurityWarning)
            }
            state.selectedLoginOption = option
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        case .openAppSpecificSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                environment.openURL(url, [:], nil)
            }
            return .none
        case .advance:
            state.showNextScreen = true
            return .none
        case .navigateBack:
            state.showNextScreen = false
            return .none
        case .close:
            return .none
        case .presentSecurityWarning:
            state.isSecurityWarningPresented = true
            return .none
        case .acceptSecurityWarning:
            state.selectedLoginOption = .withBiometry
            state.isSecurityWarningPresented = false
            return .none
        case .dismissSecurityWarning:
            state.isSecurityWarningPresented = false
            return .none
        }
    }
}

enum LoginOption {
    case withBiometry
    case withoutBiometry
    case notSelected

    var hasSelection: Bool {
        self != .notSelected
    }

    var isWithBiometry: Bool {
        self == .withBiometry
    }

    var isWithoutBiometry: Bool {
        self == .withoutBiometry
    }
}

extension CardWallLoginOptionDomain {
    enum Dummies {
        static let state = State(isDemoModus: false)
        static let environment = Environment(
            userSession: DemoSessionContainer(),
            openURL: UIApplication.shared.open(_:options:completionHandler:)
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
