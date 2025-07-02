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
import HealthCardControl

@Reducer
struct HealthCardPasswordReadCardDomain {
    typealias Store = StoreOf<Self>

    enum Mode: Equatable {
        case healthCardResetPinCounterNoNewSecret(can: String, puk: String)
        case healthCardResetPinCounterWithNewSecret(can: String, puk: String, newPin: String)
        case healthCardSetNewPinSecret(can: String, oldPin: String, newPin: String)
    }

    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordReadCardDomain.Mode

        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case readCard
        case backButtonTapped

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

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

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = errorAlert
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {
            case settings
            case amendPin
            case amendPuk
            case amendCan
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.nfcHealthCardPasswordController) var nfcSessionController: NFCHealthCardPasswordController

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .readCard:
            return .run { [state = state] send in
                let action: Action
                switch state.mode {
                case let .healthCardResetPinCounterNoNewSecret(can: can, puk: puk):
                    action = await environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk)
                case let .healthCardResetPinCounterWithNewSecret(can: can, puk: puk, newPin: newPin):
                    action = await environment.resetEgkMrPinRetryCounterExt(can: can, puk: puk, newPin: newPin)
                case let .healthCardSetNewPinSecret(can: can, oldPin: oldPin, newPin: newPin):
                    action = await environment.changeEgkMrPinReferenceDataExt(can: can, oldPin: oldPin, pin: newPin)
                }
                await send(action)
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
            } else
            if case let .nfcHealthCardSession(nfcHealthCardSessionError) = nfcHealthCardPasswordControllerError,
               case let .coreNFC(coreNFCError) = nfcHealthCardSessionError {
                if case .userCanceled = coreNFCError {
                    return .none
                } else {
                    state.destination = .alert(.init(for: coreNFCError))
                }
            } else {
                state.destination = .alert(AlertStates.alertFor(nfcHealthCardPasswordControllerError))
            }
            return .none

        case .backButtonTapped:
            state.destination = nil
            return .send(.delegate(.close))
        case .destination(.presented(.alert(.settings))):
            state.destination = nil
            return .run { send in
                // Delay for waiting the close animation Workaround for TCA pullback problem
                try await schedulers.main.sleep(for: 0.5)
                await send(.delegate(.navigateToSettings))
            }
        case .destination(.presented(.alert(.amendCan))):
            state.destination = nil
            return .run { send in
                // Delay for waiting the close animation Workaround for TCA pullback problem
                try await schedulers.main.sleep(for: 0.5)
                await send(.delegate(.navigateToCanScreen))
            }
        case .destination(.presented(.alert(.amendPin))):
            state.destination = nil
            return .run { send in
                // Delay for waiting the close animation Workaround for TCA pullback problem
                try await schedulers.main.sleep(for: 0.5)
                await send(.delegate(.navigateToOldPinScreen))
            }
        case .destination(.presented(.alert(.amendPuk))):
            state.destination = nil
            return .run { send in
                // Delay for waiting the close animation Workaround for TCA pullback problem
                try await schedulers.main.sleep(for: 0.5)
                await send(.delegate(.navigateToPukScreen))
            }
        case .resetNavigation:
            state.destination = nil
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
        ) async -> HealthCardPasswordReadCardDomain.Action {
            let mode: NFCResetRetryCounterMode
            if let newPin = newPin {
                mode = .resetEgkMrPinRetryCountWithNewSecret(newPin)
            } else {
                mode = .resetEgkMrPinRetryCountWithoutNewSecret
            }
            let nfcHealthCardPasswordControllerResponse = await nfcSessionController
                .resetEgkMrPinRetryCounter(can: can, puk: puk, mode: mode)

            switch nfcHealthCardPasswordControllerResponse {
            case let .success(value):
                return .response(.nfcHealthCardPasswordControllerResponseReceived(value))
            case let .failure(error):
                return .response(.nfcHealthCardPasswordControllerErrorReceived(error))
            }
        }

        func changeEgkMrPinReferenceDataExt(
            can: String,
            oldPin: String,
            pin: String
        ) async -> HealthCardPasswordReadCardDomain.Action {
            let nfcHealthCardPasswordControllerResponse = await nfcSessionController
                .changeReferenceData(can: can, old: oldPin, new: pin, mode: .changeEgkMrPinSecret)

            switch nfcHealthCardPasswordControllerResponse {
            case let .success(value):
                return .response(.nfcHealthCardPasswordControllerResponseReceived(value))
            case let .failure(error):
                return .response(.nfcHealthCardPasswordControllerErrorReceived(error))
            }
        }
    }
}

extension HealthCardPasswordReadCardDomain {
    enum Dummies {
        static let state = State(mode: .healthCardResetPinCounterNoNewSecret(can: "", puk: ""))

        static let store = Store(initialState: state) {
            HealthCardPasswordReadCardDomain()
        }
    }
}
