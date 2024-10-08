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

import CombineSchedulers
@testable import eRpFeatures
import SnapshotTesting
import SwiftUI
import XCTest

final class PickupCodeViewSnapshotTests: ERPSnapshotTestCase {
    func testPickupCodeViewWithHRCodeAndDMCCode() {
        let state = PickupCodeDomain.State(pickupCodeHR: "4911",
                                           pickupCodeDMC: "This is a data matrix code.",
                                           dmcImage: Asset.qrcode.image)
        let sut = PickupCodeView(store: PickupCodeDomain.Dummies.storeFor(state))
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testPickupCodeViewWithHRCodeOnly() {
        let state = PickupCodeDomain.State(pickupCodeHR: "4911")
        let sut = PickupCodeView(store: PickupCodeDomain.Dummies.storeFor(state))
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }

    func testPickupCodeViewWithDMCCodeOnly() {
        let state = PickupCodeDomain.State(pickupCodeDMC: "This is a data matrix code.",
                                           dmcImage: Asset.qrcode.image)
        let sut = PickupCodeView(store: PickupCodeDomain.Dummies.storeFor(state))
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
    }
}
