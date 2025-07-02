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
import eRpKit
import Pharmacy
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyPrescriptionSelectionViewSnapshotTests: ERPSnapshotTestCase {
    func testPharmacyPrescriptionAllSelected() {
        let initialState = PharmacyPrescriptionSelectionDomain.State(
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            profile: UserProfile.Fixtures.theo.profile
        )
        let sut = NavigationStack {
            PharmacyPrescriptionSelectionView(store: StoreOf<PharmacyPrescriptionSelectionDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyPrescriptionNoneSelected() {
        let initialState = PharmacyPrescriptionSelectionDomain.State(
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: []),
            profile: UserProfile.Fixtures.theo.profile
        )
        let sut = NavigationStack {
            PharmacyPrescriptionSelectionView(store: StoreOf<PharmacyPrescriptionSelectionDomain>(
                initialState: initialState

            ) {
                EmptyReducer()
            })
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
