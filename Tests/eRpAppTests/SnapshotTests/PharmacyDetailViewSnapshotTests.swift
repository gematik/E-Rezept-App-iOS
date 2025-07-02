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
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyDetailViewSnapshotTests: ERPSnapshotTestCase {
    func store(for state: PharmacyDetailDomain.State) -> StoreOf<PharmacyDetailDomain> {
        .init(initialState: state) {
            EmptyReducer()
        }
    }

    override func invokeTest() {
        withDependencies { dependencies in
            dependencies.date = .constant(PharmacyLocationViewModel.Fixtures.referenceDateMonday1645)
        } operation: {
            super.invokeTest()
        }
    }

    func testPharmacyDetailWithAllServiceButtons() {
        let sut = PharmacyDetailView(store: store(for: PharmacyDetailViewSnapshotTests.Fixtures.allServiceOptionsState))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibilityXL())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyDetailInactivePharmacy() {
        let sut = PharmacyDetailView(
            store: store(
                for: .init(
                    prescriptions: Shared(value: []),
                    selectedPrescriptions: Shared(value: []),
                    inRedeemProcess: true,
                    pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive
                )
            )
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyDetailSheetWithContactButtons() {
        let sut = PharmacyDetailView(
            store: store(for: PharmacyDetailViewSnapshotTests.Fixtures.sheetNoServiceState)
        )

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibilityXL())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension PharmacyDetailViewSnapshotTests {
    enum Fixtures {
        static let allServiceOptionsState = PharmacyDetailDomain.State(
            prescriptions: Shared(value: Prescription.Fixtures.prescriptions),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA,
            hasRedeemableTasks: true,
            availableServiceOptions: [.delivery, .onPremise, .shipment]
        )

        static let inactiveState = PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive,
            hasRedeemableTasks: false,
            availableServiceOptions: [.delivery, .onPremise, .shipment]
        )

        static let sheetNoServiceState = PharmacyDetailDomain.State(
            prescriptions: Shared(value: []),
            selectedPrescriptions: Shared(value: []),
            inRedeemProcess: false,
            inOrdersMessage: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive
        )
    }
}
