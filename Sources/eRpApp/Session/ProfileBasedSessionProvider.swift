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
import eRpKit
import Foundation
import IDP
import Profiles
import Settings

extension ProfileBasedSessionProvider: DependencyKey {
    public static let liveValue: ProfileBasedSessionProvider = {
        @Dependency(\.userSessionProvider) var userSessionProvider
        var demoUserSession = UsersSessionContainerDependency.liveValue.userSession

        func userSession(for profileId: UUID) -> UserSession {
            // In case of demo mode, we need to use the original session, otherwise NFC will not be mocked
            @Shared(.isDemoMode) var isDemoMode: Bool

            if isDemoMode {
                return demoUserSession
            }
            return userSessionProvider.userSession(for: profileId)
        }

        return ProfileBasedSessionProvider { profileId in
            userSession(for: profileId).idpSession
        } biometrieIdpSession: { profileId in
            userSession(for: profileId).pairingIdpSession
        } userDataStore: { profileId in
            userSession(for: profileId).secureUserStore
        } idTokenValidator: { profileId in
            userSession(for: profileId).idTokenValidator()
        } signatureProvider: { profileId in
            userSession(for: profileId).secureEnclaveSignatureProvider
        }
    }()
}

//
// struct DefaultSessionProvider: ProfileBasedSessionProvider {
//    init(userSessionProvider: UserSessionProvider, userSession: UserSession) {
//        self.userSessionProvider = userSessionProvider
//        self.userSession = userSession
//    }
//
//    private let userSessionProvider: UserSessionProvider
//    private let userSession: UserSession
//
//    func idpSession(for profileId: UUID) -> IDPSession {
//        userSession(for: profileId).idpSession
//    }
//
//    func signatureProvider(for profileId: UUID) -> IDP.SecureEnclaveSignatureProvider {
//        userSession(for: profileId).secureEnclaveSignatureProvider
//    }
//
//    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
//        userSession(for: profileId).pairingIdpSession
//    }
//
//    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
//        userSession(for: profileId).secureUserStore
//    }
//
//    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
//        userSession(for: profileId).idTokenValidator()
//    }
//
//    private func userSession(for profileId: UUID) -> UserSession {
//        // In case of demo mode, we need to use the original session, otherwise NFC will not be mocked
//        @Shared(.isDemoMode) var isDemoMode: Bool
//
//        if isDemoMode {
//            return userSession
//        }
//        return userSessionProvider.userSession(for: profileId)
//    }
// }
//
// class DummyProfileBasedSessionProvider: ProfileBasedSessionProvider {
//    var userSessionProvider: UserSessionProvider = DummyUserSessionProvider()
//
//    func idpSession(for _: UUID) -> IDPSession {
//        DemoIDPSession(storage: MemoryStorage())
//    }
//
//    func signatureProvider(for _: UUID) -> SecureEnclaveSignatureProvider {
//        DummySecureEnclaveSignatureProvider()
//    }
//
//    func biometrieIdpSession(for _: UUID) -> IDPSession {
//        DemoIDPSession(storage: MemoryStorage())
//    }
//
//    func userDataStore(for _: UUID) -> SecureUserDataStore {
//        MemoryStorage()
//    }
//
//    func idTokenValidator(for _: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
//        DummySessionContainer().idTokenValidator()
//    }
// }
