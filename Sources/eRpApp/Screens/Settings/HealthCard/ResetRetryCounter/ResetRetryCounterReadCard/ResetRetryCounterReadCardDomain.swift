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
import HealthCardControl

enum ResetRetryCounterReadCardDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: ResetRetryCounterReadCardDomain.Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case alert(AlertState<Action>)

        enum Tag: Int {
            case alert
        }

        var tag: Tag {
            switch self {
            case .alert:
                return .alert
            }
        }
    }

    struct State: Equatable {
        let withNewPin: Bool
        let can: String
        let puk: String
        let newPin: String

        var route: Route?
    }

    enum Action: Equatable {
        case readCard
        case resetRetryCounterResponseReceived(ResetRetryCounterResponse)
        case resetRetryCounterControllerErrorReceived(ResetRetryCounterControllerError)

        case close
        case okButtonTapped
        case navigateToSettings
        case setNavigation(tag: Route.Tag?)

        case nothing
    }

    struct Environment {
        let schedulers: Schedulers
        let nfcSessionController: NFCResetRetryCounterController
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .readCard:
            let can = state.can
            let puk = state.puk
            let pin = state.newPin
            return environment.resetEgkMrPinRetryCounterExt(
                withNewPin: state.withNewPin,
                can: state.can,
                puk: state.puk,
                pin: state.newPin
            )
            .receive(on: environment.schedulers.main)
            .eraseToEffect()

        case let .resetRetryCounterResponseReceived(resetRetryCounterResponse):
            switch resetRetryCounterResponse {
            case .success:
                state.route = .alert(AlertStates.cardUnlocked)
            case let .wrongSecretWarning(retryCount: retriesLeft):
                state.route = .alert(AlertStates.pukIncorrect(retriesLeft: retriesLeft))
            case .commandBlocked:
                state.route = state.withNewPin ?
                    .alert(AlertStates.pukCounterExhaustedWithSetNewPin) :
                    .alert(AlertStates.pukCounterExhausted)
            case .passwordNotFound,
                 .securityStatusNotSatisfied,
                 .memoryFailure,
                 .wrongPasswordLength,
                 .unknownFailure:
                state.route = .alert(AlertStates.unknownError)
            }
            return .none
        case let .resetRetryCounterControllerErrorReceived(resetRetryCounterControllerError):
            if case .wrongCan = resetRetryCounterControllerError {
                state.route = .alert(AlertStates.wrongCan)
            } else {
                state.route = .alert(AlertStates.alertFor(resetRetryCounterControllerError))
            }
            return .none

        case .close:
            return .none
        case .okButtonTapped:
            return .init(value: .navigateToSettings)
        case .navigateToSettings:
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

extension ResetRetryCounterReadCardDomain.Environment {
    func resetEgkMrPinRetryCounterExt(
        withNewPin: Bool,
        can: String,
        puk: String,
        pin: String
    ) -> Effect<ResetRetryCounterReadCardDomain.Action, Never> {
        .run { subscriber -> Cancellable in
            let mode: NFCResetRetryCounterControllerMode = withNewPin ? .setNewPassword(pin) : .withoutNewPassword
            return nfcSessionController
                .resetEgkMrPinRetryCounter(can: can, puk: puk, mode: mode)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            subscriber.send(.resetRetryCounterControllerErrorReceived(error))
                        }
                        subscriber.send(completion: .finished)
                    },
                    receiveValue: { value in
                        subscriber.send(.resetRetryCounterResponseReceived(value))
                    }
                )
        }
    }
}

extension ResetRetryCounterReadCardDomain {
    enum Dummies {
        static let state = State(withNewPin: false, can: "", puk: "", newPin: "")
        static let environment = Environment(
            schedulers: Schedulers(),
            nfcSessionController: DummyResetRetryCounterController()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
