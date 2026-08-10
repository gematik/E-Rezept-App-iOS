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

import ConcurrencyExtras
import CryptoKit
import Dependencies
import Foundation
@testable import PushNotificationCrypto
import Testing

/// Thread-safe counters for tracking how often each storage endpoint is called.
struct StorageCallCounts {
    let store = LockIsolated(0)
    let load = LockIsolated(0)
    let loadAll = LockIsolated(0)
    let delete = LockIsolated(0)
}

@Suite("Decryption & PNM1 Framing")
struct PushNotificationCryptoDecryptionTests {
    let specISS = Data(hexEncoded: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2")

    /// Wires mocked storage with call counting into `withDependencies`.
    private func withMockedStorage(
        storedGenerations: LockIsolated<[String: [KeyGeneration]]>,
        counts: StorageCallCounts,
        operation: () throws -> Void
    ) throws {
        try withDependencies {
            $0.pushNotificationCryptoStorage.storeKeyGeneration = { id, gen in
                counts.store.withValue { $0 += 1 }
                storedGenerations.withValue { $0[id, default: []].append(gen) }
            }
            $0.pushNotificationCryptoStorage.loadKeyGeneration = { id, month in
                counts.load.withValue { $0 += 1 }
                return storedGenerations.withValue {
                    $0[id]?.filter { $0.yearMonth <= month }.max(by: { $0.yearMonth < $1.yearMonth })
                }
            }
            $0.pushNotificationCryptoStorage.loadAllKeyGenerations = { id in
                counts.loadAll.withValue { $0 += 1 }
                return storedGenerations.withValue {
                    ($0[id] ?? []).sorted(by: { $0.yearMonth < $1.yearMonth })
                }
            }
            $0.pushNotificationCryptoStorage.deleteKeyGenerations = { id, months in
                counts.delete.withValue { $0 += 1 }
                storedGenerations.withValue { $0[id]?.removeAll(where: { months.contains($0.yearMonth) }) }
            }
            $0.pushNotificationCrypto = .liveValue
        } operation: {
            try operation()
        }
    }

    @Test("Decrypt round-trip with derived key")
    func decryptRoundTrip() throws {
        let keyPair = PushNotificationKeyDerivation.deriveKeyPair(from: specISS, info: "2023-09")
        let symmetricKey = SymmetricKey(data: keyPair.aesGCMKey)

        let payload = Data("{\"test\":\"hello\"}".utf8)
        let framedPayload = createPNM1FramedPayload(payload)

        let sealedBox = try AES.GCM.seal(framedPayload, using: symmetricKey)
        let ciphertext = try #require(sealedBox.combined)

        let storedGenerations = LockIsolated<[String: [KeyGeneration]]>([:])
        let counts = StorageCallCounts()
        let keyId = "test-key"

        try withMockedStorage(storedGenerations: storedGenerations, counts: counts) {
            @Dependency(\.pushNotificationCrypto) var crypto
            try crypto.initializeKeyChain(specISS, "2023-09", keyId)
            let decrypted = try crypto.decrypt(ciphertext, "2023-09", keyId)
            #expect(decrypted == payload)
        }

        // initializeKeyChain stores 1 generation (for 2023-09, derived from ISS + "2023-09")
        #expect(counts.store.value == 1)
        // decrypt calls loadKeyGeneration once
        #expect(counts.load.value == 1)
        // no advance needed (stored gen is already 2023-09), so only 1 loadAll for target lookup
        #expect(counts.loadAll.value == 1)
        // no old generations to delete
        #expect(counts.delete.value == 0)
    }

    @Test("Decrypt with advanced month auto-chains and decrypts")
    func decryptWithAdvancedMonth() throws {
        let storedGenerations = LockIsolated<[String: [KeyGeneration]]>([:])
        let counts = StorageCallCounts()
        let keyId = "test-key"

        // Chain from ISS: 2023-09 → 2023-10 → 2023-11
        let sepSharedSecret = PushNotificationKeyDerivation.deriveKeyPair(from: specISS, info: "2023-09").sharedSecret
        let octSharedSecret = PushNotificationKeyDerivation.deriveKeyPair(from: sepSharedSecret, info: "2023-10")
            .sharedSecret
        let novKeyPair = PushNotificationKeyDerivation.deriveKeyPair(from: octSharedSecret, info: "2023-11")
        let symmetricKey = SymmetricKey(data: novKeyPair.aesGCMKey)
        let payload = Data("test payload".utf8)
        let framedPayload = createPNM1FramedPayload(payload)
        let sealedBox = try AES.GCM.seal(framedPayload, using: symmetricKey)
        let ciphertext = try #require(sealedBox.combined)

        try withMockedStorage(storedGenerations: storedGenerations, counts: counts) {
            @Dependency(\.pushNotificationCrypto) var crypto
            try crypto.initializeKeyChain(specISS, "2023-09", keyId)
            let decrypted = try crypto.decrypt(ciphertext, "2023-11", keyId)
            #expect(decrypted == payload)
        }

        // initializeKeyChain stores 1 (2023-09), decrypt advancing 09→10→11 stores 2
        #expect(counts.store.value == 3)
        // decrypt calls loadKeyGeneration once
        #expect(counts.load.value == 1)
        // decrypt: 2× loadAll for cleanup + 1× loadAll for target lookup
        #expect(counts.loadAll.value == 3)
        // cleanup: cutoff = decrementMonth(decrementMonth("2023-11")) = "2023-09"
        // "2023-09" is NOT > "2023-09" and is NOT youngest "2023-11" → deleted
        // "2023-10" > "2023-09" → kept. "2023-11" is youngest → kept.
        #expect(counts.delete.value == 1)
    }

    @Test("Decrypt throws noKeyAvailable when no key is stored")
    func decryptFailsWithNoKey() {
        let counts = StorageCallCounts()
        withDependencies {
            $0.pushNotificationCryptoStorage.loadKeyGeneration = { _, _ in
                counts.load.withValue { $0 += 1 }
                return nil
            }
            $0.pushNotificationCryptoStorage.loadAllKeyGenerations = { _ in
                counts.loadAll.withValue { $0 += 1 }
                return []
            }
            $0.pushNotificationCrypto = .liveValue
        } operation: {
            @Dependency(\.pushNotificationCrypto) var crypto
            #expect(throws: PushNotificationCryptoError.noKeyAvailable) {
                _ = try crypto.decrypt(Data(), "2023-10", "key")
            }
        }

        // Only loadKeyGeneration is called, then it throws immediately
        #expect(counts.load.value == 1)
        #expect(counts.loadAll.value == 0)
        #expect(counts.store.value == 0)
        #expect(counts.delete.value == 0)
    }

    @Test("Strip PNM1 framing from valid payload")
    func stripPNM1Valid() throws {
        let payload = Data("hello world".utf8)
        let framed = createPNM1FramedPayload(payload)

        let result = try PNM1Framing.strip(framed)
        #expect(result == payload)
    }

    @Test("Strip PNM1 throws on invalid prefix")
    func stripPNM1InvalidPrefix() {
        let badData = Data("BADX\u{00}\u{00}payload".utf8)

        #expect(throws: PushNotificationCryptoError.invalidPNM1Prefix) {
            try PNM1Framing.strip(badData)
        }
    }

    @Test("Strip PNM1 throws on too-short data")
    func stripPNM1TooShort() {
        let shortData = Data("PNM".utf8)

        #expect(throws: PushNotificationCryptoError.invalidPayloadTooShort) {
            try PNM1Framing.strip(shortData)
        }
    }

    @Test("Strip PNM1 throws on invalid length")
    func stripPNM1InvalidLength() {
        var badData = Data("PNM1".utf8)
        badData.append(contentsOf: [0x03, 0xE7]) // 999 in big-endian
        badData.append(Data("x".utf8))

        #expect(throws: PushNotificationCryptoError.invalidPayloadLength) {
            try PNM1Framing.strip(badData)
        }
    }

    @Test("Strip PNM1 with padding")
    func stripPNM1WithPadding() throws {
        let payload = Data("{\"key\":\"value\"}".utf8)
        let paddingLength: UInt16 = 5
        var framed = Data("PNM1".utf8)
        var len = paddingLength.bigEndian
        framed.append(Data(bytes: &len, count: 2))
        framed.append(Data(repeating: 0x20, count: Int(paddingLength)))
        framed.append(payload)

        let result = try PNM1Framing.strip(framed)
        #expect(result == payload)
    }

    private func createPNM1FramedPayload(_ payload: Data) -> Data {
        var framed = Data("PNM1".utf8)
        var paddingLength: UInt16 = 0
        framed.append(Data(bytes: &paddingLength, count: 2))
        framed.append(payload)
        return framed
    }
}
