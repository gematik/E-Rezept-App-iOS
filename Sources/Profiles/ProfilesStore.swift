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
import DependenciesMacros
import eRpKit
import Foundation

/// Interface for saving, loading and deleting profiles
@DependencyClient
public struct ProfilesStore {
    /// Fetches a profile by it's identifier
    /// - Parameter identifier: Identifier of the Profile to fetch
    public var fetchProfile: (_ identifier: UUID) -> AnyPublisher<Profile?, LocalStoreError> = { _ in
        Just(nil)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    /// List all profiles contained in the store
    public var listAllProfiles: () -> AnyPublisher<[Profile], LocalStoreError> = { Just([])
        .setFailureType(to: LocalStoreError.self)
        .eraseToAnyPublisher()
    }

    /// Creates or updates a sequence of profiles into the store
    /// - Parameter profiles: Array of profiles to be saved
    ///
    /// sourcery: SkipStreamWrapped
    public var save: (_ profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> = { _ in
        Just(false)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    /// Deletes a sequence of profiles from the store
    /// - Parameter profiles: Array of profiles to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    public var delete: (_ profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> = { _ in
        Just(false)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }

    /// Updates a Profile entity
    /// - Parameters:
    ///   - profileId: Identifier of the Profile to update
    ///   - mutating: Closure with the actual profile to be updated
    ///
    /// sourcery: SkipStreamWrapped
    public var update: (
        _ profileId: UUID,
        _ mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Bool, LocalStoreError> = { _, _ in
        Just(false)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()
    }
}

extension ProfilesStore: TestDependencyKey {
    public static var previewValue: ProfilesStore = .init()

    public static var testValue: ProfilesStore = .init()
}

extension DependencyValues {
    /// Access to the ProfilesStore
    public var profilesStore: ProfilesStore {
        get { self[ProfilesStore.self] }
        set { self[ProfilesStore.self] = newValue }
    }
}
