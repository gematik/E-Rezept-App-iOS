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
import eRpKit
import SwiftUI

enum AddProfileDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var alertState: AlertState<Action>?
        var profileName: String = ""
        var isValidName: Bool {
            !profileName.trimmed().isEmpty
        }
    }

    enum Action: Equatable {
        case saveProfile(String)
        case saveProfileReceived(Result<UUID, LocalStoreError>)
        case updateProfileName(profilename: String)
        case close
    }

    struct Environment {
        let localUserStore: UserDataStore
        let profileStore: ProfileDataStore
        let schedulers: Schedulers
        let userSession: UserSession
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case let .saveProfile(profilename):
            let name = profilename.trimmed()
            guard state.isValidName else { return .none }
            let profile = Profile(name: name,
                                  identifier: UUID(),
                                  insuranceId: nil,
                                  lastAuthenticated: nil,
                                  erxTasks: [])
            return environment.profileStore.save(profiles: [profile])
                .first()
                .catchToEffect()
                .map { result in
                    Action.saveProfileReceived(result.map { _ in profile.id })
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .saveProfileReceived(.success(profileId)):
            environment.localUserStore.set(selectedProfileId: profileId)
            return Effect(value: .close)
        case let .saveProfileReceived(.failure(error)):
            state.alertState = AlertState(for: error)
            return .none
        case let .updateProfileName(profilename):
            state.profileName = profilename
            return .none
        case .close:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        domainReducer
    )
}

extension AddProfileDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: reducer,
            environment: Dummies.environment
        )

        static let state = State()

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: domainReducer,
                environment: Dummies.environment
            )
        }

        static let environment = Environment(
            localUserStore: DummyUserSessionContainer().userSession.localUserStore,
            profileStore: DemoProfileDataStore(),
            schedulers: Schedulers(),
            userSession: DummySessionContainer()
        )
    }
}
