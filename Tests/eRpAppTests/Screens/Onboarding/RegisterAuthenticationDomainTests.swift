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
            state.selectedSecurityOption = .biometry(.faceID)
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
            state.selectedSecurityOption = .password
            state.securityOptionsError = expectedLoadingError
        }
    }

    func testSelectingWeakPassword() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)]
            )
        )

        await store.send(\.binding.selectedSecurityOption, .password) { state in
            state.availableSecurityOptions = [.password, .biometry(.faceID)]
            state.selectedSecurityOption = .password
            state.passwordA = ""
            state.passwordB = ""
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        await store.send(\.binding.passwordA, "Strong") { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Strong"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "Strong"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordStrengthInsufficient.text
        }
        await store.send(\.binding.passwordA, "Secure Pass word") { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = ""
            state.passwordStrength = .strong
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
    }

    func testSelectingStrongAndEqualPasswords() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC"
            )
        )

        await store.send(\.binding.passwordA, "Secure Pass word") { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "ABC"
            state.passwordStrength = .strong
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "ABC"
            state.passwordStrength = .strong
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordsDontMatch.text
        }
        await store.send(\.binding.passwordB, "Secure Pass word") { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "Secure Pass word"
            state.passwordStrength = .strong
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = false
        }
    }

    func testSelectingFaceIDWithPreviousPasswordSelection() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC"
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()

        await store.send(\.binding.selectedSecurityOption, .biometry(.faceID)) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        await store.send(.startBiometry) { state in
            state.passwordA = ""
            state.passwordB = ""
        }
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.biometrySuccessful = true
        }
        await testScheduler.advance(by: 1)
        await store.receive(.continueBiometry)

        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCalled).to(beTrue())
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 1
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

        await store.send(.startBiometry)
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

        await store.send(.startBiometry)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(expectedResponse)) { state in
            state.biometrySuccessful = false
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

    func testAlternatingSelection() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                showNoSelectionMessage: true
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()

        await store.send(\.binding.selectedSecurityOption, .biometry(.faceID)) { state in
            state.selectedSecurityOption = .biometry(.faceID)
            state.showNoSelectionMessage = false
        }
        await store.send(.startBiometry)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.biometrySuccessful = true
            state.showNoSelectionMessage = false
        }
        await store.send(\.binding.selectedSecurityOption, .password) { state in
            state.selectedSecurityOption = .password
            state.showNoSelectionMessage = false
        }
        await store.send(\.binding.selectedSecurityOption, .biometry(.faceID)) { state in
            state.selectedSecurityOption = .biometry(.faceID)
            state.showNoSelectionMessage = false
        }
        await store.send(.startBiometry)
        await testScheduler.advance()
        await store.receive(.authenticationChallengeResponse(.success(true)))
        await testScheduler.advance(by: 1)
        await store.receive(.continueBiometry)
        await store.receive(.continueBiometry)
    }

    func testSaveSelectionPasswordNoEntry() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .unsecured,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        await store.send(.comparePasswords)
    }

    func testSaveSelectionPasswordNotEqual() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "",
                passwordStrength: .strong,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        await store.send(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
        }
    }

    func testSaveSelectionPasswordEqual() async {
        mockAppSecurityManager.savePasswordReturnValue = true
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .password,
                passwordA: "abc",
                passwordB: "abc",
                passwordStrength: .veryStrong,
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        await store.send(.comparePasswords)
    }

    func testSaveBiometrics() async {
        mockAppSecurityManager.savePasswordReturnValue = true
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .biometry(.faceID),
                biometrySuccessful: true,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        await store.send(.comparePasswords)
    }

    func testSelectBiometricsSucceeds() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .unsecured,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        await store.send(\.binding.selectedSecurityOption, .biometry(.faceID)) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectBiometricsFails() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .biometry(.faceID),
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(false))
            .eraseToAnyPublisher()

        await store.send(.startBiometry)
        await testScheduler.run()
        await store.receive(.authenticationChallengeResponse(.success(false)))
    }

    func testSetPasswordACalculatesStrength() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .password,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            ),
            passwordStrengthTester: mockPasswordStrengthTester
        )

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .veryWeak

        await store.send(\.binding.passwordA, "ABC") { state in
            state.passwordA = "ABC"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            state.showPasswordErrorMessage = false
        }

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .medium

        await store.send(\.binding.passwordA, "ABCD") { state in
            state.passwordA = "ABCD"
            state.passwordStrength = .medium
            state.showPasswordErrorMessage = false
        }

        await testScheduler.run()

        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }

        await store.receive(.comparePasswords)
    }

    func testWeakPasswordFailsSave() async {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC"
            ),
            passwordStrengthTester: mockPasswordStrengthTester
        )

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .weak

        await store.send(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordStrengthInsufficient.text
        }

        expect(self.mockAppSecurityManager.savePasswordCallsCount).to(equal(0))
    }
}
