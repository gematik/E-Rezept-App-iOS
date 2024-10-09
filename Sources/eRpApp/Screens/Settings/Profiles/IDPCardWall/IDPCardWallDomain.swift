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
import IDP
import UIKit

@Reducer
struct IDPCardWallDomain {
    @ObservableState
    struct State: Equatable {
        let profileId: UUID
        var subdomain: Subdomain.State?
        var can: String?
        var isDemoMode = false
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Subdomain {
        case can(CardWallCANDomain)
        case pin(CardWallPINDomain)
        case readCard(CardWallReadCardDomain)
    }

    enum Action: Equatable {
        case task
        case setCan(String?)
        case subdomain(Subdomain.Action)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case finished
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userSessionProvider) var userSessionProvider: UserSessionProvider
    @Dependency(\.userSession) var userSession: UserSession

    static var dismissTimeout: DispatchQueue.SchedulerTimeType.Stride = 0.5

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.subdomain, action: \.subdomain) {
                Subdomain.body
            }
    }

    // swiftlint:disable:next function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.isDemoMode = userSession.isDemoMode
            return .publisher(
                userSessionProvider.userSession(for: state.profileId).secureUserStore.can
                    .first()
                    .map(Action.setCan)
                    .eraseToAnyPublisher
            )
        case let .setCan(can):
            state.can = can

            state.subdomain = .can(CardWallCANDomain.State(
                isDemoModus: state.isDemoMode,
                profileId: state.profileId,
                can: can ?? ""
            ))
            return .none
        case .subdomain(.can(.advance)):
            state.subdomain = .pin(CardWallPINDomain.State(isDemoModus: state.isDemoMode,
                                                           profileId: state.profileId,
                                                           transition: .fullScreenCover))
            return .none
        case .subdomain(.pin(.advance(.fullScreenCover))):
            guard let pin = state.subdomain?.pin else {
                return .none
            }

            state.subdomain = .readCard(.init(
                isDemoModus: state.isDemoMode,
                profileId: state.profileId,
                pin: pin.pin,
                loginOption: .withoutBiometry,
                output: .idle
            ))
            return .none
        case .subdomain(.readCard(.delegate(.wrongCAN))):
            state.subdomain = .can(CardWallCANDomain.State(
                isDemoModus: state.isDemoMode,
                profileId: state.profileId,
                can: state.can ?? "",
                wrongCANEntered: true
            ))
            return .none
        case .subdomain(.readCard(.delegate(.wrongPIN))):
            state.subdomain = .pin(CardWallPINDomain.State(isDemoModus: state.isDemoMode,
                                                           profileId: state.profileId,
                                                           wrongPinEntered: true,
                                                           transition: .fullScreenCover))
            return .none
        case .subdomain(.can(.delegate(.close))),
             .subdomain(.pin(.delegate(.close))):
            // closing a subscreen should close the whole stack -> forward to generic `.close`
            return Effect.send(.delegate(.close))
        case .subdomain(.readCard(.delegate(.close))):
            state.subdomain = nil
            return .run { send in
                try await schedulers.main.sleep(for: Self.dismissTimeout)
                await send(.delegate(.finished))
            }
        case .delegate,
             .subdomain:
            return .none
        }
    }
}

extension IDPCardWallDomain {
    enum Dummies {
        static let state = State(
            profileId: DemoProfileDataStore.anna.id
        )

        static let store = Store(
            initialState: state
        ) {
            IDPCardWallDomain()
        }
    }
}
