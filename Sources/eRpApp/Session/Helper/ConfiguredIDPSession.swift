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
import Foundation
import HTTPClient
import IDP
import TrustStore

class ConfiguredIDPSession: IDPSession {
    struct Configuration {
        let httpClient: HTTPClient
        let idpSessionConfiguration: DefaultIDPSession.Configuration
    }

    private let sessionProvider: AnyPublisher<IDPSession, Never>

    init(
        _ configurationProvider: AnyPublisher<Configuration, Never>,
        storage: IDPStorage,
        schedulers: IDPSchedulers,
        trustStoreSession: TrustStoreSession
    ) {
        sessionProvider = configurationProvider
            .map { configuration in
                DefaultIDPSession(config: configuration.idpSessionConfiguration,
                                  storage: storage,
                                  schedulers: schedulers,
                                  httpClient: configuration.httpClient,
                                  trustStoreSession: trustStoreSession) as IDPSession
            }
            .eraseToAnyPublisher()
    }

    var isLoggedIn: AnyPublisher<Bool, IDPError> {
        sessionProvider.map(\.isLoggedIn).switchToLatest().eraseToAnyPublisher()
    }

    var disposeBag: Set<AnyCancellable> = []

    func invalidateAccessToken() {
        sessionProvider
            .first()
            .sink { session in
                session.invalidateAccessToken()
            }
            .store(in: &disposeBag)
    }

    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        sessionProvider.map(\.autoRefreshedToken).switchToLatest().eraseToAnyPublisher()
    }

    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        sessionProvider.map { $0.requestChallenge() }.switchToLatest().eraseToAnyPublisher()
    }

    func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        sessionProvider.map { $0.verify(signedChallenge) }.switchToLatest().eraseToAnyPublisher()
    }

    func exchange(token: IDPExchangeToken,
                  challengeSession: IDPChallengeSession) -> AnyPublisher<IDPToken, IDPError> {
        sessionProvider
            .map { $0.exchange(token: token, challengeSession: challengeSession) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        sessionProvider.map { $0.refresh(token: token) }.switchToLatest().eraseToAnyPublisher()
    }

    func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        sessionProvider
            .map { $0.pairDevice(with: registrationData, token: token) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func unregisterDevice(_ keyIdentifier: String) -> AnyPublisher<Bool, IDPError> {
        sessionProvider
            .map { $0.unregisterDevice(keyIdentifier) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        sessionProvider.map { $0.altVerify(signedChallenge) }.switchToLatest().eraseToAnyPublisher()
    }
}
