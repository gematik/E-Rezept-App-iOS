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

import Combine
@testable import eRpApp
import eRpKit
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class CardWallSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testSelectionView() {
        let sut = CardWallView(
            store: CardWallDomain.Store(
                initialState: .init(
                    introAlreadyDisplayed: false,
                    isNFCReady: true,
                    isMinimalOS14: true,
                    pin: .init(isDemoModus: false),
                    loginOption: .init(isDemoModus: false)
                ),
                reducer: .empty,
                environment: CardWallDomain.Dummies.environment
            )
        )

        // This snapshots are subject to feature flags.
        // If these test fail, delete the app within your simulator and restart the test.
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testFastTrackFallbackView() {
        let sut = CardWallExtAuthFallbackView(closeAction: {})

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testIntroductionView() {
        let sut = CardWallIntroductionView(
            store: CardWallIntroductionDomain.Dummies.store,
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testNotForYouViewWithCapabilties() {
        let sut = CapabilitiesView(
            store: CardWallDomain.Dummies.store
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testNotForYouViewWithoutCapabilties() {
        let sut = CapabilitiesView(
            store: CardWallDomain.Store(
                initialState: CardWallDomain
                    .State(
                        introAlreadyDisplayed: true,
                        isNFCReady: false,
                        isMinimalOS14: true,
                        can: nil,
                        pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                        loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
                    ),
                reducer: CardWallDomain.reducer,
                environment: CardWallDomain.Dummies.environment
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputView() {
        let sut = CardWallCANView(
            store: CardWallCANDomain.Store(
                initialState: CardWallCANDomain.State(isDemoModus: false, can: "", showNextScreen: false),
                reducer: .empty,
                environment: CardWallCANDomain.Dummies.environment
            ),
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputViewInDemoMode() {
        let sut = CardWallCANView(
            store: CardWallCANDomain.Store(
                initialState: CardWallCANDomain.State(isDemoModus: true, can: "", showNextScreen: false),
                reducer: .empty,
                environment: CardWallCANDomain.Dummies.environment
            ),
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputWrongCANEnteredView() {
        let sut = CardWallCANView(
            store: CardWallCANDomain.Store(
                initialState: CardWallCANDomain.State(isDemoModus: false,
                                                      can: "",
                                                      wrongCANEntered: true,
                                                      showNextScreen: false),
                reducer: .empty,
                environment: CardWallCANDomain.Dummies.environment
            ),
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputView() {
        let sut = CardWallPINView(
            store: CardWallPINDomain.Store(
                initialState: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                reducer: .empty,
                environment: CardWallPINDomain.Dummies.environment
            ), nextView: { _ in EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputViewInDemoMode() {
        let sut = CardWallPINView(
            store: CardWallPINDomain.Store(
                initialState: CardWallPINDomain.State(isDemoModus: true, pin: "123"),
                reducer: .empty,
                environment: CardWallPINDomain.Dummies.environment
            ),
            nextView: { _ in EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputWrongPINEnteredView() {
        var state = CardWallPINDomain.State(isDemoModus: false,
                                            pin: "")
        state.wrongPinEntered = true
        let sut = CardWallPINView(
            store: CardWallPINDomain.Store(
                initialState: state,
                reducer: .empty,
                environment: CardWallPINDomain.Dummies.environment
            ), nextView: { _ in EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoginOptionView() {
        let sut = CardWallLoginOptionView(
            store: CardWallLoginOptionDomain.Store(
                initialState: CardWallLoginOptionDomain.State(isDemoModus: false,
                                                              selectedLoginOption: .withoutBiometry),
                reducer: .empty,
                environment: CardWallLoginOptionDomain.Dummies.environment
            ),
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoginOptionViewInDemoMode() {
        let sut = CardWallLoginOptionView(
            store: CardWallLoginOptionDomain.Store(
                initialState: CardWallLoginOptionDomain.State(isDemoModus: true,
                                                              selectedLoginOption: .withoutBiometry),
                reducer: .empty,
                environment: CardWallLoginOptionDomain.Dummies.environment
            ),
            nextView: { EmptyView() }
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    lazy var testProfile = { Profile(name: "testProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockCurrentProfile: AnyPublisher<Profile, LocalStoreError>!
    private func readCardStore(for state: CardWallReadCardDomain.State) -> CardWallReadCardDomain.Store {
        mockProfileValidator = CurrentValueSubject(
            ProfileValidator(currentProfile: testProfile, otherProfiles: [testProfile])
        ).eraseToAnyPublisher()
        mockCurrentProfile = CurrentValueSubject(testProfile).eraseToAnyPublisher()

        return CardWallReadCardDomain.Store(
            initialState: state,
            reducer:
            CardWallReadCardDomain.Reducer.empty,
            environment: CardWallReadCardDomain.Environment(
                userSession: MockUserSession(),
                schedulers: Schedulers(),
                currentProfile: mockCurrentProfile,
                idTokenValidator: mockProfileValidator,
                profileDataStore: MockProfileDataStore(),
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )
    }

    private func readCardStore(for output: CardWallReadCardDomain.State.Output) -> CardWallReadCardDomain.Store {
        readCardStore(for: CardWallReadCardDomain.State(
            isDemoModus: false,
            pin: "000000",
            loginOption: .withoutBiometry,
            output: output
        ))
    }

    func testReadCardView() {
        let sut = CardWallReadCardView(store: readCardStore(for: .idle))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewInDemoMode() {
        let sut = CardWallReadCardView(
            store: readCardStore(
                for: CardWallReadCardDomain.State(
                    isDemoModus: true,
                    pin: "123456",
                    loginOption: .withoutBiometry,
                    output: .idle
                )
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewStep1() {
        let sut = CardWallReadCardView(store: readCardStore(for: .retrievingChallenge(.loading)))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewFailedStep2() {
        let sut =
            CardWallReadCardView(
                store: readCardStore(for: .signingChallenge(.error(.signChallengeError(.wrongPin(retryCount: 2)))))
            )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewStep3() {
        let sut = CardWallReadCardView(store: readCardStore(for: .verifying(.loading)))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewDone() {
        let idpToken = IDPToken(accessToken: "", expires: Date(), idToken: "")
        let sut = CardWallReadCardView(store: readCardStore(for: .loggedIn(idpToken)))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
    }
}
