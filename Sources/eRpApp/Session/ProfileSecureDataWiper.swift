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
import ComposableArchitecture
import DataKit
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
        let storage = userSessionProvider.userSession(for: profileId).secureUserStore
        // [REQ:gemSpec_IDP_Frontend:A_20499] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        // [REQ:gemSpec_eRp_FdV:A_20186] Deletion of SSO_TOKEN, ID_TOKEN, AUTH_TOKEN
        // [REQ:gemSpec_IDP_Frontend:A_21603] Certificate
        storage.wipe()

        return storage.keyIdentifier
            .first()
            .flatMap { identifier -> AnyPublisher<Void, Never> in
                if let someIdentifier = identifier,
                   let identifier = Base64.urlSafe.encode(data: someIdentifier).utf8string {
                    // [REQ:gemSpec_IDP_Frontend:A_21603] key identifier
                    storage.set(keyIdentifier: nil)
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
