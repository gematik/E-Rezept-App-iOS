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

import eRpKit
import Foundation
// swiftlint:disable file_length
extension ErxTask {
    // swiftlint:disable:next type_body_length
    enum Demo {
        static let demoRatio = ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "2.5", unit: "%"),
            denominator: ErxMedication.Quantity(value: "1")
        )

        static let medication1: ErxMedication = .init(
            name: "Saflorblüten-Extrakt Pulver Peroral",
            pzn: "06876512",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "10", unit: "St.")
            ),
            dosageForm: "PUL",
            normSizeCode: "N1",
            batch: .init(
                lotNumber: "TOTO-5236-VL",
                expiresOn: "12.12.2024"
            ),
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication2: ErxMedication = .init(
            name: "Yucca filamentosa",
            pzn: "06876511",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "12", unit: "St.")
            ),
            dosageForm: "FDA",
            normSizeCode: "N2",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication3: ErxMedication = .init(
            name: "Lebenselixir 9000",
            pzn: "06876513",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "200", unit: "ml")
            ),
            dosageForm: "ELI",
            normSizeCode: "KTP",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication4: ErxMedication = .init(
            name: "Zimtöl",
            pzn: "06876514",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "100", unit: "ml")
            ),
            dosageForm: "AEO",
            normSizeCode: "KA",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication5: ErxMedication = .init(
            name: "Gelitan Wundgel Zur äußerlichen Anwendung",
            pzn: "06876515",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "2", unit: "Pack.")
            ),
            dosageForm: "GEL",
            normSizeCode: "sonstiges",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication6: ErxMedication = .init(
            name: "Asthmazopol Inhalator Flasche",
            pzn: "06876516",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "1", unit: "Flasche")
            ),
            dosageForm: "INH",
            normSizeCode: "N2",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication7: ErxMedication = .init(
            name: "Iboprogenal 100+",
            pzn: "06876517",
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "20", unit: "St.")
            ),
            dosageForm: "TAB",
            normSizeCode: "N3",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let medication8: ErxMedication = .init(
            name: "Vita-Tee",
            pzn: "06876518",
            isVaccine: true,
            amount: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "8", unit: "Beutel")
            ),
            dosageForm: "INS",
            normSizeCode: "NB",
            packaging: "Box",
            manufacturingInstructions: "Anleitung beiliegend",
            ingredients: []
        )

        static let pznMedication = medication1

        static let freeTextMedication = ErxMedication(
            name: "Freier Text für eine Rezeptur oder Wirkstoffverordnung die nicht strukturiert erfasst werden können",
            profile: .freeText,
            drugCategory: .avm,
            pzn: nil,
            isVaccine: true,
            dosageForm: "Angabe der Darreichungsform als Freitext",
            batch: .init(lotNumber: "TOTO-5236-VL", expiresOn: "12.12.2024")
        )

        static let compoundingMedication: ErxMedication = .init(
            name: "Yucca filamentosa",
            profile: .compounding,
            drugCategory: .avm,
            pzn: nil,
            isVaccine: false,
            amount: .init(ErxMedication.Ratio(numerator: .init(value: "1", unit: "St."))),
            dosageForm: "FDA",
            normSizeCode: "N2",
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

        static let erxTaskReady = erxTask1

        static let erxTaskRedeemed = erxTask10

        static let erxTaskDirectAssignment = Self.erxTask4

        static let erxTaskError: ErxTask = .init(
            identifier: "1790f983-1e67-11b2-8555-63bf44e44fb8",
            status: .error(.decoding(message: "error: decoding")),
            flowType: ErxTask.FlowType.pharmacyOnly,
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
            insuranceId: "A123456789",
            coverageType: .GKV
        )

        static let demoSelfPayerPatient = ErxPatient(
            name: "Ludger von Königsstein",
            address: "Musterstr. 1 \n10624 Berlin",
            birthDate: "22.6.1936",
            phone: "555 1234568",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456788",
            coverageType: .SEL
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

        static let demoMedicationRequest: ErxMedicationRequest = .init(
            dosageInstructions: "Some informations on how to take your prescription",
            substitutionAllowed: true,
            hasEmergencyServiceFee: true,
            dispenseValidityEnd: "12.12.1936",
            accidentInfo: demoAccidentInfo,
            coPaymentStatus: .subjectToCharge,
            multiplePrescription: demoMultiplePrescription,
            quantity: .init(value: "17", unit: "Packungen")
        )

        static let demoMultiplePrescription = MultiplePrescription(
            mark: true,
            numbering: 2,
            totalNumber: 4,
            startPeriod: "2323-01-26T15:23:21+00:00",
            endPeriod: "2323-04-26T15:23:21+00:00"
        )

        static let erxTask1: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.tomorrow),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                dosageInstructions: "1-0-0-0",
                substitutionAllowed: true,
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo,
                coPaymentStatus: .subjectToCharge,
                quantity: .init(value: "2", unit: "Packungen")

            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask2: ErxTask = .init(
            identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twentyEightDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication2,
            medicationRequest: .init(
                dosageInstructions: "1-0-1-0",
                substitutionAllowed: true,
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask3: ErxTask = .init(
            identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twelveDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                dosageInstructions: "1-0-2-0",
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")

            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        // Direktzuweisung
        static let erxTask4: ErxTask = .init(
            identifier: "169.000.000.000.021.02",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: nil, // A Direktzuweisung (169) does not have an access code
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.dayBeforeYesterday),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twentyEightDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                coPaymentStatus: .noSubjectToCharge,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask5: ErxTask = .init(
            identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication5,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask6: ErxTask = .init(
            identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.dayBeforeYesterday),
            author: "Praxis Dr. med. Karin Hasenbein",
            medication: medication6,
            medicationRequest: .init(
                hasEmergencyServiceFee: true,
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask7: ErxTask = .init(
            identifier: "6390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twentyEightDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask8: ErxTask = .init(
            identifier: "6380f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(from: Date(timeIntervalSince1970: 1_706_612_400)),
            acceptedUntil: FHIRDateFormatter.liveValue
                .stringWithLongUTCTimeZone(from: Date(timeIntervalSince1970: 1_704_106_800)),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication8,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask9: ErxTask = .init(
            identifier: "6370f983-1e67-11b2-8555-63bf44e44fb8",
            status: .inProgress,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
            expiresOn: DemoDate.createDemoDate(.twelveDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.twelveDaysAhead),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication7,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask10: ErxTask = .init(
            identifier: "7360f983-1e67-11b2-8555-63bf44e44fb8",
            status: .completed,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.yesterday),
            acceptedUntil: DemoDate.createDemoDate(.yesterday),
            redeemedOn: DemoDate.createDemoDate(.yesterday),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask11: ErxTask = .init(
            identifier: "7350f983-1e67-11b2-8955-63bf44e44fb8",
            status: .cancelled,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication2,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask12: ErxTask = .init(
            identifier: "7340f983-1e67-11b2-8955-63bf44e44fb8",
            status: .draft,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: nil,
            expiresOn: nil,
            acceptedUntil: nil,
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication3,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask13: ErxTask = .init(
            identifier: "6450f983-1e67-11b2-8955-63bf44e44fb8",
            status: .undefined(status: "on-hold"),
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
            expiresOn: DemoDate.createDemoDate(.weekBefore),
            acceptedUntil: DemoDate.createDemoDate(.weekBefore),
            redeemedOn: nil,
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication4,
            medicationRequest: .init(
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTask14: ErxTask = .init(
            identifier: "34235f983-1e67-22c5-8955-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
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
                multiplePrescription: demoMultiplePrescription,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTaskSelfPayer: ErxTask = .init(
            identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.today),
            expiresOn: DemoDate.createDemoDate(.ninetyTwoDaysAhead),
            acceptedUntil: DemoDate.createDemoDate(.tomorrow),
            author: "Dr. Dr. med. Carsten van Storchhausen",
            medication: medication1,
            medicationRequest: .init(
                dosageInstructions: "1-0-1-0",
                substitutionAllowed: true,
                accidentInfo: demoAccidentInfo,
                quantity: .init(value: "2", unit: "Packungen")
            ),
            patient: demoSelfPayerPatient,
            practitioner: demoPractitioner,
            organization: demoOrganization
        )

        static let erxTaskScanned1: ErxTask = .init(
            identifier: "34235f983-1e67-331g-8955-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            redeemedOn: nil,
            source: .scanner
        )

        static let erxTaskScanned2: ErxTask = .init(
            identifier: "34235f983-1e67-321g-8955-63bf44e44fb8",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
            fullUrl: nil,
            authoredOn: DemoDate.createDemoDate(.yesterday),
            redeemedOn: nil,
            source: .scanner
        )

        static func expiredErxTask(with status: ErxTask.Status) -> ErxTask {
            .init(
                identifier: "34235f983-1e67-22c5-8955-63bf44e44fb8",
                status: status,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30336811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: DemoDate.createDemoDate(.ninetyTwoDaysBefore),
                expiresOn: DemoDate.createDemoDate(.weekBefore),
                acceptedUntil: DemoDate.createDemoDate(.thirtyDaysBefore),
                redeemedOn: nil,
                author: "Dr. Dr. med. Carsten van Storchhausen",
                medication: medication8,
                medicationRequest: .init(
                    accidentInfo: demoAccidentInfo,
                    quantity: .init(value: "2", unit: "Packungen")
                ),
                patient: demoPatient,
                practitioner: demoPractitioner,
                organization: demoOrganization
            )
        }

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
                erxTask14,
            ]

        static let erxTasksScanned: [ErxTask] =
            [
                erxTaskScanned1,
                erxTaskScanned2,
            ]
    }
}
