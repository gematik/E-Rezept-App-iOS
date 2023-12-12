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
import IDP
import LocalAuthentication
import UIKit

struct CardWallLoginOptionDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        let isDemoModus: Bool
        let profileId: UUID
        var pin: String = ""
        var selectedLoginOption = LoginOption.notSelected
        @PresentationState var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<Action.Alert>)
            // sourcery: AnalyticsScreen = cardWall_readCard
            case readcard(CardWallReadCardDomain.State)
            // sourcery: AnalyticsScreen = cardWall_saveLoginSecurityInfo
            case warning
        }

        enum Action: Equatable {
            case readcardAction(action: CardWallReadCardDomain.Action)
            case alert(Alert)

            public enum Alert: Equatable {
                case dismiss
                case openAppSpecificSettings
            }
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.readcard,
                action: /Action.readcardAction
            ) {
                CardWallReadCardDomain()
            }
        }
    }

    indirect enum Action: Equatable {
        case select(option: LoginOption)
        case advance
        case presentSecurityWarning
        case acceptSecurityWarning

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        case delegate(Delegate)

        enum Delegate: Equatable {
            case close
            case wrongCanClose
            case wrongPinClose
            case navigateToIntro
        }
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.resourceHandler) var resourceHandler: ResourceHandler

    let canUseBiometrics: () -> Bool = {
        var error: NSError?
        let authenticationContext = LAContext()
        return authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                       error: &error) == true
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .select(option: option):
            if state.selectedLoginOption == option, option.hasSelection {
                return .none
            }
            if option.isWithBiometry {
                guard canUseBiometrics() else {
                    state.destination = .alert(ErpAlertState(
                        title: L10n.cdwTxtBiometrySetupIncomplete,
                        actions: {
                            ButtonState(role: .cancel) {
                                .init(L10n.alertBtnOk)
                            }
                            ButtonState(action: .openAppSpecificSettings) {
                                .init(L10n.tabTxtSettings)
                            }
                        }
                    ))
                    return .none
                }
                // [REQ:gemSpec_IDP_Frontend:A_21574] Present user information
                return EffectTask.send(.presentSecurityWarning)
            }
            state.selectedLoginOption = option
            return .none
        case .destination(.presented(.alert(.openAppSpecificSettings))):
            if let url = URL(string: UIApplication.openSettingsURLString) {
                resourceHandler.open(url)
            }
            return .none
        case .advance:
            state.destination = .readcard(.init(isDemoModus: state.isDemoModus,
                                                profileId: state.profileId,
                                                pin: state.pin,
                                                loginOption: state.isDemoModus ? .withoutBiometry : state
                                                    .selectedLoginOption,
                                                output: .idle))
            return .none
        case .presentSecurityWarning:
            state.destination = .warning
            return .none
        case .acceptSecurityWarning:
            state.selectedLoginOption = .withBiometry
            state.destination = nil
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case let .destination(.presented(.readcardAction(.delegate(destinationAction)))):
            switch destinationAction {
            case .close:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.delegate(.close))
                }
            case .singleClose:
                state.destination = nil
                return .none
            case .wrongCAN:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 0.1)
                    await send(.delegate(.wrongCanClose))
                }
            case .wrongPIN:
                return EffectTask.send(.delegate(.wrongPinClose))
            case .navigateToIntro:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 1.1)
                    await send(.delegate(.navigateToIntro))
                }
            }
        case .setNavigation,
             .destination,
             .delegate:
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
        static let state = State(isDemoModus: false, profileId: UUID())

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<CardWallLoginOptionDomain> {
            Store(initialState: state) {
                CardWallLoginOptionDomain()
            }
        }
    }
}
