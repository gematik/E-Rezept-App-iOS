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
import IDP
import UIKit

struct IDPCardWallDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

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

        case delegate(Delegate)

        enum Delegate: Equatable {
            case finished
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSession) var userSession: UserSession

    static var dismissTimeout: DispatchQueue.SchedulerTimeType.Stride = 0.5

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.pin, action: /Action.pinAction(action:)) {
            CardWallPINDomain()
        }

        Reduce(core)
            .ifLet(\State.can, action: /Action.canAction(action:)) {
                CardWallCANDomain()
            }
            .ifLet(\State.readCard, action: /Action.readCard(action:)) {
                CardWallReadCardDomain()
            }
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .pinAction(action: .advance(.fullScreenCover)):
            state.readCard = CardWallReadCardDomain.State(
                isDemoModus: userSession.isDemoMode,
                profileId: state.profileId,
                pin: state.pin.pin,
                loginOption: .withoutBiometry,
                output: .idle
            )
            return .none
        case .readCard(action: .delegate(.wrongCAN)):
            if state.can == nil {
                state.can = CardWallCANDomain.State(
                    isDemoModus: false,
                    profileId: state.profileId,
                    can: ""
                )
            }
            state.can?.wrongCANEntered = true
            state.pin.destination = nil
            state.can?.destination = nil
            return .none
        case .readCard(action: .delegate(.wrongPIN)):
            state.pin.wrongPinEntered = true
            state.pin.destination = nil
            return .none
        case .canAction(action: .delegate(.close)),
             .pinAction(action: .delegate(.close)):
            // closing a subscreen should close the whole stack -> forward to generic `.close`
            return EffectTask.send(.delegate(.close))
        case .readCard(action: .delegate(.close)):
            state.pin.destination = nil
            return .run { send in
                try await schedulers.main.sleep(for: Self.dismissTimeout)
                await send(.delegate(.finished))
            }
        case .delegate,
             .canAction,
             .pinAction,
             .readCard:
            return .none
        }
    }
}

extension IDPCardWallDomain {
    enum Dummies {
        static let state = State(
            profileId: DemoProfileDataStore.anna.id,
            can: CardWallCANDomain.State(isDemoModus: false, profileId: UUID(), can: ""),
            pin: CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: "", transition: .fullScreenCover)
        )

        static let store = Store(
            initialState: state
        ) {
            IDPCardWallDomain()
        }
    }
}
