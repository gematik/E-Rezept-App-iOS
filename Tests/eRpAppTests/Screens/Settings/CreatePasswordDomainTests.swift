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
import eRpResources
import FeatureHelpers
import Nimble
import XCTest

@MainActor
final class CreatePasswordDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CreatePasswordDomain>

    override func setUp() {
        super.setUp()
        mockPasswordManager = AppSecurityManagerMock()
        mockPasswordStrengthTester = PasswordStrengthTesterMock()
        mockUserDataStore = UserDataStoreMock()
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
    var mockPasswordManager: AppSecurityManagerMock!
    var mockPasswordStrengthTester: PasswordStrengthTesterMock!
    var mockUserDataStore: UserDataStoreMock!

    func testSetPasswordAOnly() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength.none

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
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength.none

        await store.send(\.binding.passwordB, "MyPasswordB") { state in
            state.passwordB = "MyPasswordB"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
    }

    func testComparePasswords() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength.none

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
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength
            .strong
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
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = .excellent

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
        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength.none
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
        mockPasswordManager.savePasswordStringBoolReturnValue = true
        expect(self.mockPasswordManager.savePasswordStringBoolCalled) == false

        await store.send(.saveButtonTapped)

        await store.receive(.delegate(.closeAfterPasswordSaved(mode: .create)))

        expect(self.mockPasswordManager.savePasswordStringBoolCalled) == true
        expect(self.mockPasswordManager.savePasswordStringBoolCallsCount) == 1
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
        expect(self.mockPasswordManager.savePasswordStringBoolCalled) == false
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
        expect(self.mockPasswordManager.savePasswordStringBoolCalled) == false
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
        mockPasswordManager.savePasswordStringBoolReturnValue = true

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
        mockPasswordManager.savePasswordStringBoolReturnValue = true
        mockPasswordManager.matchesPasswordStringBoolReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beFalse())
        await store.send(.saveButtonTapped)
        await store.receive(.delegate(.closeAfterPasswordSaved(mode: .update)))
        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beTrue())
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
        mockPasswordManager.savePasswordStringBoolReturnValue = true
        mockPasswordManager.matchesPasswordStringBoolReturnValue = false

        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beFalse())
        await store.send(.saveButtonTapped) { state in
            state.showOriginalPasswordWrong = true
        }
        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beFalse())
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
        mockPasswordManager.savePasswordStringBoolReturnValue = true
        mockPasswordManager.matchesPasswordStringBoolReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beFalse())
        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
        }
        expect(self.mockPasswordManager.matchesPasswordStringBoolCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordStringBoolCalled).to(beFalse())
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

        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength.none
        await store.send(.saveButtonTapped) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message) == L10n.cpwTxtPasswordStrengthInsufficient.text
        }
        expect(self.mockPasswordManager.savePasswordStringBoolCallsCount).to(equal(0))
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

        mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthReturnValue = PasswordStrength
            .excellent

        await store.send(\.binding.passwordA, "abc") { state in
            state.passwordA = "abc"
            state.passwordStrength = .excellent
        }
        expect(self.mockPasswordStrengthTester.passwordStrengthForPasswordStringPasswordStrengthCallsCount).to(equal(1))

        await testScheduler.run()
        await store.receive(.comparePasswords) { state in
            state.showPasswordErrorMessage = true
            let message = state.passwordErrorMessage
            expect(message).to(beNil())
        }
    }
}
