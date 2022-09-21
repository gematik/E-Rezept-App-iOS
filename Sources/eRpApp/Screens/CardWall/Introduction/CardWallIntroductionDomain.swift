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

enum CardWallIntroductionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: CardWallReadCardDomain.Token.self)
    }

    enum Route: Equatable {
        case can(CardWallCANDomain.State)
        case pin(CardWallPINDomain.State)
        case fasttrack(CardWallExtAuthSelectionDomain.State)
        case egk
        case notCapable

        enum Tag: Int {
            case can
            case pin
            case fasttrack
            case egk
            case notCapable
        }

        var tag: Tag {
            switch self {
            case .can:
                return .can
            case .pin:
                return .pin
            case .fasttrack:
                return .fasttrack
            case .egk:
                return .egk
            case .notCapable:
                return .notCapable
            }
        }
    }

    struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool

        var canAvailable: Bool {
            can != nil
        }

        var can: CardWallCANDomain.State?
        var route: Route?
    }

    indirect enum Action: Equatable {
        case advance
        case showEGKOrderInfoView
        case close
        case setNavigation(tag: Route.Tag?)
        case canAction(action: CardWallCANDomain.Action)
        case fasttrack(action: CardWallExtAuthSelectionDomain.Action)
        case pinAction(action: CardWallPINDomain.Action)
    }

    struct Environment {
        let userSession: UserSession
        var sessionProvider: ProfileBasedSessionProvider
        var schedulers: Schedulers
        var signatureProvider: SecureEnclaveSignatureProvider
        let accessibilityAnnouncementReceiver: (String) -> Void
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .advance:
            guard state.isNFCReady else {
                state.route = .notCapable
                return .none
            }

            if state.canAvailable {
                state.route = .pin(CardWallPINDomain.State(
                    isDemoModus: environment.userSession.isDemoMode
                ))
            } else {
                state.route = .can(CardWallCANDomain.State(
                    isDemoModus: environment.userSession.isDemoMode,
                    profileId: environment.userSession.profileId,
                    can: ""
                ))
            }
            return .none
        case .close:
            return .none
        case .showEGKOrderInfoView:
            state.route = .egk
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return .none
        case .canAction(.navigateToIntro),
             .setNavigation(tag: .fasttrack):
            state.route = .fasttrack(CardWallExtAuthSelectionDomain.State())
            return .none
        case .pinAction(.close),
             .canAction(.close),
             .fasttrack(action: .close):
            state.route = nil
            return Effect(value: .close)
                // Delay for closing all views, Workaround for TCA pullback problem
                .delay(for: 0.01, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation,
             .canAction,
             .fasttrack,
             .pinAction:
            return .none
        }
    }

    static let canPullbackReducer: Reducer =
        CardWallCANDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.can),
            action: /Action.canAction(action:)
        ) { environment in
            CardWallCANDomain.Environment(
                sessionProvider: environment.sessionProvider,
                signatureProvider: environment.signatureProvider,
                userSession: environment.userSession,
                accessibilityAnnouncementReceiver: environment.accessibilityAnnouncementReceiver,
                schedulers: environment.schedulers
            )
        }

    static let fastTrackPullbackReducer: Reducer =
        CardWallExtAuthSelectionDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.fasttrack),
            action: /Action.fasttrack(action:)
        ) { environment in
            CardWallExtAuthSelectionDomain.Environment(idpSession: environment.userSession.idpSession,
                                                       schedulers: environment.schedulers)
        }

    static let pinPullbackReducer: Reducer =
        CardWallPINDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.pin),
            action: /Action.pinAction(action:)
        ) { environment in
            CardWallPINDomain.Environment(
                userSession: environment.userSession,
                schedulers: environment.schedulers,
                sessionProvider: environment.sessionProvider,
                signatureProvider: environment.signatureProvider,
                accessibilityAnnouncementReceiver: environment.accessibilityAnnouncementReceiver
            )
        }

    static let reducer = Reducer.combine(
        canPullbackReducer,
        fastTrackPullbackReducer,
        pinPullbackReducer,
        domainReducer
    )
}

extension CardWallIntroductionDomain {
    enum Dummies {
        static let state = State(isNFCReady: true)
        static let environment = Environment(userSession: DemoSessionContainer(schedulers: Schedulers()),
                                             sessionProvider: DummyProfileBasedSessionProvider(),
                                             schedulers: Schedulers(),
                                             signatureProvider: DummySecureEnclaveSignatureProvider()) { _ in }

        static let store = storeFor(state)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: reducer,
                  environment: environment)
        }
    }
}
