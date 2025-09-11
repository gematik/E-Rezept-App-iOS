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

// FHIRBundle tests with
// - workflow bundle version: 1.5.2 and
// - prescription (KBV) bundle version 1.3.2
final class FHIR_GEM_Workflow_v1_5_2_with_KBV_v1_3_2_Tests: XCTestCase {
    /// FHIRBundle test of workflow version 1.5.2 with prescription version 1.3.2
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

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories = .gem_wf_v1_5_2_with_kbv_v1_3_2
    ) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
