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
import eRpKit
import Foundation

class DemoProfileDataStore: ProfileDataStore {
    static let anna = Profile(name: "Anna Vetter",
                              identifier: UUID(),
                              insuranceId: "X123456789",
                              color: .red,
                              lastAuthenticated: Date(),
                              erxTasks: [])

    private var dummyProfiles: [Profile] = [
        anna,
    ]

    init() {}

    var profilesPublisher: CurrentValueSubject<[Profile], Never> = CurrentValueSubject([anna])

    func fetchProfile(by profileId: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        Just(dummyProfiles.first { $0.id == profileId }).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        profilesPublisher.setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        dummyProfiles = profiles + dummyProfiles
        profilesPublisher.send(dummyProfiles)

        return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        dummyProfiles = dummyProfiles.map { profile in
            if profile.id == profileId {
                var profile = profile
                mutating(&profile)
                return profile
            }
            return profile
        }
        profilesPublisher.send(dummyProfiles)

        return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        let allProfileIds = profiles.map(\.id)
        dummyProfiles = dummyProfiles.filter { !allProfileIds.contains($0.id) }
        profilesPublisher.send(dummyProfiles)

        return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
    }

    func pagedAuditEventsController(for _: UUID, with _: String?) throws -> PagedAuditEventsController {
        DemoPagedAuditEventsController()
    }

    typealias ErrorType = LocalStoreError
}
