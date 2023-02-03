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

final class CardWallPINDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        CardWallPINDomain.State,
        CardWallPINDomain.Action,
        CardWallPINDomain.State,
        CardWallPINDomain.Action,
        CardWallPINDomain.Environment
    >

    func testStore(for state: CardWallPINDomain.State)
        -> TestStore {
        TestStore(
            initialState: state,
            reducer: CardWallPINDomain.reducer,
            environment: CardWallPINDomain.Environment(
                userSession: MockUserSession(),
                schedulers: Schedulers(),
                sessionProvider: DummyProfileBasedSessionProvider(),
                signatureProvider: DummySecureEnclaveSignatureProvider()
            ) { _ in }
        )
    }

    func testStore(for pin: String)
        -> TestStore {
        testStore(for: CardWallPINDomain.State(isDemoModus: false, pin: pin, transition: .push))
    }

    override func setUp() {
        super.setUp()
    }

    func testStateHelper_enteredPINNotNumeric() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456a", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beTrue())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beFalse())
    }

    func testStateHelper_enteredPINTooShort() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beTrue())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beFalse())

        var sut2 = sut
        sut2.doneButtonPressed = true

        expect(sut2.enteredPINNotNumeric).to(beFalse())
        expect(sut2.enteredPINTooShort).to(beTrue())
        expect(sut2.enteredPINTooLong).to(beFalse())
        expect(sut2.enteredPINValid).to(beFalse())
    }

    func testStateHelper_enteredPINTooLong() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456789", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beTrue())
        expect(sut.enteredPINValid).to(beFalse())
    }

    func testStateHelper_enteredPINValid() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beTrue())
    }

    func testPINValid() {
        // given
        let store = testStore(for: "1234567")

        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .login(CardWallLoginOptionDomain.State(isDemoModus: false, pin: "1234567"))
        }
    }

    func testPINTooShort() {
        // given
        let store = testStore(for: "1234")

        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .none
            sut.doneButtonPressed = true
        }
        store.send(.update(pin: "12345")) { sut in
            // then
            sut.pin = "12345"
            sut.doneButtonPressed = false
        }
        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .none
            sut.doneButtonPressed = true
        }
        // when
        store.send(.update(pin: "123456")) { sut in
            // then
            sut.pin = "123456"
            sut.doneButtonPressed = false
        }
        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .login(CardWallLoginOptionDomain.State(isDemoModus: false, pin: "123456"))
        }
    }

    func testPINTooLong() {
        // given
        let store = testStore(for: "123456789")

        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .none
            sut.doneButtonPressed = true
        }
    }

    func testPINNotNumeric() {
        // given
        let store = testStore(for: "123456a")

        // when
        store.send(.advance(.push)) { sut in
            // then
            sut.route = .none
            sut.doneButtonPressed = true
        }
    }
}
