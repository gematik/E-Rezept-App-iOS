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

import Dependencies
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

final class PrescriptionViewStatusTests: XCTestCase {
    func generateTask(status: ErxTask.Status = .ready,
                      flowType: ErxTask.FlowType? = nil,
                      expiresOn: String? = DemoDate.createDemoDate(.tomorrow),
                      acceptedUntil: String? = DemoDate.createDemoDate(.twentyEightDaysAhead),
                      multiplePrescription: MultiplePrescription? = nil,
                      medicationDispenses: [ErxMedicationDispense] = []) -> ErxTask {
        ErxTask(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: status,
            flowType: flowType,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: expiresOn,
            acceptedUntil: acceptedUntil,
            lastMedicationDispense: DemoDate.createDemoDate(.tomorrow),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication,
            medicationRequest: .init(
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                multiplePrescription: multiplePrescription
            ),
            medicationDispenses: medicationDispenses
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

    func medicationDispense(with date: String?) -> ErxMedicationDispense {
        ErxMedicationDispense(
            identifier: "some-unique-id",
            taskId: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            insuranceId: "A123456789",
            dosageInstruction: nil,
            telematikId: "11b2-8555",
            whenHandedOver: date ?? "",
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
            ),
            epaMedication: nil
        )
    }

    func testTaskIsReady() { // CREATE, ACTIVATE
        // given
        let task = generateTask()
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskIsDispensed() {
        withDependencies {
            $0.date = DateGenerator { Date() }
        } operation: {
            // given
            let task0 = self.generateTask(
                status: .computed(status: .dispensed),
                medicationDispenses: [self.medicationDispense(with: DemoDate.createDemoDate(.dayAfterTomorrow))]
            )
            // when
            let sut0 = Prescription(erxTask: task0, dateFormatter: .testValue)
            // then
            expect(sut0.viewStatus).to(equal(.open(until: "Bereitgestellt übermorgen")))
            expect(sut0.isDeletable).to(beFalse())

            // given
            let task = self.generateTask(
                status: .computed(status: .dispensed),
                medicationDispenses: [self.medicationDispense(with: DemoDate.createDemoDate(.yesterday))]
            )
            // when
            let sut = Prescription(erxTask: task, dateFormatter: .testValue)
            // then
            expect(sut.viewStatus).to(equal(.open(until: "Bereitgestellt gestern")))

            // given
            let task2 = self.generateTask(
                status: .computed(status: .dispensed),
                medicationDispenses: [self.medicationDispense(with: FHIRDateFormatter.liveValue
                        .stringWithLongUTCTimeZone(from: Date(timeIntervalSince1970: 1_706_612_400)))]
            )
            // when
            let sut2 = Prescription(erxTask: task2, dateFormatter: .testValue)
            // then
            expect(sut2.viewStatus).to(equal(.open(until: "Bereitgestellt 30.01.2024")))
        }
    }

    func testTaskIsInProgress() { // ACCEPT
        // given
        let task = generateTask(status: .inProgress)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Angenommen ")))
        expect(sut.type).to(equal(.regular))
        expect(sut.isDeletable).to(beFalse())
    }

    func testTaskIsClosed() { // CLOSE
        // given
        let task = generateTask(
            status: .completed,
            medicationDispenses: [
                medicationDispense(with: FHIRDateFormatter.liveValue
                    .stringWithLongUTCTimeZone(from: Date(timeIntervalSince1970: 1_706_612_400))),
            ]
        )
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Eingelöst: 30.01.2024")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskIsReadyAndNotAcceptedAnymore() {
        // given
        let task = generateTask(acceptedUntil: DemoDate.createDemoDate(.yesterday))
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Nur noch heute als Selbstzahlender einlösbar")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskIsReadyWithoutExpireAndAcceptedDate() {
        // given
        let task = generateTask(expiresOn: nil,
                                acceptedUntil: nil)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Keine Angabe")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskAlreadyExpired() {
        // given
        let task = generateTask(expiresOn: "2024-01-01T08:23:19+00:00",
                                acceptedUntil: "2023-12-01T08:23:19+00:00")
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Abgelaufen am 01.01.2024")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskInProgressAndExpired() {
        // given
        let task = generateTask(
            status: .inProgress,
            expiresOn: "2024-01-01T08:23:19+00:00",
            acceptedUntil: "2023-12-01T08:23:19+00:00"
        )
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Abgelaufen am 01.01.2024")))
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskDispensedAndExpired() {
        // given
        let task = generateTask(
            status: .computed(status: .dispensed),
            expiresOn: "2024-01-01T08:23:19+00:00",
            acceptedUntil: "2023-12-01T08:23:19+00:00"
        )
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.archived(message: "Abgelaufen am 01.01.2024")))
        expect(sut.isDeletable).to(beTrue())
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
        expect(sut.isDeletable).to(beTrue())
    }

    func testTaskIsUndefined() {
        // given
        let task = generateTask(status: .draft)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: .testValue)
        // then
        expect(sut.viewStatus).to(equal(.undefined))
        expect(sut.isDeletable).to(beTrue())
    }

    func testDirectAssignment() {
        // given
        let task = generateTask(status: .ready, flowType: .directAssignment)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: UIDateFormatter.testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.type).to(equal(.directAssignment))
        expect(sut.isDeletable).to(beFalse())
    }

    func testDirectAssignmentForPKV() {
        // given
        let task = generateTask(status: .ready, flowType: .directAssignmentForPKV)
        // when
        let sut = Prescription(erxTask: task, dateFormatter: UIDateFormatter.testValue)
        // then
        expect(sut.viewStatus).to(equal(.open(until: "Noch 27 Tage einlösbar")))
        expect(sut.type).to(equal(.directAssignment))
        expect(sut.isDeletable).to(beFalse())
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
        expect(sut.isDeletable).to(beTrue())
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
            expiresOn: "2024-01-01T08:23:19+00:00",
            acceptedUntil: "2023-12-01T08:23:19+00:00"
        )
        sut = Prescription(erxTask: task, dateFormatter: .testValue)
        expect(sut.viewStatus).to(equal(.archived(message: "Abgelaufen am 01.01.2024")))

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
