//
//  Copyright (c) 2021 gematik GmbH
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
// [REQ:gemF_Tokenverschlüsselung:A_21322] Storage implementation uses iOS Keychain
// [REQ:gemSpec_IDP_Frontend:A_21595] Storage Implementation
class KeychainStorage: SecureUserDataStore, IDPStorage, SecureEGKCertificateStorage {
    @Injected(\.schedulers) var schedulers: Schedulers
    @Published private var tokenState: IDPToken?
    @Published private var accessTokenState: String?

    private var cancellable = Set<AnyCancellable>()

    internal var keychainHelper: KeychainAccessHelper = SystemKeychainAccessHelper()

    init() {
        $tokenState.map { $0?.accessToken }
            .receive(on: schedulers.main)
            .assign(to: \.accessTokenState, on: self)
            .store(in: &cancellable)
    }

    var can: AnyPublisher<String?, Never> {
        retrieveCAN()
    }

    private let egkPasswordIdentifier = "egk.can"
    private let idpTokenIdentifier = "idp.token"
    private let idpDiscoveryDocumentIdentifier = "idp.discovery"
    private let egkAuthCertIdentifier = "egk.authCert"
    private let idpBiometricKeyIdentifier = "egk.biometricKeyIdentifier"

    func set(can: String?) {
        let success: Bool
        do {
            if let can = can {
                success = try keychainHelper.setGenericPassword(can, for: egkPasswordIdentifier)
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
        Deferred { [weak self] () -> AnyPublisher<String?, Never> in
            guard let self = self,
                let result = try? self.keychainHelper.genericPassword(for: self.egkPasswordIdentifier) as String?
            else { return Just(nil).eraseToAnyPublisher() }

            return Just(result).eraseToAnyPublisher()
        }
        .merge(with: canPassthrough)
        .eraseToAnyPublisher()
    }

    private let canPassthrough = PassthroughSubject<String?, Never>()
    private let tokenPassthrough = PassthroughSubject<IDPToken?, Never>()

    var token: AnyPublisher<IDPToken?, Never> {
        Deferred { [weak self] () -> AnyPublisher<IDPToken?, Never> in
            guard let self = self,
                let result = try? self.keychainHelper.genericPassword(for: self.idpTokenIdentifier) as Data?,
                let token = try? JSONDecoder().decode(IDPToken.self, from: result)
            else { return Just(nil).eraseToAnyPublisher() }

            return Just(token).eraseToAnyPublisher()
        }
        .merge(with: tokenPassthrough)
        .eraseToAnyPublisher()
    }

    func set(token: IDPToken?) {
        // [REQ:gemSpec_eRp_FdV:A_20184]
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
        Deferred { [weak self] () -> AnyPublisher<DiscoveryDocument?, Never> in
            guard let self = self,
                let result = try? self.keychainHelper
                .genericPassword(for: self.idpDiscoveryDocumentIdentifier) as Data?,
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
        Deferred { [weak self] () -> AnyPublisher<X509?, Never> in
            guard let self = self,
                let derBytes = try? self.keychainHelper.genericPassword(for: self.egkAuthCertIdentifier) as Data?,
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
        Deferred { [weak self] () -> AnyPublisher<Data?, Never> in
            guard let self = self else {
                return Just(nil).eraseToAnyPublisher()
            }

            return Just(try? self.keychainHelper.genericPassword(for: self.idpBiometricKeyIdentifier))
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    var keyIdentifier: AnyPublisher<Data?, Never> {
        retrieveKeyIdentifier()
    }

    func set(keyIdentifier: Data?) {
        if let keyIdentifier = keyIdentifier {
            // [REQ:gemSpec_IDP_Frontend:A_21595] Store within keychain
            _ = try? keychainHelper.setGenericPassword(keyIdentifier, for: idpBiometricKeyIdentifier)
        } else {
            _ = try? keychainHelper.unsetGenericPassword(for: idpBiometricKeyIdentifier)
        }
    }
}
