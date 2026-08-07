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

/// Derives a key pair (shared secret + AES/GCM key) from an input secret and a year-month info string
/// using HKDF-SHA256 as specified in the gematik push notification encryption concept.
///
/// The derivation produces 64 bytes:
/// - First 32 bytes: shared secret for the given month (input for deriving the next month)
/// - Last 32 bytes: AES/GCM-256 encryption key for the given month
public enum PushNotificationKeyDerivation {
    public struct KeyPair: Equatable, Sendable {
        public let sharedSecret: Data
        public let aesGCMKey: Data

        public init(sharedSecret: Data, aesGCMKey: Data) {
            self.sharedSecret = sharedSecret
            self.aesGCMKey = aesGCMKey
        }
    }

    /// Derives a key pair from `secret` using `info` (format: "YYYY-MM").
    /// - Parameters:
    ///   - secret: The input key material (ISS or previous month's shared secret), 32 bytes.
    ///   - info: The year-month string, e.g. "2023-10".
    /// - Returns: A `KeyPair` containing the derived shared secret and AES/GCM key.
    /// [REQ:gemF_PushNotification:A_27170-01] HKDF-SHA256 derives 64 bytes (shared secret + AES/GCM key) for yyyy-MM
    public static func deriveKeyPair(from secret: Data, info: String) -> KeyPair {
        let inputKeyMaterial = SymmetricKey(data: secret)
        let infoData = Data(info.utf8)

        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKeyMaterial,
            info: infoData,
            outputByteCount: 64
        )

        let derivedBytes = derivedKey.withUnsafeBytes { Data(Array($0)) }
        let sharedSecret = derivedBytes.prefix(32)
        let aesGCMKey = derivedBytes.suffix(32)

        return KeyPair(
            sharedSecret: Data(sharedSecret),
            aesGCMKey: Data(aesGCMKey)
        )
    }
}
