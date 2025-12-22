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

import Combine
import Dependencies
import DependenciesMacros
import Foundation

/// Dependency client for secure user data storage (CAN operations only)
@DependencyClient
public struct SecureUserDataStoreClient {
    /// Retrieve the CAN for a profile
    public var can: (_ profileId: UUID) -> AnyPublisher<String?, Never> = { _ in
        Just(nil).eraseToAnyPublisher()
    }

    /// Set the CAN for a profile
    public var setCAN: (_ profileId: UUID, _ can: String?) -> Void = { _, _ in }

    /// Wipe CAN data for a profile
    public var wipe: (_ profileId: UUID) -> Void = { _ in }
}

extension SecureUserDataStoreClient: DependencyKey {
    public static var liveValue: SecureUserDataStoreClient {
        let keychainHelper = SystemKeychainAccessHelper()

        func egkPasswordIdentifier(for profileId: UUID) -> String {
            "\(profileId.uuidString).egk.can"
        }

        return SecureUserDataStoreClient(
            can: { profileId in
                Deferred {
                    Just(try? keychainHelper.genericPassword(for: egkPasswordIdentifier(for: profileId)))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            },
            setCAN: { profileId, can in
                do {
                    if let can = can {
                        _ = try keychainHelper.setGenericPassword(can, for: egkPasswordIdentifier(for: profileId))
                    } else {
                        _ = try keychainHelper.unsetGenericPassword(for: egkPasswordIdentifier(for: profileId))
                    }
                } catch {
                    // Handle error silently like KeychainStorage does
                }
            },
            wipe: { profileId in
                // [REQ:BSI-eRp-ePA:O.Auth_14#5|11] Deletion of CAN
                do {
                    _ = try keychainHelper.unsetGenericPassword(for: egkPasswordIdentifier(for: profileId))
                } catch {
                    // Handle error silently like KeychainStorage does
                }
            }
        )
    }

    public static let testValue = SecureUserDataStoreClient()
    public static let previewValue = SecureUserDataStoreClient()
}

extension DependencyValues {
    /// Secure user data store client dependency
    public var secureUserDataStoreClient: SecureUserDataStoreClient {
        get { self[SecureUserDataStoreClient.self] }
        set { self[SecureUserDataStoreClient.self] = newValue }
    }
}
