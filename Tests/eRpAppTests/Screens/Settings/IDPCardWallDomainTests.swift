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

@MainActor
final class IDPCardWallDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<IDPCardWallDomain>

    let testScheduler = DispatchQueue.test
    var schedulers: Schedulers!
    var mockUserSession: MockUserSession!
    var mockUserSessionProvider: MockUserSessionProvider!
    var mockSecureEnclaveSignatureProvider: MockSecureEnclaveSignatureProvider!
    var mockNFCSignatureProvider: MockNFCSignatureProvider!
    var mockSessionProvider: MockProfileBasedSessionProvider!

    override func setUp() {
        super.setUp()

        schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        mockUserSession = MockUserSession()
        mockUserSessionProvider = MockUserSessionProvider()
        mockSecureEnclaveSignatureProvider = MockSecureEnclaveSignatureProvider()
        mockNFCSignatureProvider = MockNFCSignatureProvider()
        mockSessionProvider = MockProfileBasedSessionProvider()
    }

    func testStore() -> TestStore {
        testStore(for: IDPCardWallDomain.Dummies.state)
    }

    func testStore(for state: IDPCardWallDomain.State) -> TestStore {
        TestStore(
            initialState: state
        ) {
            IDPCardWallDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = mockUserSession
        }
    }

    let testProfileId = UUID()

    func testPinActionAdvanceFullscreenCover() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            pin: CardWallPINDomain.Dummies.state
        ))

        var accessibilityAnnouncementCallsCount = 0
        store.dependencies.accessibilityAnnouncementReceiver.accessibilityAnnouncement = { _ in
            accessibilityAnnouncementCallsCount += 1
        }

        expect(accessibilityAnnouncementCallsCount) == 0
        await store.send(.pinAction(action: .advance(.fullScreenCover))) { state in
            state.pin.doneButtonPressed = true
            state.readCard = CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                pin: "",
                loginOption: LoginOption.withoutBiometry,
                output: CardWallReadCardDomain.State.Output.idle
            )
        }
        expect(accessibilityAnnouncementCallsCount) == 1
    }

    func testReadCardActionWrongPIN() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                profileId: UUID(),
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        await store.send(.readCard(action: .delegate(.wrongPIN))) { state in
            state.pin.wrongPinEntered = true
        }
    }

    func testReadCardActionWrongCAN() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                profileId: UUID(),
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        await store.send(.readCard(action: .delegate(.wrongCAN))) { state in
            state.can = CardWallCANDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                can: "",
                wrongCANEntered: true,
                scannedCAN: nil,
                isFlashOn: false,
                destination: nil
            )
        }
    }

    func testReadCardActionWrongCANWithEmptyCAN() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                profileId: UUID(),
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        await store.send(.readCard(action: .delegate(.wrongCAN))) { state in
            state.can = CardWallCANDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                can: "",
                wrongCANEntered: true
            )
        }
    }

    func testPINActionClose() async {
        let store = testStore()

        await store.send(.canAction(action: .delegate(.close)))
        await testScheduler.run()

        await store.receive(.delegate(.close))
    }

    func testCANActionClose() async {
        let store = testStore()

        await store.send(.canAction(action: .delegate(.close)))
        await testScheduler.run()

        await store.receive(.delegate(.close))
    }

    func testReadCardCloseAction() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                profileId: UUID(),
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        await store.send(.readCard(action: .delegate(.close)))
        await testScheduler.run()

        await store.receive(.delegate(.finished))
    }

    func testActionsWithoutEffectOrStateChange() async {
        let store = testStore()

        await store.send(.delegate(.close))
        await store.send(.delegate(.finished))
    }

    func testPinCloseActionShouldBeForwarded() async {
        let store = testStore()

        // when
        await store.send(.pinAction(action: .delegate(.close)))
        // then
        await store.receive(.delegate(.close))
    }
}
