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

    // MARK: - Tests with Name

    func testSingleSerializationWithName() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin")

        let expected = "\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin\"".data(using: .utf8)

        expect({ try JSONEncoder().encode(sut) }).to(equal(expected))
    }

    func testSingleSerializationWithoutName() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: nil)

        let expected = "\"1234567890|abcdefghijklmnopqrstuvwxyz\"".data(using: .utf8)

        expect({ try JSONEncoder().encode(sut) }).to(equal(expected))
    }

    func testCollectionSerializationWithMixedNames() {
        let taskA = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin")
        let taskB = SharedTask(id: "0000000000", accessCode: "aaaaa", name: nil)
        let taskC = SharedTask(id: "9999999999", accessCode: "zzzzz", name: "Ibuprofen")

        let sut = [taskA, taskB, taskC]

        let expected =
            "[\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin\",\"0000000000|aaaaa\",\"9999999999|zzzzz|Ibuprofen\"]"
                .data(using: .utf8)

        expect({ try JSONEncoder().encode(sut) }).to(equal(expected))
    }

    func testSingleDeserializationWithName() {
        let expected = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin")

        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) }).to(equal(expected))
    }

    func testSingleDeserializationWithEmptyName() {
        let expected = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: nil)

        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz|\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) }).to(equal(expected))
    }

    func testSingleDeserializationWithNameContainingSpaces() {
        let expected = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin Complex")

        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin Complex\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) }).to(equal(expected))
    }

    func testCollectionDeserializationWithMixedNames() {
        let sut =
            "[\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin\",\"0000000000|aaaaa\",\"9999999999|zzzzz|Ibuprofen\"]"
                .data(using: .utf8)!

        let taskA = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin")
        let taskB = SharedTask(id: "0000000000", accessCode: "aaaaa", name: nil)
        let taskC = SharedTask(id: "9999999999", accessCode: "zzzzz", name: "Ibuprofen")

        let expected = [taskA, taskB, taskC]

        expect({ try JSONDecoder().decode([SharedTask].self, from: sut) }).to(equal(expected))
    }

    // MARK: - Backward Compatibility Tests

    func testBackwardCompatibilityDeserialization() {
        // Test that old format without name still works
        let expected = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: nil)

        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) }).to(equal(expected))
    }

    // MARK: - Error Cases

    func testDeserializationWithTooManyComponents() {
        let sut = "\"1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin|ExtraComponent\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) })
            .to(throwError(SharedTask.Error
                    .tooManyComponents("1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin|ExtraComponent")))
    }

    func testDeserializationWithMissingSeparator() {
        let sut = "\"1234567890\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) })
            .to(throwError(SharedTask.Error.missingSeparator("1234567890")))
    }

    func testDeserializationWithEmptyString() {
        let sut = "\"\"".data(using: .utf8)!

        expect({ try JSONDecoder().decode(SharedTask.self, from: sut) })
            .to(throwError(SharedTask.Error.failedDecodingEmptyString("")))
    }

    // MARK: - AsString Property Tests

    func testAsStringWithName() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "Aspirin")

        expect(sut.asString).to(equal("1234567890|abcdefghijklmnopqrstuvwxyz|Aspirin"))
    }

    func testAsStringWithoutName() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: nil)

        expect(sut.asString).to(equal("1234567890|abcdefghijklmnopqrstuvwxyz"))
    }

    func testAsStringWithEmptyName() {
        let sut = SharedTask(id: "1234567890", accessCode: "abcdefghijklmnopqrstuvwxyz", name: "")

        expect(sut.asString).to(equal("1234567890|abcdefghijklmnopqrstuvwxyz|"))
    }

    // MARK: - ErxTask Integration Tests

    func testInitWithErxTaskWithMedication() {
        let medication = ErxMedication(name: "Test Medication")
        let erxTask = ErxTask(
            identifier: "task123",
            status: .ready,
            flowType: .directAssignment,
            accessCode: "access456",
            authoredOn: "2023-01-01",
            author: "Dr. Test",
            source: .scanner,
            medication: medication
        )

        let sut = SharedTask(with: erxTask)

        expect(sut.id).to(equal("task123"))
        expect(sut.accessCode).to(equal("access456"))
        expect(sut.name).to(equal("Test Medication"))
    }

    func testInitWithErxTaskWithoutMedication() {
        let erxTask = ErxTask(
            identifier: "task123",
            status: .ready,
            flowType: .directAssignment,
            accessCode: "access456",
            authoredOn: "2023-01-01",
            author: "Dr. Test",
            source: .scanner,
            medication: nil
        )

        let sut = SharedTask(with: erxTask)

        expect(sut.id).to(equal("task123"))
        expect(sut.accessCode).to(equal("access456"))
        expect(sut.name).to(beNil())
    }

    func testInitWithErxTaskWithEmptyAccessCode() {
        let medication = ErxMedication(name: "Test Medication")
        let erxTask = ErxTask(
            identifier: "task123",
            status: .ready,
            flowType: .directAssignment,
            accessCode: nil,
            authoredOn: "2023-01-01",
            author: "Dr. Test",
            source: .scanner,
            medication: medication
        )

        let sut = SharedTask(with: erxTask)

        expect(sut.id).to(equal("task123"))
        expect(sut.accessCode).to(equal(""))
        expect(sut.name).to(equal("Test Medication"))
    }
}
