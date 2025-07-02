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
            subdomain: .pin(CardWallPINDomain.Dummies.state)
        ))

        var accessibilityAnnouncementCallsCount = 0
        store.dependencies.accessibilityAnnouncementReceiver.accessibilityAnnouncement = { _ in
            accessibilityAnnouncementCallsCount += 1
        }

        expect(accessibilityAnnouncementCallsCount) == 0
        await store.send(.subdomain(.pin(.advance(.fullScreenCover)))) { state in
            state.subdomain = .readCard(CardWallReadCardDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                pin: "",
                loginOption: LoginOption.withoutBiometry,
                output: CardWallReadCardDomain.State.Output.idle
            ))
        }
        expect(accessibilityAnnouncementCallsCount) == 1
    }

    func testReadCardActionWrongPIN() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            subdomain: .readCard(CardWallReadCardDomain.Dummies.state)
        ))

        await store.send(.subdomain(.readCard(.delegate(.wrongPIN)))) { state in
            state.subdomain = .pin(CardWallPINDomain.State(isDemoModus: false,
                                                           profileId: self.testProfileId,
                                                           wrongPinEntered: true,
                                                           transition: .fullScreenCover))
        }
    }

    func testReadCardActionWrongCAN() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            subdomain: .readCard(CardWallReadCardDomain.Dummies.state)
        ))

        await store.send(.subdomain(.readCard(.delegate(.wrongCAN)))) { state in
            state.subdomain = .can(CardWallCANDomain.State(
                isDemoModus: false,
                profileId: self.testProfileId,
                can: "",
                wrongCANEntered: true
            ))
        }
    }

    func testPINActionClose() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            subdomain: .pin(CardWallPINDomain.Dummies.state)
        ))

        await store.send(.subdomain(.pin(.delegate(.close))))
        await testScheduler.run()

        await store.receive(.delegate(.close))
    }

    func testCANActionClose() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            subdomain: .can(CardWallCANDomain.Dummies.state)
        ))

        await store.send(.subdomain(.can(.delegate(.close))))
        await testScheduler.run()

        await store.receive(.delegate(.close))
    }

    func testReadCardCloseAction() async {
        let store = testStore(for: .init(
            profileId: testProfileId,
            subdomain: .readCard(CardWallReadCardDomain.Dummies.state)
        ))

        await store.send(.subdomain(.readCard(.delegate(.close)))) { state in
            state.subdomain = nil
        }
        await testScheduler.run()

        await store.receive(.delegate(.finished))
    }

    func testActionsWithoutEffectOrStateChange() async {
        let store = testStore()

        await store.send(.delegate(.close))
        await store.send(.delegate(.finished))
    }
}
