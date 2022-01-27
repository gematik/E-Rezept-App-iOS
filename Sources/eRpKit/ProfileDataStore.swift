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

/// Interface for saving, loading and deleting profiles
///
/// sourcery: StreamWrapped
public protocol ProfileDataStore {
    /// Fetches a profile by it's identifier
    /// - Parameter identifier: Identifier of the Profile to fetch
    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>

    /// List all profiles contained in the store
    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError>

    /// Creates or updates a sequence of profiles into the store
    /// - Parameter profiles: Array of profiles to be saved
    ///
    /// sourcery: SkipStreamWrapped
    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError>

    /// Deletes a sequence of profiles from the store
    /// - Parameter profiles: Array of profiles to be deleted
    ///
    /// sourcery: SkipStreamWrapped
    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError>

    /// Updates a Profile entity
    /// - Parameters:
    ///   - profileId: Identifier of the Profile to update
    ///   - mutating: Closure with the actual profile to be updated
    ///
    /// sourcery: SkipStreamWrapped
    func update(
        profileId: UUID,
        mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Bool, LocalStoreError>
}
