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
import DataKit
import eRpKit
import Foundation
import IDP

struct ProfileSelectionDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case loadProfiles
        case loadSelectedProfile
    }

    struct State: Equatable {
        var profiles: [UserProfile] = []
        var selectedProfileId: UUID?

        var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case alert(ErpAlertState<ProfileSelectionDomain.Action>)
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener
        case loadReceived(Result<[UserProfile], UserProfileServiceError>)
        case selectedProfileReceived(UUID)
        case selectProfile(UserProfile)
        case close

        case editProfiles

        case destination(Destinations.Action)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.router) var router: Routing

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerListener:
            return .merge(
                userProfileService.userProfilesPublisher()
                    .catchToEffect()
                    .map(Action.loadReceived)
                    .receive(on: schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.loadProfiles, cancelInFlight: true),
                userProfileService.selectedProfileId
                    .compactMap { $0 }
                    .map(Action.selectedProfileReceived)
                    .receive(on: schedulers.main)
                    .eraseToEffect()
                    .cancellable(id: Token.loadSelectedProfile, cancelInFlight: true)
            )
        case let .loadReceived(.failure(error)):
            state.destination = .alert(.init(for: error, title: TextState(L10n.errTxtDatabaseAccess)))
            return .none
        case let .loadReceived(.success(profiles)):
            state.profiles = profiles
            return .none
        case let .selectedProfileReceived(profileId):
            state.selectedProfileId = profileId
            return .none
        case let .selectProfile(profile):
            state.selectedProfileId = profile.id
            userProfileService.set(selectedProfileId: profile.id)
            return .init(value: .close)
        case .editProfiles:
            router.routeTo(.settings)
            return .init(value: .close)
        case .close, .unregisterListener:
            return Self.cleanup()
        case .destination:
            return .none
        }
    }
}

extension ProfileSelectionDomain {
    enum Dummies {
        static let state = State(
            profiles: [
                UserProfile.Dummies.profileA,
                UserProfile.Dummies.profileB,
                UserProfile.Dummies.profileC,
            ],
            selectedProfileId: UserProfile.Dummies.profileA.id
        )

        static let store = Store(initialState: state,
                                 reducer: EmptyReducer())
    }
}
