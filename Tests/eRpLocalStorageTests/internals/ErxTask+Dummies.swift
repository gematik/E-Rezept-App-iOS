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

import eRpKit
import Foundation

extension ErxTask {
    enum Dummies {
        static var demoPatientLudger = ErxPatient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789"
        )

        static var demoPatientAnna = ErxPatient(
            name: "Anna Vetter",
            address: "Benzelratherstr. 29 \nFrechen",
            birthDate: "12.12.1933",
            phone: "0221 1234567",
            status: "Mitglied",
            insurance: "Elektriker Krankenkasse",
            insuranceId: "A234567890"
        )

        static var demoPractitionerStorchhausen = ErxPractitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )

        static var demoOrganizationStorchhausen = ErxOrganization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )

        static var demoPractitionerTodgluecklich = ErxPractitioner(
            lanr: "234567891",
            name: "Dr. Dr. med. Hans Todglücklich",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Am Friedhof 2\n12345 Berlin"
        )

        static var demoOrganizationTodgluecklich = ErxOrganization(
            identifier: "3456789012",
            name: "Praxis Todglücklich",
            phone: "030 123123123",
            email: "noreply@praxistodgluecklich.de",
            address: "Am Friedhof 2\n54321 Berlin"
        )

        static var demoAccidentInfo = AccidentInfo(
            type: nil,
            workPlaceIdentifier: "1234567890",
            date: "9.4.2021"
        )

        static func auditEvents(for taskId: String) -> [ErxAuditEvent] {
            [
                ErxAuditEvent(identifier: taskId + "1",
                              locale: "de",
                              text: """
                              Das Rezept wurde gelöscht, und dieser Audit-Event ist \
                              extra sehr lang und sehr ausführlich geschrieben, \
                              um zu schauen, ob er trotzdem richtig angezeigt wird.
                              """,
                              timestamp: "2021-05-01T14:22:15.444555666+00:00",
                              taskId: taskId),
                ErxAuditEvent(identifier: taskId + "2",
                              locale: "fr",
                              text: "Cette recette a déjà été utilisée.",
                              timestamp: "2021-04-11T12:45:34.123473321+00:00",
                              taskId: taskId),
                ErxAuditEvent(identifier: taskId + "3",
                              locale: "en",
                              text: "Read operation was performed.",
                              timestamp: "2021-04-07T09:05:45.382873913+00:00",
                              taskId: taskId),
            ]
        }

        static func erxTask(
            id: String,
            status: Status = .ready,
            authoredOn: String = FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: Date()),
            practitioner: ErxPractitioner = demoPractitionerStorchhausen,
            patient: ErxPatient = demoPatientAnna,
            organisation: ErxOrganization = demoOrganizationStorchhausen,
            medication _: ErxMedication = ErxMedication.Dummies.medication1,
            medicationDispenses: [ErxMedicationDispense] = []
        ) -> ErxTask {
            ErxTask(
                identifier: id,
                status: status,
                flowType: FlowType.pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: "some/full/url",
                authoredOn: authoredOn,
                lastModified: "2021-03-10T10:55:04+02:00",
                expiresOn: "2021-09-10T10:55:04+02:00",
                acceptedUntil: "2021-06-10T10:55:04+02:00",
                redeemedOn: nil,
                author: practitioner.name,
                prescriptionId: id,
                source: .server,
                medication: ErxMedication.Dummies.medication1,
                medicationRequest: .init(
                    substitutionAllowed: !medicationDispenses.isEmpty,
                    hasEmergencyServiceFee: true,
                    dispenseValidityEnd: "2021-06-10T10:55:04+02:00",
                    accidentInfo: demoAccidentInfo
                ),
                patient: patient,
                practitioner: practitioner,
                organization: organisation,
                communications: [Communication.Dummies.communication(
                    for: id,
                    insuranceId: patient.insuranceId!
                )],
                medicationDispenses: medicationDispenses
            )
        }

        static func scannedTask(id: String,
                                authoredOn: String = FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: Date()),
                                accessCode: String) -> ErxTask {
            ErxTask(
                identifier: id,
                status: .ready,
                flowType: FlowType(rawValue: String(id.prefix(3))),
                accessCode: accessCode,
                authoredOn: authoredOn,
                author: NSLocalizedString("scn_txt_author", comment: ""),
                source: .scanner
            )
        }
    }
}

extension ErxTask.Communication {
    enum Dummies {
        // swiftlint:disable line_length
        static func communication(for taskId: String,
                                  insuranceId: String) -> ErxTask.Communication {
            let payloadJSON =
                "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
            return ErxTask.Communication(
                identifier: taskId,
                profile: .reply,
                taskId: taskId,
                userId: insuranceId,
                telematikId: "TelematikId_1",
                timestamp: "2021-07-10T10:55:04+02:00",
                payloadJSON: payloadJSON
            )
        }
    }
}

extension ErxMedication {
    enum Dummies {
        static let medication1: ErxMedication = {
            ErxMedication(
                name: "Saflorblüten-Extrakt Pulver Peroral",
                pzn: "06876512",
                amount: .init(numerator: .init(value: "10")),
                dosageForm: "PUL",
                normSizeCode: "N1",
                packaging: nil
            )
        }()

        static let medication2: ErxMedication = {
            ErxMedication(
                name: "Yucca filamentosa",
                pzn: "06876511",
                amount: .init(numerator: .init(value: "12")),
                dosageForm: "FDA",
                normSizeCode: "N2",
                packaging: nil
            )
        }()

        static let medication3: ErxMedication = {
            ErxMedication(
                name: "Lebenselixir 9000",
                pzn: "06876513",
                amount: .init(numerator: .init(value: "1")),
                dosageForm: "ELI",
                normSizeCode: "KTP",
                packaging: nil
            )
        }()
    }
}

extension ErxMedicationDispense {
    enum Dummies {
        static func medicationDispense(for taskId: String, insuranceId: String) -> ErxMedicationDispense {
            ErxMedicationDispense(
                identifier: "4567890123",
                taskId: taskId,
                insuranceId: insuranceId,
                dosageInstruction: "1-0-1",
                telematikId: "12345678",
                whenHandedOver: "2021-07-20T10:55:04+02:00",
                quantity: .init(value: "17", unit: "St."),
                noteText: "take good care",
                medication: ErxMedication.Dummies.medication1
            )
        }
    }
}
