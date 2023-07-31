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
import Nimble
import XCTest

final class AppAuthenticationBiometricPasswordDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        AppAuthenticationBiometricPasswordDomain.State,
        AppAuthenticationBiometricPasswordDomain.Action,
        AppAuthenticationBiometricPasswordDomain.State,
        AppAuthenticationBiometricPasswordDomain.Action,
        Void
    >

    var mockAppSecurityPasswordManager: MockAppSecurityManager!

    override func setUp() {
        super.setUp()
        mockAppSecurityPasswordManager = MockAppSecurityManager()
    }

    private func testStore(for _: AppAuthenticationBiometricPasswordDomain.State,
                           withResult result: AuthenticationChallengeProviderResult) -> TestStore {
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(result).eraseToAnyPublisher()
        return TestStore(
            initialState: AppAuthenticationBiometricPasswordDomain.State(
                biometryType: .faceID,
                startImmediateAuthenticationChallenge: false
            ),
            reducer: AppAuthenticationBiometricPasswordDomain()
        ) { dependencies in
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
            dependencies.appSecurityManager = mockAppSecurityPasswordManager
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Success() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .success(true)
        )

        store.send(.startAuthenticationChallenge)

        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) {
            $0.authenticationResult = .success(true)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Cannot_Evaluate_Policy() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )

        store.send(.startAuthenticationChallenge)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.failure(.cannotEvaluatePolicy(nil)))) {
            $0.authenticationResult = .failure(.cannotEvaluatePolicy(nil))
            $0.errorToDisplay = .cannotEvaluatePolicy(nil)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Failed_Evaluating_Policy() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .failure(.failedEvaluatingPolicy(nil))
        )

        store.send(.startAuthenticationChallenge)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.failure(.failedEvaluatingPolicy(nil)))) {
            $0.authenticationResult = .failure(.failedEvaluatingPolicy(nil))
            $0.errorToDisplay = .failedEvaluatingPolicy(nil)
        }
    }

    func testSetPassword() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false, password: " "),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )

        store.send(.setPassword("MyPassword")) { state in
            state.password = "MyPassword"
        }
    }

    func testPasswordIsCheckedWhenContinueButtonWasTapped() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false, password: "abc"),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        store.send(.loginButtonTapped)
        store.receive(.passwordVerificationReceived(true)) { state in
            state.lastMatchResultSuccessful = true
        }
        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
    }

    func testPasswordDoesNotMatch() {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false, password: "abc"),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = false

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        store.send(.loginButtonTapped)
        store.receive(.passwordVerificationReceived(false)) { state in
            state.lastMatchResultSuccessful = false
        }
        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
    }
}
