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
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import SwiftUI
import XCTest

/// FHIRBundle tests with
/// - workflow bundle version: 1.6.1 (profiles encoded as |1.6)
/// - prescription (KBV) bundle version 1.4.1 (profiles encoded as |1.4)
final class FHIR_GEM_Workflow_v1_6_1_with_KBV_v1_4_1_Tests: XCTestCase {
    /// FHIRBundle test of workflow version 1.6.1 with prescription version 1.4.1
    func testParseErxTaskWithPrescriptionBundle() throws {
        let gemFhirBundle = try decode(resource: "Task_and_KBV_Bundle.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "160.000.033.491.280.78") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }
        // task
        expect(task.id) == "160.000.033.491.280.78"
        expect(task.status) == ErxTask.Status.ready
        expect(task.flowType) == .pharmacyOnly
        expect(task.source) == .server
        expect(task.fullUrl).to(beNil())
        expect(task.accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        expect(task.authoredOn) == "2025-10-01T15:29:00+00:00"
        expect(task.lastModified) == "2025-10-01T16:44:00.434+00:00"
        expect(task.expiresOn) == "2025-10-01"
        expect(task.acceptedUntil) == "2025-10-01"
        expect(task.author) == "Kinderarztpraxis"
        // medication
        expect(task.medication?.name) == "Prospan® Hustensaft 100ml N1"
        expect(task.medication?.dosageForm) == "FLE"
        expect(task.medication?.normSizeCode) == "N1"
        expect(task.medication?.pzn) == "08585997"
        expect(task.medication?.amount).to(beNil())
        // medication request
        expect(task.medicationRequest.dosageInstructions) == "2mal tägl. 5ml"
        expect(task.medicationRequest.hasEmergencyServiceFee) == false
        expect(task.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(task.medicationRequest.substitutionAllowed) == true
        expect(task.medicationRequest.coPaymentStatus) == .noSubjectToCharge
        expect(task.medicationRequest.ser) == false
        expect(task.medicationRequest.multiplePrescription?.mark) == false
        expect(task.medicationRequest.multiplePrescription?.numbering).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.totalNumber).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.startPeriod).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.endPeriod).to(beNil())
        expect(task.medicationRequest.accidentInfo).to(beNil())
        expect(task.medicationRequest.quantity) == .init(value: "1", unit: "Packung")
        expect(task.medicationRequest.teratogenicRelatedInformation).to(beNil())
        // patient
        expect(task.patient?.name) == "Ingrid Erbprinzessin von und zu der Schimmelpfennig-Hammerschmidt Federmannssohn"
        expect(task.patient?.address) == "Anneliese- und Georg-von-Groscurth-Plaetzchen 149-C\n60437 Bad Homburg"
        expect(task.patient?.birthDate) == "2010-01-31"
        expect(task.patient?.phone).to(beNil())
        expect(task.patient?.status) == "3"
        expect(task.patient?.insurance) == "AOK Bayern Die Gesundh."
        expect(task.patient?.insuranceId) == "M310119802"
        expect(task.patient?.coverageType) == .GKV
        // practitioner
        expect(task.practitioner?.lanr) == "456456534"
        expect(task.practitioner?.name) == "Dr. Maximilian Weber"
        expect(task.practitioner?.qualification) == "Facharzt für Kinder- und Jugendmedizin"
        expect(task.practitioner?.email).to(beNil())
        expect(task.practitioner?.address).to(beNil())
        // organization
        expect(task.organization?.name) == "Kinderarztpraxis"
        expect(task.organization?.phone) == "09411234567"
        expect(task.organization?.address) == "Yorckstraße 15\n93049, Regensburg"
        expect(task.organization?.email).to(beNil())
        expect(task.organization?.identifier) == "687777700"
    }

    /// FHIRBundle test of workflow version 1.6.1 with prescription version 1.4.1
    func testParseErxTaskWithPrescriptionBundle2() throws {
        let gemFhirBundle = try decode(resource: "Task_and_KBV_Bundle2.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "166.000.000.001.042.08") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }
        // task
        expect(task.id) == "166.000.000.001.042.08"
        expect(task.status) == ErxTask.Status.ready
        expect(task.flowType) == .tPrescription
        expect(task.source) == .server
        expect(task.fullUrl).to(equal("https://erp-dev.zentral.erp.splitdns.ti-dienste.de/Task/166.000.000.001.042.08"))
        expect(task.accessCode) == "9d7426da539deea658f9f38b77285c8d0816bd38fafdc7db84165d0038983b55"
        expect(task.authoredOn) == "2026-05-08T07:23:28.956+00:00"
        expect(task.lastModified) == "2026-05-08T07:23:29.302+00:00"
        expect(task.expiresOn) == "2026-05-14"
        expect(task.acceptedUntil) == "2026-05-14"
        expect(task.author) == "Elle O'Quent"
        // medication
        expect(task.medication?.name) == "L-Tryptophan Kapseln 600 mg"
        expect(task.medication?.dosageForm) == "IFL"
        expect(task.medication?.normSizeCode) == "KTP"
        expect(task.medication?.pzn) == "82035212"
        expect(task.medication?.amount) == .init(
            numerator: .init(value: "218", unit: "Stück"),
            denominator: .init(value: "1")
        )
        // medication request
        expect(task.medicationRequest.dosageInstructions) == "1-2-2-2-0-1"
        expect(task.medicationRequest.hasEmergencyServiceFee) == true
        expect(task.medicationRequest.dispenseValidityEnd).to(beNil())
        expect(task.medicationRequest.substitutionAllowed) == false
        expect(task.medicationRequest.coPaymentStatus) == .noSubjectToCharge
        expect(task.medicationRequest.ser) == true
        expect(task.medicationRequest.multiplePrescription?.mark) == false
        expect(task.medicationRequest.multiplePrescription?.numbering).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.totalNumber).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.startPeriod).to(beNil())
        expect(task.medicationRequest.multiplePrescription?.endPeriod).to(beNil())
        expect(task.medicationRequest.accidentInfo).to(beNil())
        expect(task.medicationRequest.quantity) == .init(value: "20", unit: "Packung")
        // teratogenic related information
        expect(task.medicationRequest.teratogenicRelatedInformation).toNot(beNil())
        expect(task.medicationRequest.teratogenicRelatedInformation?.offLabelUse) == false
        expect(task.medicationRequest.teratogenicRelatedInformation?.womanOfChildbearingAge) == false
        expect(task.medicationRequest.teratogenicRelatedInformation?.safetyMeasuresCompliance) == true
        expect(task.medicationRequest.teratogenicRelatedInformation?.informationMaterialProvided) == true
        expect(task.medicationRequest.teratogenicRelatedInformation?.expertKnowledgeDeclaration) == true
        // patient
        expect(task.patient?.name) == "Ingrid Erbprinzessin von und zu der Schimmelpfennig-Hammerschmidt Federmannssohn"
        expect(task.patient?.address) == "Karl-Wingchen-Str. 085\n91844 Bjarnegrün"
        expect(task.patient?.birthDate) == "1988-05-02"
        expect(task.patient?.phone).to(beNil())
        expect(task.patient?.status) == "1"
        expect(task.patient?.insurance) == "TUI BKK"
        expect(task.patient?.insuranceId) == "M310119802"
        expect(task.patient?.coverageType) == .GKV
        // practitioner
        expect(task.practitioner?.lanr) == "102528369"
        expect(task.practitioner?.name) == "Nelson Ender"
        expect(task.practitioner?.qualification) == "dental hygienist"
        expect(task.practitioner?.email).to(beNil())
        expect(task.practitioner?.address).to(beNil())
        // organization
        expect(task.organization?.name) == "Elle O'Quent"
        expect(task.organization?.phone) == "09411234567"
        expect(task.organization?.address) == "Maashofstr. 8\n50374, Neu Willibrunn"
        expect(task.organization?.email).to(beNil())
        expect(task.organization?.identifier) == "170304210"
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_6_1_with_kbv_v1_4_1
    ) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
