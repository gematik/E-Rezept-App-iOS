//
//  Copyright (c) 2021 gematik GmbH
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

enum BiometryType {
    case faceID
    case touchID
}

enum AppSecurityDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: AppSecurityManagerError?

        var createPasswordState: CreatePasswordDomain.State?
        var showCreatePasswordScreen: Bool {
            createPasswordState != nil
        }
    }

    enum Action: Equatable {
        case loadSecurityOption
        case loadSecurityOptionResponse(AppSecurityOption?)
        case select(_ option: AppSecurityOption)
        case dismissError

        case hideCreatePasswordScreen
        case createPassword(action: CreatePasswordDomain.Action)
    }

    struct Environment {
        private let userDataStore: UserDataStore
        let appSecurityManager: AppSecurityManager
        let schedulers: Schedulers

        var selectedSecurityOption: SelectedSecurityOption

        init(userDataStore: UserDataStore,
             appSecurityManager: AppSecurityManager,
             schedulers: Schedulers) {
            self.userDataStore = userDataStore
            self.appSecurityManager = appSecurityManager
            self.schedulers = schedulers
            selectedSecurityOption = SelectedSecurityOption(userDataStore: userDataStore)
        }
    }

    struct SelectedSecurityOption {
        private var userDataStore: UserDataStore

        init(userDataStore: UserDataStore) {
            self.userDataStore = userDataStore
        }

        var value: AnyPublisher<Int, Never> {
            userDataStore.appSecurityOption
        }

        func set(_ selectedSecurityOption: AppSecurityOption) {
            userDataStore.set(appSecurityOption: selectedSecurityOption.id)
        }

        func remove() {
            userDataStore.set(appSecurityOption: 0)
        }
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadSecurityOption:
            let availableSecurityOptions = environment.appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableSecurityOptions.options
            state.errorToDisplay = availableSecurityOptions.error
            return environment.selectedSecurityOption.value.first()
                .map { Action.loadSecurityOptionResponse(AppSecurityOption(fromId: $0)) }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .loadSecurityOptionResponse(response):
            if let response = response,
               !state.availableSecurityOptions.contains(response) {
                environment.selectedSecurityOption.remove()
            } else {
                state.selectedSecurityOption = response
            }
            return .none
        case let .select(option):
            switch option {
            case .password:
                if state.selectedSecurityOption == .password {
                    state.createPasswordState = CreatePasswordDomain.State(mode: .update)
                } else {
                    state.createPasswordState = CreatePasswordDomain.State(mode: .create)
                }
            default:
                state.selectedSecurityOption = option
                environment.selectedSecurityOption.set(option)
            }
            return .none
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        case .hideCreatePasswordScreen:
            state.createPasswordState = nil
            return Effect.cancel(token: CreatePasswordDomain.Token.self)
        case .createPassword(.closeAfterPasswordSaved):
            state.createPasswordState = nil
            state.selectedSecurityOption = .password
            environment.selectedSecurityOption.set(.password)
            return Effect.cancel(token: CreatePasswordDomain.Token.self)
        case .createPassword:
            return .none
        }
    }

    static let createPasswordPullbackReducer: Reducer =
        CreatePasswordDomain.reducer.optional().pullback(
            state: \State.createPasswordState,
            action: /AppSecurityDomain.Action.createPassword(action:)
        ) { global in
            CreatePasswordDomain.Environment(passwordManager: global.appSecurityManager,
                                             schedulers: global.schedulers)
        }

    static let reducer = Reducer.combine(
        createPasswordPullbackReducer,
        domainReducer
    )
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [], selectedSecurityOption: .biometry(.faceID))

        static let environment = Environment(userDataStore: DemoSessionContainer().localUserStore,
                                             appSecurityManager: DummyAppSecurityManager(),
                                             schedulers: AppContainer.shared.schedulers)

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
