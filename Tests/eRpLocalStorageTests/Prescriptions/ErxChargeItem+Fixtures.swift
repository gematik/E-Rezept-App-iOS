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

extension ErxChargeItem {
    enum Fixtures {
        // non realistic chargeItem as low detail
        static let lowDetailChargeItem: ErxChargeItem = .init(
            identifier: "chargeItem_id_12",
            fhirData: "Some placeholder data".data(using: .utf8)!,
            enteredDate: "2023-03-10T10:30:04+02:00",
            medication: ErxTask.Fixtures.compoundingMedication,
            invoice: .init(
                totalAdditionalFee: 5.0,
                totalGross: 345.34,
                currency: "EUR",
                chargeableItems: [
                    DavInvoice.ChargeableItem(
                        factor: 2.0,
                        price: 5.12,
                        pzn: "pzn_123",
                        ta1: "ta1_456",
                        hmrn: "hmrn_789"
                    ),
                ]
            )
        )

        static let chargeItem1: ErxChargeItem = .init(
            identifier: "charge_id_1",
            fhirData: "fhirData1".data(using: .utf8)!,
            enteredDate: "2023-02-19T14:07:47.809+00:00"
        )

        static let chargeItem2: ErxChargeItem = .init(
            identifier: "charge_id_2",
            fhirData: "fhirData2".data(using: .utf8)!,
            enteredDate: "2023-02-23T14:07:47.809+00:00"
        )

        static let chargeItem3: ErxChargeItem = .init(
            identifier: "charge_id_3",
            fhirData: "fhirData3".data(using: .utf8)!,
            enteredDate: "2023-02-17T14:07:47.809+00:00"
        )

        static let chargeItemWithFHIRData: ErxChargeItem = .init(
            identifier: "chargeItem_id_12",
            fhirData: chargeItemAsFHIRData,
            enteredDate: "2023-02-17T14:07:46.964+00:00",
            medication: ErxMedication(
                name: "Schmerzmittel",
                drugCategory: .avm,
                pzn: "17091124",
                amount: ErxMedication.Ratio(
                    numerator: ErxMedication.Quantity(
                        value: "1",
                        unit: "Stk"
                    ),
                    denominator: ErxMedication.Quantity(value: "1")
                ),
                dosageForm: "TAB",
                dose: "NB"
            ),
            medicationRequest: .init(
                dosageInstructions: "1-0-0-0",
                substitutionAllowed: true,
                hasEmergencyServiceFee: false,
                bvg: false,
                coPaymentStatus: .subjectToCharge,
                multiplePrescription: .init(mark: false)
            ),
            patient: .init(
                name: "Günther Angermänn",
                address: "Weiherstr. 74a\n67411 Büttnerdorf",
                birthDate: "1976-04-30",
                status: "1",
                insurance: "Künstler-Krankenkasse Baden-Württemberg",
                insuranceId: "X110465770"
            ),
            practitioner: ErxPractitioner(
                lanr: "443236256",
                name: "Dr. Schraßer",
                qualification: "Super-Facharzt für alles Mögliche"
            ),
            organization: ErxOrganization(
                identifier: "734374849",
                name: "Arztpraxis Schraßer",
                phone: "(05808) 9632619",
                email: "andre.teufel@xn--schffer-7wa.name",
                address: "Halligstr. 98\n85005, Alt Mateo"
            ),
            pharmacy: .init(
                identifier: "012876",
                name: "Pharmacy Name",
                address: "Pharmacy Street 2\n13267, Berlin",
                country: "DE"
            ),
            invoice: .init(
                totalAdditionalFee: 5.0,
                totalGross: 345.34,
                currency: "EUR",
                chargeableItems: [
                    DavInvoice.ChargeableItem(
                        factor: 2.0,
                        price: 5.12,
                        pzn: "pzn_123",
                        ta1: "ta1_456",
                        hmrn: "hmrn_789"
                    ),
                ]
            ),
            medicationDispense: .init(
                identifier: "e00e96a2-6dae-4036-8e72-42b5c21fdbf3",
                whenHandedOver: "2023-02-17"
            ),
            prescriptionSignature: .init(
                when: "2023-02-17T14:07:47.806+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "vDAo+tog=="
            ),
            receiptSignature: .init(
                when: "2023-02-17T14:07:47.808+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "Mb3ej1h4E="
            ),
            dispenseSignature: .init(
                when: "2023-02-17T14:07:47.809+00:00",
                sigFormat: "application/pkcs7-mime",
                data: "aOEsSfDw=="
            )
        )

        static let chargeItemAsFHIRData: Data = // swiftlint:disable:next line_length
            "{\"resourceType\":\"Bundle\",\"id\":\"658d213d-523b-4a24-bbdb-f237611ead2d\",\"type\":\"collection\",\"timestamp\":\"2023-02-17T14:07:47.710+00:00\",\"entry\":[{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/ChargeItem/chargeItem_id_12\",\"resource\":{\"resourceType\":\"ChargeItem\",\"id\":\"chargeItem_id_12\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erpchrg/StructureDefinition/GEM_ERPCHRG_PR_ChargeItem|1.0\"]},\"identifier\":[{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_AccessCode\",\"value\":\"feaf93c400be820a1981250a29d529e3de9a5a3054049d58f133ea13e00d36b0\"}],\"status\":\"billable\",\"code\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/data-absent-reason\",\"code\":\"not-applicable\"}]},\"subject\":{\"identifier\":{\"system\":\"http://fhir.de/sid/pkv/kvid-10\",\"value\":\"A123456789\"}},\"enterer\":{\"identifier\":{\"system\":\"https://gematik.de/fhir/sid/telematik-id\",\"value\":\"3-SMC-B-Testkarte-883110000116873\"}},\"enteredDate\":\"2023-02-17T14:07:46.964+00:00\",\"supportingInformation\":[{\"reference\":\"Bundle/775157da-afc8-4248-b90b-a32163895323\",\"display\":\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle\"},{\"reference\":\"Bundle/a2442313-18da-4051-b355-42a47d9f823a\",\"display\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle\"},{\"reference\":\"Bundle/c8d36312-0000-0000-0003-000000000000\",\"display\":\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle\"}]}},{\"fullUrl\":\"urn:uuid:a2442313-18da-4051-b355-42a47d9f823a\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"a2442313-18da-4051-b355-42a47d9f823a\",\"meta\":{\"lastUpdated\":\"2023-02-17T15:07:45.077+01:00\",\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenBundle|1.1\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T15:07:45.077+01:00\",\"entry\":[{\"fullUrl\":\"urn:uuid:f67f6885-c527-4198-a44a-d5bef2fda5b9\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"f67f6885-c527-4198-a44a-d5bef2fda5b9\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-AbgabedatenComposition|1.1\"]},\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-CompositionTypes\",\"code\":\"ERezeptAbgabedaten\"}]},\"date\":\"2023-02-17T15:07:45+01:00\",\"author\":[{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}],\"title\":\"ERezeptAbgabedaten\",\"section\":[{\"title\":\"Apotheke\",\"entry\":[{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}]},{\"title\":\"Abgabeinformationen\",\"entry\":[{\"reference\":\"urn:uuid:e00e96a2-6dae-4036-8e72-42b5c21fdbf3\"}]}]}},{\"fullUrl\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\",\"resource\":{\"resourceType\":\"Organization\",\"id\":\"623e785c-0f6d-4db9-8488-9809b8493537\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Apotheke|1.1\"]},\"identifier\":[{\"system\":\"http://fhir.de/sid/arge-ik/iknr\",\"value\":\"012876\"}],\"name\":\"Pharmacy Name\",\"address\":[{\"type\":\"physical\",\"line\":[\"Pharmacy Street 2\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"2\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Pharmacy Street\"}]}],\"city\":\"Berlin\",\"postalCode\":\"13267\",\"country\":\"DE\"}]}},{\"fullUrl\":\"urn:uuid:39618663-4b23-43de-ab1d-db25b2d85130\",\"resource\":{\"resourceType\":\"Invoice\",\"id\":\"39618663-4b23-43de-ab1d-db25b2d85130\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Abrechnungszeilen|1.1\"]},\"status\":\"issued\",\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-InvoiceTyp\",\"code\":\"Abrechnungszeilen\"}]},\"lineItem\":[{\"sequence\":1,\"chargeItemCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/ifa/pzn\",\"code\":\"pzn_123\"},{\"system\":\"http://TA1.abda.de\",\"code\":\"ta1_456\"},{\"system\":\"http://fhir.de/sid/gkv/hmnr\",\"code\":\"hmrn_789\"}]},\"priceComponent\":[{\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-KostenVersicherter\",\"extension\":[{\"url\":\"Kategorie\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-PKV-CS-ERP-KostenVersicherterKategorie\",\"code\":\"0\"}]}},{\"url\":\"Kostenbetrag\",\"valueMoney\":{\"value\":5.12,\"currency\":\"EUR\"}}]},{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-MwStSatz\",\"valueDecimal\":5}],\"type\":\"informational\",\"factor\":2,\"amount\":{\"value\":5.12,\"currency\":\"EUR\"}}]}],\"totalGross\":{\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Gesamtzuzahlung\",\"valueMoney\":{\"value\":5,\"currency\":\"EUR\"}}],\"value\":345.34,\"currency\":\"EUR\"}}},{\"fullUrl\":\"urn:uuid:e00e96a2-6dae-4036-8e72-42b5c21fdbf3\",\"resource\":{\"resourceType\":\"MedicationDispense\",\"id\":\"e00e96a2-6dae-4036-8e72-42b5c21fdbf3\",\"meta\":{\"profile\":[\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-PR-ERP-Abgabeinformationen|1.1\"]},\"extension\":[{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-PKV-EX-ERP-AbrechnungsTyp\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-PKV-CS-ERP-AbrechnungsTyp\",\"code\":\"1\"}]}},{\"url\":\"http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Abrechnungszeilen\",\"valueReference\":{\"reference\":\"urn:uuid:39618663-4b23-43de-ab1d-db25b2d85130\"}}],\"status\":\"completed\",\"medicationCodeableConcept\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/data-absent-reason\",\"code\":\"not-applicable\"}]},\"performer\":[{\"actor\":{\"reference\":\"urn:uuid:623e785c-0f6d-4db9-8488-9809b8493537\"}}],\"authorizingPrescription\":[{\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"}}],\"type\":{\"coding\":[{\"system\":\"http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-MedicationDispenseTyp\",\"code\":\"Abgabeinformationen\"}]},\"whenHandedOver\":\"2023-02-17\"}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.809+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"aOEsSfDw==\"}}},{\"fullUrl\":\"urn:uuid:775157da-afc8-4248-b90b-a32163895323\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"775157da-afc8-4248-b90b-a32163895323\",\"meta\":{\"lastUpdated\":\"2023-02-17T15:07:40.162+01:00\",\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Bundle|1.1.0\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T15:07:40.162+01:00\",\"entry\":[{\"fullUrl\":\"https://pvs.gematik.de/fhir/Composition/25ecd923-1d58-4e74-a0b8-dde43bb06b5e\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"25ecd923-1d58-4e74-a0b8-dde43bb06b5e\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Composition|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_PKV_Tariff\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_PKV_TARIFF\",\"code\":\"03\"}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_Legal_basis\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_STATUSKENNZEICHEN\",\"code\":\"00\"}}],\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_FORMULAR_ART\",\"code\":\"e16A\"}]},\"subject\":{\"reference\":\"Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\"},\"date\":\"2023-02-17T15:07:40+01:00\",\"author\":[{\"reference\":\"Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"type\":\"Practitioner\"},{\"type\":\"Device\",\"identifier\":{\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_FOR_Pruefnummer\",\"value\":\"GEMATIK/410/2109/36/123\"}}],\"title\":\"elektronische Arzneimittelverordnung\",\"custodian\":{\"reference\":\"Organization/4e118502-4ed8-45f5-9c79-9a64eaab88f6\"},\"section\":[{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Section_Type\",\"code\":\"Coverage\"}]},\"entry\":[{\"reference\":\"Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\"}]},{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Section_Type\",\"code\":\"Prescription\"}]},\"entry\":[{\"reference\":\"MedicationRequest/28744ee3-ff3a-4793-9036-c11d6b4b105f\"}]}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/MedicationRequest/28744ee3-ff3a-4793-9036-c11d6b4b105f\",\"resource\":{\"resourceType\":\"MedicationRequest\",\"id\":\"28744ee3-ff3a-4793-9036-c11d6b4b105f\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Prescription|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_BVG\",\"valueBoolean\":false},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_EmergencyServicesFee\",\"valueBoolean\":false},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Multiple_Prescription\",\"extension\":[{\"url\":\"Kennzeichen\",\"valueBoolean\":false}]},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_FOR_StatusCoPayment\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_StatusCoPayment\",\"code\":\"0\"}}],\"status\":\"active\",\"intent\":\"order\",\"medicationReference\":{\"reference\":\"Medication/368dadee-d6d9-425b-afbd-93ccbf109ad8\"},\"subject\":{\"reference\":\"Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\"},\"authoredOn\":\"2023-02-17\",\"requester\":{\"reference\":\"Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\"},\"insurance\":[{\"reference\":\"Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\"}],\"dosageInstruction\":[{\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_DosageFlag\",\"valueBoolean\":true}],\"text\":\"1-0-0-0\"}],\"dispenseRequest\":{\"quantity\":{\"value\":1,\"system\":\"http://unitsofmeasure.org\",\"code\":\"{Package}\"}},\"substitution\":{\"allowedBoolean\":true}}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Medication/368dadee-d6d9-425b-afbd-93ccbf109ad8\",\"resource\":{\"resourceType\":\"Medication\",\"id\":\"368dadee-d6d9-425b-afbd-93ccbf109ad8\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_ERP_Medication_PZN|1.1.0\"]},\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_Base_Medication_Type\",\"valueCodeableConcept\":{\"coding\":[{\"system\":\"http://snomed.info/sct\",\"version\":\"http://snomed.info/sct/900000000000207008/version/20220331\",\"code\":\"763158003\",\"display\":\"Medicinal product (product)\"}]}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Category\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_ERP_Medication_Category\",\"code\":\"00\"}},{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_Vaccine\",\"valueBoolean\":false},{\"url\":\"http://fhir.de/StructureDefinition/normgroesse\",\"valueCode\":\"NB\"}],\"code\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/ifa/pzn\",\"code\":\"17091124\"}],\"text\":\"Schmerzmittel\"},\"form\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DARREICHUNGSFORM\",\"code\":\"TAB\"}]},\"amount\":{\"numerator\":{\"extension\":[{\"url\":\"https://fhir.kbv.de/StructureDefinition/KBV_EX_ERP_Medication_PackagingSize\",\"valueString\":\"1\"}],\"unit\":\"Stk\"},\"denominator\":{\"value\":1}}}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Patient/0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\",\"resource\":{\"resourceType\":\"Patient\",\"id\":\"0e69e4e7-f2c5-4bd6-bf25-5af4e715c472\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Patient|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/identifier-type-de-basis\",\"code\":\"PKV\"}]},\"system\":\"http://fhir.de/sid/pkv/kvid-10\",\"value\":\"X110465770\"}],\"name\":[{\"use\":\"official\",\"family\":\"Angermänn\",\"_family\":{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/humanname-own-name\",\"valueString\":\"Angermänn\"}]},\"given\":[\"Günther\"]}],\"birthDate\":\"1976-04-30\",\"address\":[{\"type\":\"both\",\"line\":[\"Weiherstr. 74a\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"74a\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Weiherstr.\"}]}],\"city\":\"Büttnerdorf\",\"postalCode\":\"67411\",\"country\":\"D\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Organization/4e118502-4ed8-45f5-9c79-9a64eaab88f6\",\"resource\":{\"resourceType\":\"Organization\",\"id\":\"4e118502-4ed8-45f5-9c79-9a64eaab88f6\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Organization|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/v2-0203\",\"code\":\"BSNR\"}]},\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_Base_BSNR\",\"value\":\"734374849\"}],\"name\":\"Arztpraxis Schraßer\",\"telecom\":[{\"system\":\"phone\",\"value\":\"(05808) 9632619\"},{\"system\":\"email\",\"value\":\"andre.teufel@xn--schffer-7wa.name\"}],\"address\":[{\"type\":\"both\",\"line\":[\"Halligstr. 98\"],\"_line\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber\",\"valueString\":\"98\"},{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName\",\"valueString\":\"Halligstr.\"}]}],\"city\":\"Alt Mateo\",\"postalCode\":\"85005\",\"country\":\"D\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Coverage/06f31815-aea8-490a-8c0b-b3123b1600cf\",\"resource\":{\"resourceType\":\"Coverage\",\"id\":\"06f31815-aea8-490a-8c0b-b3123b1600cf\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Coverage|1.1.0\"]},\"extension\":[{\"url\":\"http://fhir.de/StructureDefinition/gkv/besondere-personengruppe\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_PERSONENGRUPPE\",\"code\":\"00\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/dmp-kennzeichen\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_DMP\",\"code\":\"00\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/wop\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_ITA_WOP\",\"code\":\"71\"}},{\"url\":\"http://fhir.de/StructureDefinition/gkv/versichertenart\",\"valueCoding\":{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_KBV_VERSICHERTENSTATUS\",\"code\":\"1\"}}],\"status\":\"active\",\"type\":{\"coding\":[{\"system\":\"http://fhir.de/CodeSystem/versicherungsart-de-basis\",\"code\":\"PKV\"}]},\"beneficiary\":{\"reference\":\"Patient/53d4475b-bff0-470a-89a4-1811c832ee06\"},\"payor\":[{\"identifier\":{\"system\":\"http://fhir.de/sid/arge-ik/iknr\",\"value\":\"100843242\"},\"display\":\"Künstler-Krankenkasse Baden-Württemberg\"}]}},{\"fullUrl\":\"https://pvs.gematik.de/fhir/Practitioner/d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"resource\":{\"resourceType\":\"Practitioner\",\"id\":\"d31cee47-e0e8-4bd6-82f3-e70daecd4b7b\",\"meta\":{\"profile\":[\"https://fhir.kbv.de/StructureDefinition/KBV_PR_FOR_Practitioner|1.1.0\"]},\"identifier\":[{\"type\":{\"coding\":[{\"system\":\"http://terminology.hl7.org/CodeSystem/v2-0203\",\"code\":\"LANR\"}]},\"system\":\"https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR\",\"value\":\"443236256\"}],\"name\":[{\"use\":\"official\",\"family\":\"Schraßer\",\"_family\":{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/humanname-own-name\",\"valueString\":\"Schraßer\"}]},\"given\":[\"Dr.\"],\"prefix\":[\"Dr.\"],\"_prefix\":[{\"extension\":[{\"url\":\"http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier\",\"valueCode\":\"AC\"}]}]}],\"qualification\":[{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_Qualification_Type\",\"code\":\"00\"}]}},{\"code\":{\"coding\":[{\"system\":\"https://fhir.kbv.de/CodeSystem/KBV_CS_FOR_Berufsbezeichnung\",\"code\":\"Berufsbezeichnung\"}],\"text\":\"Super-Facharzt für alles Mögliche\"}}]}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.806+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"vDAo+tog==\"}}},{\"fullUrl\":\"urn:uuid:c8d36312-0000-0000-0003-000000000000\",\"resource\":{\"resourceType\":\"Bundle\",\"id\":\"c8d36312-0000-0000-0003-000000000000\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Bundle|1.2\"]},\"identifier\":{\"system\":\"https://gematik.de/fhir/erp/NamingSystem/GEM_ERP_NS_PrescriptionId\",\"value\":\"chargeItem_id_12\"},\"type\":\"document\",\"timestamp\":\"2023-02-17T14:07:43.665+00:00\",\"link\":[{\"relation\":\"self\",\"url\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Task/chargeItem_id_12/$close/\"}],\"entry\":[{\"fullUrl\":\"urn:uuid:0cf976ed-8a4c-4078-bc3b-e935f06b4362\",\"resource\":{\"resourceType\":\"Composition\",\"id\":\"0cf976ed-8a4c-4078-bc3b-e935f06b4362\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Composition|1.2\"]},\"extension\":[{\"url\":\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_Beneficiary\",\"valueIdentifier\":{\"system\":\"https://gematik.de/fhir/sid/telematik-id\",\"value\":\"3-SMC-B-Testkarte-883110000116873\"}}],\"status\":\"final\",\"type\":{\"coding\":[{\"system\":\"https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_DocumentType\",\"code\":\"3\",\"display\":\"Receipt\"}]},\"date\":\"2023-02-17T14:07:43.664+00:00\",\"author\":[{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"}],\"title\":\"Quittung\",\"event\":[{\"period\":{\"start\":\"2023-02-17T14:07:42.401+00:00\",\"end\":\"2023-02-17T14:07:43.664+00:00\"}}],\"section\":[{\"entry\":[{\"reference\":\"Binary/PrescriptionDigest-chargeItem_id_12\"}]}]}},{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\",\"resource\":{\"resourceType\":\"Device\",\"id\":\"1\",\"meta\":{\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Device|1.2\"]},\"status\":\"active\",\"serialNumber\":\"1.9.0\",\"deviceName\":[{\"name\":\"E-Rezept Fachdienst\",\"type\":\"user-friendly-name\"}],\"version\":[{\"value\":\"1.9.0\"}],\"contact\":[{\"system\":\"email\",\"value\":\"betrieb@gematik.de\"}]}},{\"fullUrl\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Binary/PrescriptionDigest-chargeItem_id_12\",\"resource\":{\"resourceType\":\"Binary\",\"id\":\"PrescriptionDigest-chargeItem_id_12\",\"meta\":{\"versionId\":\"1\",\"profile\":[\"https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Digest|1.2\"]},\"contentType\":\"application/octet-stream\",\"data\":\"ZQsm4k/OW69rLio6As1LfoTGrAEnvqNUzKBKbQRJbb4=\"}}],\"signature\":{\"type\":[{\"system\":\"urn:iso-astm:E1762-95:2013\",\"code\":\"1.2.840.10065.1.12.1.1\"}],\"when\":\"2023-02-17T14:07:47.808+00:00\",\"who\":{\"reference\":\"https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Device/1\"},\"sigFormat\":\"application/pkcs7-mime\",\"data\":\"Mb3ej1h4E=\"}}}]}"
            .data(using: .utf8)!
    }
}
