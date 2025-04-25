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

import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import SwiftUI
import TestUtils
import XCTest

// FHIRBundle tests with
// - workflow bundle version: 1.4.3
final class FHIR_GEM_Workflow_v1_4_CommunicationTests: XCTestCase {
    func testListAllCommunicationsWithSuccess() throws {
        let mixedCommunicationsBundle = try decode(
            resource: "Bundle_Mixed_Communication_versions.json",
            from: .gem_wf_v1_4,
            expectedType: ModelsR4.Bundle.self
        )

        let sut = try mixedCommunicationsBundle.parseErxTaskCommunications()

        expect(sut.count) == 4
        expect(sut[0]) == ErxTask.Fixtures.communicationDispReq
        expect(sut[1]) == ErxTask.Fixtures.communicationReply1
        expect(sut[2]) == ErxTask.Fixtures.communicationReply2
        expect(sut[3]) == ErxTask.Fixtures.communicationReply3
    }

    private func decode<T: Codable>(
        resource file: String,
        from bundle: FHIRBundleDirectories,
        expectedType: T.Type
    ) throws -> T {
        let data = try Bundle.module
            .testResourceFilePath(in: "Resources/\(bundle.rawValue)", for: file)
            .readFileContents()
        return try JSONDecoder().decode(expectedType.self, from: data)
    }
}

extension ErxTask {
    enum Fixtures {
        static let communicationDispReq = ErxTask.Communication(
            identifier: "01ebd9e1-47d8-bab8-2566-31341cc59b11",
            profile: eRpKit.ErxTask.Communication.Profile.dispReq,
            taskId: "200.000.000.157.911.86",
            userId: "X110571977",
            telematikId: "3-10.2.0111108800.16.806",
            orderId: Optional("7526e7d4-deeb-432c-97bd-7f4ccfa7e901"),
            timestamp: "2025-03-10T21:12:41.187+00:00",
            // swiftlint:disable:next line_length
            payloadJSON: "{\"version\":1,\"supplyOptionsType\":\"onPremise\",\"name\":\"Paula Privati\",\"address\":[\"Blumenweg\",\"\",\"26427\",\"Esens\"],\"hint\":\"\",\"phone\":\"\"}",
            isRead: false
        )

        static let communicationReply1 = ErxTask.Communication(
            identifier: "01ebc980-ae10-41f0-5a9f-c8ad61141a66",
            profile: .reply,
            taskId: "160.000.226.545.733.51",
            userId: "X110432693",
            telematikId: "3-01.2.2023001.16.103",
            orderId: nil,
            timestamp: "2024-08-14T11:14:38.230+00:00",
            payloadJSON: "Eisern",
            isRead: false
        )

        static let communicationReply2 = ErxTask.Communication(
            identifier: "01ebc980-ae10-41f0-5a9f-c8ad61141a66",
            profile: .reply,
            taskId: "160.000.226.545.733.51",
            userId: "X110432693",
            telematikId: "3-01.2.2023001.16.103",
            orderId: nil,
            timestamp: "2024-08-14T11:14:38.230+00:00",
            payloadJSON: "Eisern",
            isRead: false
        )

        static let communicationReply3 = ErxTask.Communication(
            identifier: "7977a4ab-97a9-4d95-afb3-6c4c1e2ac596",
            profile: .reply,
            taskId: "160.000.033.491.280.78",
            userId: "X234567890",
            telematikId: "3-SMC-B-Testkarte-883110000123465",
            orderId: nil,
            timestamp: "2020-04-29T13:46:30.128+02:00",
            payloadJSON: "Eisern",
            isRead: false
        )
    }
}
