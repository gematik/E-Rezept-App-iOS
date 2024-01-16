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

@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class PrescriptionViewStatusTests: XCTestCase {
    func generateTask(status: ErxTask.Status = .ready,
                      flowType: ErxTask.FlowType? = nil,
                      expiresOn: String? = DemoDate.createDemoDate(.tomorrow),
                      acceptedUntil: String? = DemoDate.createDemoDate(.twentyEightDaysAhead),
                      multiplePrescription: MultiplePrescription? = nil) -> ErxTask {
        ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: status,
            flowType: flowType,
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
        let task = generateTask()
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
    }

    func testTaskIsInProgress() { // ACCEPT
        // given
        let task = generateTask(status: .inProgress)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.type).to(equal(.regular))
    }

    func testTaskIsClosed() { // CLOSE
        // given
        let task = generateTask(status: .completed)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Eingelöst: Heute")))
    }

    func testTaskIsReadyAndNotAcceptedAnymore() {
        // given
        let task = generateTask(acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute als Selbstzahlender einlösbar")))
    }

    func testTaskIsReadyWithoutExpireAndAcceptedDate() {
        // given
        let task = generateTask(expiresOn: nil,
                                acceptedUntil: nil)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Keine Angabe")))
    }

    func testTaskAlreadyExpired() {
        // given
        let task = generateTask(expiresOn: DemoDate.createDemoDate(.today),
                                acceptedUntil: DemoDate.createDemoDate(.today))
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
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
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Eingelöst: Gestern")))
        expect(sut.type).to(equal(.scanned))
    }

    func testTaskIsUndefined() {
        // given
        let task = generateTask(status: .draft)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.undefined))
    }

    func testDirectAssignment() {
        // given
        let task = generateTask(status: .ready, flowType: .directAssignment)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: UIDateFormatter.testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.type).to(equal(.directAssignment))
    }

    func testDirectAssignmentForPKV() {
        // given
        let task = generateTask(status: .ready, flowType: .directAssignmentForPKV)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: UIDateFormatter.testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.type).to(equal(.directAssignment))
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
        let task = generateTask(status: .ready, multiplePrescription: multiPrescription)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.redeem(at: "Einlösbar ab 26.01.2323")))
        expect(sut.type).to(equal(.multiplePrescription))
    }

    func testXDaysLeftForAssignment() {
        // given
        var task: ErxTask
        var sut: Prescription

        // one day left for assignment (including today)
        task = generateTask(acceptedUntil: DemoDate.createDemoDate(.tomorrow))
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute einlösbar")))

        // two days left for assignment (including today)
        task = generateTask(acceptedUntil: DemoDate.createDemoDate(.dayAfterTomorrow))
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch morgen einlösbar")))

        // three days left for assignment (including today)
        task = generateTask(acceptedUntil: DemoDate.createDemoDate(.threeDaysAhead))
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Noch 2 Tage einlösbar")))

        // 28 days left for assignment (including today)
        task = generateTask()
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
    }

    func testXDaysLeftUntilExpired() {
        // given
        var task: ErxTask
        var sut: Prescription

        // expired today
        task = generateTask(
            expiresOn: DemoDate.createDemoDate(.today),
            acceptedUntil: DemoDate.createDemoDate(.dayBeforeYesterday)
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.archived(message: "Nicht mehr gültig")))

        // one day left until expired (including today)
        task = generateTask(
            expiresOn: DemoDate.createDemoDate(.tomorrow),
            acceptedUntil: DemoDate.createDemoDate(.today)
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute als Selbstzahlender einlösbar")))

        // two days left until expire (including today)
        task = generateTask(
            expiresOn: DemoDate.createDemoDate(.dayAfterTomorrow),
            acceptedUntil: DemoDate.createDemoDate(.today)
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch morgen als Selbstzahlender einlösbar")))

        // three days left until expire (including today)
        task = generateTask(
            expiresOn: DemoDate.createDemoDate(.threeDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.today)
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Noch 2 Tage als Selbstzahlender einlösbar")))

        // 28 days left until expire (including today)
        task = generateTask(
            expiresOn: DemoDate.createDemoDate(.twentyEightDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.today)
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage als Selbstzahlender einlösbar")))
    }
}
