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

    private func store(for state: GroupedPrescriptionListDomain.State)
        -> MainDomain.Store {
        MainDomain.Store(
            initialState: MainDomain.State(
                prescriptionListState: state
            ),
            reducer: MainDomain.Reducer.empty,
            environment: MainDomain.Dummies.environment
        )
    }

    private func store(for profile: UserProfile? = nil) -> ProfileSelectionToolbarItemDomain.Store {
        ProfileSelectionToolbarItemDomain.Store(
            initialState: .init(
                profile: profile ?? UserProfile.Fixtures.theo,
                profileSelectionState: .init(
                    profiles: [],
                    selectedProfileId: nil,
                    route: nil
                )
            ),
            reducer: .empty,
            environment: ProfileSelectionToolbarItemDomain.Dummies.environment
        )
    }

    func testMainView_Empty() {
        let sut = MainView(store: store(for: GroupedPrescriptionListDomain.State(
            groupedPrescriptions: []
        )), profileSelectionToolbarItemStore: store(for: nil))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testMainView() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2020-02-03",
            prescriptions: [GroupedPrescription.Prescription.Dummies.prescriptionReady],
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: [groupedPrescription]
        )
        let sut = MainView(
            store: store(for: state),
            profileSelectionToolbarItemStore: store(for: UserProfile.Fixtures.olafOffline)
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
            store: store(for: state),
            profileSelectionToolbarItemStore: store(for: nil)
        )
        .frame(width: 320, height: 700)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_LowDetailPrescriptions() {
        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: [GroupedPrescription.Dummies.scannedPrescriptions]
        )

        let sut = MainView(
            store: store(for: state),
            profileSelectionToolbarItemStore: store(for: nil)
        )
        .frame(width: 320, height: 1600)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_ALotOfPrescriptions() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2019-12-20",
            prescriptions: GroupedPrescription.Prescription.Fixtures.prescriptions,
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: Array(
                repeating: groupedPrescription,
                count: 6
            )
        )

        let sut = MainView(
            store: store(for: state),
            profileSelectionToolbarItemStore: store(for: nil)
        )
        .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
