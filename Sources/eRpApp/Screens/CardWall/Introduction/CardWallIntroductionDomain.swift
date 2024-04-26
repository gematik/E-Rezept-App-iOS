//
//  Copyright (c) 2024 gematik GmbH
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

struct CardWallIntroductionDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardWall_CAN
            case can(CardWallCANDomain.State)
            // sourcery: AnalyticsScreen = cardWall_extAuth
            case extauth(CardWallExtAuthSelectionDomain.State)
            // sourcery: AnalyticsScreen = contactInsuranceCompany
            case egk(OrderHealthCardDomain.State)
        }

        enum Action: Equatable {
            case canAction(action: CardWallCANDomain.Action)
            case extauth(action: CardWallExtAuthSelectionDomain.Action)
            case egkAction(action: OrderHealthCardDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.can, action: /Action.canAction) {
                CardWallCANDomain()
            }
            Scope(state: /State.extauth, action: /Action.extauth) {
                CardWallExtAuthSelectionDomain()
            }
            Scope(state: /State.egk, action: /Action.egkAction) {
                OrderHealthCardDomain()
            }
        }
    }

    struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool
        let profileId: UUID
        @PresentationState var destination: Destinations.State?
    }

    indirect enum Action: Equatable {
        case advance
        case advanceCAN(String?)

        case delegate(Delegate)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        enum Delegate: Equatable {
            case close
            case unlockCardClose
        }
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .advance:
            return .publisher(
                userSessionProvider.userSession(for: state.profileId).secureUserStore.can
                    .first()
                    .map(Action.advanceCAN)
                    .eraseToAnyPublisher
            )
        case let .advanceCAN(can):
            state.destination = .can(CardWallCANDomain.State(
                isDemoModus: userSession.isDemoMode,
                profileId: state.profileId,
                can: can ?? ""
            ))
            return .none
        case .delegate(.close):
            return .none
        case .setNavigation(tag: .egk):
            state.destination = .egk(.init())
            return .none
        case .setNavigation(tag: .none),
             .destination(.presented(.egkAction(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.canAction(.delegate(.navigateToIntro)))),
             .setNavigation(tag: .extauth):
            state.destination = .extauth(CardWallExtAuthSelectionDomain.State())
            return .none
        case .destination(.presented(.canAction(.delegate(.close)))),
             .destination(.presented(.extauth(action: .delegate(.close)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.close))
            }
        case .destination(.presented(.canAction(action: .delegate(.unlockCardClose)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.unlockCardClose))
            }
        case .setNavigation,
             .destination:
            return .none
        case .delegate(.unlockCardClose):
            return .none
        }
    }
}

extension CardWallIntroductionDomain {
    enum Dummies {
        static let state = State(isNFCReady: true, profileId: UUID())

        static let store = Store(initialState: state) {
            CardWallIntroductionDomain()
        }
    }
}
