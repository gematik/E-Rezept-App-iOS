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

import CombineSchedulers
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PrescriptionLowDetailSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testPrescriptionLowDetailView_Show() {
        let sut = PrescriptionLowDetailView(store: PrescriptionDetailDomain.Dummies.store)
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionLowDetailView_Show_NotRedeemed() {
        let stateRedeemed = PrescriptionDetailDomain.State(
            erxTask: ErxTask(
                identifier: "06313728",
                accessCode: "06313728",
                fullUrl: nil,
                authoredOn: nil,
                expiresOn: "24.6.2021",
                redeemedOn: nil,
                author: nil,
                medication: ErxTask.Dummies.medication1
            ), isRedeemed: false
        )
        let storeRedeemed = PrescriptionDetailDomain.Store(
            initialState: stateRedeemed,
            reducer: PrescriptionDetailDomain.reducer,
            environment: PrescriptionDetailDomain.Dummies.environment
        )
        let sutRedeemed = PrescriptionLowDetailView(store: storeRedeemed)
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .dark))
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .light))
    }

    func testPrescriptionLowDetailView_Show_Redeemed() {
        let stateRedeemed = PrescriptionDetailDomain.State(
            erxTask: ErxTask(
                identifier: "06313728",
                accessCode: "06313728",
                fullUrl: nil,
                authoredOn: nil,
                expiresOn: "24.6.2021",
                redeemedOn: "24.5.2021",
                author: nil,
                medication: ErxTask.Dummies.medication1
            ), isRedeemed: true
        )
        let storeRedeemed = PrescriptionDetailDomain.Store(
            initialState: stateRedeemed,
            reducer: PrescriptionDetailDomain.reducer,
            environment: PrescriptionDetailDomain.Dummies.environment
        )
        let sutRedeemed = PrescriptionLowDetailView(store: storeRedeemed)
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .dark))
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .light))
    }
}
