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
final class RegisterPasswordDomainTests: XCTestCase {
    var mockAppSecurityManager: MockAppSecurityManager!
    var mockPasswordStrengthTester: MockPasswordStrengthTester!
    var mockAuthenticationChallengeProvider: MockAuthenticationChallengeProvider!
    var mockFeedbackReceiver: MockFeedbackReceiver!

    typealias TestStore = TestStoreOf<RegisterPasswordDomain>

    override func setUp() {
        super.setUp()

        mockAppSecurityManager = MockAppSecurityManager()
        mockPasswordStrengthTester = MockPasswordStrengthTester()
        mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockFeedbackReceiver = MockFeedbackReceiver()
    }

    func testStore(
        with state: RegisterPasswordDomain.State,
        passwordStrengthTester: PasswordStrengthTester = DefaultPasswordStrengthTester()
    ) -> TestStore {
        TestStore(initialState: state) {
            RegisterPasswordDomain()
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

    func testSelectingWeakPassword() async {
        let store = testStore(
            with: RegisterPasswordDomain.State()
        )

        await store.send(\.binding.passwordA, "Strong") { state in
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
            state.passwordA = "Strong"
            state.passwordB = ""
            state.passwordStrength = .veryWeak
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordStrengthInsufficient.text
        }
        await store.send(\.binding.passwordA, "Secure Pass word") { state in
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
            with: RegisterPasswordDomain.State(
                passwordA: "ABC",
                passwordB: "ABC"
            )
        )

        await store.send(\.binding.passwordA, "Secure Pass word") { state in
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
            state.passwordA = "Secure Pass word"
            state.passwordB = "ABC"
            state.passwordStrength = .strong
            let message = state.passwordErrorMessage
            expect(message) == L10n.onbAuthTxtPasswordsDontMatch.text
        }
        await store.send(\.binding.passwordB, "Secure Pass word") { state in
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

    func testSaveSelectionPasswordNotEqual() async {
        let store = testStore(
            with: RegisterPasswordDomain.State(
                passwordA: "ABC",
                passwordB: "",
                passwordStrength: .strong
            )
        )

        await store.send(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
        }
    }

    func testSaveSelectionPasswordEqual() async {
        mockAppSecurityManager.savePasswordReturnValue = true
        let store = testStore(
            with: RegisterPasswordDomain.State(
                passwordA: "abc",
                passwordB: "abc",
                passwordStrength: .veryStrong,
                showPasswordErrorMessage: false
            )
        )

        await store.send(.comparePasswords)
    }

    func testSetPasswordACalculatesStrength() async {
        let store = testStore(
            with: RegisterPasswordDomain.State(
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false
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
            with: RegisterPasswordDomain.State(
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
