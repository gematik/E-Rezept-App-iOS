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
import IDP
import Profiles

/// Dependency client for IDP storage operations
@DependencyClient
struct IDPStorageClient {
    /// Retrieve the IDP token for a profile
    var token: (_ profileId: UUID) -> AnyPublisher<IDPToken?, Never> = { _ in
        Just(nil).eraseToAnyPublisher()
    }

    /// Set the IDP token for a profile
    var setToken: (_ profileId: UUID, _ token: IDPToken?) -> Void = { _, _ in }

    /// Retrieve the discovery document (global, not profile-specific)
    var discoveryDocument: () -> AnyPublisher<DiscoveryDocument?, Never> = {
        Just(nil).eraseToAnyPublisher()
    }

    /// Set the discovery document (global, not profile-specific)
    var setDiscoveryDocument: (_ document: DiscoveryDocument?) -> Void = { _ in }

    /// Wipe IDP data for a profile (token and discovery document)
    var wipe: (_ profileId: UUID) -> Void = { _ in }
}

extension IDPStorageClient: DependencyKey {
    static var liveValue: IDPStorageClient {
        let keychainHelper = SystemKeychainAccessHelper()

        func idpTokenIdentifier(for profileId: UUID) -> String {
            "\(profileId.uuidString).idp.token"
        }

        let idpDiscoveryDocumentIdentifier = "idp.discovery"

        return IDPStorageClient(
            token: { profileId in
                Deferred {
                    guard let result = try? keychainHelper.genericPasswordData(for: idpTokenIdentifier(for: profileId)),
                          let token = try? JSONDecoder().decode(IDPToken.self, from: result)
                    else { return Just(nil).eraseToAnyPublisher() as AnyPublisher<IDPToken?, Never> }

                    return Just(token).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            },
            setToken: { profileId, token in
                do {
                    if let token,
                       let tokenData = try? JSONEncoder().encode(token) {
                        _ = try keychainHelper.setGenericPassword(tokenData, for: idpTokenIdentifier(for: profileId))
                    } else {
                        _ = try keychainHelper.unsetGenericPassword(for: idpTokenIdentifier(for: profileId))
                    }
                } catch {
                    // Handle error silently like KeychainStorage does
                }
            },
            discoveryDocument: {
                Deferred {
                    guard let result = try? keychainHelper.genericPasswordData(for: idpDiscoveryDocumentIdentifier),
                          let archiver = try? NSKeyedUnarchiver(forReadingFrom: result),
                          let document = try? archiver.decodeTopLevelDecodable(
                              DiscoveryDocument.self,
                              forKey: NSKeyedArchiveRootObjectKey
                          )
                    else {
                        return Just(nil).eraseToAnyPublisher() as AnyPublisher<DiscoveryDocument?, Never>
                    }

                    return Just(document).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            },
            setDiscoveryDocument: { document in
                do {
                    if let document {
                        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                        archiver.outputFormat = .binary
                        try archiver.encodeEncodable(document, forKey: NSKeyedArchiveRootObjectKey)
                        archiver.finishEncoding()
                        let encodedDocument = archiver.encodedData
                        _ = try keychainHelper.setGenericPassword(encodedDocument, for: idpDiscoveryDocumentIdentifier)
                    } else {
                        _ = try keychainHelper.unsetGenericPassword(for: idpDiscoveryDocumentIdentifier)
                    }
                } catch {
                    // Handle error silently like KeychainStorage does
                }
            },
            wipe: { profileId in
                // [REQ:gemSpec_IDP_Frontend:A_20499,A_20499-1#3] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
                // [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
                do {
                    _ = try keychainHelper.unsetGenericPassword(for: idpTokenIdentifier(for: profileId))
                    _ = try keychainHelper.unsetGenericPassword(for: idpDiscoveryDocumentIdentifier)
                } catch {
                    // Handle error silently like KeychainStorage does
                }
            }
        )
    }

    static let testValue = IDPStorageClient()
    static let previewValue = IDPStorageClient()
}

extension DependencyValues {
    var idpStorageClient: IDPStorageClient {
        get { self[IDPStorageClient.self] }
        set { self[IDPStorageClient.self] = newValue }
    }
}
