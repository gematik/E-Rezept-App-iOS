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
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyDetailInactivePharmacy() {
        let sut = PharmacyDetailView(
            store: store(
                for: .init(
                    prescriptions: Shared([]),
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: true,
                    pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive,
                    pharmacyRedeemState: Shared(nil)
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

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension PharmacyDetailViewSnapshotTests {
    enum Fixtures {
        static let allServiceOptionsState = PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyA,
            hasRedeemableTasks: true,
            pharmacyRedeemState: Shared(nil),
            reservationService: .erxTaskRepository,
            shipmentService: .erxTaskRepository,
            deliveryService: .erxTaskRepository
        )

        static let inactiveState = PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive,
            hasRedeemableTasks: false,
            pharmacyRedeemState: Shared(nil),
            reservationService: .erxTaskRepository,
            shipmentService: .erxTaskRepository,
            deliveryService: .erxTaskRepository
        )

        static let sheetNoServiceState = PharmacyDetailDomain.State(
            prescriptions: Shared([]),
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            inOrdersMessage: true,
            pharmacyViewModel: PharmacyLocationViewModel.Fixtures.pharmacyInactive,
            pharmacyRedeemState: Shared(nil),
            reservationService: .noService,
            shipmentService: .noService,
            deliveryService: .noService
        )
    }
}
