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

@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class PrescriptionViewStatusTests: XCTestCase {
    func task(status: ErxTask.Status = .ready,
              expiresOn: String? = DemoDate.createDemoDate(.tomorrow),
              acceptedUntil: String? = DemoDate.createDemoDate(.twentyEightDaysAhead),
              redeemedOn: String? = nil) -> ErxTask {
        ErxTask(identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                status: status,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: DemoDate.createDemoDate(.today),
                expiresOn: expiresOn,
                acceptedUntil: acceptedUntil,
                redeemedOn: redeemedOn,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                noctuFeeWaiver: true,
                substitutionAllowed: true,
                medication: medication,
                auditEvents: ErxAuditEvent.Dummies.auditEvents)
    }

    let medication: ErxTask.Medication = {
        ErxTask.Medication(
            name: "Yucca filamentosa",
            pzn: "06876511",
            amount: 12,
            dosageForm: "FDA",
            dose: "N2",
            dosageInstructions: nil
        )
    }()

    func testTaskIsReady() { // CREATE, ACTIVATE
        // given
        let task = task()
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Still valid for 28 days")))
    }

    func testTaskIsInProgress() { // ACCEPT
        // given
        let task = task(status: .inProgress)
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Still valid for 28 days")))
    }

    func testTaskIsClosed() { // CLOSE
        // given
        let task = task(status: .completed, redeemedOn: DemoDate.createDemoDate(.today))
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Redeemed: Today")))
    }

    func testTaskIsReadyAndNotAcceptedAnymore() {
        // given
        let task = task(acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute als Selbstzahler einlösbar")))
    }

    func testTaskIsReadyWithoutExpireAndAcceptedDate() {
        // given
        let task = task(expiresOn: nil,
                        acceptedUntil: nil)
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Not specified")))
    }

    func testTaskIsReadyExpiredAndRedeemYourselfExpired() {
        // given
        let task = task(expiresOn: DemoDate.createDemoDate(.yesterday),
                        acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "No longer valid")))
    }

    func testTaskIsClosedWithoutRedeemedDate() {
        // given
        let task = task(status: .completed)
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Redeemed: Not specified")))
    }

    func testTaskIsUndefined() {
        // given
        let task = task(status: .draft)
        // when
        let sut = GroupedPrescription.Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.undefined))
    }
}
