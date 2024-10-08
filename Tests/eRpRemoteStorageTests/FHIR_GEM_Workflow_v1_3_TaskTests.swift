//
//  Copyright (c) 2024 gematik GmbH
//
//  Licensed under the Apache License, Version 2.0 (the License);
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an 'AS IS' BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import SwiftUI
import XCTest

// FHIRBundle tests with
// - workflow bundle version: 1.3.0 and
// - no prescription bundle (no changes)
final class FHIR_GEM_Workflow_v1_3_TaskTests: XCTestCase {
    /// FHIRBundle test of workflow version 1.3.0 without prescription bundle
    func testParseErxTaskWithoutPrescriptionBundle() throws {
        let tasksBundle = try decode(
            resource: "Tasks_Bundle.json",
            from: .gem_wf_v1_3
        )

        let tasks = try tasksBundle.parseErxTasksFromContainer()

        guard tasks.count == 3 else {
            fail("unexpected number of tasks")
            return
        }

        expect(tasks[0].id) == "160.123.456.789.123.58"
        expect(tasks[0].status) == ErxTask.Status.ready
        expect(tasks[0].flowType) == .pharmacyOnly
        expect(tasks[0].fullUrl) == "https://erp.app.ti-dienste.de/Task/160.123.456.789.123.58"
        expect(tasks[0].accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        expect(tasks[0].authoredOn) == "2020-03-02T08:25:05+00:00"
        expect(tasks[0].lastModified) == "2020-03-02T08:45:05+00:00"
        expect(tasks[0].expiresOn) == "2020-06-02"
        expect(tasks[0].acceptedUntil) == "2020-04-01"
        expect(tasks[0].lastMedicationDispense).to(beNil())

        expect(tasks[1].id) == "160.123.456.789.123.78"
        expect(tasks[1].status) == ErxTask.Status.ready
        expect(tasks[1].flowType) == .pharmacyOnly
        expect(tasks[1].fullUrl) == "https://erp.app.ti-dienste.de/Task/160.123.456.789.123.78"
        expect(tasks[1].accessCode) == "777bea0e13cc9c42ceec14aec3ddee8402643dc2c6c699db115f58fe423607ea"
        expect(tasks[1].authoredOn) == "2020-03-02T08:25:05+00:00"
        expect(tasks[1].lastModified) == "2020-03-02T08:45:05+00:00"
        expect(tasks[1].expiresOn) == "2020-06-02"
        expect(tasks[1].acceptedUntil) == "2020-04-01"
        expect(tasks[1].lastMedicationDispense).to(beNil())

        expect(tasks[2].id) == "160.123.456.789.123.61"
        expect(tasks[2].status) == ErxTask.Status.inProgress
        expect(tasks[2].flowType) == .pharmacyOnly
        expect(tasks[2].fullUrl) == "https://erp.app.ti-dienste.de/Task/160.123.456.789.123.61"
        expect(tasks[2].accessCode) == "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607bl"
        expect(tasks[2].authoredOn) == "2020-03-02T08:25:05+00:00"
        expect(tasks[2].lastModified) == "2020-03-02T08:45:05+00:00"
        expect(tasks[2].expiresOn) == "2020-06-02"
        expect(tasks[2].acceptedUntil) == "2020-04-01"
        // New in version 1.3
        expect(tasks[2].lastMedicationDispense) == "2020-04-01T16:37:17+01:00"
    }

    func testParseErxTaskCommunicationReply() throws {
        let communicationsBundle = try decode(
            resource: "Communications_Bundle.json",
            from: .gem_wf_v1_3
        )

        let communications = try communicationsBundle.parseErxTaskCommunications()

        guard communications.count == 3 else {
            fail("unexpected number of tasks")
            return
        }

        expect(communications[0].identifier) == "01ebc980-ae10-41f0-5a9f-c8ad61141a66"
        expect(communications[0].taskId) == "160.000.226.545.733.51"
        expect(communications[0].profile) == .reply
        expect(communications[0].timestamp) == "2024-08-14T11:14:38.230+00:00"
        expect(communications[0].insuranceId) == "X110432693"
        expect(communications[0].telematikId) == "3-01.2.2023001.16.103"
        expect(communications[0].payloadJSON) == "Eisern"

        expect(communications[1].identifier) == "01ebc980-c555-9bf8-66b2-0d434e302916"
        expect(communications[1].taskId) == "160.000.226.545.733.51"
        expect(communications[1].profile) == .reply
        expect(communications[1].timestamp) == "2024-08-14T11:21:08.651+00:00"
        expect(communications[1].insuranceId) == "X110432693"
        expect(communications[1].telematikId) == "3-01.2.2023001.16.103"
        expect(communications[1].payloadJSON) == "Eisern"

        expect(communications[2].identifier) == "01ebc980-cb72-d730-762e-dd08075f568a"
        expect(communications[2].taskId) == "160.000.226.545.733.51"
        expect(communications[2].profile) == .reply
        expect(communications[2].timestamp) == "2024-08-14T11:22:51.230+00:00"
        expect(communications[2].insuranceId) == "X110432693"
        expect(communications[2].telematikId) == "3-01.2.2023001.16.103"
        expect(communications[2].payloadJSON) == "Eisern"
    }

    private func decode(
        resource file: String,
        from bundle: FHIRBundleDirectories
    ) throws -> ModelsR4.Bundle {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(ModelsR4.Bundle.self, from: data)
    }
}
