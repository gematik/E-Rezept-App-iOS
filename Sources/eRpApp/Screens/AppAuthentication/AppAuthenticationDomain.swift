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

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case failedAuthentications
    }

    struct State: Equatable {
        var didCompleteAuthentication = false
        var biometrics: AppAuthenticationBiometricsDomain.State?
        var password: AppAuthenticationPasswordDomain.State?
        var failedAuthenticationsCount: Int = 0
    }

    enum Action: Equatable {
        case onAppear
        case failedAppAuthenticationsReceived(Int)
        case loadAppAuthenticationOptionResponse(AppSecurityOption?, Int)
        case removeSubscriptions
        case biometrics(action: AppAuthenticationBiometricsDomain.Action)
        case password(action: AppAuthenticationPasswordDomain.Action)
    }

    struct Environment {
        let userDataStore: UserDataStore
        let schedulers: Schedulers
        let appAuthenticationProvider: AppAuthenticationProvider
        let appSecurityPasswordManager: AppSecurityManager
        let authenticationChallengeProvider: AuthenticationChallengeProvider
        let didCompleteAuthentication: (() -> Void)?

        init(userDataStore: UserDataStore,
             schedulers: Schedulers,
             appAuthenticationProvider: AppAuthenticationProvider,
             appSecurityPasswordManager: AppSecurityManager,
             authenticationChallengeProvider: AuthenticationChallengeProvider,
             didCompleteAuthentication: (() -> Void)? = nil) {
            self.userDataStore = userDataStore
            self.schedulers = schedulers
            self.appAuthenticationProvider = appAuthenticationProvider
            self.appSecurityPasswordManager = appSecurityPasswordManager
            self.didCompleteAuthentication = didCompleteAuthentication
            self.authenticationChallengeProvider = authenticationChallengeProvider
        }
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return Effect.merge(
                environment.subscribeToFailedAuthenticationChanges()
                    .cancellable(id: Token.failedAuthentications, cancelInFlight: true),
                environment.loadAppAuthenticationOption()
            )
        case let .failedAppAuthenticationsReceived(count):
            state.failedAuthenticationsCount = count
            return .none
        case let .loadAppAuthenticationOptionResponse(response, failedAuthenticationsCount):
            guard let authenticationOption = response else {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
                return .none
            }
            switch authenticationOption {
            case let .biometry(type):
                state.biometrics = AppAuthenticationBiometricsDomain.State(
                    biometryType: type,
                    startImmediateAuthenticationChallenge: failedAuthenticationsCount == 0
                )
            case .unsecured:
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
            case .password:
                state.password = AppAuthenticationPasswordDomain.State()
            }
            return .none

        case let .biometrics(action: .authenticationChallengeResponse(response)):
            if case .success(true) = response {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
                environment.userDataStore.set(failedAppAuthentications: 0)
            } else {
                state.failedAuthenticationsCount += 1
                environment.userDataStore.set(failedAppAuthentications: state.failedAuthenticationsCount)
            }
            return .none

        case let .password(.passwordVerificationReceived(isLoggedIn)):
            if isLoggedIn {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.password = nil
                environment.userDataStore.set(failedAppAuthentications: 0)
            } else {
                state.failedAuthenticationsCount += 1
                environment.userDataStore.set(failedAppAuthentications: state.failedAuthenticationsCount)
            }

            return .none
        case .removeSubscriptions:
            return cleanup()
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
                    authenticationChallengeProvider: $0.authenticationChallengeProvider
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

extension AppAuthenticationDomain.Environment {
    func subscribeToFailedAuthenticationChanges() -> Effect<AppAuthenticationDomain.Action, Never> {
        userDataStore.failedAppAuthentications
            .receive(on: schedulers.main.animation())
            .map(AppAuthenticationDomain.Action.failedAppAuthenticationsReceived)
            .eraseToEffect()
    }

    func loadAppAuthenticationOption() -> Effect<AppAuthenticationDomain.Action, Never> {
        appAuthenticationProvider
            .loadAppAuthenticationOption()
            .zip(userDataStore.failedAppAuthentications.first())
            .receive(on: schedulers.main)
            .first()
            .map(AppAuthenticationDomain.Action.loadAppAuthenticationOptionResponse)
            .eraseToEffect()
    }
}

extension AppAuthenticationDomain {
    struct DefaultAuthenticationProvider: AppAuthenticationProvider {
        private var userDataStore: UserDataStore

        init(userDataStore: UserDataStore) {
            self.userDataStore = userDataStore
        }

        func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityOption?, Never> {
            userDataStore
                .appSecurityOption
                .map {
                    AppSecurityOption(fromId: $0)
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
            appSecurityPasswordManager: DummyAppSecurityManager(),
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
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
    func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityOption?, Never>
}
