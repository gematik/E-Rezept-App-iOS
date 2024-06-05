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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PrescriptionDetailViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func store(
        with erxTask: ErxTask,
        profile: UserProfile = UserProfile.Dummies.profileA,
        chargeItem: ErxSparseChargeItem? = nil,
        chargeItemConstentState: PrescriptionDetailDomain.ChargeItemConsentState = .notAuthenticated,
        isArchived: Bool = false
    ) -> StoreOf<PrescriptionDetailDomain> {
        Store(
            initialState: .init(
                prescription: Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue),
                profile: profile,
                chargeItemConsentState: chargeItemConstentState,
                chargeItem: chargeItem,
                isArchived: isArchived
            )

        ) {
            EmptyReducer()
        }
    }

    func testPrescriptionDetail_Ready() {
        let store = store(with: ErxTask.Fixtures.erxTaskReady)
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_WithSubstitutionAllowedPrescription() {
        let store = store(with: ErxTask.Fixtures.erxTaskSubstitutionAllowed)
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_WithDirectAssignmentPrescription() {
        let store = store(with: ErxTask.Fixtures.erxTaskDirectAssigned)
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_WithErrorPrescription() {
        let store = store(with: ErxTask.Fixtures.erxTaskError)
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_WithScannedPrescription() {
        let store = store(with: ErxTask.Fixtures.scannedTask)
        let sut = PrescriptionDetailView(store: store)

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_PkvWithoutChargeItem() {
        let store = store(
            with: ErxTask.Fixtures.erxTaskRedeemedFixDate,
            profile: UserProfile.Fixtures.privatePaul,
            chargeItemConstentState: .granted,
            isArchived: true
        )
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_PkvWithoutConsent() {
        let store = store(
            with: ErxTask.Fixtures.erxTaskRedeemedFixDate,
            profile: UserProfile.Fixtures.privatePaul,
            chargeItemConstentState: .notGranted,
            isArchived: true
        )
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_PkvWithChargeItem() {
        let store = store(
            with: ErxTask.Fixtures.erxTaskRedeemed,
            profile: UserProfile.Fixtures.privatePaul,
            chargeItem: ErxChargeItem.Dummies.dummy.sparseChargeItem,
            chargeItemConstentState: .granted,
            isArchived: true
        )
        let sut = PrescriptionDetailView(store: store)
            .frame(width: 320, height: 1100)

        assertSnapshots(matching: sut, as: snapshotModi())
    }

    func testPrescriptionDetail_TechnicalInformations() {
        let sut = NavigationView {
            PrescriptionDetailView.TechnicalInformationsView(
                store: Store(initialState: .init(
                    taskId: "34235f983-1e67-321g-8955-63bf44e44fb8",
                    accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24"
                )) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_PatientView() {
        let sut = NavigationView {
            PrescriptionDetailView.PatientView(
                store: Store(initialState: .init(patient: ErxTask.Fixtures.demoPatient)) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_PractitionerView() {
        let sut = NavigationView {
            PrescriptionDetailView.PractitionerView(
                store: Store(initialState: .init(practitioner: ErxTask.Fixtures.demoPractitioner)) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_OrganizationView() {
        let sut = NavigationView {
            PrescriptionDetailView.OrganizationView(
                store: Store(initialState: .init(organization: ErxTask.Fixtures.demoOrganization)) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_AccidentInfoView() {
        let sut = NavigationView {
            PrescriptionDetailView.AccidentInfoView(
                store: Store(initialState: .init(accidentInfo: ErxTask.Fixtures.demoAccidentInfo)) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_ValidityView() {
        let acceptBegin = "25.03.2024"
        let acceptEnd = "25.03.2024"
        let expiresBegin = "26.03.2024"
        let expiresEnd = "24.06.2024"

        let sut = NavigationView {
            PrescriptionDetailView.HeaderView.PrescriptionValidityView(
                store: Store(initialState: .init(
                    acceptBeginDisplayDate: acceptBegin,
                    acceptEndDisplayDate: acceptEnd,
                    expiresBeginDisplayDate: expiresBegin,
                    expiresEndDisplayDate: expiresEnd,
                    isMVO: false
                )) {
                    EmptyReducer()
                }
            )
        }
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPrescriptionDetail_MVO() {
        let prescription = Prescription.Dummies.prescriptionMVO
        let oneDay: TimeInterval = 60 * 60 * 24
        let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)

        let sut = NavigationView {
            PrescriptionDetailView.HeaderView.PrescriptionValidityView(
                store: Store(initialState: .init(
                    acceptBeginDisplayDate: uiDateFormatter
                        .date(prescription.medicationRequest.multiplePrescription?.startPeriod),
                    acceptEndDisplayDate: uiDateFormatter.date(
                        prescription.medicationRequest.multiplePrescription?.endPeriod,
                        advancedBy: -oneDay
                    ),
                    expiresBeginDisplayDate: nil,
                    expiresEndDisplayDate: nil,
                    isMVO: true
                )) {
                    EmptyReducer()
                }
            )
        }
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
