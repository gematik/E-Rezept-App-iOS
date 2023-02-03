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

final class IDPCardWallDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        IDPCardWallDomain.State,
        IDPCardWallDomain.Action,
        IDPCardWallDomain.State,
        IDPCardWallDomain.Action,
        IDPCardWallDomain.Environment
    >

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
        TestStore(initialState: state,
                  reducer: IDPCardWallDomain.reducer,
                  environment: IDPCardWallDomain.Environment(
                      schedulers: schedulers,
                      userSession: mockUserSession,
                      userSessionProvider: mockUserSessionProvider,
                      secureEnclaveSignatureProvider: mockSecureEnclaveSignatureProvider,
                      nfcSignatureProvider: mockNFCSignatureProvider,
                      sessionProvider: mockSessionProvider,
                      accessibilityAnnouncementReceiver: { _ in }
                  ))
    }

    let testProfileId = UUID()

    func testPinActionAdvanceFullscreenCover() {
        let store = testStore(for: .init(
            profileId: testProfileId,
            pin: CardWallPINDomain.Dummies.state
        ))

        store.send(.pinAction(action: .advance(.fullScreenCover))) { state in
            state.pin.doneButtonPressed = true
            state.readCard = CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                pin: "",
                loginOption: LoginOption.withoutBiometry,
                output: CardWallReadCardDomain.State.Output.idle
            )
        }
    }

    func testReadCardActionWrongPIN() {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        store.send(.readCard(action: .wrongPIN)) { state in
            state.pin.wrongPinEntered = true
        }
    }

    func testReadCardActionWrongCAN() {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        store.send(.readCard(action: .wrongCAN)) { state in
            state.can = CardWallCANDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                can: "",
                wrongCANEntered: true,
                scannedCAN: nil,
                isFlashOn: false,
                route: nil
            )
        }
    }

    func testReadCardActionWrongCANWithEmptyCAN() {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        store.send(.readCard(action: .wrongCAN)) { state in
            state.can = CardWallCANDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                can: "",
                wrongCANEntered: true
            )
        }
    }

    func testPINActionClose() {
        let store = testStore()

        store.send(.canAction(action: .close))
        testScheduler.run()

        store.receive(.close)
    }

    func testCANActionClose() {
        let store = testStore()

        store.send(.canAction(action: .close))
        testScheduler.run()

        store.receive(.close)
    }

    func testReadCardCloseAction() {
        let store = testStore(for: .init(
            profileId: testProfileId,
            can: nil,
            pin: .init(
                isDemoModus: false,
                transition: .fullScreenCover
            ),
            readCard: CardWallReadCardDomain.Dummies.state
        ))

        store.send(.readCard(action: .close))
        testScheduler.run()

        store.receive(.finished)
    }

    func testActionsWithoutEffectOrStateChange() {
        let store = testStore()

        store.send(.close)
        store.send(.finished)
    }

    func testPinCloseActionShouldBeForwarded() {
        let store = testStore()

        // when
        store.send(.pinAction(action: .close))
        // then
        store.receive(.close)
    }
}
