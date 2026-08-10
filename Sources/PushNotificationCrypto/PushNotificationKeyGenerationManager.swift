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

import CryptoKit
import Foundation

/// A single key generation representing a derived key pair for a specific year-month.
public struct KeyGeneration: Equatable, Sendable, Codable {
    public let sharedSecret: Data
    public let aesGCMKey: Data
    public let yearMonth: String // format: "2015-05"

    public init(sharedSecret: Data, aesGCMKey: Data, yearMonth: String) {
        self.sharedSecret = sharedSecret
        self.aesGCMKey = aesGCMKey
        self.yearMonth = yearMonth
    }
}

/// Manages the HKDF-based key generation chain for push notification encryption.
///
/// Implements the gematik push notification encryption concept:
/// - Creates an initial shared secret (ISS)
/// - Derives monthly key generations using HKDF-SHA256
/// - Chains through intermediate months when months are skipped
/// - Enforces a 2-month retention policy (never deletes the youngest generation)
public enum PushNotificationKeyGenerationManager {
    // MARK: - ISS Creation

    /// Creates a new random initial shared secret (ISS) and records the current year-month.
    /// - Returns: A tuple of the ISS (32 bytes) and the year-month string when it was created.
    /// [REQ:gemF_PushNotification:A_27174] Generates iss (32 bytes, >=120 bit entropy) and time_iss_created
    public static func createInitialSharedSecret() -> (iss: Data, timeCreated: String) {
        let key = SymmetricKey(size: .bits256)
        let iss = key.withUnsafeBytes { Data(Array($0)) }
        let timeCreated = currentYearMonth()
        return (iss, timeCreated)
    }

    // MARK: - First Generation

    /// Derives the first key generation from the ISS.
    /// After calling this, the ISS should be deleted.
    /// - Parameters:
    ///   - iss: The initial shared secret (32 bytes).
    ///   - timeISSCreated: The year-month when the ISS was created (e.g. "2023-09").
    /// - Returns: The first `KeyGeneration`.
    /// [REQ:gemF_PushNotification:A_27176] Initial derivation of shared-secret/AES-key for time_iss_created
    public static func createFirstKeyGeneration(iss: Data, timeISSCreated: String) -> KeyGeneration {
//        let nextMonth = incrementMonth(timeISSCreated)
        let keyPair = PushNotificationKeyDerivation.deriveKeyPair(from: iss, info: timeISSCreated)
        return KeyGeneration(
            sharedSecret: keyPair.sharedSecret,
            aesGCMKey: keyPair.aesGCMKey,
            yearMonth: timeISSCreated
        )
    }

    // MARK: - Advance to Target Month

    /// Advances the key chain from a given generation to a target year-month,
    /// producing all intermediate generations.
    /// - Parameters:
    ///   - targetMonth: The target year-month string (e.g. "2024-01").
    ///   - current: The most recent generation available.
    /// - Returns: An array of all newly derived generations (not including `current`),
    ///   ordered oldest-first. Returns empty if `current` is already at or past `targetMonth`.
    /// [REQ:gemF_PushNotification:A_27179] Derives missing key generations up to time_message_encrypted
    public static func advanceTo(
        targetMonth: String,
        from current: KeyGeneration
    ) -> [KeyGeneration] {
        var generations: [KeyGeneration] = []
        var latest = current

        while latest.yearMonth < targetMonth {
            let nextMonth = incrementMonth(latest.yearMonth)
            let keyPair = PushNotificationKeyDerivation.deriveKeyPair(
                from: latest.sharedSecret,
                info: nextMonth
            )
            let generation = KeyGeneration(
                sharedSecret: keyPair.sharedSecret,
                aesGCMKey: keyPair.aesGCMKey,
                yearMonth: nextMonth
            )
            generations.append(generation)
            latest = generation
        }

        return generations
    }

    // MARK: - Cleanup

    /// Removes generations older than 2 months relative to `currentMonth`,
    /// but never removes the youngest (most recent) generation even if it is older than 2 months.
    /// - Parameters:
    ///   - currentMonth: The reference year-month (typically the current month).
    ///   - generations: The list of generations to clean up.
    /// - Returns: The filtered list of generations.
    /// [REQ:gemF_PushNotification:A_27180] Deletes secrets/keys older than two months relative to newest
    public static func cleanupOldKeyGenerations(
        currentMonth: String,
        generations: [KeyGeneration]
    ) -> [KeyGeneration] {
        guard generations.count > 1 else { return generations }

        let cutoff = decrementMonth(decrementMonth(currentMonth))

        let sorted = generations.sorted { $0.yearMonth < $1.yearMonth }

        guard let youngest = sorted.last else { return generations }
        return sorted.filter { generation in
            generation.yearMonth == youngest.yearMonth || generation.yearMonth > cutoff
        }
    }

    // MARK: - Month Arithmetic

    /// Increments a "YYYY-MM" string by one month, handling year rollover.
    public static func incrementMonth(_ yearMonth: String) -> String {
        let parts = yearMonth.split(separator: "-")
        guard parts.count == 2,
              var year = Int(parts[0]),
              var month = Int(parts[1]) else {
            preconditionFailure("Invalid yearMonth format: \(yearMonth). Expected YYYY-MM.")
        }

        month += 1
        if month > 12 {
            month = 1
            year += 1
        }

        return String(format: "%04d-%02d", year, month)
    }

    /// Decrements a "YYYY-MM" string by one month, handling year rollover.
    public static func decrementMonth(_ yearMonth: String) -> String {
        let parts = yearMonth.split(separator: "-")
        guard parts.count == 2,
              var year = Int(parts[0]),
              var month = Int(parts[1]) else {
            preconditionFailure("Invalid yearMonth format: \(yearMonth). Expected YYYY-MM.")
        }

        month -= 1
        if month < 1 {
            month = 12
            year -= 1
        }

        return String(format: "%04d-%02d", year, month)
    }

    /// Returns the current year-month string in "YYYY-MM" format.
    static func currentYearMonth() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard let year = components.year, let month = components.month else {
            // .year and .month from a Gregorian calendar on Date() can never be nil.
            preconditionFailure("Calendar could not provide year/month from Date()")
        }
        return String(format: "%04d-%02d", year, month)
    }
}
