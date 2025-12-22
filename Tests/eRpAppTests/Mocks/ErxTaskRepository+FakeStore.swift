//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import eRpKit
import ErxTaskRepository
import Foundation

extension ErxTaskRepository {
    static var exampleStore: [String: ErxTask] = {
        let authoredOnNinetyTwoDaysBefore = TestDate.createFormattedDate(.ninetyTwoDaysBefore, referenceDate: Date())
        let authoredOnThirtyDaysBefore = TestDate.createFormattedDate(.thirtyDaysBefore, referenceDate: Date())
        let authoredOnSixteenDaysBefore = TestDate.createFormattedDate(.sixteenDaysBefore, referenceDate: Date())
        let authoredOnWeekBefore = TestDate.createFormattedDate(.weekBefore, referenceDate: Date())
        let expiresIn12DaysString = TestDate.createFormattedDate(.twelveDaysAhead, referenceDate: Date())
        let expiresYesterdayString = TestDate.createFormattedDate(.yesterday, referenceDate: Date())
        let expiresIn31DaysString = TestDate.createFormattedDate(.twentyEightDaysAhead, referenceDate: Date())
        let redeemedOnToday = TestDate.createFormattedDate(.today, referenceDate: Date())
        let handedOverAWeekBefore = TestDate.createFormattedDate(.weekBefore, referenceDate: Date())

        return [
            // Group 1 [0 - 2]
            "0390f983-1e67-11b2-8555-63bf44e44fb8": ErxTask(
                identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Sumatriptan-1a Pharma 100 mg Tabletten",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "1": ErxTask(
                identifier: "1390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Saflorblüten-Extrakt",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "2": ErxTask(
                identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Yucca filamentosa",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Group 2 [3]: archived because expired
            "3": ErxTask(
                identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnThirtyDaysBefore,
                expiresOn: expiresYesterdayString,
                author: "Dr. Abgelaufen",
                medication: ErxMedication(
                    name: "Zimtöl",
                    amount: .init(numerator: .init(value: "20")),
                    dosageForm: "AEO"
                )
            ),
            // Group 3 [4 -7]: other authored on date same author
            "4": ErxTask(
                identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Iboprogenal 100+",
                    amount: .init(numerator: .init(value: "10")),
                    dosageForm: "TAB"
                )
            ),
            "5": ErxTask(
                identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Saflorblüten-Extrakt",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "6": ErxTask(
                identifier: "6390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresIn31DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Med. A",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // expired but not jet acceptDate passed
            "7": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44fb8",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnWeekBefore,
                expiresOn: expiresYesterdayString,
                acceptedUntil: expiresIn12DaysString,
                author: "Dr. A",
                medication: ErxMedication(
                    name: "Med. A",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Gruppe 4 [8 - 9]: Redeemed by hand (scanned tasks)
            "8": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f1c",
                status: .completed,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnToday,
                author: nil,
                source: .scanner,
                medication: ErxMedication(
                    name: "Meditonsin 1",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            "9": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f2c",
                status: .completed,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                redeemedOn: redeemedOnToday,
                author: nil,
                source: .scanner,
                medication: ErxMedication(
                    name: "Meditonsin 2",
                    amount: .init(numerator: .init(value: "12")),
                    dosageForm: "TAB"
                )
            ),
            // Gruppe 5 [10 - 12] other author
            "10": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f3c",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 1",
                    amount: .init(numerator: .init(value: "1")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            "11": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f4c",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 2",
                    amount: .init(numerator: .init(value: "1")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            "12": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f5c",
                status: .ready,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnSixteenDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "123456789",
                    name: "Dr. White"
                )
            ),
            // Group 6 [13 -14]: Redeemed by server with medication dispenses
            "13": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                status: .completed,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnNinetyTwoDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "987654321",
                    name: "Dr. Black"
                ),
                medicationDispenses: [ErxMedicationDispense(
                    identifier: "3456789987654",
                    taskId: "7390f983-1e67-11b2-8555-63bf44e44f6c",
                    insuranceId: "ABC",
                    dosageInstruction: "",
                    telematikId: "1234567",
                    whenHandedOver: handedOverAWeekBefore!,
                    medication: ErxMedication(
                        name: "Brausepulver 3",
                        amount: .init(numerator: .init(value: "11")),
                        dosageForm: "TAB"
                    ),
                    epaMedication: nil,
                    diGaDispense: nil
                )]
            ),
            "14": ErxTask(
                identifier: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                status: .completed,
                flowType: .pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e25",
                fullUrl: nil,
                authoredOn: authoredOnNinetyTwoDaysBefore,
                expiresOn: expiresIn12DaysString,
                author: "Dr. B",
                medication: ErxMedication(
                    name: "Brausepulver 3",
                    amount: .init(numerator: .init(value: "11")),
                    dosageForm: "TAB"
                ),
                practitioner: ErxPractitioner(
                    lanr: "987654322"
                ),
                medicationDispenses: [
                    ErxMedicationDispense(
                        identifier: "098767825647892",
                        taskId: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                        insuranceId: "ABC",
                        dosageInstruction: "",
                        telematikId: "A12345678",
                        whenHandedOver: handedOverAWeekBefore!,
                        medication: ErxMedication(
                            name: "Brausepulver 3",
                            amount: .init(numerator: .init(value: "6")),
                            dosageForm: "TAB"
                        ),
                        epaMedication: nil,
                        diGaDispense: nil
                    ),
                    ErxMedicationDispense(
                        identifier: "098767825647892-2",
                        taskId: "7390f983-1e67-11b2-8555-63bf44e44f7c",
                        insuranceId: "ABC",
                        dosageInstruction: "",
                        telematikId: "A12345678",
                        whenHandedOver: handedOverAWeekBefore!,
                        medication: ErxMedication(
                            name: "Brausepulver 3",
                            amount: .init(numerator: .init(value: "5")),
                            dosageForm: "TAB"
                        ),
                        epaMedication: nil,
                        diGaDispense: nil

                    ),
                ]
            ),
        ]
    }()
}
