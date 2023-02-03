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
import eRpKit
import LocalAuthentication

enum AppSecurityDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    struct State: Equatable {
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: AppSecurityManagerError?
    }

    enum Action: Equatable {
        case loadSecurityOption
        case loadSecurityOptionResponse(AppSecurityOption)
        case select(_ option: AppSecurityOption)
        case dismissError
    }

    struct Environment {
        let userDataStore: UserDataStore
        let appSecurityManager: AppSecurityManager
        let schedulers: Schedulers
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadSecurityOption:
            let availableSecurityOptions = environment.appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableSecurityOptions.options
            state.errorToDisplay = availableSecurityOptions.error
            return environment.userDataStore.appSecurityOption
                .first()
                .map(Action.loadSecurityOptionResponse)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .loadSecurityOptionResponse(response):
            if !state.availableSecurityOptions.contains(response) {
                environment.userDataStore.set(appSecurityOption: .unsecured)
            } else {
                state.selectedSecurityOption = response
            }
            return .none
        case let .select(option):
            switch option {
            case .password:
                // state change is done after save button is tapped
                // creat passwort view presented by parent
                return .none
            default:
                state.selectedSecurityOption = option
                environment.userDataStore.set(appSecurityOption: option)
            }
            return .none
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        }
    }

    static let reducer = Reducer.combine(
        domainReducer
    )
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [], selectedSecurityOption: .biometry(.faceID))

        static let environment = Environment(userDataStore: DummySessionContainer().localUserStore,
                                             appSecurityManager: DummyAppSecurityManager(),
                                             schedulers: Schedulers())

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
