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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class CreatePasswordDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CreatePasswordDomain>

    override func setUp() {
        super.setUp()
        mockPasswordManager = MockAppSecurityManager()
        mockPasswordStrengthTester = MockPasswordStrengthTester()
        mockUserDataStore = MockUserDataStore()
    }

    func testStore(for state: CreatePasswordDomain.State) -> TestStore {
        TestStore(initialState: state) {
            CreatePasswordDomain()
        } withDependencies: { dependencies in
            dependencies.appSecurityManager = mockPasswordManager
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.passwordStrengthTester = mockPasswordStrengthTester
            dependencies.userDataStore = mockUserDataStore
        }
    }

    let emptyPasswords = CreatePasswordDomain.State(mode: .create, passwordA: "", passwordB: "")
    let testScheduler = DispatchQueue.test
    var mockPasswordManager: MockAppSecurityManager!
    var mockPasswordStrengthTester: MockPasswordStrengthTester!
    var mockUserDataStore: MockUserDataStore!

    func testSetPasswordAOnly() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none

        await store.send(\.binding.passwordA, "MyPasswordA") { state in
            state.passwordA = "MyPasswordA"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.cpwTxtPasswordStrengthInsufficient.text
        }
    }

    func testSetPasswordBOnly() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none

        await store.send(\.binding.passwordB, "MyPasswordB") { state in
            state.passwordB = "MyPasswordB"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
    }

    func testComparePasswords() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none

        await store.send(\.binding.passwordA, "MyPassword") { state in
            state.passwordA = "MyPassword"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            state.passwordStrength = .none
            let message = state.passwordErrorMessage
            expect(message) == L10n.cpwTxtPasswordStrengthInsufficient.text
        }
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.strong
        await store.send(\.binding.passwordA, "Secure password") { state in
            state.passwordA = "Secure password"
            state.passwordStrength = .strong
        }

        await testScheduler.run()
        await store.receive(.comparePasswords)

        await store.send(\.binding.passwordB, "MyPasswordB") { state in
            state.passwordB = "MyPasswordB"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)

        await store.send(\.binding.passwordB, "Secure password") { state in
            state.passwordB = "Secure password"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
    }

    func testShowPasswordsNotEqualMessageTiming() async {
        mockPasswordStrengthTester.passwordStrengthForReturnValue = .excellent

        let store = testStore(for: .init(mode: .create,
                                         passwordA: "ABC",
                                         passwordB: "ABC"))

        await store.send(\.binding.passwordB, "ABCD") { state in
            state.passwordB = "ABCD"
        }
        await testScheduler.advance(by: .seconds(0.49))
        await store.send(\.binding.passwordB, "ABCDE") { state in
            state.passwordB = "ABCDE"
        }
        await testScheduler.advance(by: .seconds(0.5))
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
        }
    }

    func testShowPasswordsNotEqualMessageTappedWhenInactive() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABCD"
            )
        )
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none
        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
        }
    }

    func testShowPasswordsNotEqualMessageTappedWhenInactiveAndZeroPasswordLength() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "",
                passwordB: "ABC",
                passwordStrength: .excellent,
                showPasswordErrorMessage: false
            )
        )

        await store.send(\.binding.passwordB, "ABCD") { state in
            state.passwordB = "ABCD"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
        await store.send(.saveButtonTapped)
    }

    func testPasswordWasSavedWhenValidCreatePasswordAndButtonPressed() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABC",
                passwordStrength: .excellent,
                showPasswordErrorMessage: true
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        expect(self.mockPasswordManager.savePasswordCalled) == false

        await store.send(.saveButtonTapped)

        await store.receive(.delegate(.closeAfterPasswordSaved(mode: .create)))

        expect(self.mockPasswordManager.savePasswordCalled) == true
        expect(self.mockPasswordManager.savePasswordCallsCount) == 1
    }

    func testPasswordWasSavedWhenInvalidCreatePasswordAndButtonPressed() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABCD"
            )
        )

        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.cpwTxtPasswordStrengthInsufficient.text
        }
        expect(self.mockPasswordManager.savePasswordCalled) == false
    }

    func testPasswordWasSavedWhenEmptyCreatePasswordAndButtonPressed() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "",
                passwordB: "",
                showPasswordErrorMessage: false
            )
        )

        await store.send(.saveButtonTapped)
        expect(self.mockPasswordManager.savePasswordCalled) == false
    }

    func testCloseWhenPasswordSavedSuccessfully() async {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABC",
                passwordStrength: .excellent
            )
        )
        mockPasswordManager.savePasswordReturnValue = true

        await store.send(.saveButtonTapped)
        await store.receive(.delegate(.closeAfterPasswordSaved(mode: .create)))
    }

    func testUpdatePasswordChecksPassword() async {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABC",
                passwordStrength: .excellent
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        await store.send(.saveButtonTapped)
        await store.receive(.delegate(.closeAfterPasswordSaved(mode: .update)))
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordCalled).to(beTrue())
    }

    func testUpdatePasswordFailsIfPreviousPasswordIsWrong() async {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABC",
                passwordStrength: .excellent
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = false

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        await store.send(.saveButtonTapped) { state in
            state.showOriginalPasswordWrong = true
        }
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
    }

    func testUpdatePasswordFailsIfPasswordDontMatch() async {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABCD",
                passwordStrength: .excellent
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
        }
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
    }

    func testSaveFailsIfPasswordStrengthLow() async {
        let store = testStore(
            for: .init(
                mode: .create,
                password: "",
                passwordA: "abc",
                passwordB: "abc",
                passwordStrength: .veryWeak,
                showPasswordErrorMessage: false,
                showOriginalPasswordWrong: false
            )
        )

        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none
        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.cpwTxtPasswordStrengthInsufficient.text
        }
        expect(self.mockPasswordManager.savePasswordCallsCount).to(equal(0))
    }

    func testSetPasswordTriggersSetPasswordStrength() async {
        let store = testStore(
            for: .init(
                mode: .create,
                password: "",
                passwordA: "",
                passwordB: ""
            )
        )

        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.excellent

        await store.send(\.binding.passwordA, "abc") { state in
            state.passwordA = "abc"
            state.passwordStrength = .excellent
        }
        expect(self.mockPasswordStrengthTester.passwordStrengthForCallsCount).to(equal(1))

        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
    }
}
