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

@testable import eRpKit
import Nimble
import XCTest

final class ScannedErxTaskTests: XCTestCase {
    func testInitializeFromString() {
        let valid = "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        let expectedValid = ScannedErxTask(
            id: "4711",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )

        expect {
            try ScannedErxTask(taskString: valid)
        } == expectedValid
    }

    func testFailInitializeFromMalformedString() {
        expect(try? ScannedErxTask(taskString: "Task/4711/$accept?ac=noBase64Format")).to(beNil())
    }

    func testInitializeFromUrlToken() {
        let data = """
        {"urls": ["Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"]}
        """

        let expected = ScannedErxTask(
            id: "4711",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )

        expect(try ScannedErxTask.from(tasks: data)) == [expected]
    }

    func testInitializeFromUrlTokenMultipleTasks() {
        let data = """
        {
          "urls": [
            "Task/4711/$accept?ac=777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea",
            "Task/4712/$accept?ac=0936cfa582b447144b71ac89eb7bb83a77c67c99d4054f91ee3703acf5d6a629",
            "Task/TaskId123/$accept?ac=d3e6092ae3af14b5225e2ddbe5a4f59b3939a907d6fdd5ce6a760ca71f45d8e5"
          ]
        }
        """

        let expected2 = ScannedErxTask(
            id: "4712",
            accessCode: "0936cfa582b447144b71ac89eb7bb83a77c67c99d4054f91ee3703acf5d6a629"
        )

        expect {
            try ScannedErxTask.from(tasks: data)[1]
        } == expected2

        let expected3 = ScannedErxTask(
            id: "TaskId123",
            accessCode: "d3e6092ae3af14b5225e2ddbe5a4f59b3939a907d6fdd5ce6a760ca71f45d8e5"
        )

        expect {
            try ScannedErxTask.from(tasks: data)[2]
        } == expected3
    }
}
