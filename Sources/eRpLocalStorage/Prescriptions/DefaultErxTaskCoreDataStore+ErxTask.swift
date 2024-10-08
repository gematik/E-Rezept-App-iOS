//
//  Copyright (c) 2024 gematik GmbH
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
import CoreData
import eRpKit

/// ErxTask related local store interfaces
extension DefaultErxTaskCoreDataStore {
    /// Fetch the entire database (incl. other profiles) for an ErxTask by its id and accessCode
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    /// - Returns: Publisher for the fetch request
    public func fetchTask(by taskID: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        var subPredicates = [NSPredicate]()
        subPredicates.append(NSPredicate(format: "%K == %@", #keyPath(ErxTaskEntity.identifier), taskID))
        if let accessCode = accessCode {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ErxTaskEntity.accessCode),
                accessCode
            )
            subPredicates.append(predicate)
        }
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]

        return coreDataCrudable.fetch(request)
            .map { results in
                guard let task = results.first else {
                    return nil
                }
                return ErxTask(entity: task, dateProvider: self.dateProvider)
            }
            .eraseToAnyPublisher()
    }

    /// Fetch the most recent `lastModified` of all `ErxTask`s
    public func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, LocalStoreError> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.lastModified), ascending: false)]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
        }
        return coreDataCrudable.fetch(request)
            .map { $0.first?.lastModified }
            .eraseToAnyPublisher()
    }

    // tag::ErxTaskCoreDataStoreExample1[]
    /// List all tasks contained in the store
    public func listAllTasks() -> AnyPublisher<[ErxTask], LocalStoreError> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false),
            NSSortDescriptor(key: #keyPath(ErxTaskEntity.medication.name), ascending: false),
        ]
        if let identifier = profileId {
            request.predicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
        }
        return coreDataCrudable.fetch(request)
            .map { list in list.compactMap { ErxTask(entity: $0, dateProvider: self.dateProvider) } }
            .eraseToAnyPublisher()
    }

    // end::ErxTaskCoreDataStoreExample1[]

    /// List all tasks without relationship to a `Profile`
    public func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]
        request.predicate = NSPredicate(format: "%K == nil", #keyPath(ErxTaskEntity.profile))
        return coreDataCrudable.fetch(request)
            .map { list in list.compactMap { ErxTask(entity: $0, dateProvider: self.dateProvider) } }
            .eraseToAnyPublisher()
    }

    /// Creates or updates a sequence of tasks into the store
    /// - Parameter tasks: Array of `ErxTasks`s that should be saved
    /// - Parameter updateProfileLastAuthenticated: `true` if the profile last authenticated should be updated, `false`
    ///   otherwise.
    /// - Returns: A publisher that finishes with `true` on completion or fails with an error.
    public func save(tasks: [ErxTask], updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        coreDataCrudable.save(mergePolicy: .mergeByPropertyObjectTrump) { [weak self] moc in
            let profileEntity = self?.fetchProfile(in: moc)

            if updateProfileLastAuthenticated {
                profileEntity?.lastAuthenticated = Date()
            }
            for task in tasks {
                let schedule = self?.fetchMedicationSchedule(for: task.identifier)
                schedule?.erxTask = nil
            }
            return true
        }
        .flatMap { [weak self] _ -> AnyPublisher<Bool, LocalStoreError> in
            guard let self = self else {
                return Just(false).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
            return coreDataCrudable.save(mergePolicy: .mergeByPropertyObjectTrump) { [weak self] moc -> Bool in
                guard let self = self else { return false }
                let profileEntity = self.fetchProfile(in: moc)

                if updateProfileLastAuthenticated {
                    profileEntity?.lastAuthenticated = Date()
                }

                for task in tasks {
                    let taskEntity = ErxTaskEntity.from(task: task, in: moc)

                    let request: NSFetchRequest<ErxTaskMedicationDispenseEntity> = ErxTaskMedicationDispenseEntity
                        .fetchRequest()
                    request.predicate = NSPredicate(
                        format: "%K == %@",
                        #keyPath(ErxTaskMedicationDispenseEntity.taskId),
                        task.identifier
                    )

                    taskEntity.medicationSchedule = self.fetchMedicationSchedule(for: task.identifier)

                    _ = try? request.execute().map {
                        taskEntity.addToMedicationDispenses($0)
                    }

                    if let profileEntity = profileEntity {
                        if profileEntity.insuranceId == nil || task.patient?.insuranceId == nil {
                            taskEntity.profile = profileEntity
                        } else if profileEntity.insuranceId == task.patient?.insuranceId {
                            taskEntity.profile = profileEntity
                        } else {
                            assertionFailure(
                                "This should never happen and indicates a serious problem which should be investigated!"
                            )
                        }
                    }
                }
                return true
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchMedicationSchedule(for taskId: String) -> MedicationScheduleEntity? {
        let request: NSFetchRequest<MedicationScheduleEntity> = MedicationScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(MedicationScheduleEntity.taskId),
            taskId
        )

        guard let result = try? request.execute() else {
            return nil
        }
        if result.count > 1 {
            assertionFailure("there should only be one \(MedicationScheduleEntity.self) per task id.")
        }

        return result.first
    }

    /// Deletes a sequence of tasks from the store
    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, LocalStoreError> {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(ErxTaskEntity.authoredOn), ascending: false)]
        var subPredicates = [NSPredicate]()
        if let identifier = profileId {
            let profilePredicate = NSPredicate(
                format: "%K == %@",
                argumentArray: [#keyPath(ErxTaskEntity.profile.identifier), identifier]
            )
            subPredicates.append(profilePredicate)
        }
        let ids = tasks.map(\.id)
        subPredicates.append(NSPredicate(format: "%K in %@", #keyPath(ErxTaskEntity.identifier), ids))
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: subPredicates)

        return coreDataCrudable.delete(resultsOf: request)
    }
}
