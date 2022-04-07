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
import eRpKit
import Foundation
import IDP

protocol ProfileBasedSessionProvider {
    func idpSession(for profileId: UUID) -> IDPSession
    func biometrieIdpSession(for profileId: UUID) -> IDPSession
    func userDataStore(for profileId: UUID) -> SecureUserDataStore
    func signatureProvider(for profileId: UUID) -> NFCSignatureProvider
    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>
}

struct DefaultSessionProvider: ProfileBasedSessionProvider {
    init(userSessionProvider: UserSessionProvider) {
        self.userSessionProvider = userSessionProvider
    }

    private let userSessionProvider: UserSessionProvider

    func idpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).idpSession
    }

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).biometrieIdpSession
    }

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userSession(for: profileId).secureUserStore
    }

    func signatureProvider(for profileId: UUID) -> NFCSignatureProvider {
        userSession(for: profileId).nfcSessionProvider
    }

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        userSession(for: profileId).idTokenValidator()
    }

    private func userSession(for profileId: UUID) -> UserSession {
        userSessionProvider.userSession(for: profileId)
    }
}

struct RegisterSessionProvider: ProfileBasedSessionProvider {
    init(userSessionProvider: UserSessionProvider) {
        self.userSessionProvider = userSessionProvider
    }

    private let userSessionProvider: UserSessionProvider

    func idpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).biometrieIdpSession
    }

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        idpSession(for: profileId)
    }

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userSession(for: profileId).secureUserStore
    }

    func signatureProvider(for profileId: UUID) -> NFCSignatureProvider {
        userSession(for: profileId).nfcSessionProvider
    }

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        userSession(for: profileId).idTokenValidator()
    }

    private func userSession(for profileId: UUID) -> UserSession {
        userSessionProvider.userSession(for: profileId)
    }
}

class DummyProfileBasedSessionProvider: ProfileBasedSessionProvider {
    var userSessionProvider: UserSessionProvider = DummyUserSessionProvider()

    func idpSession(for _: UUID) -> IDPSession {
        DemoIDPSession(storage: MemoryStorage())
    }

    func biometrieIdpSession(for _: UUID) -> IDPSession {
        DemoIDPSession(storage: MemoryStorage())
    }

    func userDataStore(for _: UUID) -> SecureUserDataStore {
        MemoryStorage()
    }

    func signatureProvider(for _: UUID) -> NFCSignatureProvider {
        DemoSignatureProvider()
    }

    func idTokenValidator(for _: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        DemoSessionContainer().idTokenValidator()
    }
}
