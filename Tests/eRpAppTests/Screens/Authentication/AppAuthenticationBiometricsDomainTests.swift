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
@testable import eRpApp
import XCTest

final class AppAuthenticationBiometricsDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppAuthenticationBiometricsDomain.State,
        AppAuthenticationBiometricsDomain.State,
        AppAuthenticationBiometricsDomain.Action,
        AppAuthenticationBiometricsDomain.Action,
        AppAuthenticationBiometricsDomain.Environment
    >

    struct MockAuthenticationChallengeProvider: AuthenticationChallengeProvider {
        var result: Result<Bool, AppAuthenticationBiometricsDomain.Error>
        func startAuthenticationChallenge()
            -> AnyPublisher<AppAuthenticationBiometricsDomain.AuthenticationResult, Never> {
            Just(result).eraseToAnyPublisher()
        }
    }

    private func testStore(for biometryType: BiometryType,
                           withResult result: Result<Bool, AppAuthenticationBiometricsDomain.Error>) -> TestStore {
        TestStore(initialState: AppAuthenticationBiometricsDomain.State(biometryType: biometryType),
                  reducer: AppAuthenticationBiometricsDomain.reducer,
                  environment: AppAuthenticationBiometricsDomain.Environment(
                      schedulers: Schedulers(
                          uiScheduler: testScheduler.eraseToAnyScheduler()
                      ),
                      authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: result)
                  ))
    }

    func testPerformAuthenticationChallenge_FaceID_Success() {
        let store = testStore(for: .faceID, withResult: .success(true))
        store
            .assert(.send(.startAuthenticationChallenge) { _ in },
                    .do { self.testScheduler.advance() },
                    .receive(.authenticationChallengeResponse(.success(true))) {
                        $0.authenticationResult = .success(true)
                    })
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Cannot_Evaluate_Policy() {
        let store = testStore(for: .faceID, withResult: .failure(.cannotEvaluatePolicy(nil)))
        store
            .assert(.send(.startAuthenticationChallenge) { _ in },
                    .do { self.testScheduler.advance() },
                    .receive(.authenticationChallengeResponse(.failure(.cannotEvaluatePolicy(nil)))) {
                        $0.authenticationResult = .failure(.cannotEvaluatePolicy(nil))
                        $0.errorToDisplay = .cannotEvaluatePolicy(nil)
                    })
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Failed_Evaluating_Policy() {
        let store = testStore(for: .faceID, withResult: .failure(.failedEvaluatingPolicy(nil)))
        store
            .assert(.send(.startAuthenticationChallenge) { _ in },
                    .do { self.testScheduler.advance() },
                    .receive(.authenticationChallengeResponse(.failure(.failedEvaluatingPolicy(nil)))) {
                        $0.authenticationResult = .failure(.failedEvaluatingPolicy(nil))
                        $0.errorToDisplay = .failedEvaluatingPolicy(nil)
                    })
    }
}
