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
import LocalAuthentication
import Nimble
import XCTest

@MainActor
final class RegisterAuthenticationDomainTests: XCTestCase {
    var mockAppSecurityManager: MockAppSecurityManager!
    var mockPasswordStrengthTester: MockPasswordStrengthTester!
    var mockAuthenticationChallengeProvider: MockAuthenticationChallengeProvider!
    var mockFeedbackReceiver: MockFeedbackReceiver!

    typealias TestStore = TestStoreOf<RegisterAuthenticationDomain>

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockPasswordStrengthTester = MockPasswordStrengthTester()
        mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockFeedbackReceiver = MockFeedbackReceiver()
    }

    func testStore(
        with state: RegisterAuthenticationDomain.State,
        passwordStrengthTester: PasswordStrengthTester = DefaultPasswordStrengthTester()
    ) -> TestStore {
        TestStore(initialState: state) {
            RegisterAuthenticationDomain()
        } withDependencies: { dependencies in
            dependencies.appSecurityManager = mockAppSecurityManager
            dependencies.userDataStore = MockUserDataStore()
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.authenticationChallengeProvider = mockAuthenticationChallengeProvider
            dependencies.passwordStrengthTester = passwordStrengthTester
            dependencies.feedbackReceiver = mockFeedbackReceiver
        }
    }

    let testScheduler = DispatchQueue.test

    func testLoadingSecurityOptions() async {
        mockAppSecurityManager.underlyingAvailableSecurityOptions = (options: [.password, .biometry(.faceID)],
                                                                     error: nil)
        let store = testStore(with: RegisterAuthenticationDomain.State(availableSecurityOptions: []))

        await store.send(.loadAvailableSecurityOptions) { state in
            state.availableSecurityOptions = [.password, .biometry(.faceID)]
            state.selectedSecurityOption = .unsecured
        }
    }

    func testLoadingSecurityOptionsWithoutBiometry() async {
        let expectedLoadingError = AppSecurityManagerError.localAuthenticationContext(
            NSError(domain: "", code: LAError.Code.biometryNotEnrolled.rawValue)
        )
        mockAppSecurityManager.underlyingAvailableSecurityOptions =
            (options: [.password], error: expectedLoadingError)
        let store = testStore(with: RegisterAuthenticationDomain.State(availableSecurityOptions: []))

        await store.send(.loadAvailableSecurityOptions) { state in
            state.availableSecurityOptions = [.password]
            state.selectedSecurityOption = .unsecured
            state.securityOptionsError = expectedLoadingError
        }
    }

    func testSelectingFaceIDWithCancelation() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .biometry(.faceID)
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(false))
            .eraseToAnyPublisher()

        await store.send(.startBiometry(.biometry(.faceID)))
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(false)))
    }

    struct MockError: Error, LocalizedError {
        var errorDescription: String? {
            "my error message"
        }
    }

    func testSelectingTouchIDWithErrorResponse() async {
        let expectedResponse: AuthenticationChallengeProviderResult =
            .failure(.cannotEvaluatePolicy(MockError() as NSError))
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.touchID)],
                selectedSecurityOption: .biometry(.touchID)
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(expectedResponse)
            .eraseToAnyPublisher()

        await store.send(.startBiometry(.biometry(.touchID)))
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(expectedResponse)) { state in
            state.alertState = AlertState(
                title: { TextState(L10n.alertErrorTitle) },
                actions: {
                    ButtonState(role: .cancel, action: .send(.none)) {
                        TextState(L10n.alertBtnOk)
                    }
                },
                message: { TextState("my error message") }
            )
        }
        await store.send(.alert(.dismiss)) { state in
            state.alertState = nil
        }
    }

    func testSelectBiometricsSucceeds() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .unsecured,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()

        await store.send(.startBiometry(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        await testScheduler.run()
        await store.receive(.authenticationChallengeResponse(.success(true)))
        await store.receive(.delegate(.nextPage))
    }

    func testSelectBiometricsFails() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                securityOptionsError: nil,
                alertState: nil
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(false))
            .eraseToAnyPublisher()

        await store.send(.startBiometry(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        await testScheduler.run()
        await store.receive(.authenticationChallengeResponse(.success(false)))
    }
}
