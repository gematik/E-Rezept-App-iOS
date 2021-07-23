//
//  Copyright (c) 2021 gematik GmbH
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
    func listAllTasks() -> AnyPublisher<[ErxTask], ErrorType>

    /// Save a sequence of tasks into the store
    func save(tasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Deletes a sequence of tasks from the store
    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Fetch the ErxAuditEvent by its id and accessCode when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxAuditEvent ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    /// - Returns: Publisher for the fetch request
    func fetchAuditEvent(by id: ErxAuditEvent.ID) // swiftlint:disable:this identifier_name
        -> AnyPublisher<ErxAuditEvent?, ErrorType>

    /// Fetch all audit events related to a specific task.
    func listAllAuditEvents(forTaskID taskID: ErxTask.ID,
                            for locale: String?) -> AnyPublisher<[ErxAuditEvent], ErrorType>

    /// List all audit events contained in the store
    func listAllAuditEvents(after referenceDate: String?,
                            for locale: String?) -> AnyPublisher<[ErxAuditEvent], ErrorType>

    /// Save a sequence of audit events into the store
    func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, ErrorType>

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter orders: Array of an order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: `true` if the server has received the order
    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType>

    /// Load All communications of the given profile
    /// - Returns: Array of all loaded `ErxTaskCommunication`
    /// - Parameter profile: Filters for the passed Profile type
    func listAllCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType>

    /// Saves the passes sequence of `ErxTaskCommunication`s
    /// - Parameter communications: Array of communications that should be stored
    /// - Returns: `true` if save operation was successful
    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType>

    /// Returns a count for all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType>
}
