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

/// Interface for the app to the ErxTask data layer
public protocol ErxTaskRepository {
    /// ErxTaskRepository error
    associatedtype ErrorType: Swift.Error

    /// Loads the ErxTask by its id and accessCode from a remote (server).
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: when nil only load from local store(s)
    /// - Returns: Publisher for the load request
    func loadRemote(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
                    accessCode: String?) -> AnyPublisher<ErxTask?, ErrorType>

    /// Loads the `ErxTask` by its id and accessCode from disk
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - accessCode: when nil only look for the `id`
    /// - Returns: Publisher for the load request
    func loadLocal(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
                   accessCode: String?) -> AnyPublisher<ErxTask?, ErrorType>

    /// Load all local tasks (from disk)
    /// - Returns: Publisher for the load request
    func loadLocalAll() -> AnyPublisher<[ErxTask], ErrorType>

    /// Load all ErxTasks (from remote)
    /// - Returns: Publisher for the load request
    func loadRemoteAll(for locale: String?) -> AnyPublisher<[ErxTask], ErrorType>

    /// Saves an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be saved
    /// - Returns: Publisher for the load request
    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Delete an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be deleted
    /// - Returns: Publisher for the load request
    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErrorType>

    /// Set a redeem request of  an `ErxTask` in the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter orders: Array of orders that contain informations about the task,  redeem option
    ///                     and the pharmacy where the tasks should be redeemed
    /// - Returns: `true` if the server has received the order
    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, ErrorType>

    /// Load All communications of the given profile
    /// - Returns: Array of all unread loaded `ErxTaskCommunication` sorted by timestamp
    /// - Parameter profile: Filters for the passed profile type
    func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErrorType>

    /// Save communications `isRead` property to local data store.
    /// - Parameter communications: communications where the `isRead` state should be changed.
    func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErrorType>

    /// Returns a count for all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    func countAllUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErrorType>
}
