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
        RegisterAuthenticationDomain.State,
        RegisterAuthenticationDomain.Action,
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
                passwordStrengthTester: mockPasswordStrengthTester
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
            state.securityOptionsError = expectedLoadingError
        }
        expect(self.mockAppSecurityManager.availableSecurityOptionsCallsCount) == 1
    }

    func testSelectingPassword() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)]
            )
        )
        mockPasswordStrengthTester.passwordStrengthForReturnValue = .excellent

        store.send(.select(.password)) { state in
            state.availableSecurityOptions = [.password, .biometry(.faceID)]
            state.selectedSecurityOption = .password
            state.passwordA = ""
            state.passwordB = ""
            state.showPasswordsNotEqualMessage = false
        }
        store.send(.setPasswordA("ABC")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = ""
            state.passwordStrength = .excellent
            state.showPasswordsNotEqualMessage = false
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = true
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = ""
        }
        store.send(.setPasswordB("ABC")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = "ABC"
            state.showPasswordsNotEqualMessage = true
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = false
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = "ABC"
        }
        store.send(.enterButtonTapped) { state in
            state.showPasswordsNotEqualMessage = false
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = "ABC"
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = false
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = "ABC"
        }
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
            // password should be reseted
            state.passwordA = ""
            state.passwordB = ""
        }
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
    }

    func testSelectingFaceIDWithCancelation() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password, .biometry(.faceID)]
            ),
            challengeResponse: .success(false)
        )

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(false))) { state in
            state.selectedSecurityOption = nil
        }
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
                availableSecurityOptions: [.password, .biometry(.touchID)]
            ),
            challengeResponse: expectedResponse
        )

        store.send(.select(.biometry(.touchID))) { state in
            state.selectedSecurityOption = .biometry(.touchID)
        }
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(expectedResponse)) { state in
            state.selectedSecurityOption = nil
            state.alertState = AlertState(
                title: TextState(L10n.alertErrorTitle),
                message: TextState("my error message"),
                dismissButton: .default(TextState(L10n.alertBtnOk), send: .alertDismissButtonTapped)
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
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
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
        testScheduler.advance()
        store.receive(.authenticationChallengeResponse(.success(true))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
            state.showNoSelectionMessage = false
        }
    }

    func testSaveSelectionPasswordNoEntry() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: nil,
                passwordA: "",
                passwordB: "",
                showPasswordsNotEqualMessage: false,
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
                showPasswordsNotEqualMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.saveSelection) { state in
            state.showPasswordsNotEqualMessage = true
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
                showPasswordsNotEqualMessage: false,
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
                passwordA: "",
                passwordB: "",
                showPasswordsNotEqualMessage: false,
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
                showPasswordsNotEqualMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        testScheduler.run()
        store.receive(.authenticationChallengeResponse(.success(true)))
    }

    func testSelectBiometricsFails() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .none,
                passwordA: "",
                passwordB: "",
                showPasswordsNotEqualMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )
        let authenticationChallengeProvider =
            store.environment.authenticationChallengeProvider as! MockAuthenticationChallengeProvider
        authenticationChallengeProvider.result = .success(false)

        store.send(.select(.biometry(.faceID))) { state in
            state.selectedSecurityOption = .biometry(.faceID)
        }
        testScheduler.run()
        store.receive(.authenticationChallengeResponse(.success(false))) { state in
            state.selectedSecurityOption = .none
        }
    }

    func testSetPasswordACalculatesStrength() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.biometry(.faceID)],
                selectedSecurityOption: .none,
                passwordA: "",
                passwordB: "",
                showPasswordsNotEqualMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .veryWeak

        store.send(.setPasswordA("ABC")) { state in
            state.selectedSecurityOption = .password
            state.passwordA = "ABC"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            state.showPasswordsNotEqualMessage = false
        }

        mockPasswordStrengthTester.passwordStrengthForReturnValue = .medium

        store.send(.setPasswordA("ABCD")) { state in
            state.passwordA = "ABCD"
            state.passwordStrength = .medium
        }

        testScheduler.run()

        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = true
        }
    }

    func testWeakPasswordFailsSave() {
        let store = testStore(
            with: RegisterAuthenticationDomain.State(
                availableSecurityOptions: [.password],
                selectedSecurityOption: .password,
                passwordA: "ABC",
                passwordB: "ABC",
                passwordStrength: .weak,
                showPasswordsNotEqualMessage: false,
                showNoSelectionMessage: false,
                securityOptionsError: nil,
                alertState: nil
            )
        )

        store.send(.saveSelection)

        expect(self.mockAppSecurityManager.savePasswordCallsCount).to(equal(0))
    }
}
