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
import eRpKit
import LocalAuthentication

struct AppSecurityDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: AppSecurityManagerError?
        @PresentationState var destination: Destinations.State?
        var isBiometricSelected: Bool {
            selectedSecurityOption == .biometryAndPassword(.touchID) || selectedSecurityOption ==
                .biometryAndPassword(.faceID) || selectedSecurityOption == .biometry(.faceID) ||
                selectedSecurityOption == .biometry(.touchID)
        }

        var isPasswordSelected: Bool {
            selectedSecurityOption == .password || selectedSecurityOption == .biometryAndPassword(.faceID) ||
                selectedSecurityOption == .biometryAndPassword(.touchID)
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case appPassword(CreatePasswordDomain.State)
        }

        enum Action: Equatable {
            case appPassword(CreatePasswordDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(state: /State.appPassword,
                  action: /Action.appPassword) {
                CreatePasswordDomain()
            }
        }
    }

    enum Action: Equatable {
        enum Response: Equatable {
            case loadSecurityOption(AppSecurityOption)
        }

        case loadSecurityOption
        case select(_ option: AppSecurityOption)
        case dismissError
        case response(Response)
        case setNavigation(tag: Destinations.State.Tag?)
        case togglePasswordSelected
        case toggleBiometricSelected(BiometryType)
        case destination(PresentationAction<Destinations.Action>)
    }

    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadSecurityOption:
            let availableSecurityOptions = appSecurityManager.availableSecurityOptions
            state.availableSecurityOptions = availableSecurityOptions.options
            state.errorToDisplay = availableSecurityOptions.error
            return .publisher(
                userDataStore.appSecurityOption
                    .first()
                    .map {
                        Action.response(.loadSecurityOption($0))
                    }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.loadSecurityOption(appSecurityOption)):
            if appSecurityOption == .biometryAndPassword(.faceID) || appSecurityOption ==
                .biometryAndPassword(.touchID), !state.availableSecurityOptions.contains(appSecurityOption) {
                userDataStore.set(appSecurityOption: .password)
                state.selectedSecurityOption = .password
            } else if !state.availableSecurityOptions.contains(appSecurityOption) {
                userDataStore.set(appSecurityOption: .unsecured)
            } else {
                state.selectedSecurityOption = appSecurityOption
            }
            return .none
        case .togglePasswordSelected:
            if !state.isBiometricSelected, state.isPasswordSelected {
                return .none
            }
            if !state.isPasswordSelected {
                return EffectTask.send(.setNavigation(tag: .appPassword))
            } else {
                switch state.selectedSecurityOption {
                case .biometryAndPassword(.faceID):
                    return EffectTask.send(.select(.biometry(.faceID)))
                case .biometryAndPassword(.touchID):
                    return EffectTask.send(.select(.biometry(.touchID)))
                default:
                    return .none
                }
            }
        case let .toggleBiometricSelected(type):
            if !state.isPasswordSelected, state.isBiometricSelected {
                return .none
            }
            if state.isBiometricSelected {
                return EffectTask.send(.select(.password))
            } else {
                switch state.selectedSecurityOption {
                case .password:
                    return EffectTask.send(.select(.biometryAndPassword(type)))
                default:
                    return EffectTask.send(.select(.biometry(type)))
                }
            }
        case let .select(option):
            state.selectedSecurityOption = option
            userDataStore.set(appSecurityOption: option)
            return .none
        case .setNavigation(tag: .appPassword):
            if state.selectedSecurityOption == .password {
                state.destination = .appPassword(.init(mode: .update))
            } else {
                state.destination = .appPassword(.init(mode: .create))
            }
            return .none
        case .setNavigation(tag: nil):
            state.destination = nil
            return .none
        case .destination(.presented(.appPassword(.delegate(.closeAfterPasswordSaved)))):
            state.destination = nil
            switch state.selectedSecurityOption {
            case .biometry(.faceID):
                return EffectTask.send(.select(.biometryAndPassword(.faceID)))
            case .biometry(.touchID):
                return EffectTask.send(.select(.biometryAndPassword(.touchID)))
            default:
                return EffectTask.send(.select(.password))
            }
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        case .destination,
             .setNavigation:
            return .none
        }
    }
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [], selectedSecurityOption: .biometry(.faceID))

        static let store = Store(initialState: state) {
            AppSecurityDomain()
        }
    }
}
