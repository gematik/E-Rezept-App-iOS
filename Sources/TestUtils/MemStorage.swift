//
//  Copyright (c) 2023 gematik GmbH
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
import Foundation
@testable import IDP
import OpenSSL
@testable import TrustStore
@testable import VAUClient

public class MemStorage: IDPStorage, SecureEGKCertificateStorage, TrustStoreStorage, VAUStorage {
    public private(set) var tokenState: CurrentValueSubject<IDPToken?, Never> = CurrentValueSubject(nil)
    public var token: AnyPublisher<IDPToken?, Never> {
        tokenState
            .eraseToAnyPublisher()
    }

    public init(token: IDPToken? = nil) {
        tokenState.value = token
    }

    public convenience init(accessToken: String) {
        self.init(token: IDPToken(
            accessToken: accessToken,
            expires: Date.distantFuture,
            idToken: "",
            ssoToken: "",
            tokenType: "Bearer",
            redirect: "redirect"
        ))
    }

    public func set(token: IDPToken?) {
        tokenState.value = token
    }

    @Published public private(set) var discoveryDocumentState: DiscoveryDocument?
    public var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        $discoveryDocumentState.eraseToAnyPublisher()
    }

    public func set(discovery document: DiscoveryDocument?) {
        discoveryDocumentState = document
    }

    @Published public private(set) var certListState: CertList?
    public var certList: AnyPublisher<CertList?, Never> {
        $certListState.eraseToAnyPublisher()
    }

    public func set(certList: CertList?) {
        certListState = certList
    }

    @Published public private(set) var ocspListState: OCSPList?
    public var ocspList: AnyPublisher<OCSPList?, Never> {
        $ocspListState.eraseToAnyPublisher()
    }

    public func set(ocspList: OCSPList?) {
        ocspListState = ocspList
    }

    @Published private(set) var userPseudonymState: String?
    public var userPseudonym: AnyPublisher<String?, Never> {
        $userPseudonymState.eraseToAnyPublisher()
    }

    public func set(userPseudonym: String?) {
        userPseudonymState = userPseudonym
    }

    @Published private(set) var certificateState: X509?
    public var certificate: AnyPublisher<X509?, Never> {
        $certificateState.eraseToAnyPublisher()
    }

    public func set(certificate: X509?) {
        certificateState = certificate
    }

    @Published private(set) var keyIdentifierState: Data?
    public var keyIdentifier: AnyPublisher<Data?, Never> {
        $keyIdentifierState.eraseToAnyPublisher()
    }

    public func set(keyIdentifier: Data?) {
        keyIdentifierState = keyIdentifier
    }
}
