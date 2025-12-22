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
import OpenSSL
import Profiles

/// Dependency client for secure EGK certificate storage operations
@DependencyClient
struct SecureEGKCertificateStorageClient {
    /// Retrieve the certificate for a profile
    var certificate: (_ profileId: UUID) -> AnyPublisher<X509?, Never> = { _ in
        Just(nil).eraseToAnyPublisher()
    }

    /// Set the certificate for a profile
    var setCertificate: (_ profileId: UUID, _ certificate: X509?) throws -> Void = { _, _ in }

    /// Retrieve the key identifier for a profile
    var keyIdentifier: (_ profileId: UUID) -> AnyPublisher<Data?, Never> = { _ in
        Just(nil).eraseToAnyPublisher()
    }

    /// Set the key identifier for a profile
    var setKeyIdentifier: (_ profileId: UUID, _ keyIdentifier: Data?) throws -> Void = { _, _ in }

    /// Wipe certificate data for a profile (certificate only, keyIdentifier is handled separately)
    var wipe: (_ profileId: UUID) throws -> Void = { _ in }
}

extension SecureEGKCertificateStorageClient: DependencyKey {
    static var liveValue: SecureEGKCertificateStorageClient {
        let keychainHelper = SystemKeychainAccessHelper()

        func egkAuthCertIdentifier(for profileId: UUID) -> String {
            "\(profileId.uuidString).egk.authCert"
        }

        func idpBiometricKeyIdentifier(for profileId: UUID) -> String {
            "\(profileId.uuidString).egk.biometricKeyIdentifier"
        }

        return SecureEGKCertificateStorageClient(
            certificate: { profileId in
                Deferred {
                    guard let derBytes = try? keychainHelper
                        .genericPasswordData(for: egkAuthCertIdentifier(for: profileId)),
                        let certificate = try? X509(der: derBytes)
                    else {
                        return Just(nil).eraseToAnyPublisher() as AnyPublisher<X509?, Never>
                    }

                    return Just(certificate).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            },
            setCertificate: { profileId, certificate in
                if let derBytes = certificate?.derBytes {
                    _ = try keychainHelper.setGenericPassword(derBytes, for: egkAuthCertIdentifier(for: profileId))
                } else {
                    _ = try keychainHelper.unsetGenericPassword(for: egkAuthCertIdentifier(for: profileId))
                }
            },
            keyIdentifier: { profileId in
                Deferred {
                    Just(try? keychainHelper.genericPasswordData(for: idpBiometricKeyIdentifier(for: profileId)))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            },
            setKeyIdentifier: { profileId, keyIdentifier in
                if let keyIdentifier = keyIdentifier {
                    _ = try keychainHelper.setGenericPassword(
                        keyIdentifier,
                        for: idpBiometricKeyIdentifier(for: profileId)
                    )
                } else {
                    _ = try keychainHelper.unsetGenericPassword(for: idpBiometricKeyIdentifier(for: profileId))
                }
            },
            wipe: { profileId in
                // [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
                // Note: `keyIdentifier` is not wiped here because it's deletion is done asynchronously
                // together with the secure enclave representative in `ProfileSecureDataWiper`
                _ = try keychainHelper.unsetGenericPassword(for: egkAuthCertIdentifier(for: profileId))
            }
        )
    }

    static let testValue = SecureEGKCertificateStorageClient()
    static let previewValue = SecureEGKCertificateStorageClient()
}

extension DependencyValues {
    var secureEGKCertificateStorageClient: SecureEGKCertificateStorageClient {
        get { self[SecureEGKCertificateStorageClient.self] }
        set { self[SecureEGKCertificateStorageClient.self] = newValue }
    }
}
