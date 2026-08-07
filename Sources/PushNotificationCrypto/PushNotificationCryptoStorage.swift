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

import Dependencies
import DependenciesMacros
import Foundation
import Security

@DependencyClient
public struct PushNotificationCryptoStorage: Sendable {
    /// Stores a key generation for a given key identifier.
    /// [REQ:gemF_PushNotification:A_27177] Persists shared-secret/AES-key for decryption and re-derivation
    public var storeKeyGeneration: @Sendable (_ keyIdentifier: String, _ generation: KeyGeneration) throws -> Void

    /// Loads the most recent key generation for a given key identifier
    /// whose yearMonth is less than or equal to the given `timeMessageEncrypted`.
    public var loadKeyGeneration: @Sendable (
        _ keyIdentifier: String,
        _ timeMessageEncrypted: String
    ) throws -> KeyGeneration?

    /// Loads all stored key generations for a given key identifier, ordered by yearMonth ascending.
    public var loadAllKeyGenerations: @Sendable (_ keyIdentifier: String) throws -> [KeyGeneration]

    /// Deletes key generations for a given key identifier whose yearMonth is in the provided set.
    /// [REQ:gemF_PushNotification:A_27180] Deletes secrets/keys older than two months relative to newest
    public var deleteKeyGenerations: @Sendable (_ keyIdentifier: String, _ yearMonths: [String]) throws -> Void
}

extension DependencyValues {
    /// The push notification crypto storage client used for persisting key generations.
    public var pushNotificationCryptoStorage: PushNotificationCryptoStorage {
        get { self[PushNotificationCryptoStorage.self] }
        set { self[PushNotificationCryptoStorage.self] = newValue }
    }
}

extension PushNotificationCryptoStorage: TestDependencyKey {
    public static let testValue: PushNotificationCryptoStorage = Self()
}

// MARK: - Keychain-backed live implementation

extension PushNotificationCryptoStorage: DependencyKey {
    static let accessGroup: String = Bundle.main.gemAppGroupIdentifier

    /// Service identifier for all push notification crypto keychain items.
    static let service = "de.gematik.erp.pushNotificationCrypto"

    /// Builds the keychain account string for a specific generation.
    /// Format: `"pushcrypto.{keyIdentifier}.{yearMonth}"`
    static func account(keyIdentifier: String, yearMonth: String) -> String {
        "pushcrypto.\(keyIdentifier).\(yearMonth)"
    }

    /// Account prefix used for querying all generations belonging to a key identifier.
    static func accountPrefix(keyIdentifier: String) -> String {
        "pushcrypto.\(keyIdentifier)."
    }

    public static let liveValue: PushNotificationCryptoStorage = Self(
        storeKeyGeneration: { keyIdentifier, generation in
            let accountString = account(keyIdentifier: keyIdentifier, yearMonth: generation.yearMonth)
            let data = try JSONEncoder().encode(generation)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: accountString,
                kSecAttrAccessGroup as String: accessGroup,
            ]

            // Try to update first; if not found, add new item
            let updateAttributes: [String: Any] = [kSecValueData as String: data]
            var status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

            if status == errSecItemNotFound {
                var addQuery = query
                addQuery[kSecValueData as String] = data
                addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                status = SecItemAdd(addQuery as CFDictionary, nil)
            }

            guard status == errSecSuccess else {
                let message = SecCopyErrorMessageString(status, nil).map { String($0) } ?? "unknown"
                throw PushNotificationCryptoError.storageError(status: status, message: message)
            }
        },

        loadKeyGeneration: { keyIdentifier, timeMessageEncrypted in
            let allGenerations = try liveValue.loadAllKeyGenerations(keyIdentifier)
            return allGenerations
                .filter { $0.yearMonth <= timeMessageEncrypted }
                .max { $0.yearMonth < $1.yearMonth }
        },

        loadAllKeyGenerations: { keyIdentifier in
            let prefix = accountPrefix(keyIdentifier: keyIdentifier)

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccessGroup as String: accessGroup,
                kSecMatchLimit as String: kSecMatchLimitAll,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true,
            ]

            var items: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &items)

            if status == errSecItemNotFound {
                return []
            }

            guard status == errSecSuccess,
                  let results = items as? [[String: Any]] else {
                let message = SecCopyErrorMessageString(status, nil).map { String($0) } ?? "unknown"
                throw PushNotificationCryptoError.storageError(status: status, message: message)
            }

            let decoder = JSONDecoder()
            return results
                .compactMap { item -> KeyGeneration? in
                    guard let accountData = item[kSecAttrAccount as String] as? String,
                          accountData.hasPrefix(prefix),
                          let data = item[kSecValueData as String] as? Data,
                          let generation = try? decoder.decode(KeyGeneration.self, from: data)
                    else { return nil }
                    return generation
                }
                .sorted { $0.yearMonth < $1.yearMonth }
        },

        deleteKeyGenerations: { keyIdentifier, yearMonths in
            for yearMonth in yearMonths {
                let accountString = account(keyIdentifier: keyIdentifier, yearMonth: yearMonth)

                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: service,
                    kSecAttrAccount as String: accountString,
                    kSecAttrAccessGroup as String: accessGroup,
                ]

                let status = SecItemDelete(query as CFDictionary)
                if status != errSecSuccess, status != errSecItemNotFound {
                    let message = SecCopyErrorMessageString(status, nil).map { String($0) } ?? "unknown"
                    throw PushNotificationCryptoError.storageError(status: status, message: message)
                }
            }
        }
    )
}

private extension Bundle { // swiftlint:disable:this no_extension_access_modifier
    /// App group shared between the main app and the PushNotificationService extension,
    /// enabling both to access the same keychain items.
    /// Reads the value from the hosting bundle's Info.plist (`GEMAppGroupIdentifier` key)
    /// so that derived apps (d-rezept, konny) use their own app group identifier.
    var gemAppGroupIdentifier: String {
        infoDictionary?["GEMAppGroupIdentifier"] as? String ?? "group.de.gematik.erezept.pngroup"
    }
}
