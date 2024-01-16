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
import Foundation

/// Interface for the app to the ErxTask data layer
/// sourcery: StreamWrapped, SkipCurrent
public protocol ErxTaskRepository {
    /// Loads the ErxTask by its id and accessCode from a remote (server).
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: when nil only load from local store(s)
    /// - Returns: Publisher for the load request
    func loadRemote(by id: ErxTask.ID,
                    accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError>

    /// Loads the `ErxTask` by its id and accessCode from disk
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - accessCode: when nil only look for the `id`
    /// - Returns: Publisher for the load request
    func loadLocal(by id: ErxTask.ID,
                   accessCode: String?) -> AnyPublisher<ErxTask?, ErxRepositoryError>

    /// Load all local tasks (from disk)
    /// - Returns: Publisher for the load request
    func loadLocalAll() -> AnyPublisher<[ErxTask], ErxRepositoryError>

    /// Load all ErxTasks (from remote)
    /// - Returns: Publisher for the load request
    func loadRemoteAll(for locale: String?) -> AnyPublisher<[ErxTask], ErxRepositoryError>

    /// Saves an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be saved
    /// - Returns: Publisher for the load request
    func save(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError>

    /// Delete an array of `ErxTask`s
    /// - Parameters:
    ///   - erxTasks: the `ErxTask`s to be deleted
    /// - Returns: Publisher for the load request
    func delete(erxTasks: [ErxTask]) -> AnyPublisher<Bool, ErxRepositoryError>

    /// Set a redeem request of  an `ErxTask` in the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter order: Order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: The `ErxTaskOrder` that has been redeemed
    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, ErxRepositoryError>

    /// Load All communications of the given profile
    /// - Returns: Array of all unread loaded `ErxTaskCommunication` sorted by timestamp
    /// - Parameter profile: Filters for the passed profile type
    func loadLocalCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], ErxRepositoryError>

    /// Save communications `isRead` property to local data store.
    /// - Parameter communications: communications where the `isRead` state should be changed.
    func saveLocal(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, ErxRepositoryError>

    /// Returns a count for all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    func countAllUnreadCommunicationsAndChargeItems(
        for fhirProfile: ErxTask.Communication.Profile
    ) -> AnyPublisher<Int, ErxRepositoryError>

    /// Load all AuditEvent's from a remote (server)
    ///
    /// - Returns: AnyPublisher that emits true if loading and sing the audit events was successful.
    ///            Raises a `DefaultErxTaskRepository.Error` if not
    func loadRemoteLatestAuditEvents(for locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError>

    /// Load one page of audit events from a remote (server) from an url previously provided by the server
    /// - Parameters:
    ///   - url: destination of the request
    ///   - locale: Location type of the language in which the result should be returned
    func loadRemoteAuditEventsPage(from url: URL, locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, ErxRepositoryError>

    /// Load all ErxChargeItem's from a remote (server).
    ///
    /// - Returns: AnyPublisher that emits an array of all `ErxChargeItems`s or `DefaultErxTaskRepository.Error`
    func loadRemoteChargeItems() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError>

    /// Loads All consents of a given profile
    /// Uses the request headers  ACCESS_TOKEN with the containing insurance id
    ///
    /// - Returns: Array of all loaded `ErxConsent`
    func fetchConsents() -> AnyPublisher<[ErxConsent], ErxRepositoryError>

    /// Loads the `ErxChargeItem` by its id from disk
    /// - Parameters:
    ///   - id: the `ErxChargeItem` ID
    /// - Returns: Publisher for the load request
    func loadLocal(by id: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, ErxRepositoryError>

    /// Load all local charge items (from disk)
    /// - Returns: Publisher for the load request
    func loadLocalAll() -> AnyPublisher<[ErxSparseChargeItem], ErxRepositoryError>

    /// Saves an array of `ErxChargeItem`s
    /// - Parameters:
    ///   - chargeItems: the `ErxChargeItem`s to be saved
    /// - Returns: Publisher for the load request
    func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError>

    /// Delete an array of `ErxChargeItem`s
    /// - Parameters:
    ///   - chargeItems: the `ErxChargeItem`s to be deleted
    /// - Returns: Publisher for the load request
    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, ErxRepositoryError>

    /// Send a grant consent request of  an `ErxConsent`
    ///
    /// - Parameter consent: Consent that contains information about the type of consent
    ///                         and insurance id which the consent will be granted for
    /// - Returns: The `ErxConsent` that was granted
    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, ErxRepositoryError>

    /// Delete an consent of `ErxConsent` to revoke it
    /// - Parameters:
    ///   - category: the `ErxConsent.Category`of the consent to be revoked
    /// - Returns: Publisher for the load request
    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, ErxRepositoryError>
}
