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
import LocalAuthentication
import Settings
import UIKit

/// Domain for handling login option selection during card wall flow
@Reducer
public struct CardWallLoginOptionDomain {
    /// State for the login option screen
    @ObservableState
    public struct State: Equatable {
        @Shared(.isDemoMode) var isDemoMode

        let profileId: UUID
        var pin: String = ""
        var selectedLoginOption = LoginOption.notSelected
        @Presents public var destination: Destination.State?
    }

    /// Destination states for navigation from login option screen
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = alert
        /// Show alert dialog
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)
        // sourcery: AnalyticsScreen = cardWall_readCard
        /// Navigate to card reading
        case readCard(CardWallReadCardDomain)
        // sourcery: AnalyticsScreen = cardWall_saveLoginSecurityInfo
        /// Show security warning
        case warning

        /// Alert types
        public enum Alert: Equatable {
            case dismiss
            case openAppSpecificSettings
        }
    }

    /// Actions that can be performed in the login option domain
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)

        case advance
        case presentSecurityWarning
        case acceptSecurityWarning

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case close
            case wrongCanClose
            case wrongPinClose
            case navigateToIntro
            case unlockCardClose
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.openURLHandler) var openURLHandler
    @Dependency(\.securityPolicyEvaluator) var securityPolicyEvaluator: SecurityPolicyEvaluator
    func canUseBiometrics() -> Bool {
        var error: NSError?
        return securityPolicyEvaluator.canEvaluatePolicy(policy: .deviceOwnerAuthenticationWithBiometrics,
                                                         error: &error) == true
    }

    /// The reducer body that handles state transitions and effects
    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding(\.selectedLoginOption):
            if state.selectedLoginOption.isWithBiometry {
                guard canUseBiometrics() else {
                    state.destination = .alert(ErpAlertState(
                        title: L10n.cdwTxtBiometrySetupIncomplete
                    ) {
                        ButtonState(role: .cancel) {
                            .init(L10n.alertBtnOk)
                        }
                        ButtonState(action: .openAppSpecificSettings) {
                            .init(L10n.tabTxtSettings)
                        }
                    })
                    return .none
                }
                // [REQ:gemSpec_IDP_Frontend:A_21574] Present user information
                return Effect.send(.presentSecurityWarning)
            }
            return .none
        case .destination(.presented(.alert(.openAppSpecificSettings))):
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return .none }
            return .run { _ in
                _ = await openURLHandler.open(url)
            }
        case .advance:
            state.destination = .readCard(.init(profileId: state.profileId,
                                                pin: state.pin,
                                                loginOption: state.isDemoMode ? .withoutBiometry : state
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
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .destination(.presented(.readCard(.delegate(destinationAction)))):
            switch destinationAction {
            case .close:
                return Effect.send(.delegate(.close))
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
                return Effect.send(.delegate(.wrongPinClose))
            case .navigateToIntro:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 1.1)
                    await send(.delegate(.navigateToIntro))
                }
            case .unlockCardClose:
                return .run { send in
                    // Delay for waiting the close animation Workaround for TCA pullback problem
                    try await schedulers.main.sleep(for: 0.1)
                    await send(.delegate(.unlockCardClose))
                }
            }
        case .binding,
             .destination,
             .delegate:
            return .none
        }
    }
}

/// Login options available during card wall authentication
public enum LoginOption {
    /// Login with biometric authentication
    case withBiometry
    /// Login without biometric authentication
    case withoutBiometry
    /// No option selected yet
    case notSelected

    var hasSelection: Bool {
        self != .notSelected
    }

    var isWithBiometry: Bool {
        get { self == .withBiometry }
        set {
            if newValue {
                self = .withBiometry
            }
        }
    }

    var isWithoutBiometry: Bool {
        get { self == .withoutBiometry }
        set {
            if newValue {
                self = .withoutBiometry
            }
        }
    }
}

extension CardWallLoginOptionDomain {
    enum Dummies {
        static let state = State(profileId: UUID())

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> StoreOf<CardWallLoginOptionDomain> {
            Store(initialState: state) {
                CardWallLoginOptionDomain()
            }
        }
    }
}

extension CardWallLoginOptionDomain.Destination.State: Equatable {}
extension CardWallLoginOptionDomain.Destination.Action: Equatable {}
