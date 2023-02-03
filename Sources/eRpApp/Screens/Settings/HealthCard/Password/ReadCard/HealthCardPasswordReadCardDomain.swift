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

enum HealthCardPasswordReadCardDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: HealthCardPasswordReadCardDomain.Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case alert(ErpAlertState<Action>)
    }

    enum Mode: Equatable {
        case healthCardResetPinCounterNoNewSecret(can: String, puk: String)
        case healthCardResetPinCounterWithNewSecret(can: String, puk: String, newPin: String)
        case healthCardSetNewPinSecret(can: String, oldPin: String, newPin: String)
    }

    struct State: Equatable {
        let mode: HealthCardPasswordReadCardDomain.Mode

        var route: Route?
    }

    enum Action: Equatable {
        case readCard
        // swiftlint:disable identifier_name
        case nfcHealthCardPasswordControllerResponseReceived(NFCHealthCardPasswordControllerResponse)
        case nfcHealthCardPasswordControllerErrorReceived(NFCHealthCardPasswordControllerError)
        // swiftlint:enable identifier_name

        case close
        case alertOkButtonTapped
        case alertCancelButtonTapped
        case alertAmendCanButtonTapped
        case alertAmendPinButtonTapped
        case alertAmendPukButtonTapped
        case navigateToSettings
        case navigateToCanScreen
        case navigateToOldPinScreen
        case navigateToPukScreen
        case setNavigation(tag: Route.Tag?)

        case nothing
    }

    struct Environment {
        let schedulers: Schedulers
        let nfcSessionController: NFCHealthCardPasswordController
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .readCard:
            switch state.mode {
            case let .healthCardResetPinCounterNoNewSecret(can: can, puk: puk):
                return environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()

            case let .healthCardResetPinCounterWithNewSecret(can: can, puk: puk, newPin: newPin):
                return environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk, newPin: newPin)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()

            case let .healthCardSetNewPinSecret(can: can, oldPin: oldPin, newPin: newPin):
                return environment.changeEgkMrPinReferenceDataExt(can: can, oldPin: oldPin, pin: newPin)
                    .receive(on: environment.schedulers.main)
                    .eraseToEffect()
            }

        case let .nfcHealthCardPasswordControllerResponseReceived(nfcHealthCardPasswordControllerResponse):
            switch (nfcHealthCardPasswordControllerResponse, state.mode) {
            // success
            case (.success, .healthCardResetPinCounterWithNewSecret):
                state.route = .alert(AlertStates.cardUnlockedWithSetNewPin)
            case (.success, .healthCardResetPinCounterNoNewSecret):
                state.route = .alert(AlertStates.cardUnlocked)
            case (.success, .healthCardSetNewPinSecret):
                state.route = .alert(AlertStates.setNewPin)

            // warning: retry counter
            case let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardResetPinCounterWithNewSecret),
                 let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardResetPinCounterNoNewSecret):
                state.route = .alert(AlertStates.pukIncorrect(retriesLeft: retriesLeft))
            case let (.wrongSecretWarning(retryCount: retriesLeft), .healthCardSetNewPinSecret):
                state.route = .alert(AlertStates.pinIncorrect(retriesLeft: retriesLeft))

            // error: blocked
            case (.commandBlocked, .healthCardResetPinCounterWithNewSecret):
                state.route = .alert(AlertStates.pukCounterExhaustedWithSetNewPin)
            case (.commandBlocked, .healthCardResetPinCounterNoNewSecret):
                state.route = .alert(AlertStates.pukCounterExhausted)
            case (.commandBlocked, .healthCardSetNewPinSecret):
                state.route = .alert(AlertStates.pinCounterExhausted)

            // error: others
            case (.passwordNotFound, _):
                state.route = .alert(AlertStates.passwordNotFound)
            case (.securityStatusNotSatisfied, _):
                state.route = .alert(AlertStates.securityStatusNotSatisfied)
            case (.memoryFailure, _):
                state.route = .alert(AlertStates.memoryFailure)
            case (.unknownFailure, _):
                state.route = .alert(AlertStates.unknownFailure)
            case (.wrongPasswordLength, _):
                state.route = .alert(AlertStates.unknownError)
            }
            return .none

        case let .nfcHealthCardPasswordControllerErrorReceived(nfcHealthCardPasswordControllerError):
            if case .wrongCan = nfcHealthCardPasswordControllerError {
                state.route = .alert(AlertStates.wrongCan)
            } else if let tagError = nfcHealthCardPasswordControllerError.underlyingTagError {
                if case .userCanceled = tagError { return .none }
                state.route = .alert(.init(for: tagError))
            } else {
                state.route = .alert(AlertStates.alertFor(nfcHealthCardPasswordControllerError))
            }
            return .none

        case .close:
            return .none
        case .alertOkButtonTapped:
            return .init(value: .navigateToSettings)
        case .alertCancelButtonTapped:
            return .init(value: .setNavigation(tag: .none))
        case .alertAmendCanButtonTapped:
            return .init(value: .navigateToCanScreen)
        case .alertAmendPinButtonTapped:
            return .init(value: .navigateToOldPinScreen)
        case .alertAmendPukButtonTapped:
            return .init(value: .navigateToPukScreen)
        case .navigateToSettings:
            state.route = nil
            return .none
        case .navigateToCanScreen:
            state.route = nil
            return .none
        case .navigateToOldPinScreen:
            state.route = nil
            return .none
        case .navigateToPukScreen:
            state.route = nil
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .setNavigation:
            return .none
        case .nothing:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        domainReducer
    )
}

extension HealthCardPasswordReadCardDomain.Environment {
    func resetEgkMrPinRetryCounterExt(
        can: String,
        puk: String,
        newPin: String? = nil
    ) -> Effect<HealthCardPasswordReadCardDomain.Action, Never> {
        .run { subscriber -> Cancellable in
            let mode: NFCResetRetryCounterMode
            if let newPin = newPin {
                mode = .resetEgkMrPinRetryCountWithNewSecret(newPin)
            } else {
                mode = .resetEgkMrPinRetryCountWithoutNewSecret
            }
            return nfcSessionController
                .resetEgkMrPinRetryCounter(can: can, puk: puk, mode: mode)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            subscriber.send(.nfcHealthCardPasswordControllerErrorReceived(error))
                        }
                        subscriber.send(completion: .finished)
                    },
                    receiveValue: { value in
                        subscriber.send(.nfcHealthCardPasswordControllerResponseReceived(value))
                    }
                )
        }
    }

    func changeEgkMrPinReferenceDataExt(
        can: String,
        oldPin: String,
        pin: String
    ) -> Effect<HealthCardPasswordReadCardDomain.Action, Never> {
        .run { subscriber -> Cancellable in
            nfcSessionController
                .changeReferenceData(can: can, old: oldPin, new: pin, mode: .changeEgkMrPinSecret)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            subscriber.send(.nfcHealthCardPasswordControllerErrorReceived(error))
                        }
                        subscriber.send(completion: .finished)
                    },
                    receiveValue: { value in
                        subscriber.send(.nfcHealthCardPasswordControllerResponseReceived(value))
                    }
                )
        }
    }
}

extension HealthCardPasswordReadCardDomain {
    enum Dummies {
        static let state = State(mode: .healthCardResetPinCounterNoNewSecret(can: "", puk: ""))
        static let environment = Environment(
            schedulers: Schedulers(),
            nfcSessionController: DummyNFCHealthCardPasswordController()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
