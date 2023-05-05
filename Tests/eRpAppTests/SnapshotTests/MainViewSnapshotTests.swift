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
                         reducer: EmptyReducer())
    }

    private func store(for state: PrescriptionListDomain.State)
        -> MainDomain.Store {
        MainDomain.Store(
            initialState: MainDomain.State(
                prescriptionListState: state, horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State()
            ),
            reducer: EmptyReducer()
        )
    }

    private func store(for _: UserProfile? = nil) -> HorizontalProfileSelectionDomain.Store {
        HorizontalProfileSelectionDomain.Store(
            initialState: .init(
                profiles: [],
                selectedProfileId: nil
            ),
            reducer: EmptyReducer()
        )
    }

    func testMainView_Empty() {
        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: []
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State(
                profiles: [],
                selectedProfileId: nil
            )
        )))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testMainView_Empty_ProfileConnected() {
        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: [],
                profile: UserProfile.Dummies.profileA
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State(
                profiles: [UserProfile.Dummies.profileA],
                selectedProfileId: UserProfile.Dummies.profileA.id
            )
        )))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testMainView() {
        let prescription = Prescription.Dummies.prescriptionReady

        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: [prescription],
                profile: UserProfile.Dummies.profileA
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )))
            .frame(width: 320, height: 700)
        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_LowDetailPrescriptions() {
        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: Prescription.Dummies.prescriptionsScanned,
                profile: UserProfile.Dummies.profileA
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )))

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_ALotOfPrescriptions() {
        let prescriptions = Prescription.Fixtures.prescriptions

        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: prescriptions,
                profile: UserProfile.Dummies.profileA
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )))
            .frame(width: 320, height: 2000)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testMainView_WelcomeDrawer() {
        let sut =
            WelcomeDrawerView(store: store(for: MainDomain.State(
                prescriptionListState: .init(),
                horizontalProfileSelectionState: .init()
            )))

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
