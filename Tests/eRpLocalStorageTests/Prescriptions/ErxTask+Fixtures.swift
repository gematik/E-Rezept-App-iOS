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

extension ErxTask {
    enum Fixtures {
        static let task_id_1 = ErxTask(
            identifier: "id_1",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            lastModified: "2021-07-10T10:55:04+02:00"
        )

        static let task_id_2 = ErxTask(
            identifier: "id_2",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            lastModified: "2021-07-10T10:55:04+02:00"
        )

        // non realistic task
        static let taskWithAllFieldsFilled: ErxTask =
            .init(
                identifier: "task_id_17",
                status: .completed,
                flowType: .narcoticForPKV,
                accessCode: "task_access_code_123",
                fullUrl: "full_url_17",
                authoredOn: "2021-06-10T10:55:04+02:00",
                lastModified: "2021-07-10T10:55:04+02:00",
                expiresOn: "2021-09-10T10:55:04+02:00",
                acceptedUntil: "2021-08-10T10:55:04+02:00",
                lastMedicationDispense: "2021-07-10T10:55:04+02:00",
                redeemedOn: "2021-07-16T10:55:04+02:00",
                author: "Dr. Med. Complete",
                prescriptionId: "prescription_id_17",
                source: .server,
                medication: Self.compoundingMedication,
                medicationRequest: .init(
                    dosageInstructions: "1-0-1-0",
                    substitutionAllowed: true,
                    hasEmergencyServiceFee: true,
                    dispenseValidityEnd: "2021-08-10T10:55:04+02:00",
                    accidentInfo: .init(
                        type: .workAccident,
                        workPlaceIdentifier: "Hard-Work-Comp",
                        date: "2021-06-05T10:55:04+02:00"
                    ),
                    bvg: true,
                    coPaymentStatus: .artificialInsemination,
                    multiplePrescription: .init(
                        mark: true,
                        numbering: 3,
                        totalNumber: 5,
                        startPeriod: "2021-07-16T10:55:04+02:00",
                        endPeriod: "2021-09-16T10:55:04+02:00"
                    ),
                    quantity: .init(value: "2", unit: "Packungen")
                ),
                patient: .init(
                    name: "Tohmas Krank",
                    address: "Demo Street 17,12345, Demostadt",
                    birthDate: "22.12.2022",
                    phone: "0177123456",
                    status: "ledig",
                    insurance: "AKK",
                    insuranceId: "A123456789",
                    coverageType: .PKV
                ),
                practitioner: practitioner,
                organization: organization,
                communications: [communication],
                medicationDispenses: [
                    medicationDispense,
                    medicationDispenseWithEpaMedication,
                ]
            )

        static let practitioner: ErxPractitioner = .init(
            lanr: "12343",
            zanr: "56778",
            name: "Dr. Dr. med. Sauer",
            qualification: "all",
            email: "mail@praxis-dr-sauer.de",
            address: "Sauer Str. 17, 1234 Sauerland, Schland"
        )

        static let organization: ErxOrganization = .init(
            identifier: "orga_id_17",
            name: "Praxis Dr. Sauer und Kollegen",
            phone: "0900121212",
            email: "mail@praxis-dr-sauer.de",
            address: "Sauer Str. 17, 1234 Sauerland, Schland"
        )

        static let communication: Communication = .init(
            identifier: "1",
            profile: .reply,
            taskId: "task_id_17",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}",
            // swiftlint:disable:previous line_length
            isRead: true
        )

        static let medicationDispense: ErxMedicationDispense = .init(
            identifier: "task_id_17",
            taskId: "task_id_17",
            insuranceId: "A123456789",
            dosageInstruction: "1-1-1",
            telematikId: "11b2-8555",
            whenHandedOver: "2021-07-20T10:55:04+02:00",
            quantity: .init(value: "1", unit: "Packung"),
            noteText: "Take good care",
            medication: compoundingMedication,
            epaMedication: nil
        )

        static let medicationDispenseWithEpaMedication: ErxMedicationDispense = .init(
            identifier: "task_id_17_epa",
            taskId: "task_id_17",
            insuranceId: "A123456789",
            dosageInstruction: "1-1-1",
            telematikId: "11b2-8555",
            whenHandedOver: "2021-07-20T10:55:04+02:00",
            quantity: .init(value: "1", unit: "Packung"),
            noteText: "Take good care",
            medication: nil,
            epaMedication: epaMedicationMedicinalProductPackage
        )

        static let medicationDispenseWithPZN: ErxMedicationDispense = .init(
            identifier: "task_id_42",
            taskId: "task_id_42",
            insuranceId: "A987654",
            dosageInstruction: "1-1-1-0",
            telematikId: "11b2-8555",
            whenHandedOver: "2021-07-23T10:55:04+02:00",
            quantity: .init(value: "1", unit: "Packung"),
            noteText: "read everything",
            medication: pznMedication,
            epaMedication: nil
        )

        static let compoundingMedication: ErxMedication = .init(
            name: "Yucca filamentosa",
            profile: .compounding,
            drugCategory: .avm,
            pzn: "12345",
            isVaccine: true,
            amount: .init(ErxMedication.Ratio(numerator: .init(value: "1", unit: "St."))),
            dosageForm: "FDA",
            normSizeCode: "N2",
            batch: .init(
                lotNumber: "set in medication dispense only",
                expiresOn: "set in medication dispense only"
            ),
            packaging: "Small package",
            manufacturingInstructions: "no instructions",
            ingredients: [yuccaIngredient]
        )

        static let pznMedication: ErxMedication = .init(
            name: "Ibosulfan",
            profile: .pzn,
            drugCategory: .avm,
            pzn: "12345",
            isVaccine: false,
            amount: .init(ErxMedication.Ratio(numerator: .init(value: "1", unit: "Packung"))),
            dosageForm: "TAB",
            normSizeCode: "N2",
            batch: .init(
                lotNumber: "set in medication dispense only",
                expiresOn: "set in medication dispense only"
            ),
            packaging: "Small package",
            manufacturingInstructions: "no instructions",
            ingredients: []
        )

        static let epaMedicationMedicinalProductPackage: ErxEpaMedication = .init(
            epaMedicationType: .medicinalProductPackage,
            drugCategory: .avm,
            code: nil,
            status: .active,
            isVaccine: false,
            amount: nil,
            form: .init(
                codings: [.init(system: .kbvDarreichungsform, code: "KPG", display: nil)],
                text: nil
            ),
            normSizeCode: nil,
            batch: nil,
            packaging: nil,
            manufacturingInstructions: nil,
            ingredients: [
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .pharmaceuticalBiologicProduct,
                            drugCategory: nil,
                            code: EpaMedicationCodableConcept(
                                codings: [
                                    EpaMedicationCoding<CodeCodingSystem>(
                                        system: .productKey,
                                        code: "01746517-2",
                                        display: "Nasenspray, Lösung"
                                    ),
                                ],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: nil,
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: [
                                EpaMedicationIngredient(
                                    item: .codableConcept(
                                        EpaMedicationCodableConcept(
                                            codings: [
                                                EpaMedicationCoding<CodeCodingSystem>(
                                                    system: .atcDe,
                                                    code: "R01AC01",
                                                    display: "Natriumcromoglicat"
                                                ),
                                            ],
                                            text: nil
                                        )
                                    ),
                                    isActive: nil,
                                    strength: .init(
                                        ratio: .init(
                                            numerator: .init(value: "2.8", unit: "mg"),
                                            denominator: .init(value: "1", unit: "Sprühstoß")
                                        ),
                                        amountText: nil
                                    ),
                                    darreichungsForm: nil
                                ),
                            ]
                        )
                    )
                ),
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .pharmaceuticalBiologicProduct,
                            drugCategory: nil,
                            code: EpaMedicationCodableConcept(
                                codings: [
                                    EpaMedicationCoding<CodeCodingSystem>(
                                        system: .productKey,
                                        code: "01746517-1",
                                        display: "Augentropfen"
                                    ),
                                ],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: nil,
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: [
                                EpaMedicationIngredient(
                                    item: .codableConcept(
                                        EpaMedicationCodableConcept(
                                            codings: [
                                                EpaMedicationCoding<CodeCodingSystem>(
                                                    system: .atcDe,
                                                    code: "R01AC01",
                                                    display: "Natriumcromoglicat"
                                                ),
                                            ],
                                            text: nil
                                        )
                                    ),
                                    isActive: nil,
                                    strength: .init(
                                        ratio: .init(
                                            numerator: .init(value: "20", unit: "mg"),
                                            denominator: .init(value: "1", unit: "ml")
                                        ),
                                        amountText: nil
                                    ),
                                    darreichungsForm: nil
                                ),
                            ]
                        )
                    )
                ),
            ]
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
    }
}

extension ErxAuditEvent {
    enum Fixtures {
        static let auditEvent1: ErxAuditEvent = .init(
            identifier: "id_1",
            locale: "locale_1",
            text: "Text 1",
            timestamp: "2021-07-20T10:55:04+02:00",
            taskId: nil
        )

        static let auditEvent2: ErxAuditEvent = .init(
            identifier: "id_2",
            locale: "locale_2",
            text: "Text 2",
            timestamp: "2021-07-23T10:55:04+02:00",
            taskId: nil
        )

        static let auditEvent3: ErxAuditEvent = .init(
            identifier: "id_3",
            locale: "locale_3",
            text: "Text 3",
            timestamp: "2021-07-10T10:55:04+02:00",
            taskId: nil
        )
    }
}
