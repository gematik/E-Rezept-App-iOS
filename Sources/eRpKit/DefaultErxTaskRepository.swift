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
// swiftlint:disable type_body_length file_length

import Combine
import Foundation

/// Repository for the app to the MedicationSchedule data layer handling the syncing between its data stores.
public struct MedicationScheduleRepository {
    /// Create a MedicationSchedule
    public var create: @Sendable (MedicationSchedule) async throws -> Void
    /// Load all MedicationSchedule
    public var readAll: @Sendable () async throws -> [MedicationSchedule]
    /// Load a MedicationSchedule with `taskId`
    public var read: @Sendable (_ taskId: String) async throws -> MedicationSchedule?
    /// Delete all passed MedicationSchedule
    public var delete: @Sendable ([MedicationSchedule]) async throws -> Void

    /// Default init for MedicationScheduleRepository
    public init(
        create: @escaping @Sendable (MedicationSchedule) async throws -> Void,
        readAll: @escaping @Sendable () async throws -> [MedicationSchedule],
        read: @escaping @Sendable (String) async throws -> MedicationSchedule?,
        delete: @escaping @Sendable ([MedicationSchedule]) async throws -> Void
    ) {
        self.create = create
        self.readAll = readAll
        self.read = read
        self.delete = delete
    }
}

/// Repository for the app to the ErxTask data layer handling the syncing between its data stores.
public class DefaultErxTaskRepository: ErxTaskRepository {
    /// ErxTaskRepository ErrorType
    public typealias ErrorType = ErxRepositoryError

    private let disk: ErxLocalDataStore
    private let cloud: ErxRemoteDataStore
    private let medicationScheduleRepository: MedicationScheduleRepository
    private let profile: AnyPublisher<Profile, LocalStoreError>

    /// Initialize a new ErxTaskRepository as the gateway between Presentation layer and underlying data layer(s)
    ///
    /// - Parameters:
    ///   - disk: The data source that represents the disk/local storage
    ///   - cloud: The data source that represents the cloud/remote storage
    public required init(
        disk: ErxLocalDataStore,
        cloud: ErxRemoteDataStore,
        medicationScheduleRepository: MedicationScheduleRepository,
        profile: AnyPublisher<Profile, LocalStoreError>
    ) {
        self.disk = disk
        self.cloud = cloud
        self.medicationScheduleRepository = medicationScheduleRepository
        self.profile = profile
    }

    /// Get ErxTask by id from cloud (if possible)
    ///
    /// - Parameters:
    ///   - id: String that identifies the requested `ErxTask`
    ///   - accessCode: When nil only load from local store(s)
    /// - Returns: AnyPublisher that emits the requested `ErxTask` or `DefaultErxTaskRepository.Error`
    public func loadRemote(
        by id: ErxTask.ID,
        accessCode: String?
    ) -> AnyPublisher<ErxTask?, ErrorType> {
        if let accessCode = accessCode {
            return cloud.fetchTask(by: id, accessCode: accessCode)
                .mapError(ErrorType.remote)
                .compactMap { $0 }
                .flatMap { task in
                    self.disk.save(tasks: [task], updateProfileLastAuthenticated: false)
                        .map { _ in task }
                        .mapError(ErrorType.local)
                }
                .eraseToAnyPublisher()
        } else {
            return loadLocal(by: id, accessCode: nil)
        }
    }

    /// Load ErxTask by id from local store
    /// - Parameters:
    ///   - id: String that identifies the requested `ErxTask`
    ///   - accessCode: String representing the accessCode. Can be nil
    /// - Returns: AnyPublisher that emits the requested `ErxTask` or `DefaultErxTaskRepository.Error`
    public func loadLocal(
        by id: ErxTask.ID,
        accessCode: String?
    ) -> AnyPublisher<ErxTask?, ErrorType> {
        disk.fetchTask(by: id, accessCode: accessCode)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    /// Load all local tasks
    ///
    /// - Returns: AnyPublisher that emits an array of all `ErxTask`s or `DefaultErxTaskRepository.Error`
    public func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType> {
        disk.listAllTasks()
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    /// Load all ErxTasks from a remote (server).
    /// - Parameters:
    ///   - locale: The locale to fetch the audit events by
    /// - Returns: AnyPublisher that emits an array of all `ErxTask`s or `DefaultErxTaskRepository.Error`
    public func loadRemoteAll(for _: String?) -> AnyPublisher<[ErxTask], ErrorType> {
        loadRemoteLatestTasks()
            .flatMap { _ in
                self.loadRemoteLatestCommunications()
            }
            .flatMap { _ in
                self.profile
                    .mapError { error in
                        ErxRepositoryError.local(error)
                    }
                    .flatMap { profile in
                        guard profile.insuranceType == Profile.InsuranceType.pKV else {
                            return Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
                        }
                        return self.loadRemoteLatestChargeItems()
                    }
            }
            .flatMap { _ -> AnyPublisher<[ErxTask], ErrorType> in
                self.disk.listAllTasks()
                    .first()
                    .mapError(ErrorType.local)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func loadRemoteLatestTasks() -> AnyPublisher<Bool, ErrorType> {
        disk.fetchLatestLastModifiedForErxTasks()
            .first() // only read once, we are interested in latest event to fetch all younger events.
            .mapError(ErrorType.local)
            .flatMap { lastModified in
                self.cloud.listAllTasks(after: lastModified)
                    .mapError(ErrorType.remote)
            }
            .flatMap { tasks -> AnyPublisher<PagedContent<[ErxTask]>, ErrorType> in
                self.loadAndUpdateAllDetailedTasks(tasks)
            }
            .flatMap { tasks -> AnyPublisher<Bool, ErrorType> in
                self.loadRemoteMedicationDispenses(for: tasks.content)
                    .flatMap {
                        self.disk.save(tasks: $0, updateProfileLastAuthenticated: true)
                            .mapError(ErrorType.local)
                    }
                    .flatMap { result -> AnyPublisher<Bool, ErrorType> in
                        if result, tasks.next != nil {
                            return self.loadRemoteTasksPage(of: tasks)
                        } else {
                            return Just(result).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func loadRemoteTasksPage(of previousPage: PagedContent<[ErxTask]>) -> AnyPublisher<Bool, ErrorType> {
        cloud.listTasksNextPage(of: previousPage)
            .first() // only read once, we are interested in latest event to fetch all younger events.
            .mapError(ErrorType.remote)
            .flatMap { tasks -> AnyPublisher<PagedContent<[ErxTask]>, ErrorType> in
                self.loadAndUpdateAllDetailedTasks(tasks)
            }
            .flatMap { tasks -> AnyPublisher<Bool, ErrorType> in
                self.loadRemoteMedicationDispenses(for: tasks.content)
                    .flatMap {
                        self.disk.save(tasks: $0, updateProfileLastAuthenticated: true)
                            .mapError(ErrorType.local)
                    }
                    .flatMap { result -> AnyPublisher<Bool, ErrorType> in
                        if result, tasks.next != nil {
                            return self.loadRemoteTasksPage(of: tasks)
                        } else {
                            return Just(result).setFailureType(to: ErrorType.self).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func loadAndUpdateAllDetailedTasks(_ tasks: PagedContent<[ErxTask]>)
        -> AnyPublisher<PagedContent<[ErxTask]>, ErrorType> {
        // Load and update cancelled local ErxTasks
        let cancelledTaskPublishers = tasks.content
            .filter { $0.status == .cancelled }
            .map { task in
                self.disk.fetchTask(by: task.identifier, accessCode: nil)
                    .first()
                    .compactMap {
                        $0?.cancelled(on: task.lastModified)
                    }
                    .mapError(ErrorType.local)
                    .eraseToAnyPublisher()
            }

        // Load all other ErxTasks from remote
        let detailedTasks = cloud.listDetailedTasks(
            for: PagedContent(
                content: tasks.content
                    .filter { $0.status != .cancelled },
                next: tasks.next
            )
        )
        .first()
        .mapError(ErrorType.remote)
        .eraseToAnyPublisher()

        // Early out if no cancelled tasks are present
        guard !cancelledTaskPublishers.isEmpty else {
            return detailedTasks
        }

        return Publishers.MergeMany(cancelledTaskPublishers)
            .collect()
            .flatMap { cancelled in
                detailedTasks.map {
                    PagedContent(
                        content: $0.content + cancelled,
                        next: $0.next
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    public func loadRemoteLatestAuditEvents(for locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErrorType> {
        cloud.listAllAuditEvents(after: nil, for: locale)
            .mapError(ErrorType.remote)
            .first()
            .eraseToAnyPublisher()
    }

    public func loadRemoteAuditEventsPage(from url: URL, locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErrorType> {
        cloud.listAuditEventsNextPage(from: url, locale: locale)
            .mapError(ErrorType.remote)
            .first()
            .eraseToAnyPublisher()
    }

    private func loadRemoteLatestCommunications() -> AnyPublisher<Bool, ErrorType> {
        disk.fetchLatestTimestampForCommunications()
            .first() // only read once, we are interested in latest event to fetch all younger events.
            .mapError(ErrorType.local)
            .flatMap { timestamp in
                self.cloud.listAllCommunications(after: timestamp, for: .all)
                    .mapError(ErrorType.remote)
            }
            .flatMap {
                self.disk.save(communications: $0)
                    .mapError(ErrorType.local)
            }
            .eraseToAnyPublisher()
    }

    private func loadRemoteMedicationDispenses(for tasks: [ErxTask]) -> AnyPublisher<[ErxTask], ErrorType> {
        let taskPublishers: [AnyPublisher<ErxTask, ErrorType>] =
            tasks.compactMap { task in
                if task.lastMedicationDispense != nil || task.status == .completed {
                    return self.cloud.listMedicationDispenses(for: task.id)
                        .mapError(ErrorType.remote)
                        .flatMap {
                            self.disk.save(medicationDispenses: $0)
                                .mapError(ErrorType.local)
                                .map { _ in task }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just(task)
                        .setFailureType(to: ErrorType.self)
                        .eraseToAnyPublisher()
                }
            }

        return Publishers.MergeMany(taskPublishers)
            .collect()
            .eraseToAnyPublisher()
    }

    /// Save an array of `ErxTask`s
    ///
    /// - Parameter erxTasks: The tasks that should be saved
    /// - Returns: AnyPublisher that emits `true` if saving was successful or returns an`ErrorType`
    public func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        disk.save(tasks: erxTasks, updateProfileLastAuthenticated: false)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    /// Delete an array of `ErxTask`s
    ///
    /// - Parameter erxTasks: The tasks that should be deleted
    /// - Returns: AnyPublisher that emits `true` if deletion was successful or returns an`ErrorType`
    public func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        let schedules = erxTasks.compactMap(\.medicationSchedule)
        // Delete only locally when all tasks are scanned tasks
        if erxTasks.allSatisfy({ $0.source == ErxTask.Source.scanner }) {
            return disk.delete(tasks: erxTasks)
                .mapError(ErrorType.local)
                .flatMap { _ in
                    self.delete(schedules: schedules)
                }
                .eraseToAnyPublisher()
            // Delete remote & locally when at least one is not a scanned task
        } else {
            // 1. Delete on cloud/server
            return cloud.delete(tasks: erxTasks)
                .mapError(ErrorType.remote)

                // 2. Delete on disk/locally
                .flatMap { _ in
                    self.disk.delete(tasks: erxTasks)
                        .mapError(ErrorType.local)
                }
                .flatMap { _ in
                    self.delete(schedules: schedules)
                }
                .eraseToAnyPublisher()
        }
    }

    private func delete(schedules: [MedicationSchedule]) -> AnyPublisher<Bool, ErrorType> {
        if schedules.isEmpty {
            return Just(true)
                .setFailureType(to: ErrorType.self)
                .eraseToAnyPublisher()
        }

        return Future<Bool, ErrorType> { promise in
            Task {
                do {
                    try await self.medicationScheduleRepository.delete(schedules)
                    promise(.success(true))
                } catch {
                    promise(.failure(ErrorType.local(.delete(error: error))))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter order: Order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: `ErxTaskOrder` if the server has received the order
    public func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErrorType> {
        cloud.redeem(order: order)
            .mapError(ErrorType.remote)
            .eraseToAnyPublisher()
    }

    public func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType> {
        disk.listAllCommunications(for: profile)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    /// Save communications `isRead` property to local data store.
    /// - Parameter communications: communications where the `isRead` state should be changed.
    public func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType> {
        disk.save(communications: communications)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    /// Updates `DiGaInfo` property to local data store.
    /// - Parameter diGaInfo: new`DiGaInfo` that should be updated.
    public func updateLocal(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, ErrorType> {
        disk.update(diGaInfo: diGaInfo)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    public func setLocalDiGaInfo(for tasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType> {
        let taskPublishers: [AnyPublisher<Bool, ErrorType>] =
            tasks.compactMap { task in
                if task.deviceRequest?.appName != nil, task.deviceRequest?.diGaInfo == nil {
                    // task with DiGa and create new DiGaInfo, return bool value of result from save function
                    return self.disk.update(diGaInfo: DiGaInfo(diGaState: .request, taskId: task.identifier))
                        .mapError(ErrorType.local)
                        .eraseToAnyPublisher()
                }
                // task without DiGa just return true, don't expect anything
                return Just(true)
                    .setFailureType(to: ErrorType.self)
                    .eraseToAnyPublisher()
            }
        return Publishers.MergeMany(taskPublishers)
            .collect()
            .map { result in
                result.allSatisfy { $0 == true }
            }
            .eraseToAnyPublisher()
    }

    /// Returns a count for all unread communications for the given  communication profile
    /// and for all unread ChargeItems
    /// - Parameter profile: Communication profile for which you want to have the count
    public func countAllUnreadCommunicationsAndChargeItems(
        for fhirProfile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType> {
        disk.listAllCommunications(for: fhirProfile)
            .mapError(ErrorType.local)
            .flatMap { communications -> AnyPublisher<([ErxTask.Communication], [ErxSparseChargeItem]), ErrorType> in
                self.disk.listAllChargeItems()
                    .mapError(ErrorType.local)
                    .flatMap { chargeItems in
                        Just((communications, chargeItems)).setFailureType(to: ErxRepositoryError.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .map { communications, chargeItems in
                // filter for unique communications
                let uniqueCommunications = communications.filterUnique()
                // make sure there is a communication to an existing charge item
                // since there can be chargeItems without orders
                let taskIds = uniqueCommunications.map(\.taskIds)
                let relevantChargeItems = chargeItems.filter { chargeItem in taskIds.contains { task in
                    task.contains(chargeItem.identifier)
                }
                }
                var count = 0
                count += uniqueCommunications.filter { $0.isRead == false }.count
                count += relevantChargeItems.filter { $0.isRead == false }.count
                return count
            }
            .eraseToAnyPublisher()
    }

    /// Load all ErxChargeItem's from a remote (server).
    ///
    /// - Returns: AnyPublisher that emits an array of all `ErxSparseChargeItem`s or `DefaultErxTaskRepository.Error`
    public func loadRemoteChargeItems() -> AnyPublisher<[ErxSparseChargeItem], ErrorType> {
        loadRemoteLatestChargeItems()
            .flatMap { _ -> AnyPublisher<[ErxSparseChargeItem], ErrorType> in
                self.disk.listAllChargeItems()
                    .first()
                    .mapError(ErrorType.local)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func loadRemoteLatestChargeItems() -> AnyPublisher<Bool, ErrorType> {
        disk.fetchLatestTimestampForChargeItems()
            .first()
            .mapError(ErrorType.local)
            .flatMap {
                self.cloud.listAllChargeItems(after: $0)
                    .mapError(ErrorType.remote)
            }
            .flatMap {
                self.disk.save(chargeItems: $0.map(\.sparseChargeItem))
                    .mapError(ErrorType.local)
            }
            .eraseToAnyPublisher()
    }

    public func loadLocal(by id: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError> {
        disk.fetchChargeItem(by: id)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    public func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError> {
        disk.listAllChargeItems()
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    public func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        disk.save(chargeItems: chargeItems)
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    public func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        cloud.delete(chargeItems: chargeItems)
            .mapError(ErrorType.remote)
            .flatMap { _ in
                self.disk.delete(chargeItems: chargeItems.map(\.sparseChargeItem))
                    .mapError(ErrorType.local)
            }
            .eraseToAnyPublisher()
    }

    public func deleteLocal(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError> {
        disk.delete(chargeItems: chargeItems.map(\.sparseChargeItem))
            .mapError(ErrorType.local)
            .eraseToAnyPublisher()
    }

    public func fetchConsents() -> AnyPublisher<[ErxConsent], ErrorType> {
        cloud.fetchConsents()
            .mapError(ErrorType.remote)
            .eraseToAnyPublisher()
    }

    public func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, ErrorType> {
        cloud.grantConsent(consent)
            .mapError(ErrorType.remote)
            .eraseToAnyPublisher()
    }

    public func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, ErrorType> {
        cloud.revokeConsent(category)
            .mapError(ErrorType.remote)
            .eraseToAnyPublisher()
    }
}

// swiftlint:enable type_body_length file_length
