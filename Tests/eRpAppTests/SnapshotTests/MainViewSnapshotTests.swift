//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class MainViewSnapshotTests: ERPSnapshotTestCase {
    override func invokeTest() {
        withDependencies { dependencies in
            dependencies.date.now = TestDate.defaultReferenceDate
        } operation: {
            super.invokeTest()
        }
    }

    private func store(for state: MainDomain.State) -> StoreOf<MainDomain> {
        StoreOf<MainDomain>(initialState: state) {
            EmptyReducer()
        }
    }

    private func store(for state: PrescriptionListDomain.State)
        -> StoreOf<MainDomain> {
        StoreOf<MainDomain>(
            initialState: MainDomain.State(
                prescriptionListState: state,
                horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State(
                )
            )

        ) {
            EmptyReducer()
        }
    }

    private func store(for _: UserProfile? = nil) -> StoreOf<HorizontalProfileSelectionDomain> {
        .init(
            initialState: .init(
                profiles: [UserProfile](),
                selectedProfileId: nil
            )

        ) {
            EmptyReducer()
        }
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
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
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
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
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
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testMainView_ProfileDisconnected() {
        let prescription = Prescription.Dummies.prescriptionReady

        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: [prescription],
                profile: UserProfile.Dummies.profileC
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )))
            .frame(width: 320, height: 700)
        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testMainView_LowDetailPrescriptions() {
        let sut = MainView(store: store(for: MainDomain.State(
            prescriptionListState: PrescriptionListDomain.State(
                prescriptions: Prescription.Dummies.prescriptionsScanned,
                profile: UserProfile.Dummies.profileA
            ),
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
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

        assertSnapshots(of: sut, as: snapshotModi())
    }

    func testMainView_WelcomeDrawer() {
        let sut =
            WelcomeDrawerView(store: store(for: MainDomain.State(
                prescriptionListState: .init(),
                horizontalProfileSelectionState: .init()
            )))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testMainView_GrantChargeItemConsentDrawer() {
        let sut =
            GrantChargeItemConsentDrawerView(store: store(for: MainDomain.State(
                prescriptionListState: .init(),
                horizontalProfileSelectionState: .init()
            )))

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
