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

import Foundation
@testable import PushNotificationCrypto
import Testing

@Suite("Key Generation Manager")
struct PushNotificationKeyGenerationManagerTests {
    let specISS = Data(hexEncoded: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2")

    @Test("First generation from ISS produces correct month and keys")
    func createFirstGeneration() {
        let gen = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
            iss: specISS,
            timeISSCreated: "2023-09"
        )

        #expect(gen.yearMonth == "2023-09")
        #expect(gen.sharedSecret.hexEncodedString
            == "f099ac874c05856b815ac88a93a628df5fd28b8cddd1a88ce53d7b3a3e3563e6")
        #expect(gen.aesGCMKey.hexEncodedString
            == "e2957d2f86ee3bc8e567c48e7f27c31870504af06e1bed8dde2ed910a0b252e8")
    }

    @Test("Advance to next month produces single generation with correct keys")
    func advanceToNextMonth() {
        let september = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
            iss: specISS,
            timeISSCreated: "2023-09"
        )

        let newGenerations = PushNotificationKeyGenerationManager.advanceTo(
            targetMonth: "2023-10",
            from: september
        )

        #expect(newGenerations.count == 1)
        #expect(newGenerations[0].yearMonth == "2023-10")
        #expect(newGenerations[0].sharedSecret.hexEncodedString
            == "039caceaa77b2cb9c8d35561389ae0f8740d49404b5b2eb23f00a51a4dfbfd54")
        #expect(newGenerations[0].aesGCMKey.hexEncodedString
            == "cbfe3ae30ef49df59fca17c88d60392927ae15923641f22366f82a1203624a70")
    }

    @Test("Advance across skipped months chains correctly")
    func advanceToSkippedMonths() {
        let september = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
            iss: specISS,
            timeISSCreated: "2023-09"
        )

        let newGenerations = PushNotificationKeyGenerationManager.advanceTo(
            targetMonth: "2023-12",
            from: september
        )

        #expect(newGenerations.count == 3)
        #expect(newGenerations[0].yearMonth == "2023-10")
        #expect(newGenerations[1].yearMonth == "2023-11")
        #expect(newGenerations[2].yearMonth == "2023-12")

        let octFromSep = PushNotificationKeyDerivation.deriveKeyPair(
            from: september.sharedSecret, info: "2023-10"
        )
        #expect(newGenerations[0].sharedSecret == octFromSep.sharedSecret)
        #expect(newGenerations[0].aesGCMKey == octFromSep.aesGCMKey)

        let novFromOct = PushNotificationKeyDerivation.deriveKeyPair(
            from: newGenerations[0].sharedSecret, info: "2023-11"
        )
        #expect(newGenerations[1].sharedSecret == novFromOct.sharedSecret)
        #expect(newGenerations[1].aesGCMKey == novFromOct.aesGCMKey)
    }

    @Test("Advance to same month returns empty")
    func advanceToSameMonth() {
        let september = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
            iss: specISS,
            timeISSCreated: "2023-09"
        )

        let newGenerations = PushNotificationKeyGenerationManager.advanceTo(
            targetMonth: "2023-09",
            from: september
        )

        #expect(newGenerations.isEmpty)
    }

    @Test("Advance to past month returns empty")
    func advanceToPastMonth() {
        let september = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
            iss: specISS,
            timeISSCreated: "2023-09"
        )

        let newGenerations = PushNotificationKeyGenerationManager.advanceTo(
            targetMonth: "2023-08",
            from: september
        )

        #expect(newGenerations.isEmpty)
    }

    @Test("Year rollover from December handled correctly")
    func advanceToYearRollover() {
        let december = KeyGeneration(
            sharedSecret: Data(repeating: 0x42, count: 32),
            aesGCMKey: Data(repeating: 0x43, count: 32),
            yearMonth: "2023-12"
        )

        let newGenerations = PushNotificationKeyGenerationManager.advanceTo(
            targetMonth: "2024-02",
            from: december
        )

        #expect(newGenerations.count == 2)
        #expect(newGenerations[0].yearMonth == "2024-01")
        #expect(newGenerations[1].yearMonth == "2024-02")
    }

    @Test("Increment regular month")
    func incrementMonthRegular() {
        #expect(PushNotificationKeyGenerationManager.incrementMonth("2023-10") == "2023-11")
    }

    @Test("Increment December rolls over to January")
    func incrementMonthDecember() {
        #expect(PushNotificationKeyGenerationManager.incrementMonth("2023-12") == "2024-01")
    }

    @Test("Decrement regular month")
    func decrementMonthRegular() {
        #expect(PushNotificationKeyGenerationManager.decrementMonth("2023-11") == "2023-10")
    }

    @Test("Decrement January rolls back to December")
    func decrementMonthJanuary() {
        #expect(PushNotificationKeyGenerationManager.decrementMonth("2024-01") == "2023-12")
    }

    @Test("Cleanup removes generations older than two months")
    func cleanupRemovesOld() {
        let generations: [KeyGeneration] = [
            makeGeneration("2023-08"),
            makeGeneration("2023-09"),
            makeGeneration("2023-10"),
            makeGeneration("2023-11"),
        ]

        let result = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
            currentMonth: "2023-11",
            generations: generations
        )

        let months = result.map(\.yearMonth)
        #expect(months == ["2023-10", "2023-11"])
    }

    @Test("Cleanup never deletes the youngest generation")
    func cleanupNeverDeletesYoungest() {
        let generations: [KeyGeneration] = [
            makeGeneration("2023-06"),
        ]

        let result = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
            currentMonth: "2023-11",
            generations: generations
        )

        #expect(result.count == 1)
        #expect(result[0].yearMonth == "2023-06")
    }

    @Test("Cleanup keeps youngest even if all generations are old")
    func cleanupKeepsYoungestEvenIfAllOld() {
        let generations: [KeyGeneration] = [
            makeGeneration("2023-01"),
            makeGeneration("2023-02"),
            makeGeneration("2023-03"),
        ]

        let result = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
            currentMonth: "2023-11",
            generations: generations
        )

        #expect(result.count == 1)
        #expect(result[0].yearMonth == "2023-03")
    }

    @Test("Cleanup on empty array is a no-op")
    func cleanupEmptyArray() {
        let generations: [KeyGeneration] = []

        let result = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
            currentMonth: "2023-11",
            generations: generations
        )

        #expect(result.isEmpty)
    }

    @Test("Cleanup keeps single recent generation")
    func cleanupSingleRecent() {
        let generations: [KeyGeneration] = [
            makeGeneration("2023-11"),
        ]

        let result = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
            currentMonth: "2023-11",
            generations: generations
        )

        #expect(result.count == 1)
    }

    @Test("ISS creation returns 32 bytes with valid YYYY-MM format")
    func createInitialSharedSecretFormat() {
        let (iss, timeCreated) = PushNotificationKeyGenerationManager.createInitialSharedSecret()

        #expect(iss.count == 32)
        #expect(!timeCreated.isEmpty)
        let parts = timeCreated.split(separator: "-")
        #expect(parts.count == 2)
        #expect(Int(parts[0]) != nil)
        #expect(Int(parts[1]) != nil)
    }

    @Test("ISS creation produces random values")
    func createInitialSharedSecretRandom() {
        let (iss1, _) = PushNotificationKeyGenerationManager.createInitialSharedSecret()
        let (iss2, _) = PushNotificationKeyGenerationManager.createInitialSharedSecret()

        #expect(iss1 != iss2)
    }

    private func makeGeneration(_ yearMonth: String) -> KeyGeneration {
        KeyGeneration(
            sharedSecret: Data(repeating: 0x01, count: 32),
            aesGCMKey: Data(repeating: 0x02, count: 32),
            yearMonth: yearMonth
        )
    }
}
