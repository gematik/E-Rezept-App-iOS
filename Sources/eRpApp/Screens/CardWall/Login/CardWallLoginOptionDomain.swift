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
import LocalAuthentication
import UIKit

enum CardWallLoginOptionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case alert(ErpAlertState<Action>)
        case readcard(CardWallReadCardDomain.State)
        case warning
    }

    struct State: Equatable {
        let isDemoModus: Bool
        var pin: String = ""
        var selectedLoginOption = LoginOption.notSelected
        var route: Route?
    }

    indirect enum Action: Equatable {
        case select(option: LoginOption)
        case advance
        case close
        case presentSecurityWarning
        case acceptSecurityWarning
        case openAppSpecificSettings
        case setNavigation(tag: Route.Tag?)
        case readcardAction(action: CardWallReadCardDomain.Action)
        case wrongCanClose
        case wrongPinClose
        case navigateToIntro
    }

    struct Environment {
        let userSession: UserSession
        var schedulers: Schedulers
        var sessionProvider: ProfileBasedSessionProvider
        let signatureProvider: SecureEnclaveSignatureProvider

        let canUseBiometrics: () -> Bool = {
            var error: NSError?
            let authenticationContext = LAContext()
            return authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                           error: &error) == true
        }

        let openURL: (URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?) -> Void
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .select(option: option):
            if state.selectedLoginOption == option, option.hasSelection {
                return .none
            }
            if option.isWithBiometry {
                guard environment.canUseBiometrics() else {
                    state.route = .alert(ErpAlertState(
                        title: TextState(L10n.cdwTxtBiometrySetupIncomplete),
                        message: nil,
                        primaryButton: .cancel(TextState(L10n.alertBtnOk)),
                        secondaryButton: .default(
                            TextState(L10n.tabTxtSettings),
                            action: .send(.openAppSpecificSettings)
                        )
                    ))
                    return .none
                }
                // [REQ:gemSpec_IDP_Frontend:A_21574] Present user information
                return Effect(value: .presentSecurityWarning)
            }
            state.selectedLoginOption = option
            return .none
        case .openAppSpecificSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                environment.openURL(url, [:], nil)
            }
            return .none
        case .advance:
            state.route = .readcard(.init(isDemoModus: state.isDemoModus,
                                          profileId: environment.userSession.profileId,
                                          pin: state.pin,
                                          loginOption: state.isDemoModus ? .withoutBiometry : state.selectedLoginOption,
                                          output: .idle))
            return .none
        case .close:
            return .none
        case .presentSecurityWarning:
            state.route = .warning
            return .none
        case .acceptSecurityWarning:
            state.selectedLoginOption = .withBiometry
            state.route = nil
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .readcardAction(.close):
            return Effect(value: .close)
                // Delay for waiting the close animation Workaround for TCA pullback problem
                .delay(for: 0.5, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .readcardAction(.singleClose):
            state.route = nil
            return .none
        case .readcardAction(.wrongCAN):
            return Effect(value: .wrongCanClose)
                // Delay for waiting the close animation Workaround for TCA pullback problem
                .delay(for: 0.1, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .readcardAction(.wrongPIN):
            return Effect(value: .wrongPinClose)
        case .readcardAction(.navigateToIntro):
            return Effect(value: .navigateToIntro)
                // Delay for waiting the close animation Workaround for TCA pullback problem
                .delay(for: 1.1, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation,
             .readcardAction,
             .wrongCanClose,
             .wrongPinClose,
             .navigateToIntro:
            return .none
        }
    }

    static let readCardPullbackReducer: Reducer =
        CardWallReadCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.readcard),
            action: /Action.readcardAction(action:)
        ) { environment in
            CardWallReadCardDomain.Environment(
                schedulers: environment.schedulers,
                profileDataStore: environment.userSession.profileDataStore,
                signatureProvider: environment.signatureProvider,
                sessionProvider: environment.sessionProvider,
                nfcSessionProvider: environment.userSession.nfcSessionProvider,
                application: UIApplication.shared
            )
        }

    static let reducer = Reducer.combine(
        readCardPullbackReducer,
        domainReducer
    )
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
            userSession: DummySessionContainer(),
            schedulers: Schedulers(),
            sessionProvider: DummyProfileBasedSessionProvider(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            openURL: UIApplication.shared.open(_:options:completionHandler:)
        )

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
