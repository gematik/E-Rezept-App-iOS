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

enum AppAuthenticationDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var didCompleteAuthentication = false
        var biometrics: AppAuthenticationBiometricsDomain.State?
        var password: AppAuthenticationPasswordDomain.State?
    }

    enum Action: Equatable {
        case loadAppAuthenticationOption
        case loadAppAuthenticationOptionResponse(AppSecurityDomain.AppSecurityOption?)

        case biometrics(action: AppAuthenticationBiometricsDomain.Action)
        case password(action: AppAuthenticationPasswordDomain.Action)
    }

    struct Environment {
        let schedulers: Schedulers
        var appAuthenticationProvider: AppAuthenticationProvider
        var appSecurityPasswordManager: AppSecurityPasswordManager
        var didCompleteAuthentication: (() -> Void)?

        private let userDataStore: UserDataStore

        init(userDataStore: UserDataStore,
             schedulers: Schedulers,
             appAuthenticationProvider: AppAuthenticationProvider,
             appSecurityPasswordManager: AppSecurityPasswordManager,
             didCompleteAuthentication: (() -> Void)? = nil) {
            self.userDataStore = userDataStore
            self.schedulers = schedulers
            self.appAuthenticationProvider = appAuthenticationProvider
            self.appSecurityPasswordManager = appSecurityPasswordManager
            self.didCompleteAuthentication = didCompleteAuthentication
        }
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadAppAuthenticationOption:
            return environment
                .appAuthenticationProvider
                .loadAppAuthenticationOption()
                .first()
                .map { Action.loadAppAuthenticationOptionResponse($0) }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()

        case let .loadAppAuthenticationOptionResponse(response):
            guard let authenticationOption = response else {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
                return .none
            }
            switch authenticationOption {
            case let .biometry(type):
                state.biometrics = AppAuthenticationBiometricsDomain.State(biometryType: type)
            case .unsecured:
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
            case .password:
                state.password = AppAuthenticationPasswordDomain.State()
            }
            return .none

        case let .biometrics(action: .authenticationChallengeResponse(response)):
            if case .success = response {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
            }
            return .none

        case .password(.closeAfterPasswordVerified):
            state.didCompleteAuthentication = true
            environment.didCompleteAuthentication?()
            state.password = nil
            return .none

        case .password,
             .biometrics:
            return .none
        }
    }

    static let reducer = Reducer.combine(
        biometricsPullbackReducer,
        passwordPullbackReducer,
        domainReducer
    )

    private static let biometricsPullbackReducer: Reducer =
        AppAuthenticationBiometricsDomain.reducer
            .optional()
            .pullback(
                state: \.biometrics,
                action: /AppAuthenticationDomain.Action.biometrics(action:)
            ) {
                AppAuthenticationBiometricsDomain.Environment(
                    schedulers: $0.schedulers,
                    authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
                )
            }

    private static let passwordPullbackReducer: Reducer =
        AppAuthenticationPasswordDomain.reducer
            .optional()
            .pullback(state: \.password,
                      action: /AppAuthenticationDomain.Action.password(action:)) { currentEnvironment in
                AppAuthenticationPasswordDomain.Environment(
                    appSecurityPasswordManager: currentEnvironment.appSecurityPasswordManager
                )
            }
}

extension AppAuthenticationDomain {
    struct DefaultAuthenticationProvider: AppAuthenticationProvider {
        private var userDataStore: UserDataStore

        init(userDataStore: UserDataStore) {
            self.userDataStore = userDataStore
        }

        func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityDomain.AppSecurityOption?, Never> {
            userDataStore
                .appSecurityOption
                .map {
                    AppSecurityDomain.AppSecurityOption(fromId: $0)
                }
                .eraseToAnyPublisher()
        }
    }
}

extension AppAuthenticationDomain {
    enum Dummies {
        static let state = State()

        static let environment = Environment(
            userDataStore: DemoSessionContainer().localUserStore,
            schedulers: AppContainer.shared.schedulers,
            appAuthenticationProvider:
            AppAuthenticationDomain.DefaultAuthenticationProvider(
                userDataStore: DemoSessionContainer().localUserStore
            ),
            appSecurityPasswordManager: DummyAppSecurityPasswordManager()
        )

        static let store = Store(
            initialState: state,
            reducer: reducer,
            environment: environment
        )

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: domainReducer,
                environment: environment
            )
        }
    }
}

protocol AppAuthenticationProvider {
    func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityDomain.AppSecurityOption?, Never>
}
