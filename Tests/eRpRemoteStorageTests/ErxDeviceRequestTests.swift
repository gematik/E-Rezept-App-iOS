//
//  Copyright (c) 2025 gematik GmbH
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

import CoreData
import eRpKit
@testable import eRpRemoteStorage
import Foundation
import ModelsR4
import Nimble
import XCTest

final class ErxDeviceRequestTests: XCTestCase {
    private var moc: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
    }

    func testDiGaParser() throws {
        let secondJSONS = ["EVDGA.json", "EVDGA_Bundle.json", "EVDGA_Bundle_Zahnarzt.json",
                           "EVDGA_Bundle_BG_Arbeitsunfall.json", "EVDGA_Bundle_BG_Arbeitsunfall_2.json",
                           "EVDGA_Bundle_BG_Arbeitsunfall_3.json", "EVDGA_Bundle_BG_Berufskrankheit.json",
                           "EVDGA_Bundle_Krankenhaus.json", "EVDGA_Bundle_Krankenhaus_Standortnummer.json",
                           "EVDGA_Bundle_Unfall.json"]

        var result: [ErxTask] = []

        guard let mainJSON = try loadJSON("Bundle+Sig.json") else {
            XCTFail("Failed to load Bundle+Sig.json file")
            return
        }

        for jsonName in secondJSONS {
            guard let replaceJSON = try loadJSON(jsonName) else {
                XCTFail("Failed to load \(jsonName) file")
                return
            }

            let replaceMainJSON = mainJSON.replacingOccurrences(of: "\"{{ENTRYDIGA}}\"", with: replaceJSON)

            if let JSONData = replaceMainJSON.data(using: .utf8) {
                let gemFhirBundle = try JSONDecoder().decode(ModelsR4.Bundle.self, from: JSONData)
                guard let task = gemFhirBundle.parseErxTask(taskId: "5e00e907-1e4f-11b2-80be-b806a73c0cd0") else {
                    fail("Could not parse ModelsR4.Bundle into TaskBundle from \(jsonName)")
                    return
                }
                result.append(task)
            }
        }

        let deviceRequests = result.map(\.deviceRequest)
        // Expect all erxTasks to have deviceRequest
        expect(deviceRequests.count) == secondJSONS.count
        // Expect all request to have a appName
        expect(deviceRequests.compactMap(\.?.appName).count) == secondJSONS.count
        guard let firstRequest = deviceRequests.first else {
            fail("Could not extract first deviceRequest from list")
            return
        }

        expect(firstRequest?.isSER).to(beFalse())
        expect(firstRequest?.accidentInfo).to(beNil())
        expect(firstRequest?.pzn) == "19205615"
        expect(firstRequest?.intent) == ErxDeviceRequest.Intent.order
        expect(firstRequest?.status) == ErxDeviceRequest.DeviceRequestStatus.active
        expect(firstRequest?.appName) == "Vantis KHK und Herzinfarkt 001"
    }

    private func loadJSON(_ file: String) throws -> String? {
        let jsonData = try Bundle.module.testResourceFilePath(in: "Resources/DiGa", for: file).readFileContents()
        let json = String(data: jsonData, encoding: .utf8)
        return json
    }
}
