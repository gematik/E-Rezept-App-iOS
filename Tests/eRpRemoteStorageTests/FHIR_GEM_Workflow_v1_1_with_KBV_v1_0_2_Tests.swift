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

import BundleKit
import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import XCTest

// FHIRBundle tests with different workflow and kbv versions
final class FHIR_GEM_Workflow_v1_1_with_KBV_v1_0_2_Tests: XCTestCase {
    /// FHIRBundle test with
    /// - workflow bundle version: 1.0.0 and
    /// - prescription (KBV) bundle version 1.0.1 / 1.0.2
    func testParseErxTasks() throws {
        let gemFhirBundle = try decode(resource: "getTaskResponse_5e00e907-1e4f-11b2-80be-b806a73c0cd0.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "5e00e907-1e4f-11b2-80be-b806a73c0cd0") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }

        expect(task.id) == "5e00e907-1e4f-11b2-80be-b806a73c0cd0"
        expect(task.status) == ErxTask.Status.ready
        expect(task.flowType) == .pharmacyOnly
        expect(task.prescriptionId) == "160.000.711.572.601.54"
        expect(task.accessCode) == "9d6f58a2c5a89c0681f91cbd69dd666f365443e3ae114d7d9ca9162181f7d34d"
        expect(task.fullUrl).to(beNil())
        expect(task.medication?.name) == "Sumatriptan-1a Pharma 100 mg Tabletten"
        expect(task.authoredOn) == "2021-03-24T08:35:26.548167988+00:00"
        expect(task.lastModified) == "2021-03-24T08:35:26.548174460+00:00"
        expect(task.expiresOn) == "2021-06-24"
        expect(task.acceptedUntil) == "2021-04-23"
        expect(task.author) == "Hausarztpraxis Dr. Topp-Glücklich"
        expect(task.medication?.dosageForm) == "TAB"
        expect(task.medication?.normSizeCode) == "N1"
        expect(task.medication?.pzn) == "06313728"
        expect(task.medication?.amount) ==
            .init(numerator: .init(value: "12", unit: "TAB"), denominator: .init(value: "1"))
        expect(task.medication?.batch?.lotNumber) == "1234567890abcde"
        expect(task.medication?.batch?.expiresOn) == "2020-02-03T00:00:00+00:00"
        expect(task.medicationRequest.dosageInstructions) == "1-0-1-0"
        expect(task.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.mark) == true
        expect(task.medicationRequest.multiplePrescription?.numbering) == 2
        expect(task.medicationRequest.multiplePrescription?.totalNumber) == 4
        expect(task.medicationRequest.multiplePrescription?.startPeriod) == "2021-01-02"
        expect(task.medicationRequest.multiplePrescription?.endPeriod) == "2021-03-30"
        expect(task.medicationRequest.hasEmergencyServiceFee) == false
        expect(task.medicationRequest.substitutionAllowed) == true
        expect(task.medicationRequest.quantity) == .init(value: "1", unit: "{Package}")
        expect(task.source) == .server
        expect(task.patient?.name) == "Ludger Ludger Königsstein"
        expect(task.patient?.address) == "Musterstr. 1\n10623 Berlin"
        expect(task.patient?.birthDate) == "1935-06-22"
        expect(task.patient?.phone).to(beNil())
        expect(task.patient?.status) == "1"
        expect(task.patient?.insurance) == "AOK Rheinland/Hamburg"
        expect(task.patient?.insuranceId) == "X234567890"
        expect(task.practitioner?.lanr) == "838382202"
        expect(task.practitioner?.name) == "Dr. med. Hans Topp-Glücklich"
        expect(task.practitioner?.qualification) == "Hausarzt"
        expect(task.practitioner?.email).to(beNil())
        expect(task.practitioner?.address).to(beNil())
        // organization
        expect(task.organization?.name) == "Hausarztpraxis Dr. Topp-Glücklich"
        expect(task.organization?.phone) == "0301234567"
        expect(task.organization?.address) == "Musterstr. 2\n10623, Berlin"
        expect(task.organization?.email).to(beNil())
        expect(task.organization?.identifier) == "031234567"

        expect(task.medicationRequest.accidentInfo) == AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "Dummy-Betrieb",
            date: "2020-05-01"
        )
        expect(task.medicationRequest.coPaymentStatus) == .subjectToCharge
        expect(task.medicationRequest.bvg) == true
    }

    /// FHIRBundle test with
    /// - workflow bundle version: 1.1.1 and
    /// - prescription (KBV) bundle version 1.0.2
    func testParseErxTaskBundle1_v1_1_1() throws {
        let gemFhirBundle = try decode(resource: "getTaskResponse1_bundle_v1_1_1.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "160.000.088.357.676.93") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }
        // task
        expect(task.id) == "160.000.088.357.676.93"
        expect(task.status) == ErxTask.Status.ready
        expect(task.flowType) == .pharmacyOnly
        expect(task.source) == .server
        expect(task.prescriptionId) == "160.000.088.357.676.93"
        expect(task.accessCode) == "68db761b666f7e75a32090fd4d109e2766e02693741278ab6dc2df90f1cbb3af"
        expect(task.fullUrl) == "https://erp-ref.zentral.erp.splitdns.ti-dienste.de/Task/160.000.088.357.676.93"
        expect(task.authoredOn) == "2021-11-30T14:16:43.239+00:00"
        expect(task.lastModified) == "2021-11-30T14:17:39.222+00:00"
        expect(task.expiresOn) == "2022-03-02"
        expect(task.acceptedUntil) == "2021-12-28"
        expect(task.author) == "Universitätsklinik Campus Süd"
        // medication
        expect(task.medication?.name) == "Olanzapin Heumann 20mg"
        expect(task.medication?.dosageForm) == "SMT"
        expect(task.medication?.normSizeCode) == "N3"
        expect(task.medication?.pzn) == "08850519"
        expect(task.medication?.amount) ==
            .init(numerator: .init(value: "70", unit: "St"), denominator: .init(value: "1"))
        expect(task.medication?.batch?.lotNumber).to(beNil())
        expect(task.medication?.batch?.expiresOn).to(beNil())
        // medication request
        expect(task.medicationRequest.dosageInstructions) == "1x täglich"
        expect(task.medicationRequest.hasEmergencyServiceFee) == true
        expect(task.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(task.medicationRequest.substitutionAllowed) == false
        expect(task.medicationRequest.multiplePrescription?.mark) == false
        expect(task.medicationRequest.multiplePrescription?.numbering).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.totalNumber).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.startPeriod).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.endPeriod).to(beNil())
        expect(task.medicationRequest.accidentInfo) == AccidentInfo(
            type: .workAccident,
            workPlaceIdentifier: "Arbeitsplatz",
            date: "2021-04-01"
        )
        expect(task.medicationRequest.coPaymentStatus) == .noSubjectToCharge
        expect(task.medicationRequest.bvg) == true
        expect(task.medicationRequest.quantity) == .init(value: "1", unit: "{Package}")
        // patient
        expect(task.patient?.name) == "Prof. Dr. Karl-Friederich Graf Freiherr von Schaumberg"
        expect(task.patient?.address) == "Siegburger Str. 155\n51105 Köln"
        expect(task.patient?.birthDate) == "1964-04-04"
        expect(task.patient?.phone).to(beNil())
        expect(task.patient?.status) == "1"
        expect(task.patient?.insurance) == "AOK Nordost - Die Gesundheitskasse"
        expect(task.patient?.insuranceId) == "X110498793"
        // practitioner
        expect(task.practitioner?.lanr) == "445588777"
        expect(task.practitioner?.name) == "Prof. Dr. Hannelore Popówitsch"
        expect(task.practitioner?.qualification) == "Innere und Allgemeinmedizin (Hausarzt)"
        expect(task.practitioner?.email).to(beNil())
        expect(task.practitioner?.address).to(beNil())
        // organization
        expect(task.organization?.name) == "Universitätsklinik Campus Süd"
        expect(task.organization?.phone) == "06841/7654321"
        expect(task.organization?.address) == "Kirrberger Str. 100\n66421, Homburg"
        expect(task.organization?.email) == "unikliniksued@test.de"
        expect(task.organization?.identifier) == "998877665"
    }

    func testParseAuditEventsFromSamplePayload() throws {
        let gemFhirBundle = try decode(resource: "getAuditEventResponse_4_entries.json")

        let auditEvents = try gemFhirBundle.parseErxAuditEvents()

        expect(auditEvents.count) == 4

        expect(auditEvents[0].identifier) == "64c4f143-1de0-11b2-80eb-443cac489883"
        expect(auditEvents[0].timestamp) == "2021-04-29T16:02:39.475065591+00:00"
        expect(auditEvents[0].taskId) == "20544d02-1dd2-11b2-805e-443cac489883"

        expect(auditEvents[1].identifier) == "64c4f1af-1de0-11b2-80ec-443cac489883"
        expect(auditEvents[1].timestamp) == "2021-04-29T16:02:39.475074398+00:00"
        expect(auditEvents[1].taskId) == "23285587-1dd2-11b2-80a6-443cac489883"

        expect(auditEvents[2].identifier) == "64c4f1cc-1de0-11b2-80ed-443cac489883"
        expect(auditEvents[2].timestamp) == "2021-04-29T16:02:39.475077274+00:00"
        expect(auditEvents[2].taskId) == "234ec20e-1dd2-11b2-80aa-443cac489883"

        expect(auditEvents[3].identifier) == "64c4f1ea-1de0-11b2-80ee-443cac489883"
        expect(auditEvents[3].timestamp) == "2021-04-29T16:02:39.475080290+00:00"
        expect(auditEvents[3].taskId) == "22ff81be-1dd2-11b2-80a2-443cac489883"
    }

    func testParseAuditEventsVersion_1_1_1() throws {
        let gemFhirBundle = try decode(resource: "getAuditEventResponse_v1_1_1.json")

        let auditEvents = try gemFhirBundle.parseErxAuditEvents()

        expect(auditEvents.count) == 2

        expect(auditEvents[0].identifier) == "01eb9e9c-fa83-fd88-8479-0ccc05fed141"
        expect(auditEvents[0].timestamp) == "2023-02-15T15:56:59.973+00:00"
        expect(auditEvents[0].taskId) == "160.000.006.287.153.54"
        expect(auditEvents[0].text) ==
            "Emil Elch hat das Rezept mit der ID 160.000.006.287.153.54 heruntergeladen.\n"
        expect(auditEvents[0].title).to(beNil())
        expect(auditEvents[0].locale) == "de"

        expect(auditEvents[1].identifier) == "01eb9e9c-fb23-f6a8-fb39-4504037929d6"
        expect(auditEvents[1].timestamp) == "2023-02-15T15:57:10.457+00:00"
        expect(auditEvents[1].taskId) == "160.000.006.287.153.54"
        expect(auditEvents[1].text) ==
            "Emil Elch hat das Rezept mit der ID 160.000.006.287.153.54 heruntergeladen.\n"
        expect(auditEvents[1].title).to(beNil())
        expect(auditEvents[1].locale) == "de"
    }

    func testParseErxTaskCommunicationReply() throws {
        let communicationBundle = try decode(resource: "erxCommunicationReplyResponse.json")

        let communications = try communicationBundle.parseErxTaskCommunications()
        expect(communications.count) == 4
        guard let first = communications.first else {
            fail("expected to have this communication")
            return
        }
        expect(first.identifier) == "9d533345-1e50-11b2-8115-dd3ddb83b539"
        expect(first.taskId) == "6550190f-1dd2-11b2-80e1-dd3ddb83b539"
        expect(first.profile) == .reply
        expect(first.timestamp) == "2021-05-26T10:59:37.098245933+00:00"
        expect(first.insuranceId) == "X234567890"
        expect(first.telematikId) == "3-09.2.S.10.743"
        expect(first.orderId).to(beNil())

        // test payload parsing for all possible variations of payload
        expect(first.payloadJSON) == "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"\"}"
    }

    func testParseErxTaskCommunicationDispReq() throws {
        let communicationBundle = try decode(resource: "erxCommunicationDispReqResponse.json")

        let communications = try communicationBundle.parseErxTaskCommunications()
        expect(communications.count) == 5
        guard let first = communications.first else {
            fail("expected to have this communication")
            return
        }
        expect(first.identifier) == "16d2cfc8-2023-11b2-81e1-783a425d8e87"
        expect(first.taskId) == "39c67d5b-1df3-11b2-80b4-783a425d8e87"
        expect(first.profile) == .dispReq
        expect(first.timestamp) == "2021-05-03T08:13:38.389015396+00:00"
        expect(first.insuranceId) == "X110461389"
        expect(first.telematikId) == "3-09.2.S.10.743"
        expect(first.orderId).to(beNil())
        // test payload parsing for all possible variations of payload
        expect(first.payloadJSON) == "{do something}"

        guard let fifth = communications.last else {
            fail("expected to have this communication")
            return
        }
        expect(fifth.identifier) == "01eb8e09-19d2-eea0-a14f-ed08a549fae3"
        expect(fifth.taskId) == "160.000.000.030.106.46"
        expect(fifth.profile) == .dispReq
        expect(fifth.timestamp) == "2022-07-19T16:48:24.036+00:00"
        expect(fifth.insuranceId) == "X110495330"
        expect(fifth.telematikId) == "3-15.2.010873.824"
        expect(fifth.orderId) == "d58894dd-c93c-4841-b6f6-4ac4cda4922f"
        expect(fifth.payloadJSON) == "{do something else}"
    }

    func testParseErxTaskMedicationDispense_with_Medication_PZN() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_two_Medication_PZN.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 2
        guard let first = medicationDispenses.last else {
            fail("expected to have this medicationDispenses")
            return
        }

        expect(first.identifier) == "160.000.000.014.285.76.1"
        expect(first.taskId) == "160.000.000.014.285.76"
        expect(first.insuranceId) == "X114428530"
        expect(first.dosageInstruction) == "1-0-1-0"
        expect(first.telematikId) == "3-SMC-B-Testkarte-883110000129068"
        expect(first.whenHandedOver) == "2021-07-23T10:55:04+02:00"
        expect(first.quantity) == .init(value: "1", unit: "g")
        expect(first.noteText) == "These are two notes\nseparated by newlines!"

        expect(first.medication?.name) == "gesund"
        expect(first.medication?.profile) == .pzn
        expect(first.medication?.pzn) == "03273514"
        expect(first.medication?.drugCategory) == .avm
        expect(first.medication?.isVaccine) == true
        expect(first.medication?.amount) ==
            .init(numerator: .init(value: "12", unit: "TAB"), denominator: .init(value: "1"))
        expect(first.medication?.dosageForm) == "TAB"
        expect(first.medication?.normSizeCode).to(beNil())
        expect(first.medication?.batch).to(beNil())
        expect(first.medication?.packaging).to(beNil())
        expect(first.medication?.manufacturingInstructions).to(beNil())

        expect(first.medication?.ingredients.count) == 0
    }

    func testParseErxTaskMedicationDispense_With_Medication_FreeText() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_FreeText.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let medicationDispense = medicationDispenses.first else {
            fail("expected to have this medicationDispenses")
            return
        }

        expect(medicationDispense.identifier) == "160.000.000.014.298.37.1"
        expect(medicationDispense.taskId) == "160.000.000.014.298.37"
        expect(medicationDispense.insuranceId) == "X114428530"
        expect(medicationDispense.dosageInstruction) == "1-0-1-0"
        expect(medicationDispense.telematikId) == "3-SMC-B-Testkarte-883110000129068"
        expect(medicationDispense.whenHandedOver) == "2021-07-23T23:04:01+02:00"
        expect(medicationDispense.quantity) == .init(value: "1", unit: "g")
        expect(medicationDispense.noteText).to(beNil())

        expect(medicationDispense.medication?.profile) == .freeText
        expect(medicationDispense.medication?.drugCategory) == .avm
        expect(medicationDispense.medication?.isVaccine).to(beTrue())
        expect(medicationDispense.medication?.manufacturingInstructions).to(beNil())
        expect(medicationDispense.medication?.packaging).to(beNil())
        expect(medicationDispense.medication?.amount).to(beNil())
        expect(medicationDispense.medication?.dosageForm) == "Darreichungsform als Freitext"
        expect(medicationDispense.medication?.normSizeCode).to(beNil())
        expect(medicationDispense.medication?.batch).to(beNil())
        expect(medicationDispense.medication?.ingredients.count) == 0
    }

    func testParseErxTaskMedicationDispense_With_Medication_Ingredient() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_Ingredient.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let medicationDispense = medicationDispenses.first else {
            fail("expected to have this medicationDispenses")
            return
        }

        expect(medicationDispense.identifier) == "160.000.000.014.298.37.1"
        expect(medicationDispense.taskId) == "160.000.000.014.298.37"
        expect(medicationDispense.insuranceId) == "X114428530"
        expect(medicationDispense.dosageInstruction) == "1-0-1-0"
        expect(medicationDispense.telematikId) == "3-SMC-B-Testkarte-883110000129068"
        expect(medicationDispense.whenHandedOver) == "2021-07-23T23:04:01+02:00"
        expect(medicationDispense.quantity) == .init(value: "1", unit: "g")
        expect(medicationDispense.noteText).to(beNil())

        expect(medicationDispense.medication?.profile) == .ingredient
        expect(medicationDispense.medication?.drugCategory) == .avm
        expect(medicationDispense.medication?.isVaccine).to(beTrue())
        expect(medicationDispense.medication?.manufacturingInstructions).to(beNil())
        expect(medicationDispense.medication?.packaging).to(beNil())
        expect(medicationDispense.medication?.amount).to(beNil())
        expect(medicationDispense.medication?.dosageForm) == "Flüssigkeiten"
        expect(medicationDispense.medication?.normSizeCode) == "N1"
        expect(medicationDispense.medication?.batch).to(beNil())
        expect(medicationDispense.medication?.ingredients.count) == 1
        guard medicationDispense.medication?.ingredients.count == 1 else {
            fail("expected to have two ingredients")
            return
        }
        expect(medicationDispense.medication?.ingredients[0]) == ErxMedication.Ingredient(
            text: "Wirkstoff Paulaner Weissbier",
            number: "37197",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "1", unit: "Maß"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
    }

    func testParseErxTaskMedicationDispense_With_Medication_Compounding() throws {
        let medicationDispenceBundle: ModelsR4
            .Bundle = try decode(resource: "MedicationDispense_with_Medication_Compounding.json")

        let medicationDispenses = try medicationDispenceBundle.parseErxMedicationDispenses()
        expect(medicationDispenses.count) == 1
        guard let medicationDispense = medicationDispenses.first else {
            fail("expected to have this medicationDispenses")
            return
        }

        expect(medicationDispense.identifier) == "160.000.000.014.298.37.1"
        expect(medicationDispense.taskId) == "160.000.000.014.298.37"
        expect(medicationDispense.insuranceId) == "X114428530"
        expect(medicationDispense.dosageInstruction) == "1-0-1-0"
        expect(medicationDispense.telematikId) == "3-SMC-B-Testkarte-883110000129068"
        expect(medicationDispense.whenHandedOver) == "2021-07-23T23:04:01+02:00"
        expect(medicationDispense.quantity) == .init(value: "1", unit: "g")
        expect(medicationDispense.noteText).to(beNil())

        expect(medicationDispense.medication?.profile) == .compounding
        expect(medicationDispense.medication?.drugCategory) == .avm
        expect(medicationDispense.medication?.isVaccine).to(beFalse())
        expect(medicationDispense.medication?.manufacturingInstructions) ==
            "Anweisungen bzgl. der Herstellung der Rezeptur"
        expect(medicationDispense.medication?.packaging) ==
            "Angabe zur Transportbehältnisse, Verpackungen bzw. Applikationshilfen für eine Rezeptur"
        expect(medicationDispense.medication?.amount) == ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: "100", unit: "ml"),
            denominator: ErxMedication.Quantity(value: "1")
        )
        expect(medicationDispense.medication?.dosageForm) == "Lösung"
        expect(medicationDispense.medication?.normSizeCode).to(beNil())
        expect(medicationDispense.medication?.batch).to(beNil())
        expect(medicationDispense.medication?.ingredients.count) == 2
        guard medicationDispense.medication?.ingredients.count == 2 else {
            fail("expected to have two ingredients")
            return
        }
        expect(medicationDispense.medication?.ingredients[0]) == ErxMedication.Ingredient(
            text: "1_3 Graf 02.08.2022",
            number: "10206346",
            form: nil,
            strength: ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: "5", unit: "g"),
                denominator: ErxMedication.Quantity(value: "1")
            ),
            strengthFreeText: nil
        )
        expect(medicationDispense.medication?.ingredients[1]) == ErxMedication.Ingredient(
            text: "2-propanol 70 %",
            number: nil,
            form: "Pulver",
            strength: nil,
            strengthFreeText: "Ad 100 g"
        )
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_1_with_kbv_v1_0_2
    ) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle.rawValue)
            .decode(ModelsR4.Bundle.self, from: file)
    }
}
