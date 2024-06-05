//
//  Copyright (c) 2024 gematik GmbH
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
@testable import eRpFeatures
import eRpKit
import Pharmacy
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyPrescriptionSelectionViewSnapshotTests: ERPSnapshotTestCase {
    override class func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testPharmacyPrescriptionAllSelected() {
        let initialState = PharmacyPrescriptionSelectionDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            selectedErxTasks: Set(ErxTask.Fixtures.erxTasks),
            profile: UserProfile.Fixtures.theo.profile
        )
        let sut = NavigationView {
            PharmacyPrescriptionSelectionView(store: StoreOf<PharmacyPrescriptionSelectionDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyPrescriptionNoneSelected() {
        let initialState = PharmacyPrescriptionSelectionDomain.State(
            erxTasks: ErxTask.Fixtures.erxTasks,
            profile: UserProfile.Fixtures.theo.profile
        )
        let sut = NavigationView {
            PharmacyPrescriptionSelectionView(store: StoreOf<PharmacyPrescriptionSelectionDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
