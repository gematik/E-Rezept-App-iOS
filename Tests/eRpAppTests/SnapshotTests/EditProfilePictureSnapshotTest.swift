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
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class EditProfilePictureSnapshotTest: XCTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    func testEditProfilePictureViewEmpty() {
        let sut = EditProfilePictureView(
            store: .init(
                initialState: .init(profile: Fixtures.noImageProfile),
                reducer: EmptyReducer()
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testEditProfilePictureViewImage() {
        let sut = EditProfilePictureView(
            store: .init(
                initialState: .init(profile: Fixtures.ImageProfile),
                reducer: EmptyReducer()
            )
        )

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension EditProfilePictureSnapshotTest {
    enum Fixtures {
        static let ImageProfile = UserProfile(
            profile: Profile(
                name: "Lazy Niklas",
                color: .green,
                image: .baby
            ),
            connectionStatus: .connected,
            activityIndicating: false
        )

        static let noImageProfile = UserProfile(
            profile: Profile(
                name: "Teo Test",
                color: .blue
            ),
            connectionStatus: .connected,
            activityIndicating: false
        )
    }
}
