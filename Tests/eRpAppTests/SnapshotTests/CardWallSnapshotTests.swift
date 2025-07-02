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

import Combine
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class CardWallSnapshotTests: ERPSnapshotTestCase {
    func testSelectionView() {
        let sut = CardWallIntroductionView(
            store: StoreOf<CardWallIntroductionDomain>(
                initialState: .init(
                    isNFCReady: true,
                    profileId: UUID()
                )
            ) {
                EmptyReducer()
            }
        )

        // This snapshots are subject to feature flags.
        // If these test fail, delete the app within your simulator and restart the test.
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testExtAuthFallbackView() {
        let sut = CardWallExtAuthFallbackView(closeAction: {})

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testIntroductionView() {
        let sut = CardWallIntroductionView(
            store: StoreOf<CardWallIntroductionDomain>(
                initialState: .init(
                    isNFCReady: true,
                    profileId: UUID()
                )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testIntroductionViewWithCapabilties() {
        let sut = CardWallIntroductionView(
            store: StoreOf<CardWallIntroductionDomain>(
                initialState: CardWallIntroductionDomain
                    .State(
                        isNFCReady: false,
                        profileId: UUID()
                    )
            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputView() {
        let sut = CardWallCANView(
            store: StoreOf<CardWallCANDomain>(
                initialState: CardWallCANDomain.State(
                    isDemoModus: false,
                    profileId: UUID(),
                    can: ""
                )
            ) {
                CardWallCANDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputViewInDemoMode() {
        let sut = CardWallCANView(
            store: StoreOf<CardWallCANDomain>(
                initialState: CardWallCANDomain.State(
                    isDemoModus: true,
                    profileId: UUID(),
                    can: ""
                )
            ) {
                CardWallCANDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testCANInputWrongCANEnteredView() {
        let sut = CardWallCANView(
            store: StoreOf<CardWallCANDomain>(
                initialState: CardWallCANDomain.State(isDemoModus: false,
                                                      profileId: UUID(),
                                                      can: "",
                                                      wrongCANEntered: true)
            ) {
                CardWallCANDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputView() {
        let sut = CardWallPINView(
            store: StoreOf<CardWallPINDomain>(
                initialState: CardWallPINDomain.State(
                    isDemoModus: false,
                    profileId: UUID(),
                    pin: "",
                    transition: .fullScreenCover
                )
            ) {
                CardWallPINDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputViewInDemoMode() {
        let sut = CardWallPINView(
            store: StoreOf<CardWallPINDomain>(
                initialState: CardWallPINDomain.State(
                    isDemoModus: true,
                    profileId: UUID(),
                    pin: "123",
                    transition: .fullScreenCover
                )
            ) {
                CardWallPINDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPINInputWrongPINEnteredView() {
        var state = CardWallPINDomain.State(isDemoModus: false,
                                            profileId: UUID(),
                                            pin: "",
                                            transition: .fullScreenCover)
        state.wrongPinEntered = true
        let sut = CardWallPINView(
            store: StoreOf<CardWallPINDomain>(
                initialState: state
            ) {
                CardWallPINDomain()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoginOptionView() {
        let sut = CardWallLoginOptionView(
            store: StoreOf<CardWallLoginOptionDomain>(
                initialState: CardWallLoginOptionDomain.State(isDemoModus: false,
                                                              profileId: UUID(),
                                                              selectedLoginOption: .withoutBiometry)

            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testLoginOptionViewInDemoMode() {
        let sut = CardWallLoginOptionView(
            store: StoreOf<CardWallLoginOptionDomain>(
                initialState: CardWallLoginOptionDomain.State(isDemoModus: true,
                                                              profileId: UUID(),
                                                              selectedLoginOption: .withoutBiometry)

            ) {
                EmptyReducer()
            }
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    lazy var testProfile = { Profile(name: "testProfile") }()
    var mockProfileValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var mockCurrentProfile: AnyPublisher<Profile, LocalStoreError>!
    private func readCardStore(for state: CardWallReadCardDomain.State) -> StoreOf<CardWallReadCardDomain> {
        mockProfileValidator = CurrentValueSubject(
            ProfileValidator(currentProfile: testProfile, otherProfiles: [testProfile])
        ).eraseToAnyPublisher()
        mockCurrentProfile = CurrentValueSubject(testProfile).eraseToAnyPublisher()

        return Store(
            initialState: state

        ) {
            EmptyReducer()
        }
    }

    private func readCardStore(for output: CardWallReadCardDomain.State.Output) -> StoreOf<CardWallReadCardDomain> {
        readCardStore(for: CardWallReadCardDomain.State(
            isDemoModus: false,
            profileId: UUID(),
            pin: "000000",
            loginOption: .withoutBiometry,
            output: output
        ))
    }

    func testReadCardView() {
        let sut = CardWallReadCardView(store: readCardStore(for: .idle))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewInDemoMode() {
        let sut = CardWallReadCardView(
            store: readCardStore(
                for: CardWallReadCardDomain.State(
                    isDemoModus: true,
                    profileId: UUID(),
                    pin: "123456",
                    loginOption: .withoutBiometry,
                    output: .idle
                )
            )
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewFailedSigningChallenge() {
        let sut =
            CardWallReadCardView(
                store: readCardStore(
                    for: .signingChallenge(
                        .error(.signChallengeError(.verifyCardError(.wrongSecretWarning(retryCount: 2))))
                    )
                )
            )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewVerifying() {
        let sut = CardWallReadCardView(store: readCardStore(for: .verifying(.loading)))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardViewDone() {
        let idpToken = IDPToken(accessToken: "", expires: Date(), idToken: "", redirect: "redirect")
        let sut = CardWallReadCardView(store: readCardStore(for: .loggedIn(idpToken)))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardHelpCardView() {
        let sut =
            ReadCardHelpView(store: .init(initialState: .init(destination: .first)) {
                EmptyReducer()
            })

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardHelpPositionView() {
        let sut = ReadCardHelpView(store: .init(initialState: .init(destination: .second)) {
            EmptyReducer()
        })

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardHelpListView() {
        let sut =
            ReadCardHelpView(store: .init(initialState: .init(destination: .fourth)) {
                EmptyReducer()
            })

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testReadCardHelpVideoView() {
        let sut = ReadCardHelpView(store: .init(initialState: .init(destination: .third)) {
            EmptyReducer()
        })

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }
}
