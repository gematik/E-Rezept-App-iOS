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

class MemoryStorage: SecureUserDataStore, IDPStorage {
    @Injected(\.schedulers) var schedulers: Schedulers
    @Published private var canState: String?
    private var tokenState: CurrentValueSubject<IDPToken?, Never>
    @Published private var discoveryState: DiscoveryDocument?
    @Published private var accessTokenState: String?

    private var cancellable = Set<AnyCancellable>()

    init() {
        tokenState = CurrentValueSubject(nil)

        tokenState.map { $0?.accessToken }
            .receive(on: schedulers.main)
            .assign(to: \.accessTokenState, on: self)
            .store(in: &cancellable)
    }

    var can: AnyPublisher<String?, Never> {
        $canState.eraseToAnyPublisher()
    }

    func set(can: String?) {
        canState = can
    }

    var token: AnyPublisher<IDPToken?, Never> {
        tokenState
            .eraseToAnyPublisher()
    }

    func set(token: IDPToken?) {
        tokenState.value = token
    }

    var discoveryDocument: AnyPublisher<DiscoveryDocument?, Never> {
        $discoveryState.eraseToAnyPublisher()
    }

    func set(discovery document: DiscoveryDocument?) {
        discoveryState = document
    }

    @Published private var certificateState: X509?

    var certificate: AnyPublisher<X509?, Never> {
        $certificateState.eraseToAnyPublisher()
    }

    func set(certificate: X509?) {
        certificateState = certificate
    }

    @Published private var keyIdentifierState: Data?
    var keyIdentifier: AnyPublisher<Data?, Never> {
        $keyIdentifierState.eraseToAnyPublisher()
    }

    func set(keyIdentifier: Data?) {
        keyIdentifierState = keyIdentifier
    }
}
