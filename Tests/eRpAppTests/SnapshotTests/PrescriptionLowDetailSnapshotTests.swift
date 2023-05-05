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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

// DH.TODO: remove test and snapshots after activating new DetailViews // swiftlint:disable:this todo
final class PrescriptionLowDetailSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func store(with state: PrescriptionDetailDomain.State) -> StoreOf<PrescriptionDetailDomain> {
        Store(initialState: state,
              reducer: EmptyReducer())
    }

    func testPrescriptionLowDetailView_Show() {
        let scannedTask: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            source: .scanner
        )
        let sut = PrescriptionLowDetailView(
            store: store(with: PrescriptionDetailDomain.State(
                prescription: Prescription(erxTask: scannedTask),
                isArchived: false
            ))
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionLowDetailView_Show_NotRedeemed() {
        let now = "2021-02-20T14:34:29+00:00".date!
        let erxTask = ErxTask(
            identifier: "06313728",
            status: .ready,
            accessCode: "06313728",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: "2021-02-23T14:34:29+00:00",
            redeemedOn: nil,
            author: nil,
            source: .scanner,
            medication: ErxTask.Fixtures.medication1
        )
        let stateNotArchived = PrescriptionDetailDomain.State(
            prescription: Prescription(erxTask: erxTask, date: now),
            isArchived: false
        )
        let storeRedeemed = store(with: stateNotArchived)
        let sutRedeemed = PrescriptionLowDetailView(store: storeRedeemed)
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .dark))
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .light))
    }

    func testPrescriptionLowDetailView_Show_NotRedeemed_But_Expired() {
        let now = "2021-02-23T14:34:29+00:00".date!
        let erxTask = ErxTask(
            identifier: "06313728",
            status: .ready,
            accessCode: "06313728",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: "2021-02-20T14:34:29+00:00",
            redeemedOn: nil,
            author: nil,
            source: .scanner,
            medication: ErxTask.Fixtures.medication1
        )
        let stateNotArchived = PrescriptionDetailDomain.State(
            prescription: Prescription(erxTask: erxTask, date: now),
            isArchived: false
        )
        let storeRedeemed = store(with: stateNotArchived)
        let sutRedeemed = PrescriptionLowDetailView(store: storeRedeemed)
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .dark))
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .light))
    }

    func testPrescriptionLowDetailView_Show_Redeemed() {
        let now = "2021-02-23T14:34:29+00:00".date!
        let erxTask = ErxTask(
            identifier: "06313728",
            status: .completed,
            accessCode: "06313728",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: "24.6.2021",
            redeemedOn: "2021-02-20T14:34:29+00:00",
            author: nil,
            source: .scanner,
            medication: ErxTask.Fixtures.medication1
        )
        let stateRedeemed = PrescriptionDetailDomain.State(
            prescription: Prescription(erxTask: erxTask, date: now),
            isArchived: true
        )
        let storeRedeemed = store(with: stateRedeemed)
        let sutRedeemed = PrescriptionLowDetailView(store: storeRedeemed)
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .dark))
        assertSnapshots(matching: sutRedeemed, as: snapshotModiOnDevicesWithTheming(mode: .light))
    }
}
