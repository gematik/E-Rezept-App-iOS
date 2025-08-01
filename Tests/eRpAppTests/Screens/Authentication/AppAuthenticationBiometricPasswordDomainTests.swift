//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class AppAuthenticationBiometricPasswordDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<AppAuthenticationBiometricPasswordDomain>

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
            )
        ) {
            AppAuthenticationBiometricPasswordDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(
                uiScheduler: testScheduler.eraseToAnyScheduler()
            )
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
            dependencies.appSecurityManager = mockAppSecurityPasswordManager
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Success() async {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .success(true)
        )

        await store.send(.startAuthenticationChallenge)

        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(true))) {
            $0.authenticationResult = .success(true)
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Cannot_Evaluate_Policy() async {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )

        await store.send(.startAuthenticationChallenge)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.failure(.cannotEvaluatePolicy(nil)))) {
            $0.authenticationResult = .failure(.cannotEvaluatePolicy(nil))
            $0
                .destination =
                .alert(.init(for: AuthenticationChallengeProviderError.cannotEvaluatePolicy(nil),
                             title: L10n.alertErrorTitle))
        }
    }

    func testPerformAuthenticationChallenge_FaceID_Failure_Failed_Evaluating_Policy() async {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false),
            withResult: .failure(.failedEvaluatingPolicy(nil))
        )

        await store.send(.startAuthenticationChallenge)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.failure(.failedEvaluatingPolicy(nil)))) {
            $0.authenticationResult = .failure(.failedEvaluatingPolicy(nil))
            $0
                .destination =
                .alert(.init(for: AuthenticationChallengeProviderError.failedEvaluatingPolicy(nil),
                             title: L10n.alertErrorTitle))
        }
    }

    func testSetPassword() async {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false, password: " "),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )

        await store.send(.setPassword("MyPassword")) { state in
            state.password = "MyPassword"
        }
    }

    func testPasswordIsCheckedWhenContinueButtonWasTapped() async {
        let store = testStore(
            for: .init(biometryType: .faceID, startImmediateAuthenticationChallenge: false, password: "abc"),
            withResult: .failure(.cannotEvaluatePolicy(nil))
        )
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        await store.send(.loginButtonTapped)
        await store.receive(.passwordVerificationReceived(true)) { state in
            state.lastMatchResultSuccessful = true
        }
        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockAppSecurityPasswordManager.resetPasswordDelayCalled).to(beTrue())
        expect(self.mockAppSecurityPasswordManager.registerFailedPasswordAttemptCalled).to(beFalse())
    }

    func testPasswordDoesNotMatch() async {
        let clock = TestClock()
        let mockAppSecurityManager = MockAppSecurityManager()

        let store = TestStore(initialState: AppAuthenticationBiometricPasswordDomain.State(
            biometryType: .faceID,
            startImmediateAuthenticationChallenge: false,
            password: "abc"
        )) {
            AppAuthenticationBiometricPasswordDomain()
        } withDependencies: {
            $0.appSecurityManager = mockAppSecurityManager
            $0.continuousClock = clock
        }
        mockAppSecurityManager.matchesPasswordReturnValue = false
        mockAppSecurityManager.currentPasswordDelayReturnValue = 10.0

        expect(mockAppSecurityManager.matchesPasswordCalled).to(beFalse())
        await store.send(.loginButtonTapped)
        await store.receive(.passwordVerificationReceived(false)) { state in
            state.lastMatchResultSuccessful = false
        }
        await store.receive(.currentPasswordDelayReceived(10.0)) { state in
            state.passwordDelay = 10.0
        }

        await clock.advance(by: .seconds(10))
        for _ in 0 ..< 10 {
            await store.receive(.passwordDelayTimerTick) { state in
                state.passwordDelay -= 1.0
            }
        }

        expect(mockAppSecurityManager.matchesPasswordCalled).to(beTrue())
        expect(mockAppSecurityManager.resetPasswordDelayCalled).to(beFalse())
        expect(mockAppSecurityManager.registerFailedPasswordAttemptCalled).to(beTrue())
    }
}
