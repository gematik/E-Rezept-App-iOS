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
import HealthCardControl

struct HealthCardPasswordReadCardDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    enum Mode: Equatable {
        case healthCardResetPinCounterNoNewSecret(can: String, puk: String)
        case healthCardResetPinCounterWithNewSecret(can: String, puk: String, newPin: String)
        case healthCardSetNewPinSecret(can: String, oldPin: String, newPin: String)
    }

    struct State: Equatable {
        let mode: HealthCardPasswordReadCardDomain.Mode

        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        case readCard
        case backButtonTapped

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        case response(Response)
        case delegate(Delegate)

        enum Response: Equatable {
            // swiftlint:disable identifier_name
            case nfcHealthCardPasswordControllerResponseReceived(NFCHealthCardPasswordControllerResponse)
            case nfcHealthCardPasswordControllerErrorReceived(NFCHealthCardPasswordControllerError)
            // swiftlint:enable identifier_name
        }

        enum Delegate: Equatable {
            case close
            case navigateToSettings
            case navigateToCanScreen
            case navigateToOldPinScreen
            case navigateToPukScreen
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = errorAlert
            case alert(ErpAlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case alert(Alert)

            enum Alert: Equatable {
                case dismiss
                case settings
                case amendPin
                case amendPuk
                case amendCan
            }
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.nfcHealthCardPasswordController) var nfcSessionController: NFCHealthCardPasswordController

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .readCard:
            switch state.mode {
            case let .healthCardResetPinCounterNoNewSecret(can: can, puk: puk):
                return .publisher(
                    environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )

            case let .healthCardResetPinCounterWithNewSecret(can: can, puk: puk, newPin: newPin):
                return .publisher(
                    environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk, newPin: newPin)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )

            case let .healthCardSetNewPinSecret(can: can, oldPin: oldPin, newPin: newPin):
                return .publisher(
                    environment.changeEgkMrPinReferenceDataExt(can: can, oldPin: oldPin, pin: newPin)
                        .receive(on: schedulers.main)
                        .eraseToAnyPublisher
                )
            }

        case let .response(.nfcHealthCardPasswordControllerResponseReceived(nfcHealthCardPasswordControllerResponse)):
            switch (nfcHealthCardPasswordControllerResponse, state.mode) {
            // success
            case (.success, .healthCardResetPinCounterWithNewSecret):
                state.destination = .alert(AlertStates.cardUnlockedWithSetNewPin)
            case (.success, .healthCardResetPinCounterNoNewSecret):
                state.destination = .alert(AlertStates.cardUnlocked)
            case (.success, .healthCardSetNewPinSecret):
                state.destination = .alert(AlertStates.setNewPin)

            // warning: retry counter
            case let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardResetPinCounterWithNewSecret),
                 let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardResetPinCounterNoNewSecret):
                state.destination = .alert(AlertStates.pukIncorrect(retriesLeft: retriesLeft))
            case let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardSetNewPinSecret):
                state.destination = .alert(AlertStates.pinIncorrect(retriesLeft: retriesLeft))

            // error: blocked
            case (.commandBlocked, .healthCardResetPinCounterWithNewSecret):
                state.destination = .alert(AlertStates.pukCounterExhaustedWithSetNewPin)
            case (.commandBlocked, .healthCardResetPinCounterNoNewSecret):
                state.destination = .alert(AlertStates.pukCounterExhausted)
            case (.commandBlocked, .healthCardSetNewPinSecret):
                state.destination = .alert(AlertStates.pinCounterExhausted)

            // error: others
            case (.passwordNotFound, _):
                state.destination = .alert(AlertStates.passwordNotFound)
            case (.securityStatusNotSatisfied, _):
                state.destination = .alert(AlertStates.securityStatusNotSatisfied)
            case (.memoryFailure, _):
                state.destination = .alert(AlertStates.memoryFailure)
            case (.unknownFailure, _):
                state.destination = .alert(AlertStates.unknownFailure)
            case (.wrongPasswordLength, _):
                state.destination = .alert(AlertStates.unknownError)
            }
            return .none

        case let .response(.nfcHealthCardPasswordControllerErrorReceived(nfcHealthCardPasswordControllerError)):
            if case .wrongCan = nfcHealthCardPasswordControllerError {
                state.destination = .alert(AlertStates.wrongCan)
            } else if let tagError = nfcHealthCardPasswordControllerError.underlyingTagError {
                if case .userCanceled = tagError { return .none }
                state.destination = .alert(.init(for: tagError))
            } else {
                state.destination = .alert(AlertStates.alertFor(nfcHealthCardPasswordControllerError))
            }
            return .none

        case .backButtonTapped:
            state.destination = nil
            return .send(.delegate(.close))
        case .destination(.presented(.alert(.settings))):
            state.destination = nil
            return .send(.delegate(.navigateToSettings))
        case .destination(.presented(.alert(.amendCan))):
            state.destination = nil
            return .send(.delegate(.navigateToCanScreen))
        case .destination(.presented(.alert(.amendPin))):
            state.destination = nil
            return .send(.delegate(.navigateToOldPinScreen))
        case .destination(.presented(.alert(.amendPuk))):
            state.destination = nil
            return .send(.delegate(.navigateToPukScreen))
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation:
            return .none
        case .delegate,
             .destination:
            return .none
        }
    }
}

extension HealthCardPasswordReadCardDomain {
    var environment: Environment {
        .init(schedulers: schedulers, nfcSessionController: nfcSessionController)
    }

    struct Environment {
        let schedulers: Schedulers
        let nfcSessionController: NFCHealthCardPasswordController

        func resetEgkMrPinRetryCounterExt(
            can: String,
            puk: String,
            newPin: String? = nil
        ) -> AnyPublisher<HealthCardPasswordReadCardDomain.Action, Never> {
            let mode: NFCResetRetryCounterMode
            if let newPin = newPin {
                mode = .resetEgkMrPinRetryCountWithNewSecret(newPin)
            } else {
                mode = .resetEgkMrPinRetryCountWithoutNewSecret
            }
            return nfcSessionController
                .resetEgkMrPinRetryCounter(can: can, puk: puk, mode: mode)
                .map {
                    HealthCardPasswordReadCardDomain.Action.response(
                        .nfcHealthCardPasswordControllerResponseReceived($0)
                    )
                }
                .catch {
                    Just(
                        HealthCardPasswordReadCardDomain.Action.response(
                            .nfcHealthCardPasswordControllerErrorReceived($0)
                        )
                    )
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        func changeEgkMrPinReferenceDataExt(
            can: String,
            oldPin: String,
            pin: String
        ) -> AnyPublisher<HealthCardPasswordReadCardDomain.Action, Never> {
            nfcSessionController
                .changeReferenceData(can: can, old: oldPin, new: pin, mode: .changeEgkMrPinSecret)
                .map {
                    Action.response(.nfcHealthCardPasswordControllerResponseReceived($0))
                }
                .catch {
                    Just(Action.response(.nfcHealthCardPasswordControllerErrorReceived($0)))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }
}

extension HealthCardPasswordReadCardDomain {
    enum Dummies {
        static let state = State(mode: .healthCardResetPinCounterNoNewSecret(can: "", puk: ""))

        static let store = Store(
            initialState: state
        ) {
            HealthCardPasswordReadCardDomain()
        }
    }
}
