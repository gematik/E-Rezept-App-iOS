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
import Dependencies
import eRpKit
import Foundation

/// Instances of conforming type know how to migrate from one version to the next version
public protocol ModelMigrating {
    /// Starts a migration process from the passed version number to the next number
    /// - Parameter currentVersion: The version from which migration should be done
    /// - Parameter defaultProfileName: The apps localized default (onboarding) profile name.
    func startModelMigration(
        from currentVersion: ModelVersion,
        defaultProfileName: String
    ) -> AnyPublisher<ModelVersion, MigrationError>
}

public class MigrationManager: ModelMigrating {
    internal let coreDataControllerFactory: CoreDataControllerFactory
    private let userDataStore: UserDataStore
    private let erxTaskDataStore: ErxTaskCoreDataStore
    private var coreDataController: CoreDataController?
    private var nameCounter = 0
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public required init(
        factory: CoreDataControllerFactory,
        erxTaskCoreDataStore: ErxTaskCoreDataStore,
        userDataStore: UserDataStore,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "migration-queue", qos: .userInitiated)
            .eraseToAnyScheduler()
    ) {
        scheduler = backgroundQueue
        coreDataControllerFactory = factory
        self.userDataStore = userDataStore
        erxTaskDataStore = erxTaskCoreDataStore
    }

    public func startModelMigration(
        from currentVersion: ModelVersion,
        defaultProfileName: String
    ) -> AnyPublisher<ModelVersion, MigrationError> {
        do {
            coreDataController = try coreDataControllerFactory.loadCoreDataController()
        } catch {
            return Fail(error: .initialization(error: error))
                .eraseToAnyPublisher()
        }

        if let toVersion = currentVersion.next() {
            switch toVersion {
            case .profiles:
                return migrateToModelVersion4()
                    .tryMap { profiles -> ModelVersion in
                        guard let selectedProfile = profiles.first else {
                            throw MigrationError.missingProfile
                        }
                        self.userDataStore.set(selectedProfileId: selectedProfile.identifier)
                        return toVersion
                    }
                    .mapError { error -> MigrationError in
                        error.toMigrationError()
                    }
                    .eraseToAnyPublisher()
            case .auditEventsInProfile:
                return migrateToModelVersion5()
            case .taskStatus:
                // no migration available to this version
                return Just(toVersion)
                    .setFailureType(to: MigrationError.self)
                    .eraseToAnyPublisher()
            case .pKV:
                return migrateToModelVersion6()
            case .onboardingDate:
                @Dependency(\.date) var date
                userDataStore.set(onboardingDate: date.now)
                userDataStore.set(hideWelcomeMessage: true)
                return Just(toVersion)
                    .setFailureType(to: MigrationError.self)
                    .eraseToAnyPublisher()
            case .displayName:
                return migrateToModelVersion8()
            case .shouldAutoUpdateNameAtNextLogin:
                return migrateToModelVersion9(defaultProfileName: defaultProfileName)
            }
        } else {
            return Fail(error: .isLatestVersion)
                .eraseToAnyPublisher()
        }
    }
}

// sourcery: CodedError = "501"
public enum MigrationError: Swift.Error, LocalizedError, Equatable {
    // sourcery: errorCode = "01"
    case isLatestVersion
    // sourcery: errorCode = "02"
    case missingProfile
    // sourcery: errorCode = "03"
    case write(error: Swift.Error)
    // sourcery: errorCode = "04"
    case read(error: Swift.Error)
    // sourcery: errorCode = "05"
    case delete(error: Swift.Error)
    // sourcery: errorCode = "06"
    case unspecified(error: Swift.Error)
    // sourcery: errorCode = "07"
    case initialization(error: Swift.Error)

    public var errorDescription: String? {
        switch self {
        case .isLatestVersion: return NSLocalizedString("mgm_txt_alert_message_up_to_date", comment: "")
        case .missingProfile: return NSLocalizedString("mgm_txt_alert_message_profile_creation", comment: "")
        case let .write(error: error): return error.localizedDescription
        case let .read(error: error): return error.localizedDescription
        case let .delete(error: error): return error.localizedDescription
        case let .unspecified(error: error): return error.localizedDescription
        case let .initialization(error: error): return error.localizedDescription
        }
    }

    public static func ==(lhs: MigrationError, rhs: MigrationError) -> Bool {
        switch (lhs, rhs) {
        case (.isLatestVersion, isLatestVersion): return true
        case (.missingProfile, .missingProfile): return true
        case let (write(error: lhsError), write(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (read(error: lhsError), read(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (delete(error: lhsError), delete(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (unspecified(error: lhsError), unspecified(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (initialization(error: lhsError), initialization(error: rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default: return false
        }
    }
}

// MARK: - Migration logic to model version 4

extension MigrationManager: CoreDataCrudable {
    var foregroundQueue: AnySchedulerOf<DispatchQueue> {
        scheduler
    }

    var backgroundQueue: AnySchedulerOf<DispatchQueue> {
        scheduler
    }

    func migrateToModelVersion4() -> AnyPublisher<[Profile], MigrationError> {
        deleteAllAuditEvents()
            .flatMap { [weak self] _ -> AnyPublisher<[Profile], MigrationError> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                var scannedTasks: [ErxTask] = []
                return self.erxTaskDataStore.listAllTasks()
                    .first()
                    .map { tasks -> [Profile] in
                        Dictionary(grouping: tasks) { $0.patient?.name }
                            .compactMap { name, erxTasks -> Profile? in
                                guard let name = name else {
                                    // tasks without patient name are scanned tasks
                                    scannedTasks.append(contentsOf: erxTasks)
                                    return nil
                                }
                                return Profile(
                                    name: name,
                                    identifier: UUID(),
                                    erxTasks: erxTasks
                                )
                            }
                    }
                    .mapError(MigrationError.read)
                    .map { profiles in
                        self.add(scannedTasks, toFirstProfileOf: profiles)
                    }
                    .flatMap { profiles -> AnyPublisher<[Profile], MigrationError> in
                        self.save(profiles: profiles)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func migrateToModelVersion5() -> AnyPublisher<ModelVersion, MigrationError> {
        deleteAllAuditEvents()
            .map { _ in ModelVersion.auditEventsInProfile }
            .eraseToAnyPublisher()
    }

    func migrateToModelVersion6() -> AnyPublisher<ModelVersion, MigrationError> {
        Deferred {
            Future<ModelVersion, MigrationError> { [weak self] promise in
                guard let self = self,
                      let moc = self.coreDataController?.container.newBackgroundContext() else {
                    return
                }

                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    do {
                        let profiles = try self.fetchProfiles(in: moc)

                        // Look at all profiles that have no insurance type
                        for profile in profiles where profile.insuranceType?.isEmpty ?? true {
                            // All existing profiles with a insuranceId must be logged in via gKV
                            if profile.insuranceId?.count ?? 0 > 0 {
                                profile.insuranceType = "gKV"
                            } else {
                                // Everyone else has not been logged in yet, thus we cannot know what insurance
                                // type will be true
                                profile.insuranceType = "unknown"
                            }
                        }

                        try moc.save()
                        promise(.success(ModelVersion.pKV))
                    } catch {
                        promise(.failure(.write(error: error)))
                        moc.reset()
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func migrateToModelVersion8() -> AnyPublisher<ModelVersion, MigrationError> {
        Deferred {
            Future<ModelVersion, MigrationError> { [weak self] promise in
                guard let self = self,
                      let moc = self.coreDataController?.container.newBackgroundContext() else {
                    return
                }

                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    do {
                        let profiles = try self.fetchProfiles(in: moc)
                        for profile in profiles {
                            if let givenName = profile.givenName, let familyName = profile.familyName {
                                profile.displayName = "\(givenName) \(familyName)"
                            }
                        }

                        try moc.save()
                        promise(.success(ModelVersion.displayName))
                    } catch {
                        promise(.failure(.write(error: error)))
                        moc.reset()
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func migrateToModelVersion9(defaultProfileName: String) -> AnyPublisher<ModelVersion, MigrationError> {
        Deferred {
            Future<ModelVersion, MigrationError> { [weak self] promise in
                guard let self = self,
                      let moc = self.coreDataController?.container.newBackgroundContext() else {
                    return
                }

                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    do {
                        let profiles = try self.fetchProfiles(in: moc)
                        for profile in profiles {
                            if let name = profile.name {
                                if name == defaultProfileName {
                                    // User (probably) has not chosen this default name (e.g. "Profil 1") deliberately
                                    // and therefore it's marked for auto update.
                                    profile.shouldAutoUpdateNameAtNextLogin = true
                                } else {
                                    // User has chosen a name and therefore it should be kept.
                                    profile.shouldAutoUpdateNameAtNextLogin = false
                                }
                            }
                        }

                        try moc.save()
                        promise(.success(ModelVersion.shouldAutoUpdateNameAtNextLogin))
                    } catch {
                        promise(.failure(.write(error: error)))
                        moc.reset()
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteAllAuditEvents() -> AnyPublisher<Bool, MigrationError> {
        // Note: AuditEvents have been removed in core data model version 16!
        // Therefore deletion of audit events in earlier versions is not necessary and can be omitted
        Just(true)
            .mapError(MigrationError.delete)
            .eraseToAnyPublisher()
    }

    // Add scanned ErxTask's to the first profile
    func add(_ scannedTasks: [ErxTask], toFirstProfileOf profiles: [Profile]) -> [Profile] {
        var profiles = profiles
        guard var firstProfile = profiles.first else {
            // no profile passed so create the first one
            return [Profile(name: fallbackName, erxTasks: scannedTasks)]
        }

        firstProfile.erxTasks.append(contentsOf: scannedTasks)
        profiles[0] = firstProfile
        return profiles
    }

    func save(profiles: [Profile]) -> AnyPublisher<[Profile], MigrationError> {
        Deferred {
            Future<[Profile], MigrationError> { [weak self] promise in
                guard let self = self,
                      let moc = self.coreDataController?.container.newBackgroundContext() else {
                    return
                }

                moc.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                moc.performAndWait {
                    _ = profiles.map { profile -> ProfileEntity in
                        let profileEntity = ProfileEntity.from(profile: profile, in: moc)
                        if let erxTaskEntries = try? self.fetch(tasks: profile.erxTasks, in: moc) {
                            erxTaskEntries.forEach { erxTaskEntry in
                                // Due to saving the wrong insuranceIdentifier we reset
                                // `lastModified` so that the correct number can be fetched again
                                erxTaskEntry.lastModified = nil
                                erxTaskEntry.patient?.insuranceIdentifier = nil
                            }
                            profileEntity.addToErxTasks(NSSet(array: erxTaskEntries))
                        }
                        return profileEntity
                    }

                    do {
                        try moc.save()
                        promise(.success(profiles))
                        moc.reset()
                    } catch {
                        promise(.failure(.write(error: error)))
                        moc.reset()
                    }
                }
            }
        }
        .mapError(MigrationError.write)
        .eraseToAnyPublisher()
    }

    func fetchProfiles(in context: NSManagedObjectContext) throws -> [ProfileEntity] {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            throw MigrationError.read(error: error)
        }
    }

    func fetch(tasks: [ErxTask], in context: NSManagedObjectContext) throws -> [ErxTaskEntity] {
        guard !tasks.isEmpty else { return [] }
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        let ids = tasks.map(\.id)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(ProfileEntity.identifier), ids)
        do {
            return try context.fetch(request)
        } catch {
            throw MigrationError.read(error: error)
        }
    }

    private var fallbackName: String {
        let name = NSLocalizedString("mgm_fallback_profile_name", comment: "")
        if nameCounter == 0 {
            nameCounter += 1
            return name
        }
        nameCounter += 1
        return "\(name) \(nameCounter)"
    }
}

extension Swift.Error {
    func toMigrationError() -> MigrationError {
        if let error = self as? MigrationError {
            return error
        }
        return .unspecified(error: self)
    }
}
