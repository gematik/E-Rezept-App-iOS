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

final class FHIRBundleTests_future_version: XCTestCase {
    func testResolvingReferendeByFullUrl() throws {
        let gemFhirBundle = try decode(resource: "getTaskResponse_with_fullUrl_reference.json")

        guard let task = gemFhirBundle.parseErxTask(taskId: "160.000.000.003.223.88") else {
            fail("Could not parse ModelsR4.Bundle into TaskBundle.")
            return
        }
        // task
        expect(task.id) == "160.000.000.003.223.88"
        expect(task.status) == ErxTask.Status.ready
        expect(task.source) == .server
        expect(task.prescriptionId) == "160.000.000.003.223.88"
        expect(task.accessCode) == "43fab2ce46cf7c10e4dac7ca4d4229c561bbea02cb981ddfa413b34d61e9daa8"
        expect(task.fullUrl) == "https://erp.box.erezepttest.net/Task/160.000.000.003.223.88"
        expect(task.authoredOn) == "2022-06-14T16:01:15.301+00:00"
        expect(task.lastModified) == "2022-06-14T16:01:15.692+00:00"
        expect(task.expiresOn) == "2022-09-14"
        expect(task.acceptedUntil) == "2022-07-12"
        expect(task.author) == "Praxis Dr. Aphrodite MondwürfelTEST-ONLY"

        // medication patient, organization and practitioner must not be nil if reference has been resolved
        expect(task.medication?.name) == "Olanzapin Heuma 20 mg SMT"
        expect(task.patient?.name) == "Ulrica Lisa Vórmwinkel"
        expect(task.practitioner?.lanr) == "123456789"
        expect(task.organization?.name) == "Praxis Dr. Aphrodite MondwürfelTEST-ONLY"
    }

    private func decode(
        resource file: String,
        from bundle: String = "FHIRExampleData_future_version.bundle"
    ) throws -> ModelsR4.Bundle {
        try Bundle(for: Self.self)
            .bundleFromResources(name: bundle)
            .decode(ModelsR4.Bundle.self, from: file)
    }
}
