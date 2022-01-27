//
//  Copyright (c) 2022 gematik GmbH
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
        CardWallPINDomain.State,
        CardWallPINDomain.Action,
        CardWallPINDomain.Action,
        CardWallPINDomain.Environment
    >

    func testStore(for state: CardWallPINDomain.State)
        -> TestStore {
        TestStore(
            initialState: state,
            reducer: CardWallPINDomain.reducer,
            environment: CardWallPINDomain.Environment(userSession: MockUserSession()) { _ in }
        )
    }

    func testStore(for pin: String)
        -> TestStore {
        testStore(for: CardWallPINDomain.State(isDemoModus: false, pin: pin))
    }

    override func setUp() {
        super.setUp()
    }

    func testStateHelper_enteredPINNotNumeric() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456a")

        expect(sut.enteredPINNotNumeric).to(beTrue())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beFalse())
        expect(sut.showWarning).to(beTrue())
    }

    func testStateHelper_enteredPINTooShort() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123")

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beTrue())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beFalse())
        expect(sut.showWarning).to(beFalse())

        var sut2 = sut
        sut2.doneButtonPressed = true

        expect(sut2.enteredPINNotNumeric).to(beFalse())
        expect(sut2.enteredPINTooShort).to(beTrue())
        expect(sut2.enteredPINTooLong).to(beFalse())
        expect(sut2.enteredPINValid).to(beFalse())
        expect(sut2.showWarning).to(beTrue())
    }

    func testStateHelper_enteredPINTooLong() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456789")

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beTrue())
        expect(sut.enteredPINValid).to(beFalse())
        expect(sut.showWarning).to(beTrue())
    }

    func testStateHelper_enteredPINValid() {
        let sut = CardWallPINDomain.State(isDemoModus: false, pin: "123456")

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beTrue())
        expect(sut.showWarning).to(beFalse())
    }

    func testPINValid() {
        // given
        let store = testStore(for: "1234567")

        // when
        store.assert(
            .send(.advance) { sut in
                // then
                sut.showNextScreen = true
            }
        )
    }

    func testPINTooShort() {
        // given
        let store = testStore(for: "1234")

        store.assert(
            // when
            .send(.advance) { sut in
                // then
                sut.showNextScreen = false
                sut.doneButtonPressed = true
            },
            .send(.update(pin: "12345")) { sut in
                // then
                sut.pin = "12345"
                sut.doneButtonPressed = false
            },
            // when
            .send(.advance) { sut in
                // then
                sut.showNextScreen = false
                sut.doneButtonPressed = true
            },
            // when
            .send(.update(pin: "123456")) { sut in
                // then
                sut.pin = "123456"
                sut.doneButtonPressed = false
            },
            // when
            .send(.advance) { sut in
                // then
                sut.showNextScreen = true
            }
        )
    }

    func testPINTooLong() {
        // given
        let store = testStore(for: "123456789")

        store.assert(
            // when
            .send(.advance) { sut in
                // then
                sut.showNextScreen = false
                sut.doneButtonPressed = true
            }
        )
    }

    func testPINNotNumeric() {
        // given
        let store = testStore(for: "123456a")

        store.assert(
            // when
            .send(.advance) { sut in
                // then
                sut.showNextScreen = false
                sut.doneButtonPressed = true
            }
        )
    }
}
