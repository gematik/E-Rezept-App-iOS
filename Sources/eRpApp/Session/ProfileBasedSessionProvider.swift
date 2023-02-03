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
import eRpKit
import Foundation
import IDP

protocol ProfileBasedSessionProvider {
    func idpSession(for profileId: UUID) -> IDPSession
    func biometrieIdpSession(for profileId: UUID) -> IDPSession
    func userDataStore(for profileId: UUID) -> SecureUserDataStore
    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>
}

struct DefaultSessionProvider: ProfileBasedSessionProvider {
    init(userSessionProvider: UserSessionProvider, userSession: UserSession) {
        self.userSessionProvider = userSessionProvider
        self.userSession = userSession
    }

    private let userSessionProvider: UserSessionProvider
    private let userSession: UserSession

    func idpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).idpSession
    }

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).biometrieIdpSession
    }

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userSession(for: profileId).secureUserStore
    }

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        userSession(for: profileId).idTokenValidator()
    }

    private func userSession(for profileId: UUID) -> UserSession {
        // In case of demo mode, we need to use the original session, otherwise NFC will not be mocked
        if userSession.isDemoMode {
            return userSession
        }
        return userSessionProvider.userSession(for: profileId)
    }
}

struct RegisterSessionProvider: ProfileBasedSessionProvider {
    init(userSessionProvider: UserSessionProvider, userSession: UserSession) {
        self.userSessionProvider = userSessionProvider
        self.userSession = userSession
    }

    private let userSessionProvider: UserSessionProvider
    private let userSession: UserSession

    func idpSession(for profileId: UUID) -> IDPSession {
        userSession(for: profileId).biometrieIdpSession
    }

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        idpSession(for: profileId)
    }

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userSession(for: profileId).secureUserStore
    }

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        userSession(for: profileId).idTokenValidator()
    }

    private func userSession(for profileId: UUID) -> UserSession {
        // In case of demo mode, we need to use the original session, otherwise NFC will not be mocked
        if userSession.isDemoMode {
            return userSession
        }
        return userSessionProvider.userSession(for: profileId)
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

    func idTokenValidator(for _: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        DummySessionContainer().idTokenValidator()
    }
}
