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
import Foundation
import OSLog

/// Handle for `MedicationSchedule` and `ErxTask` associated to a `MedicationSchedule.Entry.id`
public struct MedicationScheduleFetchByEntryIdResponse: Equatable {
    /// The `entryId`'s associated `MedicationSchedule`
    public var medicationSchedule: MedicationSchedule?
    /// An `MedicationSchedule`'s associated `ErxTask`
    public var task: ErxTask?
}

/// Protocol for storing `MedicationSchedule`s.
public protocol MedicationScheduleStore {
    /// Fetch any MedicationSchedule by provided TaskId
    /// - Parameter taskID: TaskID the medication Schedule is for
    /// - Returns: The according MedicationSchedule if there is any for the given TaskID.
    func fetch(by taskID: ErxTask.ID) throws -> MedicationSchedule?

    /// Fetch `MedicationSchedule` and `ErxTask` by provided `MedicationSchedule.Entry.id`
    func fetch(byEntryId entryId: UUID, dateProvider: @escaping () -> Date) throws
        -> MedicationScheduleFetchByEntryIdResponse

    /// Fetches and returns all available Medication Schedules.
    /// - Returns: A list of all available Medication Schedules.
    func fetchAll() throws -> [MedicationSchedule]

    /// Save the given `MedicationSchedule`s. Overwrites any existing `MedicationSchedule`.
    /// - Parameter medicationSchedules: List of `MedicationSchedule`s to save.
    /// - Returns: The saved list of `MedicationSchedule`s.
    func save(medicationSchedules: [MedicationSchedule]) throws -> [MedicationSchedule]

    /// Delete the given `MedicationSchedule`s.
    /// - Parameter medicationSchedules: The list of `MedicationSchedule`s do delete.
    func delete(medicationSchedules: [MedicationSchedule]) throws
}

public class MedicationScheduleCoreDataStore: CoreDataCrudable, MedicationScheduleStore {
    let coreDataControllerFactory: CoreDataControllerFactory
    let foregroundQueue: AnySchedulerOf<DispatchQueue>
    let backgroundQueue: AnySchedulerOf<DispatchQueue>

    /// Initialize an MedicationScheduleCoreDataStore
    /// - Parameters:
    ///     `nil` if it should not be filtering by `Profile`
    ///   - coreDataControllerFactory: Factory that is capable of returning a CoreDataController instance
    ///   - foregroundQueue: read queue, remember never to access the read NSManagedObjects properties/relations on any
    ///     other queue (Default: DispatchQueue.main)
    ///   - backgroundQueue:
    ///     write queue (Default: DispatchQueue(label: "erx-task-data-source-queue", qos: .userInitiated))
    public init(
        coreDataControllerFactory: CoreDataControllerFactory,
        foregroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main,
        backgroundQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(label: "medication-schedule-data-source-queue",
                                                                       qos: .userInitiated).eraseToAnyScheduler()
    ) {
        self.coreDataControllerFactory = coreDataControllerFactory
        self.foregroundQueue = foregroundQueue
        self.backgroundQueue = backgroundQueue
    }

    private func fetchTask(taskId: String, in context: NSManagedObjectContext) -> ErxTaskEntity? {
        let request: NSFetchRequest<ErxTaskEntity> = ErxTaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            argumentArray: [#keyPath(ErxTaskEntity.identifier),
                            taskId]
        )
        var results: [ErxTaskEntity] = []
        do {
            results = try context.fetch(request)
        } catch {
            Logger.eRpLocalStorage.debug("Error loading ErxTaskEntity")
        }

        guard let result = results.first else { return nil }
        return result
    }

    public func fetch(by taskID: ErxTask.ID) throws -> MedicationSchedule? {
        let request: NSFetchRequest<MedicationScheduleEntity> = MedicationScheduleEntity.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MedicationScheduleEntity.taskId), taskID)
        request.predicate = predicate

        guard let result = try fetch(request).first else {
            return nil
        }
        return MedicationSchedule(entity: result)
    }

    public func fetch(byEntryId entryId: UUID,
                      dateProvider: () -> Date) throws -> MedicationScheduleFetchByEntryIdResponse {
        let request: NSFetchRequest<MedicationScheduleEntryEntity> = MedicationScheduleEntryEntity.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MedicationScheduleEntryEntity.id), entryId as CVarArg)
        request.predicate = predicate

        guard let result = try fetch(request).first?.medicationSchedule else {
            return MedicationScheduleFetchByEntryIdResponse(medicationSchedule: nil, task: nil)
        }
        if let task = result.erxTask,
           let erxTask = ErxTask(entity: task, dateProvider: dateProvider) {
            return MedicationScheduleFetchByEntryIdResponse(
                medicationSchedule: erxTask.medicationSchedule,
                task: erxTask
            )
        }
        return MedicationScheduleFetchByEntryIdResponse(
            medicationSchedule: MedicationSchedule(entity: result),
            task: nil
        )
    }

    public func fetchAll() throws -> [MedicationSchedule] {
        let request: NSFetchRequest<MedicationScheduleEntity> = MedicationScheduleEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MedicationScheduleEntity.start), ascending: false),
        ]
        request.relationshipKeyPathsForPrefetching = ["entries"]
        let result: [MedicationScheduleEntity] = try fetch(request)
        return result.compactMap(MedicationSchedule.init(entity:))
    }

    public func save(medicationSchedules: [MedicationSchedule]) throws -> [MedicationSchedule] {
        // Delete existing schedules and always create new entities
        for schedule in medicationSchedules {
            let request: NSFetchRequest<MedicationScheduleEntity> = MedicationScheduleEntity.fetchRequest()
            let predicate = NSPredicate(format: "%K == %@", #keyPath(MedicationScheduleEntity.taskId), schedule.taskId)
            request.predicate = predicate
            try delete(with: request)
        }
        return try save(mergePolicy: .error) { moc in
            for schedule in medicationSchedules {
                let erxTaskEntity = self.fetchTask(taskId: schedule.taskId, in: moc)
                let entity = MedicationScheduleEntity.from(schedule: schedule, in: moc)
                entity.erxTask = erxTaskEntity
            }
            return medicationSchedules
        }
    }

    public func delete(medicationSchedules: [MedicationSchedule]) throws {
        let request: NSFetchRequest<MedicationScheduleEntity> = MedicationScheduleEntity.fetchRequest()
        let ids = medicationSchedules.map(\.id)
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(MedicationScheduleEntity.id), ids)
        try delete(with: request)
    }
}
