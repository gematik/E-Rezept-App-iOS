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

import ComposableArchitecture
@testable import eRpApp
import LocalAuthentication
import Nimble
import XCTest

final class RegisterAuthenticationDomainTests: XCTestCase {
    var mockAppSecurityManager: MockAppSecurityManager!
    var mockPasswordStrengthTester: MockPasswordStrengthTester!

    typealias TestStore = ComposableArchitecture.TestStore<
        RegisterAuthenticationDomain.State,
        RegisterAuthenticationDomain.Action,
        RegisterAuthenticationDomain.State,
        RegisterAuthenticationDomain.Action,
        RegisterAuthenticationDomain.Environment
    >

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockPasswordStrengthTester = MockPasswordStrengthTester()
    }

    func testStore(
        with state: RegisterAuthenticationDomain.State,
        passwordStrengthTester: PasswordStrengthTester = DefaultPasswordStrengthTester(),
        challengeResponse: Result<Bool, AppAuthenticationBiometricsDomain.Error> = .success(true)
    ) -> TestStore {
        TestStore(
            initialState: state,
            reducer: RegisterAuthenticationDomain.reducer,
            environment: RegisterAuthenticationDomain.Environment(
                appSecurityManager: mockAppSecurityManager,
                userDataStore: MockUserDataStore(),
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: challengeResponse),
                passwordStrengthTester: passwordStrengthTester
            )
        )
    }

    let testScheduler = DispatchQueue.test

    func testLoadingSecurityOptions() {
        mockAppSecurityManager.availableSecurityOptionsReturnValue = (options: [.password, .biometry(.faceID)],
                                                                      error: nil)
        let store = testStore(with: RegisterAuthenticationDomain.State(availableSecurityOptions: []))

        store.send(.loadAvailableSecurityOptions) { state in
            state.availableSecurityOptions = [.password, .biometry(.faceID)]
            state.selectedSecurityOption = .biometry(.faceID)
        }
        expect(self.mockAppSecurityManager.availableSecurityOptionsCallsCount) == 1
    }

    func testLoadingSecurityOptionsWithoutBiometry() {
        let expectedLoadingError = AppSecurityManagerError.localAuthenticationContext(
            NSError(domain: "", code: LAError.Code.biometryNotEnrolled.rawValue)
        )
        mockAppSecurityManager.availableSecurityOptionsReturnValue =
            (options: [.password], error: expectedLoadingError)
        let store = testStore(with: RegisterAuthenticationDomain.State(availableSecurityOptions: []))

        store.send(.loadAvailableSecurityOptions) { state in
            state.availableSecurityOptions = [.password]
            state.selectedSecurityOption = .password
            state.securityOptionsError = expectedLoadingError
        }
        expect(self.mockAppSecurityManager.availableSecurityOptionsCallsCount) == 1
    }

    func testSelectingWeakPassword() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)]
            )
        )

        store.send(.select(.password)) { state in
            state.availableSecurityOptions = [.password, .biometry(.faceID)]
            state.selectedSecurityOption = .password
            state.passwordA = ""
            state.passwordB = ""
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        store.send(.setPasswordA("Strong")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Strong"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "Strong"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordStrengthInsufficient.text
        }
        store.send(.setPasswordA("Secure Pass word")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = ""
            state.passwordStrength = .strong
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = ""
            state.passwordStrength = .strong
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
    }

    func testSelectingStrongAndEqualPasswords() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC"
            )
        )

        store.send(.setPasswordA("Secure Pass word")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "ABC"
            state.passwordStrength = .strong
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "ABC"
            state.passwordStrength = .strong
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordsDontMatch.text
        }
        store.send(.setPasswordB("Secure Pass word")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "Secure Pass word"
            state.passwordB = "Secure Pass word"
            state.passwordStrength = .strong
            state.showPasswordErrorMessage = false
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
        testScheduler.run()
        store.receive(.comparePasswords)
    }

    func testSelectingFaceIDWithPreviousPasswordSelection() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC"
            )
        )

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        store.send(.startBiometry) { state in
            state.passwordA = ""
            state.passwordB = ""
        }
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.biometrySuccessful = true
        }
        testScheduler.advance(by: 1)
        store.receive(.continueBiometry)
    }

    func testSelectingFaceIDWithCancelation() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                selectedSecurityOption: .biometry(.faceID)
            ),
            challengeResponse: .success(false)
        )

        store.send(.startBiometry)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(false)))
    }

    struct MockError: Error, LocalizedError {
        var errorDescription: String? {
            "my error message"
        }
    }

    func testSelectingTouchIDWithErrorResponse() {
        let expectedResponse: Result<Bool, AppAuthenticationBiometricsDomain.Error> =
            .failure(.cannotEvaluatePolicy(MockError() as NSError))
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.touchID)],
                selectedSecurityOption: .biometry(.touchID)
            ),
            challengeResponse: expectedResponse
        )

        store.send(.startBiometry)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(expectedResponse)) { state in
            state.biometrySuccessful = false
            state.alertState = AlertState(
                title: TextState(L10n.alertErrorTitle),
                message: TextState("my error message"),
                dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.alertDismissButtonTapped))
            )
        }
        store.send(.alertDismissButtonTapped) { state in
            state.alertState = nil
        }
    }

    func testAlternatingSelection() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)],
                showNoSelectionMessage: true
            )
        )

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
            state.showNoSelectionMessage = false
        }
        store.send(.startBiometry)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.biometrySuccessful = true
            state.showNoSelectionMessage = false
        }
        store.send(.select(.password)) { state in
            state.selectedSecurityOption = .password
            state.showNoSelectionMessage = false
        }
        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
            state.showNoSelectionMessage = false
        }
        store.send(.startBiometry)
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true)))
        testScheduler.advance(by: 1)
        store.receive(.continueBiometry)
    }

    func testSaveSelectionPasswordNoEntry() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: nil,
                passwordA: "",
                passwordB: "",
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.saveSelection) { state in
            state.showNoSelectionMessage = true
        }
    }

    func testSaveSelectionPasswordNotEqual() {
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

        store.send(.saveSelection) { state in
            state.showPasswordErrorMessage = true
        }
    }

    func testSaveSelectionPasswordEqual() {
        mockAppSecurityManager.savePasswordReturnValue = true
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .password,
                passwordA: "abc",
                passwordB: "abc",
                passwordStrength: .veryStrong,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.saveSelection)
        testScheduler.advance()
        store.receive(.saveSelectionSuccess)
    }

    func testSaveBiometrics() {
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

        store.send(.saveSelection)
        store.receive(.saveSelectionSuccess)
    }

    func testSelectBiometricsSucceeds() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .none,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectBiometricsFails() {
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
        let authenticationChallengeProvider =
            store.environment.authenticationChallengeProvider as! MockAuthenticationChallengeProvider
        authenticationChallengeProvider.result = .success(false)

        store.send(.startBiometry)
        testScheduler.run()
        store.receive(.authenticationChallengeResponse(.success(false)))
    }

    func testSetPasswordACalculatesStrength() {
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

        store.send(.setPasswordA("ABC")) { state in
            state.passwordA = "ABC"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            state.showPasswordErrorMessage = false
        }

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .medium

        store.send(.setPasswordA("ABCD")) { state in
            state.passwordA = "ABCD"
            state.passwordStrength = .medium
            state.showPasswordErrorMessage = false
        }

        testScheduler.run()

        store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
    }

    func testWeakPasswordFailsSave() {
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

        store.send(.saveSelection) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordStrengthInsufficient.text
        }

        expect(self.mockAppSecurityManager.savePasswordCallsCount).to(equal(0))
    }
}
