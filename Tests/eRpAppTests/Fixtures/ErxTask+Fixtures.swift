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

@testable import eRpApp // todo rm me (DemoDate)
import eRpKit
import Foundation

extension ErxTask {
    // swiftlint:disable:next type_body_length
    enum Fixtures {
        static let medication1: ErxMedication = .init(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: .init(numerator: .init(value: "10")),
            dosageForm: "PUL",
            dose: "N1",
            batch: .init(
                lotNumber: "TOTO-5236-VL",
                expiresOn: nil
            )
        )

        static let compoundingMedication: ErxMedication = .init(
            name: "Yucca filamentosa",
            profile: .compounding,
            drugCategory: .avm,
            pzn: nil,
            isVaccine: false,
            amount: .init(ErxMedication.Ratio(numerator: .init(value: "1", unit: "St."))),
            dosageForm: "FDA",
            dose: "N2",
            packaging: "Small package",
            manufacturingInstructions: "no instructions",
            ingredients: [yuccaIngredient, filmaIngredient]
        )

        static let yuccaIngredient = ErxMedication.Ingredient(
            text: "Yucca",
            number: "12345",
            form: "creme",
            strength: nil,
            strengthFreeText: "1/2"
        )

        static let filmaIngredient = ErxMedication.Ingredient(
            text: "Filamentosa",
            number: "9872136",
            form: "liquid",
            strength: .init(numerator: .init(value: "40", unit: "%")),
            strengthFreeText: nil
        )

        static let medication3: ErxMedication = .init(
            name: "Lebenselixir 9000",
            pzn: "06876513",
            amount: .init(numerator: .init(value: "1")),
            dosageForm: "ELI",
            dose: "KTP",
            batch: .init(
                lotNumber: "ABBA-5236-VL",
                expiresOn: nil
            )
        )

        static let medication4: ErxMedication = .init(
            name: "Zimtöl",
            pzn: "06876514",
            amount: .init(numerator: .init(value: "1")),
            dosageForm: "AEO",
            dose: "KA",
            batch: .init(
                lotNumber: "DODO-5236-VL",
                expiresOn: nil
            )
        )

        static let medication5: ErxMedication = .init(
            name: "Gelitan Wundgel Zur äußerlichen Anwendung",
            pzn: "06876515",
            amount: .init(numerator: .init(value: "2")),
            dosageForm: "GEL",
            dose: "sonstiges"
        )

        static let medication6: ErxMedication = .init(
            name: "Asthmazopol Inhalator Flasche",
            pzn: "06876516",
            amount: .init(numerator: .init(value: "5")),
            dosageForm: "INH",
            dose: "N2"
        )

        static let medication7: ErxMedication = .init(
            name: "Iboprogenal 100+",
            pzn: "06876517",
            amount: .init(numerator: .init(value: "20")),
            dosageForm: "TAB",
            dose: "N3"
        )

        static let medication8: ErxMedication = .init(
            name: "Vita-Tee",
            pzn: "06876518",
            amount: .init(numerator: .init(value: "8")),
            dosageForm: "INS",
            dose: "NB"
        )

        static let medicationDispense1: ErxMedicationDispense = .init(
            identifier: "taskId-1",
            taskId: "53210f983-1e67-22c5-8955-63bf44e44fb8",
            insuranceId: "A123456789",
            dosageInstruction: nil,
            telematikId: "11b2-8555",
            whenHandedOver: DemoDate.createDemoDate(.today) ?? "",
            medication: .init(
                name: "Vita-Tee",
                pzn: "06876519",
                amount: .init(numerator: .init(value: "4")),
                dosageForm: "INS",
                dose: "NB",
                batch: .init(
                    lotNumber: "Charge number 1001",
                    expiresOn: "2323-01-26T15:23:21+00:00"
                )
            )
        )

        static let medicationDispense2: ErxMedicationDispense = .init(
            identifier: "taskId-2",
            taskId: "53210f983-1e67-22c5-8955-63bf44e44fb8",
            insuranceId: "A123456789",
            dosageInstruction: nil,
            telematikId: "11b2-8555",
            whenHandedOver: DemoDate.createDemoDate(.today) ?? "",
            medication: .init(
                name: "Vita-Tee",
                pzn: "06876519",
                amount: .init(numerator: .init(value: "4")),
                dosageForm: "INS",
                dose: "NB",
                batch: .init(
                    lotNumber: "Charge number 1001",
                    expiresOn: "2323-01-26T15:23:21+00:00"
                )
            )
        )

        static let erxTaskReady = erxTask1

        static let erxTaskInProgress = erxTask14

        static let erxTaskRedeemed = erxTask10

        static let erxTaskCompleted = erxTask15

        static let erxTaskRedeemAt = erxTask16

        static let erxTaskDirectAssigned = ErxTask(
            identifier: "169.123.456.789.123.58",
            status: .inProgress,
            flowType: .directAssignment,
            accessCode: nil, // must be nil with flowtype directAssignment
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twentyEightDaysAhead),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTaskError: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .error(.decoding(message: "error: decoding")),
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            authoredOn: DemoDate.createDemoDate(.yesterday)
        )

        static let demoPatient = ErxPatient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789"
        )

        static let demoPractitioner = ErxPractitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )

        static let demoOrganization = ErxOrganization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )

        static let demoAccidentInfo = AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "1234567890",
            date: "9.4.2021"
        )

        static let demoMultiplePrescription = MultiplePrescription(
            mark: true,
            numbering: 2,
            totalNumber: 4,
            startPeriod: "2323-01-26T15:23:21+00:00",
            endPeriod: "2323-04-26T15:23:21+00:00"
        )

        static let demoNoMultiplePrescription = MultiplePrescription(
            mark: false,
            numbering: 0,
            totalNumber: 0,
            startPeriod: DemoDate.createDemoDate(.yesterday),
            endPeriod: DemoDate.createDemoDate(.yesterday)
        )

        static func avsTransaction(for taskId: String) -> AVSTransaction {
            .init(
                httpStatusCode: 200,
                groupedRedeemTime: Date(timeIntervalSinceNow: -60 * 60 * 24),
                groupedRedeemID: UUID(),
                taskId: taskId
            )
        }

        static let scannedTask: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            source: .scanner
        )

        static let scannedTaskWithAVSTransaction: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            avsTransactions: [avsTransaction(for: "2390f983-1e67-11b2-8555-63bf44e44fb8")],
            source: .scanner
        )

        static let erxTask1: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.tomorrow),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask2: ErxTask = .init(
            identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.twentyEightDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: compoundingMedication,
            medicationRequest: .init(
                substitutionAllowed: true,
                accidentInfo: demoAccidentInfo,
                coPaymentStatus: .noSubjectToCharge
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask3: ErxTask = .init(
            identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            expiresOn: DemoDate.createDemoDate(.twelveDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo,
                coPaymentStatus: .subjectToCharge,
                multiplePrescription: demoNoMultiplePrescription
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask4: ErxTask = .init(
            identifier: "1390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.dayBeforeYesterday),
            expiresOn: DemoDate.createDemoDate(.twentyEightDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask5: ErxTask = .init(
            identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.yesterday),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication5,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask6: ErxTask = .init(
            identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.dayBeforeYesterday),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Praxis Dr. med. Karin Hasenbein",
            medication: medication6,
            medicationRequest: .init(
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask7: ErxTask = .init(
            identifier: "6380f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.twentyEightDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask8: ErxTask = .init(
            identifier: "6370f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.yesterday),
            acceptedUntil: DemoDate.createDemoDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication8,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask9: ErxTask = .init(
            identifier: "6360f983-1e67-11b2-8555-63bf44e44fb8",
            status: .inProgress,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.twelveDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twelveDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask10: ErxTask = .init(
            identifier: "7350f983-1e67-11b2-8555-63bf44e44fb8",
            status: .completed,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.yesterday),
            acceptedUntil: DemoDate.createDemoDate(.yesterday),
            redeemedOn: DemoDate.createDemoDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask11: ErxTask = .init(
            identifier: "7340f983-1e67-11b2-8955-63bf44e44fb8",
            status: .cancelled,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: compoundingMedication,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask12: ErxTask = .init(
            identifier: "7330f983-1e67-11b2-8955-63bf44e44fb8",
            status: .draft,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: nil,
            acceptedUntil: nil,
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask13: ErxTask = .init(
            identifier: "7320f983-1e67-11b2-8955-63bf44e44fb8",
            status: .undefined(status: "on-hold"),
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask14: ErxTask = .init(
            identifier: "7390f983-1e67-11b2-8955-63bf44e44fb8",
            status: .inProgress,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask15: ErxTask = .init(
            identifier: "53210f983-1e67-22c5-8955-63bf44e44fb8",
            status: .completed,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: DemoDate.createDemoDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication8,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization,
            medicationDispenses: [
                medicationDispense1,
                medicationDispense2,
            ]
        )

        static let erxTask16: ErxTask = .init(
            identifier: "34235f983-1e67-22c5-8955-63bf44e44fb8",
            status: .ready,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication8,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                multiplePrescription: demoMultiplePrescription
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTasks: [ErxTask] =
            [
                erxTask1,
                erxTask2,
                erxTask3,
                erxTask4,
                erxTask5,
                erxTask6,
                erxTask7,
                erxTask8,
                erxTask9,
                erxTask10,
                erxTask11,
                erxTask12,
                erxTask13,
                erxTask16,
            ]
    }
}
