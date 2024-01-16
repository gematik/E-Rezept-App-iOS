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

struct AppAuthenticationDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var didCompleteAuthentication = false
        var biometrics: AppAuthenticationBiometricsDomain.State?
        var password: AppAuthenticationPasswordDomain.State?
        var biometricAndPassword: AppAuthenticationBiometricPasswordDomain.State?
        var failedAuthenticationsCount: Int = 0
    }

    enum Action: Equatable {
        case task
        case failedAppAuthenticationsReceived(Int)
        case loadAppAuthenticationOptionResponse(AppSecurityOption?, Int)
        case biometrics(action: AppAuthenticationBiometricsDomain.Action)
        case password(action: AppAuthenticationPasswordDomain.Action)
        case biometricAndPassword(action: AppAuthenticationBiometricPasswordDomain.Action)
    }

    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.appAuthenticationProvider) var appAuthenticationProvider: AppAuthenticationProvider

    let didCompleteAuthentication: (() -> Void)?

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.biometrics, action: /AppAuthenticationDomain.Action.biometrics(action:)) {
                AppAuthenticationBiometricsDomain()
            }
            .ifLet(\.password, action: /AppAuthenticationDomain.Action.password(action:)) {
                AppAuthenticationPasswordDomain()
            }
            .ifLet(\.biometricAndPassword, action: /AppAuthenticationDomain.Action.biometricAndPassword(action:)) {
                AppAuthenticationBiometricPasswordDomain()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            return .merge(
                subscribeToFailedAuthenticationChanges(),
                loadAppAuthenticationOption()
            )
        case let .failedAppAuthenticationsReceived(count):
            state.failedAuthenticationsCount = count
            return .none
        case let .loadAppAuthenticationOptionResponse(response, failedAuthenticationsCount):
            guard let authenticationOption = response else {
                state.didCompleteAuthentication = true
                didCompleteAuthentication?()
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
                didCompleteAuthentication?()
                state.biometrics = nil
            case .password:
                state.password = AppAuthenticationPasswordDomain.State()
            case let .biometryAndPassword(type):
                state.biometricAndPassword = AppAuthenticationBiometricPasswordDomain.State(
                    biometryType: type,
                    startImmediateAuthenticationChallenge: failedAuthenticationsCount == 0
                )
            }
            return .none
        case let .biometrics(action: .authenticationChallengeResponse(response)),
             let .biometricAndPassword(action: .authenticationChallengeResponse(response)):
            if case .success(true) = response {
                state.didCompleteAuthentication = true
                didCompleteAuthentication?()
                state.biometrics = nil
                userDataStore.set(failedAppAuthentications: 0)
            } else {
                state.failedAuthenticationsCount += 1
                userDataStore.set(failedAppAuthentications: state.failedAuthenticationsCount)
            }
            return .none
        case let .password(.passwordVerificationReceived(isLoggedIn)),
             let .biometricAndPassword(.passwordVerificationReceived(isLoggedIn)):
            if isLoggedIn {
                state.didCompleteAuthentication = true
                didCompleteAuthentication?()
                state.password = nil
                userDataStore.set(failedAppAuthentications: 0)
            } else {
                state.failedAuthenticationsCount += 1
                userDataStore.set(failedAppAuthentications: state.failedAuthenticationsCount)
            }

            return .none
        case .password,
             .biometrics,
             .biometricAndPassword:
            return .none
        }
    }
}

extension AppAuthenticationDomain {
    func subscribeToFailedAuthenticationChanges() -> EffectTask<AppAuthenticationDomain.Action> {
        .publisher(
            userDataStore.failedAppAuthentications
                .receive(on: schedulers.main.animation())
                .map(AppAuthenticationDomain.Action.failedAppAuthenticationsReceived)
                .eraseToAnyPublisher
        )
    }

    // [REQ:BSI-eRp-ePA:O.Biom_5#1] Check whether at least one biometric reference is available.
    func loadAppAuthenticationOption() -> EffectTask<AppAuthenticationDomain.Action> {
        .publisher(
            appAuthenticationProvider
                .loadAppAuthenticationOption()
                .zip(userDataStore.failedAppAuthentications.first())
                .receive(on: schedulers.main)
                .first()
                .map(AppAuthenticationDomain.Action.loadAppAuthenticationOptionResponse)
                .eraseToAnyPublisher
        )
    }
}

extension AppAuthenticationDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(initialState: state) {
            AppAuthenticationDomain {}
        }

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state) {
                AppAuthenticationDomain {}
            }
        }
    }
}
