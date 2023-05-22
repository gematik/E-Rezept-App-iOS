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

@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class PrescriptionViewStatusTests: XCTestCase {
    func task(status: ErxTask.Status = .ready,
              expiresOn: String? = DemoDate.createDemoDate(.tomorrow),
              acceptedUntil: String? = DemoDate.createDemoDate(.twentyEightDaysAhead),
              multiplePrescription: MultiplePrescription? = nil) -> ErxTask {
        ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: status,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: expiresOn,
            acceptedUntil: acceptedUntil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication,
            medicationRequest: .init(
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                multiplePrescription: multiplePrescription
            ),
            medicationDispenses: status == .completed ? [medicationDispense] : []
        )
    }

    let medication: ErxMedication = {
        ErxMedication(
            name: "Yucca filamentosa",
            pzn: "06876511",
            amount: .init(numerator: .init(value: "12")),
            dosageForm: "FDA",
            normSizeCode: "N2"
        )
    }()

    let medicationDispense: ErxMedicationDispense = .init(
        identifier: "some-unique-id",
        taskId: "2390f983-1e67-11b2-8555-63bf44e44fb8",
        insuranceId: "A123456789",
        dosageInstruction: nil,
        telematikId: "11b2-8555",
        whenHandedOver: DemoDate.createDemoDate(.today) ?? "",
        medication: .init(
            name: "Vita-Tee",
            pzn: "06876519",
            amount: .init(numerator: .init(value: "4")),
            dosageForm: "INS",
            normSizeCode: "NB",
            batch: .init(
                lotNumber: "Charge number 1001",
                expiresOn: "2323-01-26T15:23:21+00:00"
            )
        )
    )

    func testTaskIsReady() { // CREATE, ACTIVATE
        // given
        let task = task()
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 28 Tage gültig")))
    }

    func testTaskIsInProgress() { // ACCEPT
        // given
        let task = task(status: .inProgress)
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 28 Tage gültig")))
    }

    func testTaskIsClosed() { // CLOSE
        // given
        let task = task(status: .completed)
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Eingelöst: Heute")))
    }

    func testTaskIsReadyAndNotAcceptedAnymore() {
        // given
        let task = task(acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute als Selbstzahler einlösbar")))
    }

    func testTaskIsReadyWithoutExpireAndAcceptedDate() {
        // given
        let task = task(expiresOn: nil,
                        acceptedUntil: nil)
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Keine Angabe")))
    }

    func testTaskIsReadyExpiredAndRedeemYourselfExpired() {
        // given
        let task = task(expiresOn: DemoDate.createDemoDate(.yesterday),
                        acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Nicht mehr gültig")))
    }

    func testScannedTaskIsClosed() {
        // given
        let task = ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .completed,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            redeemedOn: DemoDate.createDemoDate(.yesterday),
            source: .scanner
        )
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Eingelöst: Gestern")))
    }

    func testTaskIsUndefined() {
        // given
        let task = task(status: .draft)
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.undefined))
    }

    func testTaskIsMultiplePrescriptionForLaterDate() {
        // given
        let startDate = "2323-01-26T15:23:21+00:00"
        let multiPrescription = MultiplePrescription(
            mark: true,
            numbering: 2,
            totalNumber: 4,
            startPeriod: startDate,
            endPeriod: "2323-04-26T15:23:21+00:00"
        )
        let task = task(status: .ready, multiplePrescription: multiPrescription)
        // when
        let sut = Prescription(erxTask: task)
        // then
        expect(sut.viewStatus).to(equal(.redeem(at: "Einlösbar ab 26.01.2323")))
    }
}
