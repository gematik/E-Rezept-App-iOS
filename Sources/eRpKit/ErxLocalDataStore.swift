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
import Foundation

/// Instances conforming to `PagedAuditEventsController` allow paged (database) access to `ErxAuditEvents`.
///
/// sourcery: StreamWrapped
public protocol PagedAuditEventsController {
    /// Returns a `PageContainer` for accessing `ErxAuditEvents` in a paged manner.
    /// - Returns: `PageContainer` containing all available pages.
    func getPageContainer() -> PageContainer?

    /// Return a publisher for `[ErxAuditEvents]` that are on a given page.
    /// - Returns: Publisher for `[ErxAuditEvents]`
    func getPage(_ page: Page) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>
}

/// Interface for the local data store
public protocol ErxLocalDataStore {
    // MARK: - ErxTask interfaces

    /// Fetch the ErxTask by its id and accessCode when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    /// - Returns: Publisher for the fetch request
    func fetchTask(by id: ErxTask.ID, accessCode: String?)
        -> AnyPublisher<ErxTask?, LocalStoreError>

    /// List all tasks contained in the store
    func listAllTasks() -> AnyPublisher<[ErxTask], LocalStoreError>

    /// Fetch the most recent `lastModified` of all `ErxTask`s
    func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, LocalStoreError>

    /// Creates or updates a sequence of tasks into the store
    /// - Parameter tasks: Array of `ErxTasks`s that should be saved
    /// - Parameter updateProfileLastAuthenticated: `true` if the profile last authenticated should be updated, `false`
    ///   otherwise.
    /// - Returns: A publisher that finishes with `true` on completion or fails with an error.
    func save(tasks: [ErxTask], updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError>

    /// Deletes a sequence of tasks from the store
    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, LocalStoreError>

    /// List all tasks without relationship to a `Profile`
    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError>

    // MARK: - Communication interfaces

    /// List all communications for the given profile contained in the store
    /// - Parameter profile: Filters for the passed Profile type
    /// - Returns: array of the fetched communications or error
    func listAllCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>

    /// Fetch the most recent `timestamp` of all `Communication`s
    func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, LocalStoreError>

    /// Creates or updates the passes sequence of `ErxTaskCommunication`s
    /// - Parameter communications: Array of communications that should be stored
    /// - Returns: `true` if save operation was successful
    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError>

    /// Returns all unread communications for the given profile
    /// - Parameter profile: profile for which you want to have the count
    func allUnreadCommunications(
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>

    // MARK: - MedicationDispense interfaces

    /// List all medication dispenses contained in the store
    func listAllMedicationDispenses() -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>

    /// Creates or updates the passed sequence of `ErxTask.MedicationDispense`s
    /// - Parameter medicationDispenses: Array of medication dispenses that should be stored
    /// - Returns: `true` if save operation was successful
    func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>

    // MARK: - ChargeItem interfaces

    /// Fetch the ErxChargeItem by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxChargeItem ID
    /// - Returns: Publisher for the fetch request
    func fetchChargeItem(
        by chargeItemID: ErxSparseChargeItem.ID
    ) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>

    /// Fetch the most recent `enteredDate` of all `ChargeItem`s
    func fetchLatestTimestampForChargeItems() -> AnyPublisher<String?, LocalStoreError>

    /// List all charge items with the given local contained in the store
    /// - Returns: Array of the fetched charge items or error
    func listAllChargeItems() -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>

    /// Creates or updates the passed sequence of `ErxSparseChargeItem`s
    /// - Parameter chargeItems: Array of charge items that should be stored
    /// - Returns: `true` if save operation was successful
    func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>

    /// Deletes a sequence of charge items from the store
    /// - Parameter chargeItems: Array of charge items that should be deleted
    /// - Returns: `true` if delete operation was successful
    func delete(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>

    /// Creates or updates the passed sequence of `DiGaInfo`
    /// - Parameter diGaInfo: diGaInfo that should be saved
    /// - Returns: `true` if save operation was successful
    func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError>
}
