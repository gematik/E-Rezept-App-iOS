//
//  Copyright (c) 2022 gematik GmbH
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
import HTTPClient
import OpenSSL
import TrustStore

class ConfiguredTrustStoreSession: TrustStoreSession {
    typealias Certificate = X509

    private let sessionProvider: AnyPublisher<DefaultTrustStoreSession, Never>
    private var disposeBag: Set<AnyCancellable> = []

    init(
        _ configurationProvider: AnyPublisher<Configuration, Never>,
        trustStoreStorage: TrustStoreStorage
    ) {
        sessionProvider = configurationProvider
            .map {
                DefaultTrustStoreSession(
                    serverURL: $0.serverURL,
                    trustAnchor: $0.trustAnchor,
                    trustStoreStorage: trustStoreStorage,
                    httpClient: $0.httpClient
                )
            }
            .eraseToAnyPublisher()
    }

    func loadVauCertificate() -> AnyPublisher<X509, TrustStoreError> {
        sessionProvider.map { $0.loadVauCertificate() }.switchToLatest().eraseToAnyPublisher()
    }

    func validate(certificate: X509) -> AnyPublisher<Bool, TrustStoreError> {
        sessionProvider.map { $0.validate(certificate: certificate) }.switchToLatest().eraseToAnyPublisher()
    }

    func reset() {
        sessionProvider.first().sink { $0.reset() }.store(in: &disposeBag)
    }

    struct Configuration {
        let httpClient: HTTPClient
        let serverURL: URL
        let trustAnchor: TrustAnchor
    }
}
