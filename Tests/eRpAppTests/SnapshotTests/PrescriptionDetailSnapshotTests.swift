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

final class PrescriptionDetailSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func store(with state: PrescriptionDetailDomain.State) -> StoreOf<PrescriptionDetailDomain> {
        Store(initialState: state,
              reducer: EmptyReducer())
    }

    func testPrescriptionDetail_WithSubstitutionAllowedPrescription() {
        let store = store(with: PrescriptionDetailDomain.Dummies.state)
        let sut = PrescriptionDetailView(store: store)

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_WithDirectAssignmentPrescription() {
        let store = store(with: .init(prescription: .Dummies.prescriptionDirectAssignment, isArchived: false))
        let sut = PrescriptionDetailView(store: store)

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_WithErrorPrescription() {
        let store = store(with: .init(prescription: .Dummies.prescriptionError, isArchived: false))
        let sut = PrescriptionDetailView(store: store)

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_WithScannedPrescription() {
        let store = store(with: .init(prescription: .Dummies.scanned, isArchived: false))
        let sut = PrescriptionDetailView(store: store)

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_TechnicalInformations() {
        let sut = NavigationView {
            PrescriptionDetailView.TechnicalInformationsView(
                store: Store(initialState: .init(
                    taskId: "34235f983-1e67-321g-8955-63bf44e44fb8",
                    accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
                ),
                reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_PatientView() {
        let sut = NavigationView {
            PrescriptionDetailView.PatientView(
                store: Store(initialState: .init(patient: ErxTask.Fixtures.demoPatient),
                             reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_PractitionerView() {
        let sut = NavigationView {
            PrescriptionDetailView.PractitionerView(
                store: Store(initialState: .init(practitioner: ErxTask.Fixtures.demoPractitioner),
                             reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_OrganizationView() {
        let sut = NavigationView {
            PrescriptionDetailView.OrganizationView(
                store: Store(initialState: .init(organization: ErxTask.Fixtures.demoOrganization),
                             reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_AccidentInfoView() {
        let sut = NavigationView {
            PrescriptionDetailView.AccidentInfoView(
                store: Store(initialState: .init(accidentInfo: ErxTask.Fixtures.demoAccidentInfo),
                             reducer: EmptyReducer())
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
