//
//  Copyright (c) 2024 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
import eRpKit
import Foundation
import IDP
import OpenSSL

// [REQ:gemSpec_eRp_FdV:A_19186]
// [REQ:gemSpec_eRp_FdV:A_19188] Deletion of data saved here is managed by the OS.
// [REQ:gemSpec_IDP_Frontend:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
// [REQ:BSI-eRp-ePA:O.Purp_8#1,O.Arch_2#5,O.Arch_4#3,O.Source_7#2,O.Data_2#2] Implementation of data storage that is
// persisted via keychain
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
    private let schedulers: Schedulers
    @Published private var tokenState: IDPToken?
    @Published private var accessTokenState: String?

    internal var keychainHelper: KeychainAccessHelper = SystemKeychainAccessHelper()

    private let profileId: UUID

    var profilePrefix: String {
        "\(profileId.uuidString)."
    }

    // tag::KeychainStorageInitializerSignature[]
    init(profileId: UUID, schedulers: Schedulers = Schedulers()) {
        self.profileId = profileId
        self.schedulers = schedulers
        // end::KeychainStorageInitializerSignature[]

        $tokenState.map { $0?.accessToken }
            .receive(on: schedulers.main)
            .assign(to: &$accessTokenState)
    }

    var can: AnyPublisher<String?, Never> {
        retrieveCAN()
    }

    // tag::KeychainStorageIdentifierExample1[]
    private static let egkPasswordIdentifier = "egk.can"
    // end::KeychainStorageIdentifierExample1[]
    private static let idpTokenIdentifier = "idp.token"
    private static let idpDiscoveryDocumentIdentifier = "idp.discovery"
    private static let egkAuthCertIdentifier = "egk.authCert"
    private static let idpBiometricKeyIdentifier = "egk.biometricKeyIdentifier"

    // tag::KeychainStorageIdentifierExample2[]
    var egkPasswordIdentifier: String {
        profilePrefix + Self.egkPasswordIdentifier
    }

    // end::KeychainStorageIdentifierExample2[]

    var idpTokenIdentifier: String {
        profilePrefix + Self.idpTokenIdentifier
    }

    var idpDiscoveryDocumentIdentifier: String {
        Self.idpDiscoveryDocumentIdentifier
    }

    var egkAuthCertIdentifier: String {
        profilePrefix + Self.egkAuthCertIdentifier
    }

    var idpBiometricKeyIdentifier: String {
        profilePrefix + Self.idpBiometricKeyIdentifier
    }

    func set(can: String?) {
        let success: Bool
        do {
            if let can = can {
                // tag::KeychainStorageIdentifierExample3[]
                success = try keychainHelper.setGenericPassword(can, for: egkPasswordIdentifier)
                // end::KeychainStorageIdentifierExample3[]
            } else {
                success = try keychainHelper.unsetGenericPassword(for: egkPasswordIdentifier)
            }
        } catch {
            success = false
        }
        if success {
            canPassthrough.send(can)
        }
    }

    private func retrieveCAN() -> AnyPublisher<String?, Never> {
        Deferred { [keychainHelper, egkPasswordIdentifier] () -> AnyPublisher<String?, Never> in
            guard let result = try? keychainHelper.genericPassword(for: egkPasswordIdentifier) as String?
            else { return Just(nil).eraseToAnyPublisher() }

            return Just(result).eraseToAnyPublisher()
        }
        .merge(with: canPassthrough)
        .eraseToAnyPublisher()
    }

    private let canPassthrough = PassthroughSubject<String?, Never>()
    private let tokenPassthrough = PassthroughSubject<IDPToken?, Never>()

    var token: AnyPublisher<IDPToken?, Never> {
        Deferred { [keychainHelper, idpTokenIdentifier] () -> AnyPublisher<IDPToken?, Never> in
            guard let result = try? keychainHelper.genericPassword(for: idpTokenIdentifier) as Data?,
                  let token = try? JSONDecoder().decode(IDPToken.self, from: result)
            else { return Just(nil).eraseToAnyPublisher() }

            return Just(token).eraseToAnyPublisher()
        }
        .merge(with: tokenPassthrough)
        .eraseToAnyPublisher()
    }

    func set(token: IDPToken?) {
        // [REQ:gemSpec_eRp_FdV:A_20184]
        // [REQ:gemSpec_eRp_FdV:A_21328#3] KeychainStorage implementation
        let success: Bool
        do {
            if let token = token,
               let tokenData = try? JSONEncoder().encode(token) {
                success = try keychainHelper.setGenericPassword(tokenData, for: idpTokenIdentifier)
            } else {
                success = try keychainHelper.unsetGenericPassword(for: idpTokenIdentifier)
            }
        } catch {
            success = false
        }
        if success {
            tokenPassthrough.send(token)
        }
    }

    private let discoveryPassthrough = PassthroughSubject<DiscoveryDocument?, Never>()

    private func retrieveDiscoveryDocument() -> AnyPublisher<DiscoveryDocument?, Never> {
        Deferred { [keychainHelper, idpDiscoveryDocumentIdentifier] () -> AnyPublisher<DiscoveryDocument?, Never> in
            guard let result = try? keychainHelper.genericPassword(for: idpDiscoveryDocumentIdentifier) as Data?,
                  let archiver = try? NSKeyedUnarchiver(forReadingFrom: result),
                  let document = try? archiver.decodeTopLevelDecodable(
                      DiscoveryDocument.self,
                      forKey: NSKeyedArchiveRootObjectKey
                  )
            else {
                return Just(nil).eraseToAnyPublisher()
            }

            return Just(document).eraseToAnyPublisher()
        }
        .merge(with: discoveryPassthrough)
        .eraseToAnyPublisher()
    }

    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        retrieveDiscoveryDocument()
    }

    func set(discovery document: DiscoveryDocument?) {
        let success: Bool
        do {
            if let document = document {
                let archiver = NSKeyedArchiver(requiringSecureCoding: true)
                archiver.outputFormat = .binary
                try archiver.encodeEncodable(document, forKey: NSKeyedArchiveRootObjectKey)
                archiver.finishEncoding()
                let encodedDocument = archiver.encodedData
                success = try keychainHelper.setGenericPassword(encodedDocument, for: idpDiscoveryDocumentIdentifier)
            } else {
                success = try keychainHelper.unsetGenericPassword(for: idpDiscoveryDocumentIdentifier)
            }
        } catch {
            success = false
        }
        if success {
            discoveryPassthrough.send(document)
        }
    }

    private func retrieveCertificate() -> AnyPublisher<X509?, Never> {
        Deferred { [keychainHelper, egkAuthCertIdentifier] () -> AnyPublisher<X509?, Never> in
            guard let derBytes = try? keychainHelper.genericPassword(for: egkAuthCertIdentifier) as Data?,
                  let certificate = try? X509(der: derBytes)
            else {
                return Just(nil).eraseToAnyPublisher()
            }

            return Just(certificate).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    var certificate: AnyPublisher<X509?, Never> {
        retrieveCertificate()
    }

    func set(certificate: X509?) {
        if let derBytes = certificate?.derBytes {
            // [REQ:gemSpec_IDP_Frontend:A_21595] Store within keychain
            _ = try? keychainHelper.setGenericPassword(derBytes, for: egkAuthCertIdentifier)
        } else {
            _ = try? keychainHelper.unsetGenericPassword(for: egkAuthCertIdentifier)
        }
    }

    private func retrieveKeyIdentifier() -> AnyPublisher<Data?, Never> {
        Deferred { [keychainHelper, idpBiometricKeyIdentifier] () -> AnyPublisher<Data?, Never> in
            Just(try? keychainHelper.genericPassword(for: idpBiometricKeyIdentifier))
                .eraseToAnyPublisher()
        }
        .merge(with: keyIdentifierPassthrough)
        .eraseToAnyPublisher()
    }

    // idp pairing identifier for registered device
    var keyIdentifier: AnyPublisher<Data?, Never> {
        retrieveKeyIdentifier()
    }

    private let keyIdentifierPassthrough = PassthroughSubject<Data?, Never>()

    func set(keyIdentifier: Data?) {
        let success: Bool
        do {
            if let keyIdentifier = keyIdentifier {
                // [REQ:gemSpec_IDP_Frontend:A_21595] Store within keychain
                success = try keychainHelper.setGenericPassword(keyIdentifier, for: idpBiometricKeyIdentifier)
            } else {
                success = try keychainHelper.unsetGenericPassword(for: idpBiometricKeyIdentifier)
            }
        } catch {
            success = false
        }
        if success {
            keyIdentifierPassthrough.send(keyIdentifier)
        }
    }

    func wipe() {
        // [REQ:gemSpec_IDP_Frontend:A_20499,A_20499-1#3] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        // [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        set(can: nil)
        set(token: nil)
        set(discovery: nil)
        // [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
        set(certificate: nil)
        // `keyIdentifier` is not wiped here because it's deletion is done asynchronously
        // together with the secure enclave representative in `ProfileSecureDataWiper`
    }
}
