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

final class AppAuthenticationBiometricsDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppAuthenticationBiometricsDomain.State,
        AppAuthenticationBiometricsDomain.Action,
        AppAuthenticationBiometricsDomain.State,
        AppAuthenticationBiometricsDomain.Action,
        Void
    >

    private func testStore(for biometryType: BiometryType,
                           withResult result: Result<Bool, AppAuthenticationBiometricsDomain.Error>) -> TestStore {
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(result).eraseToAnyPublisher()
        return TestStore(
            initialState: AppAuthenticationBiometricsDomain.State(
                biometryType: biometryType,
                startImmediateAuthenticationChallenge: false
            ),
            reducer: AppAuthenticationBiometricsDomain()
        ) { dependencies in
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Success() {
        let store = testStore(for: .faceID, withResult: .success(true))

        store.send(.startAuthenticationChallenge)

        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) {
            $0.authenticationResult = .success(true)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Cannot_Evaluate_Policy() {
        let store = testStore(for: .faceID, withResult: .failure(.cannotEvaluatePolicy(nil)))

        store.send(.startAuthenticationChallenge)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.failure(.cannotEvaluatePolicy(nil)))) {
            $0.authenticationResult = .failure(.cannotEvaluatePolicy(nil))
            $0.errorToDisplay = .cannotEvaluatePolicy(nil)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Failed_Evaluating_Policy() {
        let store = testStore(for: .faceID, withResult: .failure(.failedEvaluatingPolicy(nil)))

        store.send(.startAuthenticationChallenge)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.failure(.failedEvaluatingPolicy(nil)))) {
            $0.authenticationResult = .failure(.failedEvaluatingPolicy(nil))
            $0.errorToDisplay = .failedEvaluatingPolicy(nil)
        }
    }
}
