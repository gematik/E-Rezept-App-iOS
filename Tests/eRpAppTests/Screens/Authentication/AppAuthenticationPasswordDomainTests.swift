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
import Nimble
import XCTest

final class AppAuthenticationPasswordDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        AppAuthenticationPasswordDomain.State,
        AppAuthenticationPasswordDomain.Action,
        AppAuthenticationPasswordDomain.State,
        AppAuthenticationPasswordDomain.Action,
        AppAuthenticationPasswordDomain.Environment
    >
    let emptyPassword = AppAuthenticationPasswordDomain.State(password: "")
    let abcPassword = AppAuthenticationPasswordDomain.State(password: "abc")
    var mockAppSecurityPasswordManager: MockAppSecurityManager!

    override func setUp() {
        super.setUp()
        mockAppSecurityPasswordManager = MockAppSecurityManager()
    }

    func testStore(for state: AppAuthenticationPasswordDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: AppAuthenticationPasswordDomain.reducer,
            environment: AppAuthenticationPasswordDomain.Environment(
                appSecurityPasswordManager: mockAppSecurityPasswordManager
            )
        )
    }

    func testSetPassword() {
        let store = testStore(for: emptyPassword)

        store.send(.setPassword("MyPassword")) { state in
            state.password = "MyPassword"
        }
    }

    func testPasswordIsCheckedWhenContinueButtonWasTapped() {
        let store = testStore(for: abcPassword)
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        store.send(.loginButtonTapped)
        store.receive(.passwordVerificationReceived(true)) { state in
            state.lastMatchResultSuccessful = true
        }
        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
    }

    func testPasswordDoesNotMatch() {
        let store = testStore(for: abcPassword)
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = false

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        store.send(.loginButtonTapped)
        store.receive(.passwordVerificationReceived(false)) { state in
            state.lastMatchResultSuccessful = false
        }
        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
    }
}
