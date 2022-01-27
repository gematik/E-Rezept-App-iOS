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

/// Alias that aggregates all interfaces related to erxTasks
public typealias ErxDataStore =
    ErxTaskDataStore &
    ErxAuditEventDataStore &
    ErxCommunicationDataStore &
    ErxMedicationDispenseDataStore

/// Interface that is binding the repository to the various implementing data stores
public protocol ErxTaskDataStore where ErrorType: LocalizedError {
    /// Error Type
    associatedtype ErrorType: Equatable

    /// Fetch the ErxTask by its id and accessCode when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    /// - Returns: Publisher for the fetch request
    func fetchTask(by id: ErxTask.ID, accessCode: String?) // swiftlint:disable:this identifier_name
        -> AnyPublisher<ErxTask?, ErrorType>

    /// List all tasks contained in the store
    /// - Parameter referenceDate: Tasks with modification date greater or equal  `referenceDate` will be listed.
    ///                            Pass `nil` for listing all
    func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], ErrorType>

    /// Fetch the most recent `lastModified` of all `ErxTask`s
    func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, ErrorType>

    /// Creates or updates a sequence of tasks into the store
    /// - Parameter tasks: Array of `ErxTasks`s that should be saved
    func save(tasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Deletes a sequence of tasks from the store
    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter orders: Array of an order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: `true` if the server has received the order
    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType>

    /// List all tasks without relationship to a `Profile`
    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], ErrorType>
}

extension ErxTaskDataStore {
    /// List all tasks contained in the store
    public func listAllTasks() -> AnyPublisher<[ErxTask], ErrorType> {
        listAllTasks(after: nil)
    }
}

/// Interface for operations on `ErxTask.Communication`
public protocol ErxCommunicationDataStore where ErrorType: LocalizedError {
    /// Error Type
    associatedtype ErrorType: Equatable

    /// Load All communications of the given profile
    /// - Parameters:
    ///   - referenceDate: `Communication`s with modification date great or equal  `referenceDate` will be listed.
    ///                     Pass `nil` for listing all
    ///   - profile: Filters for the passed Profile type
    func listAllCommunications(
        after referenceDate: String?,
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType>

    /// Fetch the most recent `timestamp` of all `Communication`s
    func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, ErrorType>

    /// Creates or updates the passes sequence of `ErxTaskCommunication`s
    /// - Parameter communications: Array of communications that should be stored
    /// - Returns: `true` if save operation was successful
    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType>

    /// Returns a count for all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType>
}

extension ErxCommunicationDataStore {
    /// List all communications for the given profile contained in the store
    /// - Parameter profile: Filters for the passed Profile type
    /// - Returns: array of the fetched communications or error
    public func listAllCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType> {
        listAllCommunications(after: nil, for: profile)
    }
}

/// Interface for operations on `ErxAuditEventDataStore`
public protocol ErxAuditEventDataStore where ErrorType: LocalizedError {
    /// Error Type
    associatedtype ErrorType: Equatable

    /// Fetch the ErxAuditEvent by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxAuditEvent ID
    /// - Returns: Publisher for the fetch request
    func fetchAuditEvent(by id: ErxAuditEvent.ID) // swiftlint:disable:this identifier_name
        -> AnyPublisher<ErxAuditEvent?, ErrorType>

    /// Fetches all audit events related to a specific task id.
    /// - Parameters:
    ///   - taskID: Identifier of the task to fetch the audit events for
    ///   - locale: Location type of the language in which the result should be returned
    func listAllAuditEvents(forTaskID taskID: ErxTask.ID,
                            for locale: String?) -> AnyPublisher<[ErxAuditEvent], ErrorType>

    /// Fetch the most recent `timestamp` of all `AuditEvent`s
    func fetchLatestTimestampForAuditEvents() -> AnyPublisher<String?, ErrorType>

    /// List all audit events contained in the store
    /// - Parameters:
    ///   - referenceDate: `AuditEvent`s with modification date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    ///   - locale: Location type of the language in which the result should be returned
    func listAllAuditEvents(after referenceDate: String?,
                            for locale: String?) -> AnyPublisher<[ErxAuditEvent], ErrorType>

    /// Creates or updates a sequence of audit events into the store
    /// - Parameter auditEvents: Array of audit events that should be saved
    func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, ErrorType>
}

extension ErxAuditEventDataStore {
    /// List all audit events with the given local contained in the store
    /// - Parameter locale: Location type of the language in which the result should be returned
    /// - Returns: Array of the fetched audit events or error
    public func listAllAuditEvents(for locale: String) -> AnyPublisher<[ErxAuditEvent], ErrorType> {
        listAllAuditEvents(after: nil, for: locale)
    }
}

/// Interface for operations on `ErxTask.MedicationDispense`
public protocol ErxMedicationDispenseDataStore where ErrorType: LocalizedError {
    /// Error Type
    associatedtype ErrorType: Equatable

    /// Fetch the most recent `handOverDate` of all `MedicationDispense`s
    func fetchLatestHandOverDateForMedicationDispenses() -> AnyPublisher<String?, ErrorType>

    /// List all MedicationDispenses from the given reference date
    /// - Parameter referenceDate: `MedicationDispense`s with modification date great or equal  `referenceDate`
    ///                             will be listed. Pass `nil` for listing all
    func listAllMedicationDispenses(
        after referenceDate: String?
    ) -> AnyPublisher<[ErxTask.MedicationDispense], ErrorType>

    /// Creates or updates the passed sequence of `ErxTask.MedicationDispense`s
    /// - Parameter medicationDispenses: Array of medication dispenses that should be stored
    /// - Returns: `true` if save operation was successful
    func save(medicationDispenses: [ErxTask.MedicationDispense]) -> AnyPublisher<Bool, ErrorType>
}

extension ErxMedicationDispenseDataStore {
    /// List all medication dispenses contained in the store
    public func listAllMedicationDispenses() -> AnyPublisher<[ErxTask.MedicationDispense], ErrorType> {
        listAllMedicationDispenses(after: nil)
    }
}
