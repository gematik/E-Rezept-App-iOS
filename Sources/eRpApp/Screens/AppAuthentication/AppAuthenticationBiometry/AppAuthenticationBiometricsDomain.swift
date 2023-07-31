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

struct AppAuthenticationBiometricsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        let biometryType: BiometryType
        let startImmediateAuthenticationChallenge: Bool
        var authenticationResult: AuthenticationChallengeProviderResult?
        var errorToDisplay: AuthenticationChallengeProviderError?
    }

    enum Action: Equatable {
        case startAuthenticationChallenge
        case dismissError
        case authenticationChallengeResponse(AuthenticationChallengeProviderResult)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.authenticationChallengeProvider) var authenticationChallengeProvider: AuthenticationChallengeProvider

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .startAuthenticationChallenge:
            return authenticationChallengeProvider
                .startAuthenticationChallenge()
                .first()
                .map { Action.authenticationChallengeResponse($0) }
                .receive(on: schedulers.main.animation())
                .eraseToEffect()
        case let .authenticationChallengeResponse(response):
            state.authenticationResult = response
            if case let .failure(error) = response {
                state.errorToDisplay = error
            }
            return .none
        case .dismissError:
            state.errorToDisplay = nil
            return .none
        }
    }
}

extension AppAuthenticationBiometricsDomain {
    enum Dummies {
        static let state = State(biometryType: .faceID, startImmediateAuthenticationChallenge: false)
    }
}
