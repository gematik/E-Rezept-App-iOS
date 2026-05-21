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
import FeatureHelpers
import IDP
import Profiles
import UIKit

/// Domain for the CardWall used in IDP login and profile actions
@Reducer
public struct IDPCardWallDomain {
    /// Initializer
    public init() {}

    @ObservableState
    public struct State: Equatable {
        @Shared(.isDemoMode) var isDemoMode

        public init(profileId: UUID, subdomain: Subdomain.State? = nil, can: String? = nil) {
            self.profileId = profileId
            self.subdomain = subdomain
            self.can = can
        }

        let profileId: UUID
        var subdomain: Subdomain.State?
        var can: String?
    }

    /// Subdomains of the CardWall flow
    @Reducer
    public enum Subdomain {
        /// CAN subdomain
        case can(CardWallCANDomain)
        /// PIN subdomain
        case pin(CardWallPINDomain)
        /// Read Card subdomain
        case readCard(CardWallReadCardDomain)
    }

    public enum Action: Equatable {
        case task
        case setCan(String?)
        case subdomain(Subdomain.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case finished
            case close
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.secureUserDataStoreClient) var secureStorage

    static var dismissTimeout: DispatchQueue.SchedulerTimeType.Stride = 0.5

    /// The main body of the reducer
    public var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.subdomain, action: \.subdomain) {
                Subdomain.body
            }
    }

    // swiftlint:disable:next function_body_length
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .publisher(
                secureStorage.can(profileId: state.profileId)
                    .first()
                    .map(Action.setCan)
                    .eraseToAnyPublisher
            )
        case let .setCan(can):
            state.can = can

            state.subdomain = .can(CardWallCANDomain.State(
                profileId: state.profileId,
                can: can ?? ""
            ))
            return .none
        case .subdomain(.can(.advance)):
            state.subdomain = .pin(CardWallPINDomain.State(profileId: state.profileId,
                                                           transition: .fullScreenCover))
            return .none
        case .subdomain(.pin(.advance(.fullScreenCover))):
            guard let pin = state.subdomain?.pin else {
                return .none
            }

            state.subdomain = .readCard(.init(
                profileId: state.profileId,
                pin: pin.pin,
                loginOption: .withoutBiometry,
                output: .idle
            ))
            return .none
        case .subdomain(.readCard(.delegate(.wrongCAN))):
            state.subdomain = .can(CardWallCANDomain.State(
                profileId: state.profileId,
                can: state.can ?? "",
                wrongCANEntered: true
            ))
            return .none
        case .subdomain(.readCard(.delegate(.wrongPIN))):
            state.subdomain = .pin(CardWallPINDomain.State(profileId: state.profileId,
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
            profileId: UUID()
        )

        static let store = Store(
            initialState: state
        ) {
            IDPCardWallDomain()
        }
    }
}

extension IDPCardWallDomain.Subdomain.State: Equatable {}
extension IDPCardWallDomain.Subdomain.Action: Equatable {}
