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

    func testPharmacyRedeemViewMissingAddress() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedErxTasks: Set(ErxTask.Fixtures.erxTasks),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyRedeemViewFullAddress() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedErxTasks: Set([ErxTask.Fixtures.erxTask1]),
            selectedShipmentInfo: ShipmentInfo(
                name: "Anna Maria Vetter",
                street: "Benzelrather Str. 29",
                addressDetail: "Postfach 11122",
                zip: "50226",
                city: "Frechen",
                phone: "+491771234567",
                mail: "anna.vetter@gematik.de",
                deliveryInfo: "Please do not hesitate to ring the bell twice"
            ),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacyRedeemViewTypeShipmentMissingPhone() {
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .shipment,
            erxTasks: ErxTask.Fixtures.erxTasks,
            pharmacy: PharmacyLocation.Dummies.pharmacy,
            selectedErxTasks: Set([ErxTask.Fixtures.erxTask1]),
            selectedShipmentInfo: ShipmentInfo(
                name: "Anna Vetter",
                street: "Benzelrather Str. 29",
                zip: "50226",
                city: "Frechen",
                mail: "anna.vetter@gematik.de"
            ),
            profile: Profile(name: "Anna Vetter", color: Profile.Color.red)
        )
        let sut = NavigationView {
            PharmacyRedeemView(store: PharmacyRedeemDomain.Dummies.storeFor(initialState))
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
