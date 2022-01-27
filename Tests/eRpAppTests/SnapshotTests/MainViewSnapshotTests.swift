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

    private func store(for state: GroupedPrescriptionListDomain.State, profile: UserProfile? = nil)
        -> MainDomain.Store {
        MainDomain.Store(
            initialState: MainDomain.State(
                prescriptionListState: state,
                profile: profile ?? testProfileTheoTestprofil
            ),
            reducer: MainDomain.Reducer.empty,
            environment: MainDomain.Dummies.environment
        )
    }

    let testProfileTheoTestprofil = UserProfile(
        profile: Profile(
            name: "Theo Testprofil",
            identifier: UUID(),
            created: Date(),
            insuranceId: nil,
            color: .green,
            emoji: "🌮",
            lastAuthenticated: nil,
            erxTasks: [],
            erxAuditEvents: []
        ),
        connectionStatus: .connected
    )

    let testProfileOlafOffline = UserProfile(
        profile: Profile(
            name: "Olaf Offline",
            identifier: UUID(),
            created: Date(),
            insuranceId: nil,
            color: .red,
            emoji: nil,
            lastAuthenticated: nil,
            erxTasks: [],
            erxAuditEvents: []
        ),
        connectionStatus: .disconnected
    )

    func testMainView_Empty() {
        let sut = MainView(store: store(for: GroupedPrescriptionListDomain.State(
            groupedPrescriptions: []
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
            prescriptions: [GroupedPrescription.Prescription(erxTask: ErxTask.Dummies.erxTaskReady)],
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: [groupedPrescription]
        )
        let sut = MainView(
            store: store(for: state, profile: testProfileOlafOffline)
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
            store: store(for: state)
        )
        .frame(width: 320, height: 700)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_ALotOfPrescriptions() {
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Hausarztpraxis Dr. Topp-Glücklich",
            authoredOn: "2019-12-20",
            prescriptions: ErxTask.Dummies.erxTasks.map { GroupedPrescription.Prescription(erxTask: $0) },
            displayType: .fullDetail
        )

        let state = GroupedPrescriptionListDomain.State(
            groupedPrescriptions: Array(
                repeating: groupedPrescription,
                count: 6
            )
        )

        let sut = MainView(
            store: store(for: state)
        )
        .frame(width: 320, height: 1400)

        assertSnapshots(matching: sut, as: snapshotModi())
    }
}
