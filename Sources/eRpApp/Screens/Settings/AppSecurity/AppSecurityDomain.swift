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
        var availableSecurityOptions = [AppSecurityOption]()
        var selectedSecurityOption: AppSecurityOption?
        var errorToDisplay: Error?

        var createPasswordState: CreatePasswordDomain.State?
        var showCreatePasswordScreen: Bool {
            createPasswordState != nil
        }
    }

    enum Action: Equatable {
        case loadSecurityOption
        case loadSecurityOptionResponse(AppSecurityDomain.AppSecurityOption?)
        case select(_ option: AppSecurityOption)
        case dismissError

        case hideCreatePasswordScreen
        case createPassword(action: CreatePasswordDomain.Action)
    }

    struct Environment {
        private let userDataStore: UserDataStore
        let appSecurityPasswordManager: AppSecurityPasswordManager
        let schedulers: Schedulers

        var getAvailableSecurityOptions: ([AppSecurityOption], Error?) = {
            var error: NSError?
            let authenticationContext = LAContext()

            guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                          error: &error) == true else {
                return ([.password, .unsecured],
                        Error.localAuthenticationContext(error))
            }

            switch authenticationContext.biometryType {
            case .faceID:
                return ([.biometry(.faceID), .password, .unsecured], nil)
            case .touchID:
                return ([.biometry(.touchID), .password, .unsecured], nil)
            case .none:
                return ([.password, .unsecured], nil)
            @unknown default:
                return ([.password, .unsecured], nil)
            }
        }()

        var selectedSecurityOption: SelectedSecurityOption

        init(userDataStore: UserDataStore,
             appSecurityPasswordManager: AppSecurityPasswordManager,
             schedulers: Schedulers) {
            self.userDataStore = userDataStore
            self.appSecurityPasswordManager = appSecurityPasswordManager
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
            let availableSecurityOptions = environment.getAvailableSecurityOptions
            state.availableSecurityOptions = availableSecurityOptions.0
            state.errorToDisplay = availableSecurityOptions.1
            return environment.selectedSecurityOption.value.first()
                .map { Action.loadSecurityOptionResponse(AppSecurityDomain.AppSecurityOption(fromId: $0)) }
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
                return .none
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
            CreatePasswordDomain.Environment(passwordManager: global.appSecurityPasswordManager,
                                             schedulers: global.schedulers)
        }

    static let reducer = Reducer.combine(
        createPasswordPullbackReducer,
        domainReducer
    )
}

extension AppSecurityDomain {
    enum AppSecurityOption: Identifiable, Equatable {
        case unsecured
        case biometry(BiometryType)
        case password

        var id: Int { // swiftlint:disable:this identifier_name
            switch self {
            case .unsecured:
                return -1
            case let .biometry(biometryType):
                switch biometryType {
                case .faceID:
                    return 1
                case .touchID:
                    return 2
                }
            case .password:
                return 3
            }
        }

        init?(fromId id: Int) { // swiftlint:disable:this identifier_name
            switch id {
            case -1:
                self = .unsecured
            case 1:
                self = .biometry(.faceID)
            case 2:
                self = .biometry(.touchID)
            case 3:
                self = .password
            default:
                return nil
            }
        }
    }
}

extension AppSecurityDomain {
    enum Error: Swift.Error, Equatable {
        case localAuthenticationContext(NSError?)

        var errorDescription: String? {
            switch self {
            case let .localAuthenticationContext(error):
                guard let error = error else { return nil }

                if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                    return NSLocalizedString("auth_txt_biometrics_failed_not_enrolled",
                                             comment: "")
                }

                return error.localizedDescription
            }
        }
    }
}

extension AppSecurityDomain {
    enum Dummies {
        static let state = State(selectedSecurityOption: .biometry(.faceID))

        static let environment = Environment(userDataStore: DemoSessionContainer().localUserStore,
                                             appSecurityPasswordManager: DummyAppSecurityPasswordManager(),
                                             schedulers: AppContainer.shared.schedulers)

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )
    }
}
