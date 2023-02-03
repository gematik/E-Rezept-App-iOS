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
import Foundation
import IDP

enum CardWallIntroductionDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: CardWallReadCardDomain.Token.self)
    }

    enum Route: Equatable {
        // sourcery: AnalyticsScreen = cardwallCAN
        case can(CardWallCANDomain.State)
        // sourcery: AnalyticsScreen = cardWallExtAuth
        case fasttrack(CardWallExtAuthSelectionDomain.State)
        // sourcery: AnalyticsScreen = cardwallContactInsuranceCompany
        case egk(OrderHealthCardDomain.State)
        // sourcery: AnalyticsScreen = cardwallNotCapable
        case notCapable
    }

    struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool
        let profileId: UUID
        var route: Route?
    }

    indirect enum Action: Equatable {
        case advance
        case advanceCAN(String?)
        case close
        case setNavigation(tag: Route.Tag?)
        case canAction(action: CardWallCANDomain.Action)
        case fasttrack(action: CardWallExtAuthSelectionDomain.Action)
        case egkAction(action: OrderHealthCardDomain.Action)
    }

    struct Environment {
        let userSession: UserSession
        let userSessionProvider: UserSessionProvider
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
            return environment.userSessionProvider.userSession(for: state.profileId).secureUserStore.can
                .first()
                .map(Action.advanceCAN)
                .eraseToEffect()
        case let .advanceCAN(can):
            state.route = .can(CardWallCANDomain.State(
                isDemoModus: environment.userSession.isDemoMode,
                profileId: state.profileId,
                can: can ?? ""
            ))
            return .none
        case .close:
            return .none
        case .setNavigation(tag: .egk):
            state.route = .egk(.init())
            return .none
        case .setNavigation(tag: .none),
             .egkAction(action: .close):
            state.route = nil
            return .none
        case .canAction(.navigateToIntro),
             .setNavigation(tag: .fasttrack):
            state.route = .fasttrack(CardWallExtAuthSelectionDomain.State())
            return .none
        case .canAction(.close),
             .fasttrack(action: .close):
            state.route = nil
            return Effect(value: .close)
                // Delay for closing all views, Workaround for TCA pullback problem
                .delay(for: 0.05, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation,
             .canAction,
             .fasttrack,
             .egkAction:
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

    static let orderHealthCardPullbackReducer: Reducer =
        OrderHealthCardDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.egk),
            action: /Action.egkAction(action:)
        ) { _ in OrderHealthCardDomain.Environment() }

    static let reducer = Reducer.combine(
        canPullbackReducer,
        fastTrackPullbackReducer,
        orderHealthCardPullbackReducer,
        domainReducer
    )
}

extension CardWallIntroductionDomain {
    enum Dummies {
        static let state = State(isNFCReady: true, profileId: UUID())
        static let environment = Environment(userSession: DemoSessionContainer(schedulers: Schedulers()),
                                             userSessionProvider: DummyUserSessionProvider(),
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
