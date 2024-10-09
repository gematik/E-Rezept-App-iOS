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

@Reducer
struct AppAuthenticationDomain {
    @ObservableState
    struct State: Equatable {
        var didCompleteAuthentication = false
        var subdomain: Subdomain.State?
        var failedAuthenticationsCount: Int = 0
    }

    enum Action: Equatable {
        case task
        case failedAppAuthenticationsReceived(Int)
        case loadAppAuthenticationOptionResponse(AppSecurityOption?, Int)
        case subdomain(Subdomain.Action)
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Subdomain {
        case biometrics(AppAuthenticationBiometricsDomain)
        case password(AppAuthenticationPasswordDomain)
        case biometricAndPassword(AppAuthenticationBiometricPasswordDomain)
    }

    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.appAuthenticationProvider) var appAuthenticationProvider: AppAuthenticationProvider

    let didCompleteAuthentication: (() -> Void)?

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.subdomain, action: \.subdomain) {
                Subdomain.body
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
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
                state.subdomain = nil
                return .none
            }
            switch authenticationOption {
            case let .biometry(type):
                state.subdomain = .biometrics(
                    .init(
                        biometryType: type,
                        startImmediateAuthenticationChallenge: failedAuthenticationsCount == 0
                    )
                )
            case .unsecured:
                state.didCompleteAuthentication = true
                didCompleteAuthentication?()
                state.subdomain = nil
            case .password:
                state.subdomain = .password(.init())
            case let .biometryAndPassword(type):
                state.subdomain = .biometricAndPassword(
                    .init(
                        biometryType: type,
                        startImmediateAuthenticationChallenge: failedAuthenticationsCount == 0
                    )
                )
            }
            return .none
        case let .subdomain(action):
            switch action {
            case let .biometrics(action: .authenticationChallengeResponse(response)),
                 let .biometricAndPassword(action: .authenticationChallengeResponse(response)):
                if case .success(true) = response {
                    state.didCompleteAuthentication = true
                    didCompleteAuthentication?()
                    state.subdomain = nil
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
                    state.subdomain = nil
                    userDataStore.set(failedAppAuthentications: 0)
                } else {
                    // [REQ:BSI-eRp-ePA:O.Pass_4#3] Increase failed attempts count on failed verification
                    state.failedAuthenticationsCount += 1
                    userDataStore.set(failedAppAuthentications: state.failedAuthenticationsCount)
                }
                return .none
            default: break
            }
            return .none
        }
    }
}

extension AppAuthenticationDomain {
    func subscribeToFailedAuthenticationChanges() -> Effect<AppAuthenticationDomain.Action> {
        .publisher(
            userDataStore.failedAppAuthentications
                .receive(on: schedulers.main.animation())
                .map(AppAuthenticationDomain.Action.failedAppAuthenticationsReceived)
                .eraseToAnyPublisher
        )
    }

    func loadAppAuthenticationOption() -> Effect<AppAuthenticationDomain.Action> {
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

        static let store = StoreOf<AppAuthenticationDomain>(initialState: state) {
            AppAuthenticationDomain {}
        }

        static func storeFor(_ state: State) -> StoreOf<AppAuthenticationDomain> {
            Store(initialState: state) {
                AppAuthenticationDomain {}
            }
        }
    }
}
