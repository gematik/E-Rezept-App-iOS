//
//  Copyright (c) 2021 gematik GmbH
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

@testable import eRpApp
import eRpKit
import Pharmacy
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacyRedeemViewSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testPharmacyRedeemViewTypeReservationServiceWithSelection() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: ErxTask.Dummies.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedErxTasks: Set(ErxTask.Dummies.erxTasks)
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyRedeemViewTypeMailService() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            erxTasks: ErxTask.Dummies.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyRedeemViewTypeDeliveryService() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            erxTasks: ErxTask.Dummies.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
