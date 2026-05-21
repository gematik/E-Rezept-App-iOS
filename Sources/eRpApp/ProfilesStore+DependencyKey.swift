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
import eRpLocalStorage
import Foundation
import Profiles
import Settings
import Sharing

extension ProfilesStore: DependencyKey {
    public static let liveValue = {
        @Shared(.isDemoMode) var isDemoMode

        // switch implementation depending on demo mode
        return ProfilesStore { identifier in
            $isDemoMode.publisher
                .map { isDemoMode in
                    if isDemoMode {
                        ProfilesStore.demoModeValue.fetchProfile(identifier)
                    } else {
                        ProfilesStore.coreDataValue.fetchProfile(identifier)
                    }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        } listAllProfiles: {
            $isDemoMode.publisher
                .map { isDemoMode in
                    if isDemoMode {
                        ProfilesStore.demoModeValue.listAllProfiles()
                    } else {
                        ProfilesStore.coreDataValue.listAllProfiles()
                    }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        } save: { profiles in
            $isDemoMode.publisher
                .map { isDemoMode in
                    if isDemoMode {
                        ProfilesStore.demoModeValue.save(profiles)
                    } else {
                        ProfilesStore.coreDataValue.save(profiles)
                    }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        } delete: { profiles in
            $isDemoMode.publisher
                .map { isDemoMode in
                    if isDemoMode {
                        ProfilesStore.demoModeValue.delete(profiles)
                    } else {
                        ProfilesStore.coreDataValue.delete(profiles)
                    }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        } update: { profileId, mutating in
            $isDemoMode.publisher
                .map { isDemoMode in
                    if isDemoMode {
                        ProfilesStore.demoModeValue.update(profileId, mutating)
                    } else {
                        ProfilesStore.coreDataValue.update(profileId, mutating)
                    }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }()
}

private enum ProfilesStoreDemoModeHelper {
    static let anna = Profile(name: "Anna Vetter",
                              identifier: UUID(),
                              insuranceId: "X123456789",
                              insuranceType: .gKV,
                              color: .red,
                              lastAuthenticated: Date(),
                              erxTasks: [])

    static var dummyProfiles: [Profile] = [
        anna,
    ]
}

extension ProfilesStore {
    static let demoModeValue = ProfilesStore { identifier in
        Just(ProfilesStoreDemoModeHelper.dummyProfiles.first { $0.id == identifier })
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    } listAllProfiles: {
        Just(ProfilesStoreDemoModeHelper.dummyProfiles)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    } save: { profiles in
        ProfilesStoreDemoModeHelper.dummyProfiles = profiles + ProfilesStoreDemoModeHelper.dummyProfiles
        return Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    } delete: { profiles in
        let allProfileIds = profiles.map(\.id)
        ProfilesStoreDemoModeHelper.dummyProfiles = ProfilesStoreDemoModeHelper.dummyProfiles
            .filter { !allProfileIds.contains($0.id) }
        return Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    } update: { profileId, mutating in
        ProfilesStoreDemoModeHelper.dummyProfiles = ProfilesStoreDemoModeHelper.dummyProfiles.map { profile in
            if profile.id == profileId {
                var profile = profile
                mutating(&profile)
                return profile
            }
            return profile
        }
        return Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }
}

extension ProfilesStore {
    static let coreDataValue = {
        @Dependency(\.coreDataControllerFactory) var factory: CoreDataControllerFactory
        let profileDataStore = ProfileCoreDataStore(coreDataControllerFactory: factory)

        return ProfilesStore { identifier in
            profileDataStore.fetchProfile(by: identifier)
        } listAllProfiles: {
            profileDataStore.listAllProfiles()
        } save: { profiles in
            profileDataStore.save(profiles: profiles)
        } delete: { profiles in
            profileDataStore.delete(profiles: profiles)
        } update: { profileId, mutating in
            profileDataStore.update(profileId: profileId, mutating: mutating)
        }
    }()
}
