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
import Nimble
import XCTest

@MainActor
final class AppAuthenticationPasswordDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<AppAuthenticationPasswordDomain>

    let emptyPassword = AppAuthenticationPasswordDomain.State(password: "")
    let abcPassword = AppAuthenticationPasswordDomain.State(password: "abc")
    var mockAppSecurityPasswordManager: MockAppSecurityManager!

    override func setUp() {
        super.setUp()
        mockAppSecurityPasswordManager = MockAppSecurityManager()
    }

    func testStore(for state: AppAuthenticationPasswordDomain.State) -> TestStore {
        TestStore(initialState: state) {
            AppAuthenticationPasswordDomain()
        } withDependencies: { dependencies in
            dependencies.appSecurityManager = mockAppSecurityPasswordManager
        }
    }

    func testDomainInitializesWithActivePasswordDelay() async {
        let clock = TestClock()
        let mockAppSecurityManager = MockAppSecurityManager()

        let store = TestStore(initialState: emptyPassword) {
            AppAuthenticationPasswordDomain()
        } withDependencies: {
            $0.appSecurityManager = mockAppSecurityManager
            $0.continuousClock = clock
        }

        mockAppSecurityManager.currentPasswordDelayReturnValue = 10.0

        let task = await store.send(.task)
        await store.receive(.currentPasswordDelayReceived(10.0)) { state in
            state.passwordDelay = 10.0
        }
        expect(mockAppSecurityManager.currentPasswordDelayCalled).to(beTrue())
        expect(mockAppSecurityManager.currentPasswordDelayCallsCount).to(equal(1))

        await clock.advance(by: .seconds(9))
        // Receive 9 timer ticks
        for _ in 0 ..< 9 {
            await store.receive(.passwordDelayTimerTick) { state in
                state.passwordDelay -= 1.0
            }
        }

        // After 1 more second the delay timer should finish
        await clock.advance(by: .seconds(1))
        await store.receive(.passwordDelayTimerTick) { state in
            state.passwordDelay = 0.0
        }

        await task.cancel()
    }

    func testSetPassword() async {
        let store = testStore(for: emptyPassword)

        await store.send(.setPassword("MyPassword")) { state in
            state.password = "MyPassword"
        }
    }

    func testPasswordIsCheckedWhenContinueButtonWasTapped() async {
        let store = testStore(for: abcPassword)
        mockAppSecurityPasswordManager.matchesPasswordReturnValue = true

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beFalse())
        await store.send(.loginButtonTapped)
        await store.receive(.passwordVerificationReceived(true))

        expect(self.mockAppSecurityPasswordManager.matchesPasswordCalled).to(beTrue())
        expect(self.mockAppSecurityPasswordManager.resetPasswordDelayCalled).to(beTrue())
        expect(self.mockAppSecurityPasswordManager.registerFailedPasswordAttemptCalled).to(beFalse())
    }

    func testPasswordDoesNotMatch() async {
        let clock = TestClock()
        let mockAppSecurityManager = MockAppSecurityManager()

        let store = TestStore(initialState: abcPassword) {
            AppAuthenticationPasswordDomain()
        } withDependencies: {
            $0.appSecurityManager = mockAppSecurityManager
            $0.continuousClock = clock
        }
        mockAppSecurityManager.matchesPasswordReturnValue = false
        mockAppSecurityManager.currentPasswordDelayReturnValue = 10.0

        expect(mockAppSecurityManager.matchesPasswordCalled).to(beFalse())
        await store.send(.loginButtonTapped)
        await store.receive(.passwordVerificationReceived(false)) { state in
            state.lastMatchResultSuccessful = false
        }
        await store.receive(.currentPasswordDelayReceived(10.0)) { state in
            state.passwordDelay = 10.0
        }

        await clock.advance(by: .seconds(10))
        for _ in 0 ..< 10 {
            await store.receive(.passwordDelayTimerTick) { state in
                state.passwordDelay -= 1.0
            }
        }

        expect(mockAppSecurityManager.matchesPasswordCalled).to(beTrue())
        expect(mockAppSecurityManager.resetPasswordDelayCalled).to(beFalse())
        expect(mockAppSecurityManager.registerFailedPasswordAttemptCalled).to(beTrue())
    }
}
