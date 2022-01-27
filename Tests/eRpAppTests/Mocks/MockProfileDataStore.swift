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

// MARK: - MockProfileDataStore -

final class MockProfileDataStore: ProfileDataStore {
    // MARK: - fetchProfile

    var fetchProfileByCallsCount = 0
    var fetchProfileByCalled: Bool {
        fetchProfileByCallsCount > 0
    }

    var fetchProfileByReceivedIdentifier: Profile.ID?
    var fetchProfileByReceivedInvocations: [Profile.ID] = []
    var fetchProfileByReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    var fetchProfileByClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByCallsCount += 1
        fetchProfileByReceivedIdentifier = identifier
        fetchProfileByReceivedInvocations.append(identifier)
        return fetchProfileByClosure.map { $0(identifier) } ?? fetchProfileByReturnValue
    }

    // MARK: - listAllProfiles

    var listAllProfilesCallsCount = 0
    var listAllProfilesCalled: Bool {
        listAllProfilesCallsCount > 0
    }

    var listAllProfilesReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    var listAllProfilesClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesCallsCount += 1
        return listAllProfilesClosure.map { $0() } ?? listAllProfilesReturnValue
    }

    // MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        saveProfilesCallsCount > 0
    }

    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        return saveProfilesClosure.map { $0(profiles) } ?? saveProfilesReturnValue
    }

    // MARK: - delete

    var deleteProfilesCallsCount = 0
    var deleteProfilesCalled: Bool {
        deleteProfilesCallsCount > 0
    }

    var deleteProfilesReceivedProfiles: [Profile]?
    var deleteProfilesReceivedInvocations: [[Profile]] = []
    var deleteProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesCallsCount += 1
        deleteProfilesReceivedProfiles = profiles
        deleteProfilesReceivedInvocations.append(profiles)
        return deleteProfilesClosure.map { $0(profiles) } ?? deleteProfilesReturnValue
    }

    // MARK: - update

    var updateProfileIdMutatingCallsCount = 0
    var updateProfileIdMutatingCalled: Bool {
        updateProfileIdMutatingCallsCount > 0
    }

    var updateProfileIdMutatingReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdMutatingReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdMutatingReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateProfileIdMutatingClosure: ((UUID, @escaping (inout Profile) -> Void)
        -> AnyPublisher<Bool, LocalStoreError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdMutatingCallsCount += 1
        updateProfileIdMutatingReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdMutatingReceivedInvocations.append((profileId: profileId, mutating: mutating))
        return updateProfileIdMutatingClosure.map { $0(profileId, mutating) } ?? updateProfileIdMutatingReturnValue
    }
}
