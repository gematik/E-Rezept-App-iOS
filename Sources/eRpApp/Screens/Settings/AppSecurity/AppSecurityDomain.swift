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

struct AppSecurityDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: AppSecurityManagerError?
    }

    enum Action: Equatable {
        enum Response: Equatable {
            case loadSecurityOption(AppSecurityOption)
        }

        case loadSecurityOption
        case select(_ option: AppSecurityOption)
        case dismissError

        case response(Response)
    }

    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadSecurityOption:
            let availableSecurityOptions = appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableSecurityOptions.options
            state.errorToDisplay = availableSecurityOptions.error
            return userDataStore.appSecurityOption
                .first()
                .map {
                    Action.response(.loadSecurityOption($0))
                }
                .receive(on: schedulers.main)
                .eraseToEffect()
        case let .response(.loadSecurityOption(appSecurityOption)):
            if !state.availableSecurityOptions.contains(appSecurityOption) {
                userDataStore.set(appSecurityOption: .unsecured)
            } else {
                state.selectedSecurityOption = appSecurityOption
            }
            return .none

        case let .select(option):
            switch option {
            case .password:
                // state change is done after save button is tapped
                // CreatePassword view presented by parent
                return .none
            default:
                state.selectedSecurityOption = option
                userDataStore.set(appSecurityOption: option)
            }
            return .none
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        }
    }
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [], selectedSecurityOption: .biometry(.faceID))

        static let store = Store(
            initialState: state,
            reducer: AppSecurityDomain()
        )
    }
}
