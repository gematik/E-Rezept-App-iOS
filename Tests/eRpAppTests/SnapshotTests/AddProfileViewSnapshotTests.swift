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

import CombineSchedulers
@testable import eRpApp
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class AddProfileViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testAddProfileViewEmpty() {
        let sut = AddProfileView(
            store: .init(
                initialState: .init(profileName: ""),
                reducer: .empty,
                environment: AddProfileDomain.Environment(
                    userProfileService: MockUserProfileService(),
                    schedulers: Schedulers()
                )
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testAddProfileViewFilled() {
        let sut = AddProfileView(
            store: .init(
                initialState: .init(profileName: "Spooky Dennis"),
                reducer: .empty,
                environment: AddProfileDomain.Environment(
                    userProfileService: MockUserProfileService(),
                    schedulers: Schedulers()
                )
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
