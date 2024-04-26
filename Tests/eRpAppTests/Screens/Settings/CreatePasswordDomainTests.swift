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

        await store.send(.setPasswordA("MyPasswordA")) { state in
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

        await store.send(.setPasswordB("MyPasswordB")) { state in
            state.passwordB = "MyPasswordB"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)
    }

    func testComparePasswords() async {
        let store = testStore(for: emptyPasswords)
        mockPasswordStrengthTester.passwordStrengthForReturnValue = PasswordStrength.none

        await store.send(.setPasswordA("MyPassword")) { state in
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
        await store.send(.setPasswordA("Secure password")) { state in
            state.passwordA = "Secure password"
            state.passwordStrength = .strong
        }

        await testScheduler.run()
        await store.receive(.comparePasswords)

        await store.send(.setPasswordB("MyPasswordB")) { state in
            state.passwordB = "MyPasswordB"
        }
        await testScheduler.run()
        await store.receive(.comparePasswords)

        await store.send(.setPasswordB("Secure password")) { state in
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

        await store.send(.setPasswordB("ABCD")) { state in
            state.passwordB = "ABCD"
        }
        await testScheduler.advance(by: .seconds(0.49))
        await store.send(.setPasswordB("ABCDE")) { state in
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

        await store.send(.setPasswordB("ABCD")) { state in
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

        await store.receive(.delegate(.closeAfterPasswordSaved))

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
        await store.receive(.delegate(.closeAfterPasswordSaved))
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
        await store.receive(.delegate(.closeAfterPasswordSaved))
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

        await store.send(.setPasswordA("abc")) { state in
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

// MARK: - MockAppSecurityManager -

final class MockAppSecurityManager: AppSecurityManager {
    // MARK: - save

    var savePasswordThrowableError: Error?
    var savePasswordCallsCount = 0
    var savePasswordCalled: Bool {
        savePasswordCallsCount > 0
    }

    var savePasswordReceivedPassword: String?
    var savePasswordReceivedInvocations: [String] = []
    var savePasswordReturnValue: Bool!
    var savePasswordClosure: ((String) throws -> Bool)?

    func save(password: String) throws -> Bool {
        if let error = savePasswordThrowableError {
            throw error
        }
        savePasswordCallsCount += 1
        savePasswordReceivedPassword = password
        savePasswordReceivedInvocations.append(password)
        return try savePasswordClosure.map { try $0(password) } ?? savePasswordReturnValue
    }

    // MARK: - matches

    var matchesPasswordThrowableError: Error?
    var matchesPasswordCallsCount = 0
    var matchesPasswordCalled: Bool {
        matchesPasswordCallsCount > 0
    }

    var matchesPasswordReceivedPassword: String?
    var matchesPasswordReceivedInvocations: [String] = []
    var matchesPasswordReturnValue: Bool!
    var matchesPasswordClosure: ((String) throws -> Bool)?

    func matches(password: String) throws -> Bool {
        if let error = matchesPasswordThrowableError {
            throw error
        }
        matchesPasswordCallsCount += 1
        matchesPasswordReceivedPassword = password
        matchesPasswordReceivedInvocations.append(password)
        return try matchesPasswordClosure.map { try $0(password) } ?? matchesPasswordReturnValue
    }

    var availableSecurityOptionsCallsCount = 0
    var availableSecurityOptionsCalled: Bool {
        availableSecurityOptionsCallsCount > 0
    }

    var availableSecurityOptionsReturnValue: (options: [AppSecurityOption], error: AppSecurityManagerError?)
        = (options: [.password], error: nil)
    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        availableSecurityOptionsCallsCount += 1
        return availableSecurityOptionsReturnValue
    }
}
