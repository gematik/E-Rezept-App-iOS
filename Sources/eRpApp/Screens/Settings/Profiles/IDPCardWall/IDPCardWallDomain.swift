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
import HealthCardAccess
import IDP
import UIKit

enum IDPCardWallDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: Token.self),
            CardWallReadCardDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        let profileId: UUID

        var canAvailable: Bool {
            can == nil
        }

        var can: CardWallCANDomain.State?
        var pin: CardWallPINDomain.State
        var readCard: CardWallReadCardDomain.State?
    }

    enum Action: Equatable {
        case canAction(action: CardWallCANDomain.Action)
        case pinAction(action: CardWallPINDomain.Action)
        case readCard(action: CardWallReadCardDomain.Action)

        case finished
        case close
    }

    struct Environment {
        let schedulers: Schedulers
        let userSession: UserSession
        let userSessionProvider: UserSessionProvider
        let secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider
        let nfcSignatureProvider: NFCSignatureProvider
        var sessionProvider: ProfileBasedSessionProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    static var dismissTimeout: DispatchQueue.SchedulerTimeType.Stride = 0.5

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .pinAction(action: .advance):
            state.readCard = CardWallReadCardDomain.State(
                isDemoModus: environment.userSession.isDemoMode,
                profileId: state.profileId,
                pin: state.pin.pin,
                loginOption: .withoutBiometry,
                output: .idle
            )
            return .none
        case .readCard(action: .wrongCAN):
            if state.can == nil {
                state.can = CardWallCANDomain.State(
                    isDemoModus: false,
                    profileId: state.profileId,
                    can: ""
                )
            }
            state.can?.wrongCANEntered = true
            state.pin.route = nil
            state.can?.route = nil
            return .none
        case .readCard(action: .wrongPIN):
            state.pin.wrongPinEntered = true
            state.pin.route = nil
            return .none
        case .canAction(action: .close),
             .pinAction(action: .close):
            // closing a subscreen should close the whole stack -> forward to generic `.close`
            return Effect(value: .close)
        case .readCard(action: .close):
            state.pin.route = nil
            return Effect(value: .finished)
                .delay(for: dismissTimeout, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .close,
             .finished,
             .canAction,
             .pinAction,
             .readCard:
            return .none
        }
    }

    static let canPullbackReducer: Reducer =
        CardWallCANDomain.reducer.optional().pullback(
            state: \.can,
            action: /Action.canAction(action:)
        ) {
            .init(
                sessionProvider: $0.sessionProvider,
                signatureProvider: $0.secureEnclaveSignatureProvider,
                userSession: $0.userSession,
                accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver,
                schedulers: $0.schedulers
            )
        }

    static let pinPullbackReducer: Reducer =
        CardWallPINDomain.reducer.pullback(
            state: \.pin,
            action: /Action.pinAction(action:)
        ) {
            .init(
                userSession: $0.userSession,
                schedulers: $0.schedulers,
                sessionProvider: $0.sessionProvider,
                signatureProvider: $0.secureEnclaveSignatureProvider,
                accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver
            )
        }

    static let readCardPullbackReducer: Reducer =
        CardWallReadCardDomain.reducer.optional().pullback(
            state: \.readCard,
            action: /Action.readCard(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                profileDataStore: $0.userSession.profileDataStore,
                signatureProvider: $0.secureEnclaveSignatureProvider,
                sessionProvider: $0.sessionProvider,
                nfcSessionProvider: $0.userSession.nfcSessionProvider,
                application: UIApplication.shared
            )
        }

    static let reducer: Reducer = .combine(
        readCardPullbackReducer,
        pinPullbackReducer,
        canPullbackReducer,
        domainReducer
    )
}

extension IDPCardWallDomain {
    enum Dummies {
        static let state = State(
            profileId: DemoProfileDataStore.anna.id,
            can: CardWallCANDomain.State(isDemoModus: false, profileId: UUID(), can: ""),
            pin: CardWallPINDomain.State(isDemoModus: false, pin: "")
        )

        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            userSessionProvider: DummyUserSessionProvider(),
            secureEnclaveSignatureProvider: DummySecureEnclaveSignatureProvider(),
            nfcSignatureProvider: DemoSignatureProvider(),
            sessionProvider: DummyProfileBasedSessionProvider()
        ) { _ in }

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)
    }
}
