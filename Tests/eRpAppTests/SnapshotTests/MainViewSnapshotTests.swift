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

import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class MainViewSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        diffTool = "open"
    }

    private func store(for state: MainDomain.State) -> MainDomain.Store {
        MainDomain.Store(initialState: state,
                         reducer: MainDomain.Reducer.empty,
                         environment: MainDomain.Dummies.environment)
    }

    func testMainView_Empty() {
        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: GroupedPrescriptionListDomain.State(
                groupedPrescriptions: []
            ),
            debug: DebugDomain.State(trackingOptOut: true)
        )))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testMainView() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2020-02-03",
            prescriptions: [ErxTask.Dummies.prescription],
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: [groupedPrescription]
        )
        let sut = MainView(
            store: store(for: MainDomain.State(prescriptionListState: state,
                                               debug: DebugDomain.State(trackingOptOut: true)))
        )
        .frame(width: 320, height: 700)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_NoPrescriptions() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2020-02-03",
            prescriptions: [],
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: [groupedPrescription]
        )
        let sut = MainView(
            store: store(for: MainDomain.State(prescriptionListState: state,
                                               debug: DebugDomain.State(trackingOptOut: true)))
        )
        .frame(width: 320, height: 700)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_ALotOfPrescriptions() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2019-12-20",
            prescriptions: ErxTask.Dummies.prescriptions,
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: Array(
                repeating: groupedPrescription,
                count: 6
            )
        )

        let sut = MainView(
            store: store(for: MainDomain.State(prescriptionListState: state,
                                               debug: DebugDomain.State(trackingOptOut: true)))
        )
        .frame(width: 320, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
