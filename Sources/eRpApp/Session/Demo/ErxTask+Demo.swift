//
//  Copyright (c) 2021 gematik GmbH
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
        static let medication1: ErxTask.Medication = {
            ErxTask.Medication(
                name: "Saflorblüten-Extrakt Pulver Peroral",
                pzn: "06876512",
                amount: 10,
                dosageForm: "PUL",
                dose: "N1",
                dosageInstructions: nil
            )
        }()

        static let medication2: ErxTask.Medication = {
            ErxTask.Medication(
                name: "Yucca filamentosa",
                pzn: "06876511",
                amount: 12,
                dosageForm: "FDA",
                dose: "N2",
                dosageInstructions: nil
            )
        }()

        static let medication3: ErxTask.Medication = {
            ErxTask.Medication(name: "Lebenselixir 9000",
                               pzn: "06876513",
                               amount: 1,
                               dosageForm: "ELI",
                               dose: "KTP",
                               dosageInstructions: nil)
        }()

        static let medication4: ErxTask.Medication = {
            ErxTask.Medication(name: "Zimtöl",
                               pzn: "06876514",
                               amount: 1,
                               dosageForm: "AEO",
                               dose: "KA",
                               dosageInstructions: nil)
        }()

        static let medication5: ErxTask.Medication = {
            ErxTask.Medication(name: "Gelitan Wundgel Zur äußerlichen Anwendung",
                               pzn: "06876515",
                               amount: 2,
                               dosageForm: "GEL",
                               dose: "sonstiges",
                               dosageInstructions: nil)
        }()

        static let medication6: ErxTask.Medication = {
            ErxTask.Medication(name: "Asthmazopol Inhalator Flasche",
                               pzn: "06876516",
                               amount: 5,
                               dosageForm: "INH",
                               dose: "N2",
                               dosageInstructions: nil)
        }()

        static let medication7: ErxTask.Medication = {
            ErxTask.Medication(name: "Iboprogenal 100+",
                               pzn: "06876517",
                               amount: 20,
                               dosageForm: "TAB",
                               dose: "N3",
                               dosageInstructions: nil)
        }()

        static let medication8: ErxTask.Medication = {
            ErxTask.Medication(name: "Vita-Tee",
                               pzn: "06876518",
                               amount: 8,
                               dosageForm: "INS",
                               dose: "NB",
                               dosageInstructions: nil)
        }()

        static let prescription: ErxTask = {
            prescriptions.first ?? ErxTask(identifier: "",
                                           accessCode: "")
        }()

        static let prescriptionRedeemed: ErxTask = {
            prescriptions.last ?? ErxTask(
                identifier: "",
                accessCode: ""
            )
        }()

        static let prescriptions: [ErxTask] = {
            var demoPatient = ErxTask.Patient(
                name: "Ludger Königsstein",
                address: "Musterstr. 1 \n10623 Berlin",
                birthDate: "22.6.1935",
                phone: "555 1234567",
                status: "Mitglied",
                insurance: "AOK Rheinland/Hamburg",
                insuranceIdentifier: "A123456789"
            )

            var demoPractitioner = ErxTask.Practitioner(
                lanr: "123456789",
                name: "Dr. Dr. med. Carsten van Storchhausen",
                qualification: "Allgemeinarzt/Hausarzt",
                email: "noreply@google.de",
                address: "Hinter der Bahn 2\n12345 Berlin"
            )

            var demoOrganization = ErxTask.Organization(
                identifier: "987654321",
                name: "Praxis van Storchhausen",
                phone: "555 76543321",
                email: "noreply@praxisvonstorchhausen.de",
                address: "Vor der Bahn 6\n54321 Berlin"
            )

            var demoWorkRelatedAccicdent = ErxTask.WorkRelatedAccident(
                workPlaceIdentifier: "1234567890",
                date: "9.4.2021"
            )

            return [
                ErxTask(identifier: "2390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.today),
                        expiresOn: DemoDate.createDemoDate(.tomorrow),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        noctuFeeWaiver: true,
                        substitutionAllowed: true,
                        medication: medication1,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "5390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.today),
                        expiresOn: DemoDate.createDemoDate(.thirtyOneDaysAhead),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        substitutionAllowed: true,
                        medication: medication2,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "0390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.yesterday),
                        expiresOn: DemoDate.createDemoDate(.twelveDaysAhead),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        noctuFeeWaiver: true,
                        medication: medication3,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "1390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.dayBeforeYesterday),
                        expiresOn: DemoDate.createDemoDate(.thirtyOneDaysAhead),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        medication: medication4,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "3390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
                        expiresOn: DemoDate.createDemoDate(.yesterday),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        medication: medication5,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "490f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
                        expiresOn: DemoDate.createDemoDate(.twelveDaysAhead),
                        author: "Praxis Dr. med. Karin Hasenbein",
                        noctuFeeWaiver: true,
                        medication: medication6,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "6390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.sixteenDaysBefore),
                        expiresOn: DemoDate.createDemoDate(.thirtyOneDaysAhead),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        medication: medication7,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
                ErxTask(identifier: "7390f983-1e67-11b2-8555-63bf44e44fb8",
                        accessCode: "e46ab30636811adaa210a719021701895f5787cab2c65420ffd02b3df25f6e24",
                        fullUrl: nil,
                        authoredOn: DemoDate.createDemoDate(.thirtyDaysBefore),
                        expiresOn: DemoDate.createDemoDate(.tomorrow),
                        redeemedOn: DemoDate.createDemoDate(.yesterday),
                        author: "Dr. Dr. med. Carsten van Storchhausen",
                        medication: medication8,
                        patient: demoPatient,
                        practitioner: demoPractitioner,
                        organization: demoOrganization,
                        workRelatedAccident: demoWorkRelatedAccicdent,
                        auditEvents: ErxAuditEvent.Dummies.auditEvents),
            ]
        }()
    }
}
