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

import CodedError
import CryptoKit
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct PushNotificationCrypto: Sendable {
    /// Decrypts a push notification ciphertext using the key derived for the given month.
    /// The ciphertext is expected to be AES/GCM combined format (nonce || ciphertext || tag).
    /// The decrypted payload is expected to have a PNM1 prefix with length header.
    /// Returns the actual payload after stripping the PNM1 framing.
    /// [REQ:gemF_PushNotification:A_27181] Decrypts payload with AES/GCM-Schlüssel for time_message_encrypted
    public var decrypt: @Sendable (
        _ cipher: Data,
        _ timeMessageEncrypted: String,
        _ keyIdentifier: String
    ) throws -> Data

    /// Creates a new random initial shared secret (ISS) for push notification registration.
    /// Returns the ISS data and the year-month when it was created.
    /// [REQ:gemF_PushNotification:A_27174] Generates iss and time_iss_created for FdV-Instanz registrieren
    public var createInitialSharedSecret: @Sendable () -> (iss: Data, timeCreated: String) = {
        (iss: Data(), timeCreated: "")
    }

    /// Initializes the key chain from an ISS, deriving the first generation and storing it.
    /// The ISS must not be stored after this call.
    /// [REQ:gemF_PushNotification:A_27176] Initial derivation of shared-secret/AES-key for time_iss_created
    /// [REQ:gemF_PushNotification:A_27177] Stores derived key material for decryption and re-derivation
    /// [REQ:gemF_PushNotification:A_27375] iss itself is not persisted - only derived key material is stored
    public var initializeKeyChain: @Sendable (
        _ iss: Data,
        _ timeISSCreated: String,
        _ keyIdentifier: String
    ) throws -> Void
}

extension DependencyValues {
    /// The push notification crypto client used for decryption and key chain management.
    public var pushNotificationCrypto: PushNotificationCrypto {
        get { self[PushNotificationCrypto.self] }
        set { self[PushNotificationCrypto.self] = newValue }
    }
}

extension PushNotificationCrypto: TestDependencyKey {
    public static let testValue: PushNotificationCrypto = Self()
}

extension PushNotificationCrypto: DependencyKey {
    public static let liveValue: PushNotificationCrypto = {
        @Dependency(\.pushNotificationCryptoStorage) var storage

        return Self(
            decrypt: { cipher, timeMessageEncrypted, keyIdentifier in
                guard var keyGeneration = try storage.loadKeyGeneration(
                    keyIdentifier,
                    timeMessageEncrypted
                ) else {
                    throw PushNotificationCryptoError.noKeyAvailable
                }

                // [REQ:gemF_PushNotification:A_27179] Advance key chain to time_message_encrypted if needed
                if keyGeneration.yearMonth < timeMessageEncrypted {
                    let newKeyGenerations = PushNotificationKeyGenerationManager.advanceTo(
                        targetMonth: timeMessageEncrypted,
                        from: keyGeneration
                    )
                    for gen in newKeyGenerations {
                        try storage.storeKeyGeneration(keyIdentifier, gen)
                    }
                    if let last = newKeyGenerations.last {
                        keyGeneration = last
                    }

                    // Cleanup old generations
                    let allKeyGenerations = try storage.loadAllKeyGenerations(keyIdentifier)
                    let cleanedKeyGenerations = PushNotificationKeyGenerationManager.cleanupOldKeyGenerations(
                        currentMonth: timeMessageEncrypted,
                        generations: allKeyGenerations
                    )
                    let keptMonths = Set(cleanedKeyGenerations.map(\.yearMonth))
                    let allStored = try storage.loadAllKeyGenerations(keyIdentifier)
                    let toDelete = allStored.map(\.yearMonth).filter { !keptMonths.contains($0) }
                    if !toDelete.isEmpty {
                        try storage.deleteKeyGenerations(keyIdentifier, toDelete)
                    }
                }

                // Find the generation matching the target month
                let allKeyGenerations = try storage.loadAllKeyGenerations(keyIdentifier)
                guard let targetGeneration = allKeyGenerations.first(
                    where: { $0.yearMonth == timeMessageEncrypted }
                ) else {
                    throw PushNotificationCryptoError.keyNotFoundForMonth(timeMessageEncrypted)
                }

                // [REQ:gemF_PushNotification:A_27181] Decrypt payload with AES/GCM-Schlüssel-Jahr-Monat
                let symmetricKey = SymmetricKey(data: targetGeneration.aesGCMKey)
                let sealedBox = try AES.GCM.SealedBox(combined: cipher)
                let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

                // Strip PNM1 prefix + length header
                return try PNM1Framing.strip(decryptedData)
            },

            createInitialSharedSecret: {
                PushNotificationKeyGenerationManager.createInitialSharedSecret()
            },

            initializeKeyChain: { iss, timeISSCreated, keyIdentifier in
                let firstKeyGeneration = PushNotificationKeyGenerationManager.createFirstKeyGeneration(
                    iss: iss,
                    timeISSCreated: timeISSCreated
                )
                try storage.storeKeyGeneration(keyIdentifier, firstKeyGeneration)
            }
        )
    }()
}

// MARK: - PNM1 Payload Framing

/// Namespace for PNM1 push notification payload framing as specified in A_27610.
/// Format: "PNM1" (4 bytes) + spacer length (2 bytes big-endian) + spaces (spacer length bytes) + payload
/// Total framed size is always 1024 bytes.
public enum PNM1Framing {
    /// Applies PNM1 framing to a plaintext payload (A_27610).
    public static func apply(_ payload: Data) -> Data {
        let prefix = Data("PNM1".utf8)
        let spacerLength = UInt16(1024 - payload.count - 2 - 4)
        var spacerLengthBE = spacerLength.bigEndian
        let spacerLengthData = Data(bytes: &spacerLengthBE, count: 2)
        let spacer = Data(repeating: 0x20, count: Int(spacerLength))
        return prefix + spacerLengthData + spacer + payload
    }

    /// Strips the PNM1 prefix and length header from decrypted push notification data.
    public static func strip(_ data: Data) throws -> Data {
        let prefix = Data("PNM1".utf8)

        guard data.count >= prefix.count + 2 else {
            throw PushNotificationCryptoError.invalidPayloadTooShort
        }

        guard data.prefix(prefix.count) == prefix else {
            throw PushNotificationCryptoError.invalidPNM1Prefix
        }

        let lengthStart = prefix.count
        let lengthData = data[lengthStart ..< (lengthStart + 2)]
        let paddingLength = Int(UInt16(bigEndian: lengthData.withUnsafeBytes { $0.load(as: UInt16.self) }))

        let payloadStart = prefix.count + 2 + paddingLength
        guard payloadStart <= data.count else {
            throw PushNotificationCryptoError.invalidPayloadLength
        }

        return Data(data[payloadStart...])
    }
}

// MARK: - Errors

@CodedError("700")
public enum PushNotificationCryptoError: Error, Equatable {
    @ErrorCode("01")
    case noKeyAvailable
    @ErrorCode("02")
    case keyNotFoundForMonth(String)
    @ErrorCode("03")
    case invalidPayloadTooShort
    @ErrorCode("04")
    case invalidPNM1Prefix
    @ErrorCode("05")
    case invalidPayloadLength
    /// A keychain operation failed with the given OSStatus code and message.
    @ErrorCode("06")
    case storageError(status: OSStatus, message: String)
}
