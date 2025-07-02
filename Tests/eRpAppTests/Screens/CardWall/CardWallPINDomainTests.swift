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
final class CardWallPINDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<CardWallPINDomain>

    func testStore(for state: CardWallPINDomain.State)
        -> TestStore {
        TestStore(initialState: state) {
            CardWallPINDomain()
        } withDependencies: { dependencies in
            dependencies.userSession = MockUserSession()
            dependencies.schedulers = Schedulers()
            // TODO: use mock dependencies // swiftlint:disable:this todo
            dependencies.profileBasedSessionProvider = DummyProfileBasedSessionProvider()
            dependencies.secureEnclaveSignatureProvider = DummySecureEnclaveSignatureProvider()
        }
    }

    func testStore(for pin: String)
        -> TestStore {
        testStore(for: CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: pin, transition: .push))
    }

    override func setUp() {
        super.setUp()
    }

    func testStateHelper_enteredPINNotNumeric() async {
        let sut = CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: "123456a", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beTrue())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beFalse())
    }

    func testStateHelper_enteredPINTooShort() async {
        let sut = CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: "123", transition: .push)

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

    func testStateHelper_enteredPINTooLong() async {
        let sut = CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: "123456789", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beTrue())
        expect(sut.enteredPINValid).to(beFalse())
    }

    func testStateHelper_enteredPINValid() async {
        let sut = CardWallPINDomain.State(isDemoModus: false, profileId: UUID(), pin: "123456", transition: .push)

        expect(sut.enteredPINNotNumeric).to(beFalse())
        expect(sut.enteredPINTooShort).to(beFalse())
        expect(sut.enteredPINTooLong).to(beFalse())
        expect(sut.enteredPINValid).to(beTrue())
    }

    func testPINValid() async {
        // given
        let store = testStore(for: "1234567")

        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut
                .destination = .login(CardWallLoginOptionDomain
                    .State(isDemoModus: false, profileId: sut.profileId, pin: "1234567"))
        }
    }

    func testPINTooShort() async {
        // given
        let store = testStore(for: "1234")

        var accessibilityAnnouncementCallsCount = 0
        store.dependencies.accessibilityAnnouncementReceiver.accessibilityAnnouncement = { _ in
            accessibilityAnnouncementCallsCount += 1
        }
        expect(accessibilityAnnouncementCallsCount) == 0

        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut.destination = .none
            sut.doneButtonPressed = true
        }
        expect(accessibilityAnnouncementCallsCount) == 1
        await store.send(.update(pin: "12345")) { sut in
            // then
            sut.pin = "12345"
            sut.doneButtonPressed = false
        }
        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut.destination = .none
            sut.doneButtonPressed = true
        }
        expect(accessibilityAnnouncementCallsCount) == 2

        // when
        await store.send(.update(pin: "123456")) { sut in
            // then
            sut.pin = "123456"
            sut.doneButtonPressed = false
        }
        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut
                .destination = .login(CardWallLoginOptionDomain
                    .State(isDemoModus: false, profileId: sut.profileId, pin: "123456"))
        }
    }

    func testPINTooLong() async {
        // given
        let store = testStore(for: "123456789")

        var accessibilityAnnouncementCallsCount = 0
        store.dependencies.accessibilityAnnouncementReceiver.accessibilityAnnouncement = { _ in
            accessibilityAnnouncementCallsCount += 1
        }
        expect(accessibilityAnnouncementCallsCount) == 0

        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut.destination = .none
            sut.doneButtonPressed = true
        }
        expect(accessibilityAnnouncementCallsCount) == 1
    }

    func testPINNotNumeric() async {
        // given
        let store = testStore(for: "123456a")

        var accessibilityAnnouncementCallsCount = 0
        store.dependencies.accessibilityAnnouncementReceiver.accessibilityAnnouncement = { _ in
            accessibilityAnnouncementCallsCount += 1
        }
        expect(accessibilityAnnouncementCallsCount) == 0

        // when
        await store.send(.advance(.push)) { sut in
            // then
            sut.destination = .none
            sut.doneButtonPressed = true
        }
        expect(accessibilityAnnouncementCallsCount) == 1
    }
}
