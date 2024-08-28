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

@testable import eRpFeatures
import SnapshotTesting
import SwiftUI
import XCTest

final class RedeemSuccessViewSnapshotTests: ERPSnapshotTestCase {
    func testRedeemSuccessViewSnapshotWithOnPremise() {
        let sut = NavigationView {
            RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .onPremise))
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testRedeemSuccessViewSnapshotWithShipment() {
        let sut = NavigationView {
            RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .shipment))
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testRedeemSuccessViewSnapshotWithDelivery() {
        let sut = NavigationView {
            RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .delivery))
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
