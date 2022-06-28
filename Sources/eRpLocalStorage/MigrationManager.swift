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
import CombineSchedulers
import CoreData
import eRpKit
import Foundation

/// Instances of conforming type know how to migrate from one version to the next version
public protocol ModelMigrating {
    /// Starts a migration process from the passed version number to the next number
    /// - Parameter currentVersion: The version from which migration should be done
    func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError>
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

    public func startModelMigration(from currentVersion: ModelVersion) -> AnyPublisher<ModelVersion, MigrationError> {
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

    func deleteAllAuditEvents() -> AnyPublisher<Bool, MigrationError> {
        let request: NSFetchRequest<ErxAuditEventEntity> = ErxAuditEventEntity.fetchRequest()
        return delete(resultsOf: request)
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
