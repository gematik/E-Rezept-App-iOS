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
import CombineSchedulers
import CoreData
import eRpKit

/// Store for fetching, creating, updating or deleting `Profile`s on the provided `CoreDataController`
/// [REQ:BSI-eRp-ePA:O.Source_2#4] CoreDataStore adapter for `Profile`s
public class ProfileCoreDataStore: ProfileDataStore, CoreDataCrudable {
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>
    let dateProvider: () -> Date
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    /// Initialize a Profile Core Data Store
    /// - Parameters:
    ///   - coreDataControllerFactory: Factory that is capable of providing a CoreDataController
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "profile-queue", qos: .userInitiated))
    public init(
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "profile-queue", qos: .userInitiated)
            .eraseToAnyScheduler(),
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
        self.dateProvider = dateProvider
    }

    public func fetchProfile(by identifier: Profile.ID)
        -> AnyPublisher<Profile?, LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(ProfileEntity.identifier), identifier]
        )
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.created), ascending: true)]
        return fetch(request)
            .map { results in
                guard let profileEntity = results.first else {
                    return nil
                }
                if results.count > 1 {
                    assertionFailure("error: there should always be just one profile per id in store")
                }
                return Profile(entity: profileEntity, dateProvider: self.dateProvider)
            }
            .eraseToAnyPublisher()
    }

    public func hasProfile() throws -> Bool {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        let coreData = try coreDataControllerFactory.loadCoreDataController()
        let moc = coreData.container.newBackgroundContext()

        let result = try moc.count(for: request)
        return result > 0
    }

    public func createProfile(
        name: String,
        shouldAutoUpdateNameAtNextLogin: Bool = false
    ) throws -> Profile {
        let coreData = try coreDataControllerFactory.loadCoreDataController()
        let moc = coreData.container.newBackgroundContext()

        var saveError: Error?
        let newProfile = Profile(
            name: name,
            shouldAutoUpdateNameAtNextLogin: shouldAutoUpdateNameAtNextLogin
        )
        moc.performAndWait {
            _ = ProfileEntity(profile: newProfile, in: moc)
            do {
                try moc.save()
            } catch {
                saveError = Error.initialization(error: error)
            }
            moc.reset()
        }

        if let error = saveError {
            throw error
        }

        return newProfile
    }

    public func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.created), ascending: true)]

        return fetch(request)
            .map { list in
                list.compactMap {
                    Profile(entity: $0, dateProvider: self.dateProvider)
                }
            }
            .eraseToAnyPublisher()
    }

    // creates or updates a `Profile`. Note that the `erxTasks` relationship will not be saved
    public func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            _ = profiles.map { profile -> ProfileEntity in
                let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "%K == %@",
                    argumentArray: [#keyPath(ProfileEntity.identifier), profile.identifier]
                )

                if let profileEntity = try? moc.fetch(request).first {
                    profileEntity.name = profile.name
                    profileEntity.insuranceId = profile.insuranceId
                    profileEntity.insuranceType = profile.insuranceType.rawValue
                    profileEntity.insuranceIK = profile.insuranceIK
                    profileEntity.insurance = profile.insurance
                    profileEntity.givenName = profile.givenName
                    profileEntity.familyName = profile.familyName
                    profileEntity.displayName = profile.displayName
                    profileEntity.color = profile.color.rawValue
                    profileEntity.image = profile.image.rawValue
                    profileEntity.userImageData = profile.userImageData
                    profileEntity.lastAuthenticated = profile.lastAuthenticated
                    profileEntity.hidePkvConsentDrawerOnMainView = profile.hidePkvConsentDrawerOnMainView
                    profileEntity.shouldAutoUpdateNameAtNextLogin = profile.shouldAutoUpdateNameAtNextLogin
                    profileEntity.gIdEntry = try? ProfileCoreDataStore.encoder.encode(profile.gIdEntry)
                    return profileEntity
                } else {
                    return ProfileEntity.from(profile: profile, in: moc)
                }
            }
        }
    }

    public func update(
        profileId: UUID,
        mutating: @escaping (inout Profile) -> Void
    ) -> AnyPublisher<Bool, LocalStoreError> {
        save(mergePolicy: NSMergePolicy.error) { moc in
            let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ProfileEntity.identifier), profileId]
            )

            if let profileEntity = try? moc.fetch(request).first,
               var profile = Profile(entity: profileEntity, dateProvider: self.dateProvider) {
                mutating(&profile)
                profileEntity.name = profile.name
                profileEntity.insuranceId = profile.insuranceId
                profileEntity.insuranceType = profile.insuranceType.rawValue
                profileEntity.insuranceIK = profile.insuranceIK
                profileEntity.insurance = profile.insurance
                profileEntity.givenName = profile.givenName
                profileEntity.familyName = profile.familyName
                profileEntity.displayName = profile.displayName
                profileEntity.color = profile.color.rawValue
                profileEntity.image = profile.image.rawValue
                profileEntity.userImageData = profile.userImageData
                profileEntity.lastAuthenticated = profile.lastAuthenticated
                profileEntity.hidePkvConsentDrawerOnMainView = profile.hidePkvConsentDrawerOnMainView
                profileEntity.shouldAutoUpdateNameAtNextLogin = profile.shouldAutoUpdateNameAtNextLogin
                profileEntity.gIdEntry = try? ProfileCoreDataStore.encoder.encode(profile.gIdEntry)
            } else {
                throw Error.noMatchingEntity
            }
        }
    }

    public func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        let ids = profiles.map(\.identifier)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(ProfileEntity.identifier), ids)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ProfileEntity.name), ascending: false)]
        return delete(resultsOf: request)
    }

    // sourcery: CodedError = "502"
    public enum Error: Swift.Error {
        // sourcery: errorCode = "01"
        case noMatchingEntity
        // sourcery: errorCode = "02"
        case initialization(error: Swift.Error)
    }
}
