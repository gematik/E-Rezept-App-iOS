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
    }

    enum Action: Equatable {
        case loadAppAuthenticationOption
        case loadAppAuthenticationOptionResponse(AppSecurityDomain.AppSecurityOption?)

        case biometrics(action: AppAuthenticationBiometricsDomain.Action)
    }

    struct Environment {
        let schedulers: Schedulers
        var appAuthenticationProvider: AppAuthenticationProvider
        var didCompleteAuthentication: (() -> Void)?

        private let userDataStore: UserDataStore

        init(userDataStore: UserDataStore,
             schedulers: Schedulers,
             appAuthenticationProvider: AppAuthenticationProvider,
             didCompleteAuthentication: (() -> Void)? = nil) {
            self.userDataStore = userDataStore
            self.schedulers = schedulers
            self.appAuthenticationProvider = appAuthenticationProvider
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
            }

            return .none
        case let .biometrics(action: .authenticationChallengeResponse(response)):
            if case .success = response {
                state.didCompleteAuthentication = true
                environment.didCompleteAuthentication?()
                state.biometrics = nil
            }
            return .none
        case .biometrics(action: .startAuthenticationChallenge),
             .biometrics(action: .dismissError):
            return .none
        }
    }

    static let reducer = Reducer.combine(
        biometricsPullbackReducer,
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
}

extension AppAuthenticationDomain {
    struct DefaultAuthenticationProvider: AppAuthenticationProvider {
        private var userDataStore: UserDataStore

        init(userDataStore: UserDataStore) {
            self.userDataStore = userDataStore
        }

        func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityDomain.AppSecurityOption?, Never> {
            userDataStore.appSecurityOption.map {
                AppSecurityDomain.AppSecurityOption(fromId: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}

extension AppAuthenticationDomain {
    enum Dummies {
        static let state = State()
    }
}

protocol AppAuthenticationProvider {
    func loadAppAuthenticationOption() -> AnyPublisher<AppSecurityDomain.AppSecurityOption?, Never>
}
