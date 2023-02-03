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
        static var demoPatientLudger = ErxTask.Patient(
            name: "Ludger Königsstein",
            address: "Musterstr. 1 \n10623 Berlin",
            birthDate: "22.6.1935",
            phone: "555 1234567",
            status: "Mitglied",
            insurance: "AOK Rheinland/Hamburg",
            insuranceId: "A123456789"
        )

        static var demoPatientAnna = ErxTask.Patient(
            name: "Anna Vetter",
            address: "Benzelratherstr. 29 \nFrechen",
            birthDate: "12.12.1933",
            phone: "0221 1234567",
            status: "Mitglied",
            insurance: "Elektriker Krankenkasse",
            insuranceId: "A234567890"
        )

        static var demoPractitionerStorchhausen = ErxTask.Practitioner(
            lanr: "123456789",
            name: "Dr. Dr. med. Carsten van Storchhausen",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Hinter der Bahn 2\n12345 Berlin"
        )

        static var demoOrganizationStorchhausen = ErxTask.Organization(
            identifier: "987654321",
            name: "Praxis van Storchhausen",
            phone: "555 76543321",
            email: "noreply@praxisvonstorchhausen.de",
            address: "Vor der Bahn 6\n54321 Berlin"
        )

        static var demoPractitionerTodgluecklich = ErxTask.Practitioner(
            lanr: "234567891",
            name: "Dr. Dr. med. Hans Todglücklich",
            qualification: "Allgemeinarzt/Hausarzt",
            email: "noreply@google.de",
            address: "Am Friedhof 2\n12345 Berlin"
        )

        static var demoOrganizationTodgluecklich = ErxTask.Organization(
            identifier: "3456789012",
            name: "Praxis Todglücklich",
            phone: "030 123123123",
            email: "noreply@praxistodgluecklich.de",
            address: "Am Friedhof 2\n54321 Berlin"
        )

        static var demoWorkRelatedAccident = ErxTask.WorkRelatedAccident(
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
            status: ErxTask.Status = .ready,
            authoredOn: String = FHIRDateFormatter.shared.stringWithLongUTCTimeZone(from: Date()),
            practitioner: Practitioner = demoPractitionerStorchhausen,
            patient: Patient = demoPatientAnna,
            organisation: Organization = demoOrganizationStorchhausen,
            medication _: ErxTask.Medication = ErxTask.Medication.Dummies.medication1,
            medicationDispenses: [ErxTask.MedicationDispense] = []
        ) -> ErxTask {
            ErxTask(
                identifier: id,
                status: status,
                flowType: ErxTask.FlowType.pharmacyOnly,
                accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                fullUrl: "some/full/url",
                authoredOn: authoredOn,
                lastModified: "2021-03-10T10:55:04+02:00",
                expiresOn: "2021-09-10T10:55:04+02:00",
                acceptedUntil: "2021-06-10T10:55:04+02:00",
                redeemedOn: nil,
                author: practitioner.name,
                dispenseValidityEnd: "2021-06-10T10:55:04+02:00",
                noctuFeeWaiver: true,
                prescriptionId: id,
                substitutionAllowed: !medicationDispenses.isEmpty,
                source: .server,
                medication: ErxTask.Medication.Dummies.medication1,
                patient: patient,
                practitioner: practitioner,
                organization: organisation,
                workRelatedAccident: demoWorkRelatedAccident,
                auditEvents: auditEvents(for: id),
                communications: [ErxTask.Communication.Dummies.communication(
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
                flowType: ErxTask.FlowType(rawValue: String(id.prefix(3))),
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

extension ErxTask.Medication {
    enum Dummies {
        static let medication1: ErxTask.Medication = {
            ErxTask.Medication(
                name: "Saflorblüten-Extrakt Pulver Peroral",
                pzn: "06876512",
                amount: 10,
                dosageForm: "PUL",
                dose: "N1",
                dosageInstructions: nil,
                lot: nil,
                expiresOn: nil
            )
        }()

        static let medication2: ErxTask.Medication = {
            ErxTask.Medication(
                name: "Yucca filamentosa",
                pzn: "06876511",
                amount: 12,
                dosageForm: "FDA",
                dose: "N2",
                dosageInstructions: nil,
                lot: nil,
                expiresOn: nil
            )
        }()

        static let medication3: ErxTask.Medication = {
            ErxTask.Medication(
                name: "Lebenselixir 9000",
                pzn: "06876513",
                amount: 1,
                dosageForm: "ELI",
                dose: "KTP",
                dosageInstructions: nil,
                lot: nil,
                expiresOn: nil
            )
        }()
    }
}

extension ErxTask.MedicationDispense {
    enum Dummies {
        static func medicationDispense(for taskId: String, insuranceId: String) -> ErxTask.MedicationDispense {
            ErxTask.MedicationDispense(
                identifier: "4567890123",
                taskId: taskId,
                insuranceId: insuranceId,
                pzn: "06876513",
                name: "Lebenselixir 9000",
                dose: "N2",
                dosageForm: "TAB",
                dosageInstruction: "Not too much",
                amount: 2.0,
                telematikId: "12345678",
                whenHandedOver: "2021-07-20T10:55:04+02:00",
                lot: nil,
                expiresOn: nil
            )
        }
    }
}
