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
import ComposableArchitecture
import eRpKit
import Foundation
import IDP

protocol ProfileSecureDataWiper {
    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never>

    func logout(profile: Profile) -> AnyPublisher<Void, Never>

    func secureStorage(of profileId: UUID) -> SecureUserDataStore
}

extension ProfileSecureDataWiper {
    func wipeSecureData(of profile: Profile) -> AnyPublisher<Void, Never> {
        wipeSecureData(of: profile.id)
    }
}

class DefaultProfileSecureDataWiper: ProfileSecureDataWiper {
    var userSessionProvider: UserSessionProvider

    init(userSessionProvider: UserSessionProvider) {
        self.userSessionProvider = userSessionProvider
    }

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        let userSession = userSessionProvider.userSession(for: profileId)
        let storage = userSession.secureUserStore
        // [REQ:gemSpec_IDP_Frontend:A_20499,A_20499-01#2] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        // [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        // [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
        // [REQ:BSI-eRp-ePA:O.Auth_14#4] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        storage.wipe()
        // also delete any in memory token of the pairing IDP session
        userSession.pairingIdpSession.invalidateAccessToken()

        return storage.keyIdentifier
            .first()
            .flatMap { identifier -> AnyPublisher<Void, Never> in
                // [REQ:gemSpec_IDP_Frontend:A_21603] key identifier
                storage.set(keyIdentifier: nil)

                if let someIdentifier = identifier,
                   let encodedIdentifier = someIdentifier.encodeBase64UrlSafe(),
                   let identifier = String(data: encodedIdentifier, encoding: .utf8) {
                    // If deletion fails we cannot do anything
                    // [REQ:gemSpec_IDP_Frontend:A_21603] PrK_SE_AUT/PuK_SE_AUT
                    _ = try? PrivateKeyContainer.deleteExistingKey(for: identifier)
                }
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        wipeSecureData(of: profile)
    }

    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        userSessionProvider.userSession(for: profileId).secureUserStore
    }
}

class DummyProfileSecureDataWiper: ProfileSecureDataWiper {
    func wipeSecureData(of _: UUID) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    func logout(profile _: Profile) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    func secureStorage(of _: UUID) -> SecureUserDataStore {
        MemoryStorage()
    }
}

class DemoProfileSecureDataWiper: ProfileSecureDataWiper {
    func wipeSecureData(of _: UUID) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    func logout(profile _: Profile) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    func secureStorage(of _: UUID) -> SecureUserDataStore {
        MemoryStorage()
    }
}

// MARK: TCA Dependency

extension DefaultProfileSecureDataWiper {
    static let live = DefaultProfileSecureDataWiper(userSessionProvider: UserSessionProviderDependency.liveValue)
}

struct ProfileSecureDataWiperDependency: DependencyKey {
    static let liveValue: ProfileSecureDataWiper = DefaultProfileSecureDataWiper.live

    static let testValue: ProfileSecureDataWiper = UnimplementedProfileSecureDataWiper()
}

extension DependencyValues {
    var profileSecureDataWiper: ProfileSecureDataWiper {
        get { self[ProfileSecureDataWiperDependency.self] }
        set { self[ProfileSecureDataWiperDependency.self] = newValue }
    }
}
