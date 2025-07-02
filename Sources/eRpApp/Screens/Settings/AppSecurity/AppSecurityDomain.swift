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
import eRpKit
import LocalAuthentication

@Reducer
struct AppSecurityDomain {
    @ObservableState
    struct State: Equatable {
        var availableSecurityOptions: [AppSecurityOption]
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: AppSecurityManagerError?
        @Presents var destination: Destination.State?
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

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case appPassword(CreatePasswordDomain)
    }

    enum Action: Equatable {
        @CasePathable
        enum Response: Equatable {
            case loadSecurityOption(AppSecurityOption)
        }

        case loadSecurityOption
        case select(_ option: AppSecurityOption)
        case dismissError
        case response(Response)
        case resetNavigation
        case appPasswordTapped
        case togglePasswordSelected
        case toggleBiometricSelected(BiometryType)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.schedulers) var schedulers: Schedulers

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
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
                return Effect.send(.appPasswordTapped)
            } else {
                switch state.selectedSecurityOption {
                case .biometryAndPassword(.faceID):
                    return Effect.send(.select(.biometry(.faceID)))
                case .biometryAndPassword(.touchID):
                    return Effect.send(.select(.biometry(.touchID)))
                default:
                    return .none
                }
            }
        case let .toggleBiometricSelected(type):
            if !state.isPasswordSelected, state.isBiometricSelected {
                return .none
            }
            if state.isBiometricSelected {
                return Effect.send(.select(.password))
            } else {
                switch state.selectedSecurityOption {
                case .password:
                    return Effect.send(.select(.biometryAndPassword(type)))
                default:
                    return Effect.send(.select(.biometry(type)))
                }
            }
        case let .select(option):
            state.selectedSecurityOption = option
            userDataStore.set(appSecurityOption: option)
            return .none
        case .appPasswordTapped:
            if state.selectedSecurityOption == .password
                || state.selectedSecurityOption == .biometryAndPassword(.faceID)
                || state.selectedSecurityOption == .biometryAndPassword(.touchID) {
                state.destination = .appPassword(.init(mode: .update))
            } else {
                state.destination = .appPassword(.init(mode: .create))
            }
            return .none
        case .resetNavigation:
            state.destination = nil
            return .none
        case let .destination(.presented(.appPassword(.delegate(.closeAfterPasswordSaved(mode: mode))))):
            state.destination = nil

            // opt out early to not change the currently selected security option
            guard mode != .update else { return .none }

            switch state.selectedSecurityOption {
            case .biometry(.faceID):
                return Effect.send(.select(.biometryAndPassword(.faceID)))
            case .biometry(.touchID):
                return Effect.send(.select(.biometryAndPassword(.touchID)))
            default:
                return Effect.send(.select(.password))
            }
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        case .destination:
            return .none
        }
    }
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(availableSecurityOptions: [], selectedSecurityOption: .biometry(.faceID))

        static let store = StoreOf<AppSecurityDomain>(initialState: state) {
            AppSecurityDomain()
        }
    }
}
