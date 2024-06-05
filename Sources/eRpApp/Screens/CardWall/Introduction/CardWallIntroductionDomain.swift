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

@Reducer
struct CardWallIntroductionDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall_CAN
        case can(CardWallCANDomain)
        // sourcery: AnalyticsScreen = cardWall_extAuth
        case extAuth(CardWallExtAuthSelectionDomain)
        // sourcery: AnalyticsScreen = contactInsuranceCompany
        case egk(OrderHealthCardDomain)
    }

    @ObservableState
    struct State: Equatable {
        /// App is only usable with NFC for now
        let isNFCReady: Bool
        let profileId: UUID
        @Presents var destination: Destination.State?
    }

    indirect enum Action: Equatable {
        case advance
        case advanceCAN(String?)

        case delegate(Delegate)

        case resetNavigation
        case extAuthTapped
        case egkButtonTapped
        case destination(PresentationAction<Destination.Action>)

        enum Delegate: Equatable {
            case close
            case unlockCardClose
        }
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
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
        case .egkButtonTapped:
            state.destination = .egk(.init())
            return .none
        case .resetNavigation,
             .destination(.presented(.egk(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination(.presented(.can(.delegate(.navigateToIntro)))),
             // [REQ:BSI-eRp-ePA:O.Auth_4#3] Present the gID flow for selecting the correct insurance company
             .extAuthTapped:
            state.destination = .extAuth(CardWallExtAuthSelectionDomain.State())
            return .none
        case .destination(.presented(.can(.delegate(.close)))),
             .destination(.presented(.extAuth(.delegate(.close)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.close))
            }
        case .destination(.presented(.can(.delegate(.unlockCardClose)))):
            state.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: 0.05)
                await send(.delegate(.unlockCardClose))
            }
        case .destination:
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
