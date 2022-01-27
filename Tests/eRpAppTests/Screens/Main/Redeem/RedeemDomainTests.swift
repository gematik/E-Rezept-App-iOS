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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import IDP
import Nimble
import XCTest

final class RedeemDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        RedeemDomain.State,
        RedeemDomain.State,
        RedeemDomain.Action,
        RedeemDomain.Action,
        RedeemDomain.Environment
    >

    var workRelatedAccident: ErxTask.WorkRelatedAccident!
    var practitioner: ErxTask.Practitioner!
    var patient: ErxTask.Patient!
    var medication: ErxTask.Medication!
    var organization: ErxTask.Organization!
    var auditEvent: ErxAuditEvent!
    var erxTask: ErxTask!
    var groupedPrescription: GroupedPrescription!
    var state: RedeemDomain.State!

    override func setUpWithError() throws {
        try super.setUpWithError()

        patient = ErxTask.Patient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789"
        )
        medication = ErxTask.Medication(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: 10,
            dosageForm: "PUL",
            dose: "N1",
            dosageInstructions: nil
        )
        practitioner = ErxTask.Practitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )
        organization = ErxTask.Organization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )
        workRelatedAccident = ErxTask.WorkRelatedAccident(
            workPlaceIdentifier: "1234567890",
            date: "9.4.2021"
        )
        auditEvent = ErxAuditEvent(
            identifier: "100",
            locale: "de",
            text: "Read operation was performed.",
            timestamp: "2021-05-01T14:22:15.444555666+00:00",
            taskId: "6390f983-1e67-11b2-8555-63bf44e44fb8"
        )
        erxTask = ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.tomorrow),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            noctuFeeWaiver: true,
            substitutionAllowed: true,
            medication: medication,
            patient: patient,
            practitioner: practitioner,
            organization: organization,
            workRelatedAccident: workRelatedAccident,
            auditEvents: [auditEvent]
        )
        groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Test-Grouped-Prescription",
            authoredOn: DemoDate.createDemoDate(.today)!,
            prescriptions: [GroupedPrescription.Prescription(erxTask: erxTask)],
            displayType: GroupedPrescription.DisplayType.fullDetail
        )
        state = RedeemDomain.State(
            groupedPrescription: groupedPrescription
        )
    }

    func testStore() -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        return TestStore(
            initialState: RedeemDomain.State(
                groupedPrescription: groupedPrescription
            ),
            reducer: RedeemDomain.reducer,
            environment: RedeemDomain.Environment(
                schedulers: schedulers,
                userSession: MockUserSession(),
                fhirDateFormatter: FHIRDateFormatter.shared
            )
        )
    }

    /// Tests to open the redeem matrix code view
    func testOpenDataMatrixCodeRedeemScreen() {
        let store = testStore()

        let expectedState = RedeemMatrixCodeDomain.State(
            groupedPrescription: groupedPrescription
        )

        store.assert(
            // when
            .send(.openRedeemMatrixCodeView) { sut in
                // then
                sut.redeemMatrixCodeState = expectedState
            }
        )
    }
}
