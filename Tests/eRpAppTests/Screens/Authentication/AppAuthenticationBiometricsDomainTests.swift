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
@testable import eRpApp
import eRpKit
import XCTest

@MainActor
final class AppAuthenticationBiometricsDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<AppAuthenticationBiometricsDomain>

    private func testStore(for biometryType: BiometryType,
                           withResult result: AuthenticationChallengeProviderResult) -> TestStore {
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(result).eraseToAnyPublisher()
        return TestStore(
            initialState: AppAuthenticationBiometricsDomain.State(
                biometryType: biometryType,
                startImmediateAuthenticationChallenge: false
            )
        ) {
            AppAuthenticationBiometricsDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Success() async {
        let store = testStore(for: .faceID, withResult: .success(true))

        await store.send(.startAuthenticationChallenge)

        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(true))) {
            $0.authenticationResult = .success(true)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Cannot_Evaluate_Policy() async {
        let store = testStore(for: .faceID, withResult: .failure(.cannotEvaluatePolicy(nil)))

        await store.send(.startAuthenticationChallenge)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.failure(.cannotEvaluatePolicy(nil)))) {
            $0.authenticationResult = .failure(.cannotEvaluatePolicy(nil))
            $0.errorToDisplay = .cannotEvaluatePolicy(nil)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Failed_Evaluating_Policy() async {
        let store = testStore(for: .faceID, withResult: .failure(.failedEvaluatingPolicy(nil)))

        await store.send(.startAuthenticationChallenge)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.failure(.failedEvaluatingPolicy(nil)))) {
            $0.authenticationResult = .failure(.failedEvaluatingPolicy(nil))
            $0.errorToDisplay = .failedEvaluatingPolicy(nil)
        }
    }
}
