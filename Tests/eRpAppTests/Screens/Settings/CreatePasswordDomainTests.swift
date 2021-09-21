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
import Nimble
import XCTest

final class CreatePasswordDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CreatePasswordDomain.State,
        CreatePasswordDomain.State,
        CreatePasswordDomain.Action,
        CreatePasswordDomain.Action,
        CreatePasswordDomain.Environment
    >

    override func setUp() {
        super.setUp()
        mockPasswordManager = MockAppSecurityPasswordManager()
    }

    func testStore(for state: CreatePasswordDomain.State) -> TestStore {
        TestStore(initialState: state,
                  reducer: CreatePasswordDomain.reducer,
                  environment: CreatePasswordDomain.Environment(
                      passwordManager: mockPasswordManager,
                      schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
                  ))
    }

    let emptyPasswords = CreatePasswordDomain.State(mode: .create, passwordA: "", passwordB: "")
    let testScheduler = DispatchQueue.test
    var mockPasswordManager: MockAppSecurityPasswordManager!

    func testSetPasswordA() {
        let store = testStore(for: emptyPasswords)

        store.send(.setPasswordA("MyPasswordA")) { state in
            state.passwordA = "MyPasswordA"
        }
        testScheduler.run()
        store.receive(.comparePasswords)
    }

    func testSetPasswordB() {
        let store = testStore(for: emptyPasswords)

        store.send(.setPasswordB("MyPasswordB")) { state in
            state.passwordB = "MyPasswordB"
        }
        testScheduler.run()
        store.receive(.comparePasswords)
    }

    func testComparePasswords() {
        let store = testStore(for: emptyPasswords)

        store.send(.setPasswordA("MyPassword")) { state in
            state.passwordA = "MyPassword"
        }
        testScheduler.run()
        store.receive(.comparePasswords)

        store.send(.setPasswordB("MyPasswordB")) { state in
            state.passwordB = "MyPasswordB"
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = true
        }

        store.send(.setPasswordB("MyPassword")) { state in
            state.passwordB = "MyPassword"
        }
        testScheduler.run()
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = false
        }
    }

    func testShowPasswordsNotEqualMessageTiming() {
        let store = testStore(for: .init(mode: .create,
                                         passwordA: "ABC",
                                         passwordB: "ABC",
                                         showPasswordsNotEqualMessage: false))

        store.send(.setPasswordB("ABCD")) { state in
            state.passwordB = "ABCD"
        }
        testScheduler.advance(by: .seconds(0.49))
        store.send(.setPasswordB("ABCDE")) { state in
            state.passwordB = "ABCDE"
        }
        testScheduler.advance(by: .seconds(0.5))
        store.receive(.comparePasswords) { state in
            state.showPasswordsNotEqualMessage = true
        }
    }

    func testShowPasswordsNotEqualMessageTappedWhenInactive() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABCD",
                showPasswordsNotEqualMessage: false
            )
        )

        store.send(.saveButtonTapped) { state in
            state.showPasswordsNotEqualMessage = true
        }
    }

    func testShowPasswordsNotEqualMessageTappedWhenInactiveAndZeroPasswordLength() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "",
                passwordB: "ABC",
                showPasswordsNotEqualMessage: false
            )
        )

        store.send(.setPasswordB("ABCD")) { state in
            state.passwordB = "ABCD"
        }

        store.send(.saveButtonTapped) { state in
            state.showPasswordsNotEqualMessage = true
        }
    }

    func testPasswordWasSavedWhenValidCreatePasswordAndButtonPressed() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABC",
                showPasswordsNotEqualMessage: false
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        expect(self.mockPasswordManager.savePasswordCalled) == false

        store.send(.saveButtonTapped)

        store.receive(.closeAfterPasswordSaved)

        expect(self.mockPasswordManager.savePasswordCalled) == true
        expect(self.mockPasswordManager.savePasswordCallsCount) == 1
    }

    func testPasswordWasSavedWhenInvalidCreatePasswordAndButtonPressed() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABCD",
                showPasswordsNotEqualMessage: true
            )
        )

        store.send(.saveButtonTapped)
        expect(self.mockPasswordManager.savePasswordCalled) == false
    }

    func testPasswordWasSavedWhenEmptyCreatePasswordAndButtonPressed() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "",
                passwordB: "",
                showPasswordsNotEqualMessage: false
            )
        )

        store.send(.saveButtonTapped)
        expect(self.mockPasswordManager.savePasswordCalled) == false
    }

    func testCloseWhenPasswordSavedSuccessfully() {
        let store = testStore(
            for: .init(
                mode: .create,
                passwordA: "ABC",
                passwordB: "ABC",
                showPasswordsNotEqualMessage: false
            )
        )
        mockPasswordManager.savePasswordReturnValue = true

        store.send(.saveButtonTapped)
        store.receive(.closeAfterPasswordSaved)
    }

    func testUpdatePasswordChecksPassword() {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABC",
                showPasswordsNotEqualMessage: false
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        store.send(.saveButtonTapped)
        store.receive(.closeAfterPasswordSaved)
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordCalled).to(beTrue())
    }

    func testUpdatePasswordFailsIfPreviousPasswordIsWrong() {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABC",
                showPasswordsNotEqualMessage: false
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = false

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        store.send(.saveButtonTapped) { state in
            state.showOriginalPasswordWrong = true
        }
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
    }

    func testUpdatePasswordFailsIfPasswordDontMatch() {
        let store = testStore(
            for: .init(
                mode: .update,
                password: "abc",
                passwordA: "ABC",
                passwordB: "ABCD",
                showPasswordsNotEqualMessage: false
            )
        )
        mockPasswordManager.savePasswordReturnValue = true
        mockPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockPasswordManager.matchesPasswordCalled).to(beFalse())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
        store.send(.saveButtonTapped) { state in
            state.showPasswordsNotEqualMessage = true
        }
        expect(self.mockPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockPasswordManager.savePasswordCalled).to(beFalse())
    }
}

// MARK: - MockAppSecurityPasswordManager -

final class MockAppSecurityPasswordManager: AppSecurityPasswordManager {
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
}
