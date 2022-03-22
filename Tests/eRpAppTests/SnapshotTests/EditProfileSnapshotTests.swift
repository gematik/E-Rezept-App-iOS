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

import CombineSchedulers
@testable import eRpApp
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class EditProfileSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testEditProfileFigmaVariant1() {
        let sut = NavigationView {
            EditProfileView(
                store: .init(
                    initialState: .init(
                        name: "Spooky Dennis",
                        acronym: "",
                        fullName: nil,
                        insurance: nil,
                        insuranceId: nil,
                        emoji: "🌸",
                        color: .blue,
                        profileId: UUID()
                    ),
                    reducer: .empty,
                    environment: EditProfileDomain.Environment(
                        schedulers: Schedulers(),
                        profileDataStore: MockProfileDataStore(),
                        userDataStore: MockUserDataStore(),
                        profileSecureDataWiper: MockProfileSecureDataWiper(),
                        router: MockRouting()
                    )
                )
            )
        }
        .frame(width: 375, height: 1807, alignment: .center)

        assertSnapshots(matching: sut, as: figmaReference())
    }

    func testEditProfileFigmaVariant2() {
        let sut = NavigationView {
            EditProfileView(
                store: .init(
                    initialState: .init(
                        name: "Spooky Dennis",
                        acronym: "",
                        fullName: "Holger Muster",
                        insurance: "AOK",
                        insuranceId: "XY1234567890",
                        emoji: "🎃",
                        color: .blue,
                        profileId: UUID(),
                        token: IDPToken(accessToken: "", expires: Date(), idToken: "")
                    ),
                    reducer: .empty,
                    environment: EditProfileDomain.Environment(
                        schedulers: Schedulers(),
                        profileDataStore: MockProfileDataStore(),
                        userDataStore: MockUserDataStore(),
                        profileSecureDataWiper: MockProfileSecureDataWiper(),
                        router: MockRouting()
                    )
                )
            )
        }
        .frame(width: 375, height: 1807, alignment: .center)

        assertSnapshots(matching: sut, as: figmaReference())
    }

    func testEditProfileFigmaVariant3() {
        let sut = NavigationView {
            EditProfileView(
                store: .init(
                    initialState: .init(
                        name: "",
                        acronym: "",
                        fullName: "Holger Muster",
                        insurance: "AOK",
                        insuranceId: "XY1234567890",
                        emoji: "🎃",
                        color: .blue,
                        profileId: UUID(),
                        token: IDPToken(accessToken: "", expires: Date(), idToken: "")
                    ),
                    reducer: .empty,
                    environment: EditProfileDomain.Environment(
                        schedulers: Schedulers(),
                        profileDataStore: MockProfileDataStore(),
                        userDataStore: MockUserDataStore(),
                        profileSecureDataWiper: MockProfileSecureDataWiper(),
                        router: MockRouting()
                    )
                )
            )
        }
        .frame(width: 375, height: 1807, alignment: .center)

        assertSnapshots(matching: sut, as: figmaReference())
    }

    func testEditProfileFilledWithEmojiSnapshot() {
        let sut = EditProfileView(
            store: .init(
                initialState: .init(
                    name: "",
                    acronym: "",
                    fullName: nil,
                    insurance: nil,
                    insuranceId: nil,
                    emoji: "👵🏻",
                    color: .green,
                    profileId: UUID()
                ),
                reducer: .empty,
                environment: EditProfileDomain.Environment(
                    schedulers: Schedulers(),
                    profileDataStore: MockProfileDataStore(),
                    userDataStore: MockUserDataStore(),
                    profileSecureDataWiper: MockProfileSecureDataWiper(),
                    router: MockRouting()
                )
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testEditProfileFilledWithAcronymSnapshot() {
        let sut = EditProfileView(
            store: .init(
                initialState: .init(
                    name: "Anna Vetter",
                    acronym: "AV",
                    fullName: nil,
                    insurance: nil,
                    insuranceId: nil,
                    color: .green,
                    profileId: UUID()
                ),
                reducer: .empty,
                environment: NewProfileDomain.Environment(
                    schedulers: Schedulers(),
                    userDataStore: MockUserDataStore(),
                    profileDataStore: MockProfileDataStore()
                )
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testEditProfileFilledWithConnectedProfileSnapshot() {
        let sut = EditProfileView(
            store: .init(
                initialState: .init(
                    name: "Anna V",
                    acronym: "AV",
                    fullName: "Anne Vetter",
                    insurance: "Gematik BKK",
                    insuranceId: "X987654321",
                    emoji: "👵🏻",
                    color: .green,
                    profileId: UUID()
                ),
                reducer: .empty,
                environment: NewProfileDomain.Environment(
                    schedulers: Schedulers(),
                    userDataStore: MockUserDataStore(),
                    profileDataStore: MockProfileDataStore()
                )
            )
        )
        .frame(width: 375, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
