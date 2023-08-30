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

import BundleKit
import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import SwiftUI
import XCTest

// FHIRBundle tests with
// - workflow bundle version: 1.2.0 and
// - prescription (KBV) bundle version 1.1.0
final class FHIR_GEM_Workflow_v1_2_with_KBV_v1_1_0_Tests: XCTestCase {
    /// FHIRBundle test of workflow version 1.2.0 without prescription bundle
    func testParseErxTaskWithoutPrescriptionBundle() throws {
        let gemFhirBundle = try decode(resource: "Task-607255ed-ce41-47fc-aad3-cfce1c39963f.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "607255ed-ce41-47fc-aad3-cfce1c39963f") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }

        expect(task.id) == "607255ed-ce41-47fc-aad3-cfce1c39963f"
        expect(task.status) == ErxTask.Status.error(.missingPatientReceiptBundle)
        expect(task.flowType) == .pharmacyOnly
        expect(task.fullUrl).to(beNil())
        expect(task.accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        expect(task.authoredOn) == "2022-03-18T15:26:00+00:00"
        expect(task.lastModified) == "2022-03-18T15:27:00+00:00"
        expect(task.expiresOn) == "2022-06-02"
        expect(task.acceptedUntil) == "2022-04-02"
    }

    /// FHIRBundle test of workflow version 1.2.0 with prescription version 1.1.0
    func testParseErxTaskWithPrescriptionBundle() throws {
        let gemFhirBundle = try decode(resource: "Task-with_kbv_09330307-16ce-4cdc-810a-ca24ef80dde3.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "09330307-16ce-4cdc-810a-ca24ef80dde3") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }
        // task
        expect(task.id) == "09330307-16ce-4cdc-810a-ca24ef80dde3"
        expect(task.status) == ErxTask.Status.completed
        expect(task.flowType) == .pharmacyOnly
        expect(task.source) == .server
        expect(task.fullUrl).to(beNil())
        expect(task.accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        expect(task.authoredOn) == "2022-03-18T15:26:00+00:00"
        expect(task.lastModified) == "2022-03-18T15:29:00+00:00"
        expect(task.expiresOn) == "2022-06-02"
        expect(task.acceptedUntil) == "2022-04-02"
        expect(task.author) == "MVZ"
        // medication
        expect(task.medication?.name) == "L-Thyroxin Henning 75 100 Tbl. N3"
        expect(task.medication?.dosageForm) == "TAB"
        expect(task.medication?.normSizeCode) == "N3"
        expect(task.medication?.pzn) == "02532741"
        expect(task.medication?.amount).to(beNil())
        // medication request
        expect(task.medicationRequest.dosageInstructions?.isEmpty) == true
        expect(task.medicationRequest.hasEmergencyServiceFee) == true
        expect(task.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(task.medicationRequest.substitutionAllowed) == false
        expect(task.medicationRequest.coPaymentStatus) == .artificialInsemination
        expect(task.medicationRequest.bvg) == true
        expect(task.medicationRequest.multiplePrescription?.mark) == true
        expect(task.medicationRequest.multiplePrescription?.numbering) == 4
        expect(task.medicationRequest.multiplePrescription?.totalNumber) == 4
        expect(task.medicationRequest.multiplePrescription?.startPeriod) == "2022-12-01"
        expect(task.medicationRequest.multiplePrescription?.endPeriod) == "2023-03-31"
        expect(task.medicationRequest.accidentInfo) == AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "Arbeitsplatz",
            date: "2021-04-01"
        )
        // patient
        expect(task.patient?.name) == "Prof. Dr. Dr. med Eva Kluge"
        expect(task.patient?.address) == "Pflasterhofweg 111B\n50999 Köln"
        expect(task.patient?.birthDate) == "1982-01-03"
        expect(task.patient?.phone).to(beNil())
        expect(task.patient?.status) == "3"
        expect(task.patient?.insurance) == "Techniker Krankenkasse"
        expect(task.patient?.insuranceId) == "K030182229"
        // practitioner
        expect(task.practitioner?.lanr) == "987654423"
        expect(task.practitioner?.name) == "Prof. Dr. med. Emma Schneider"
        expect(task.practitioner?.qualification) == "Fachärztin für Innere Medizin"
        expect(task.practitioner?.email).to(beNil())
        expect(task.practitioner?.address).to(beNil())
        // organization
        expect(task.organization?.name) == "MVZ"
        expect(task.organization?.phone) == "0301234567"
        expect(task.organization?.address) == "Herbert-Lewin-Platz 2\n10623, Berlin"
        expect(task.organization?.email) == "mvz@e-mail.de"
        expect(task.organization?.identifier) == "721111100"
    }

    /// FHIRBundle test of workflow version 1.2.0
    func testParseAuditEventsFromSamplePayload() throws {
        let gemFhirBundle = try decode(resource: "AuditEvent-9361863d-fec0-4ba9-8776-7905cf1b0cfa.json")

        let auditEvents = try gemFhirBundle.parseErxAuditEvents()

        expect(auditEvents.count) == 1

        expect(auditEvents[0].identifier) == "9361863d-fec0-4ba9-8776-7905cf1b0cfa"
        expect(auditEvents[0].timestamp) == "2022-04-27T08:04:27.434+00:00"
        expect(auditEvents[0].taskId) == "160.123.456.789.123.58"
        expect(auditEvents[0].text) ==
            "Praxis Dr. Müller, Bahnhofstr. 78 hat ein E-Rezept 160.123.456.789.123.58 eingestellt\n"
        expect(auditEvents[0].title).to(beNil())
        expect(auditEvents[0].locale) == "de"
    }

    /// FHIRBundle test of workflow version 1.2.0
    func testParseErxTaskCommunicationReply() throws {
        let communicationBundle = try decode(resource: "CommunicationReply-7977a4ab-97a9-4d95-afb3-6c4c1e2ac596.json")

        let communications = try communicationBundle.parseErxTaskCommunications()
        expect(communications.count) == 1
        guard let first = communications.first else {
            fail("expected to have this communication")
            return
        }
        expect(first.identifier) == "7977a4ab-97a9-4d95-afb3-6c4c1e2ac596"
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.profile) == .reply
        expect(first.timestamp) == "2020-04-29T13:46:30.128+02:00"
        expect(first.insuranceId) == "X234567890"
        expect(first.telematikId) == "3-SMC-B-Testkarte-883110000123465"

        expect(first.payloadJSON) == "Eisern"
    }

    /// FHIRBundle test of workflow version 1.2.0
    func testParseErxTaskCommunicationDispReq() throws {
        let communicationBundle = try decode(
            resource: "CommunicationDispReq-a218a36e-f2fd-4603-ba67-c827acfef01b.json"
        )

        let communications = try communicationBundle.parseErxTaskCommunications()
        expect(communications.count) == 1
        guard let first = communications.first else {
            fail("expected to have this communication")
            return
        }
        expect(first.identifier) == "a218a36e-f2fd-4603-ba67-c827acfef01b"
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.profile) == .dispReq
        expect(first.timestamp) == "2020-04-29T13:44:30.128+02:00"
        expect(first.insuranceId) == "X234567890"
        expect(first.telematikId) == "3-SMC-B-Testkarte-883110000123465"

        expect(first.payloadJSON) ==
            "{ \"version\": \"1\", \"supplyOptionsType\": \"delivery\", \"name\": \"Dr. Maximilian von Muster\", \"address\": [ \"wohnhaft bei Emilia Fischer\", \"Bundesallee 312\", \"123. OG\", \"12345 Berlin\" ], \"hint\": \"Bitte im Morsecode klingeln: -.-.\", \"phone\": \"004916094858168\" }" // swiftlint:disable:this line_length
    }

    func testParseErxTaskCommunicationInfoReq() throws {
        let communicationBundle = try decode(
            resource: "CommunicationInfoReq-8ca3c379-ac86-470f-bc12-178c9008f5c9.json"
        )

        let communications = try communicationBundle.parseErxTaskCommunications()
        // InfoRequest is not jet supported
        expect(communications.count) == 0
    }

    func testParseErxTaskMedicationDispense_with_contained_Medication_PZN() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_PZN.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.insuranceId) == "X234567890"
        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-abc-1234567890"
        expect(first.noteText) == "These are two notes\nseparated by newlines!"
        expect(first.quantity) == .init(value: "100", unit: "mg")
        expect(first.whenHandedOver) == "2022-02-28"
        expect(first.medication?.amount) ==
            .init(numerator: .init(value: "4", unit: "St"), denominator: .init(value: "1"))
        expect(first.medication?.pzn) == "16332684"
        expect(first.medication?.name) == "GONAL-f 150 I.E./0,25ml Injektionslösung"
        expect(first.medication?.normSizeCode) == "N1"
        expect(first.medication?.profile) == .pzn
        expect(first.medication?.drugCategory) == .avm
        expect(first.medication?.packaging).to(beNil())
        expect(first.medication?.manufacturingInstructions).to(beNil())
        expect(first.medication?.isVaccine).to(beTrue())
        expect(first.medication?.dosageForm) == "PEN"
        expect(first.medication?.batch).to(beNil())
        expect(first.medication?.ingredients.count) == 0
    }

    func testParseErxTaskMedicationDispense_with_contained_Medication_FreeText() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_FreeText.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.insuranceId) == "X234567890"
        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-abc-1234567890"
        expect(first.noteText) == "These are two notes\nseparated by newlines!"
        expect(first.quantity) == .init(value: "100", unit: "mg")
        expect(first.whenHandedOver) == "2022-02-28"
        expect(first.medication?.pzn).to(beNil())
        expect(first.medication?.name) == "Metformin 850mg Tabletten N3"
        expect(first.medication?.dosageForm) == "Tabletten"
        expect(first.medication?.amount).to(beNil())
        expect(first.medication?.normSizeCode).to(beNil())
        expect(first.medication?.profile) == .freeText
        expect(first.medication?.drugCategory) == .avm
        expect(first.medication?.packaging).to(beNil())
        expect(first.medication?.manufacturingInstructions).to(beNil())
        expect(first.medication?.isVaccine).to(beTrue())
        expect(first.medication?.batch).to(beNil())
        expect(first.medication?.ingredients.count) == 0
    }

    func testParseErxTaskMedicationDispense_with_contained_Medication_Ingredient() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_Ingredient.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.insuranceId) == "X234567890"
        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-abc-1234567890"
        expect(first.noteText) == "These are two notes\nseparated by newlines!"
        expect(first.quantity) == .init(value: "100", unit: "mg")
        expect(first.whenHandedOver) == "2022-02-28"
        expect(first.medication?.pzn).to(beNil())
        expect(first.medication?.name).to(beNil())
        expect(first.medication?.amount) ==
            .init(numerator: .init(value: "100", unit: "Stück"), denominator: .init(value: "1"))
        expect(first.medication?.normSizeCode) == "N2"
        expect(first.medication?.profile) == .ingredient
        expect(first.medication?.drugCategory) == .avm
        expect(first.medication?.packaging).to(beNil())
        expect(first.medication?.manufacturingInstructions).to(beNil())
        expect(first.medication?.isVaccine).to(beTrue())
        expect(first.medication?.dosageForm) == "Tabletten"
        expect(first.medication?.batch).to(beNil())
        expect(first.medication?.ingredients.count) == 2
        expect(first.medication?.ingredients[0]) == ErxMedication.Ingredient(
            text: "Gabapentin",
            number: "22308",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "300", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(first.medication?.ingredients[1]) == ErxMedication.Ingredient(
            text: "Gabapentin2",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "300", unit: "mg"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
    }

    func testParseErxTaskMedicationDispense_with_contained_Medication_Compounding() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_Compounding.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.insuranceId) == "X234567890"

        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-abc-1234567890"
        expect(first.noteText) == "These are two notes\nseparated by newlines!"
        expect(first.quantity) == .init(value: "100", unit: "mg")
        expect(first.whenHandedOver) == "2022-02-28"
        expect(first.medication?.pzn).to(beNil())
        expect(first.medication?.name) == "Viskose Aluminiumchlorid-Hexahydrat-Lösung 20 % (NRF 11.132.)"
        expect(first.medication?.amount) ==
            .init(numerator: .init(value: "200", unit: "g"), denominator: .init(value: "1"))
        expect(first.medication?.normSizeCode).to(beNil())
        expect(first.medication?.profile) == .compounding
        expect(first.medication?.packaging) == "Deo-Roller"
        expect(first.medication?.manufacturingInstructions) == "Schwieriger Herstellungsprozess"
        expect(first.medication?.drugCategory) == .avm
        expect(first.medication?.isVaccine).to(beTrue())
        expect(first.medication?.dosageForm) == "Creme"
        expect(first.medication?.batch).to(beNil())
        expect(first.medication?.ingredients.count) == 3
        expect(first.medication?.ingredients[0]) == ErxMedication.Ingredient(
            text: "Erythromycin",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "2.5", unit: "%"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(first.medication?.ingredients[1]) == ErxMedication.Ingredient(
            text: "Oleum Rosae",
            number: nil,
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "2", unit: "%"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(first.medication?.ingredients[2]) == ErxMedication.Ingredient(
            text: "Ungt. Emulsificans aquos.",
            number: nil,
            form: "Salbe",
            strength: nil,
            strengthFreeText: "Ad 200 g"
        )
    }

    func testParseErxTaskMedicationDispense_with_random_Medication_profile() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_random_Medication_profile.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }
        expect(first.taskId) == "160.000.033.491.280.78"
        expect(first.insuranceId) == "X234567890"
        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-abc-1234567890"
        expect(first.noteText) == "These are two notes\nseparated by newlines!"
        expect(first.quantity) == .init(value: "100", unit: "mg")
        expect(first.whenHandedOver) == "2022-02-28"
        expect(first.medication?.pzn) == "06313728"
        expect(first.medication?.name) == "Sumatriptan-1a Pharma 100 mg Tabletten"
        expect(first.medication?.amount) ==
            .init(numerator: .init(value: "20", unit: "St"), denominator: .init(value: "1"))
        expect(first.medication?.normSizeCode).to(beNil())
        expect(first.medication?.profile) == .unknown
        expect(first.medication?.drugCategory).to(beNil())
        expect(first.medication?.packaging).to(beNil())
        expect(first.medication?.manufacturingInstructions).to(beNil())
        expect(first.medication?.isVaccine).to(beFalse())
        expect(first.medication?.dosageForm).to(beNil())
        expect(first.medication?.batch?.lotNumber) == "1234567890abcde"
        expect(first.medication?.batch?.expiresOn) ==
            "2020-02-03T00:00:00+00:00"
        expect(first.medication?.ingredients.count) == 0
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_2_with_kbv_v1_1_0
    ) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle.rawValue)
            .decode(ModelsR4.Bundle.self, from: file)
    }
}
