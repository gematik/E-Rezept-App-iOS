//
//  Copyright (c) 2022 gematik GmbH
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

final class SharedTaskTests: XCTestCase {
    func testSingleSerialization() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz")

        let expected = "\"1234567890|abcdefghijklmnopqrstuvwxyz\"".data(using: .utf8)

        expect({ try JSONEncoder().encode(sut) }).to(equal(expected))
    }

    func testCollectionSerialization() {
        let taskA = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz")
        let taskB = SharedTask(id: "0000000000", accessCode: "aaaaa")
        let taskC = SharedTask(id: "9999999999", accessCode: "zzzzz")

        let sut = [taskA, taskB, taskC]

        let expected = "[\"1234567890|abcdefghijklmnopqrstuvwxyz\",\"0000000000|aaaaa\",\"9999999999|zzzzz\"]"
            .data(using: .utf8)

        expect({ try JSONEncoder().encode(sut) }).to(equal(expected))
    }

    func testSingleDeserialization() {
        let expected = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz")

        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) }).to(equal(expected))
    }

    func testCollectionDeserialization() {
        let sut = "[\"1234567890|abcdefghijklmnopqrstuvwxyz\",\"0000000000|aaaaa\",\"9999999999|zzzzz\"]"
            .data(using: .utf8)!

        let taskA = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz")
        let taskB = SharedTask(id: "0000000000", accessCode: "aaaaa")
        let taskC = SharedTask(id: "9999999999", accessCode: "zzzzz")

        let expected = [taskA, taskB, taskC]

        expect({ try JSONDecoder().decode([SharedTask].self, from: sut) }).to(equal(expected))
    }
}
