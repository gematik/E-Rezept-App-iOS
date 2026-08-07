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

/// Interface for the remote data store
public protocol ErxRemoteDataStore {
    /// Fetch the ErxTask by its id and accessCode when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the fetch request
    func fetchTask(by id: ErxTask.ID, accessCode: String?,
                   profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>

    /// List all tasks contained in the store
    /// - Parameters:
    ///   - referenceDate: Tasks with modification date greater or equal  `referenceDate` will be listed.
    ///                            Pass `nil` for listing all
    ///   - profileId: The profile to use for the request
    func listAllTasks(after referenceDate: String?,
                      profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>

    /// List the next page of a previous received PagedContent.
    /// - Parameters:
    ///   - previousPage: The previous page of the content to retrieve
    ///   - profileId: The profile to use for the request
    func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>,
                           profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>

    /// List detailed tasks with all available information in the store
    /// - Parameters:
    ///   - tasks: The low detail tasks
    ///   - profileId: The profile to use for the request
    func listDetailedTasks(for tasks: PagedContent<[ErxTask]>,
                           profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>

    /// Deletes a sequence of tasks from the store
    /// - Parameters:
    ///   - tasks: The tasks to delete
    ///   - profileId: The profile to use for the request
    func delete(tasks: [ErxTask],
                profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError>

    /// Marks the `ErxTask` by its id as EU redeemable by a patient
    /// - Parameters:
    ///   - id: the `ErxTask` ID
    ///   - byPatientAuthorization: marks the task as EU redeemable `true` or `false`
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the load request
    func markEURedeemable(for id: ErxTask.ID, byPatientAuthorization: Bool,
                          profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameters:
    ///   - order: Order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    ///   - profileId: The profile to use for the request
    /// - Returns: The order that has been redeemed
    func redeem(order: ErxTaskOrder,
                profileId: UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>

    /// Load All communications of the given profile
    /// - Parameters:
    ///   - referenceDate: `Communication`s with modification date great or equal  `referenceDate` will be listed.
    ///                     Pass `nil` for listing all
    ///   - profile: Filters for the passed Profile type
    ///   - profileId: The profile to use for the request
    func listAllCommunications(
        after referenceDate: String?,
        for profile: ErxTask.Communication.Profile,
        profileId: UUID
    ) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>

    /// Fetch the ErxAuditEvent by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxAuditEvent ID
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the fetch request
    func fetchAuditEvent(by id: ErxAuditEvent.ID,
                         profileId: UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>

    /// List all audit events contained in the store
    /// - Parameters:
    ///   - referenceDate: `AuditEvent`s with modification date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    ///   - locale: Location type of the language in which the result should be returned
    ///   - profileId: The profile to use for the request
    func listAllAuditEvents(after referenceDate: String?, for locale: String?,
                            profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>

    /// List all audit events contained in the store
    /// - Parameters:
    ///   - url: destination of the request
    ///   - locale: Location type of the language in which the result should be returned
    ///   - profileId: The profile to use for the request
    func listAuditEventsNextPage(from url: URL, locale: String?,
                                 profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>

    /// List all medication dispenses for a specific `Prescription` /  `ErxTask`
    /// - Parameters:
    ///   - id: MedicationDispense for the corresponding `ErxTask.ID` will be fetched.
    ///   - profileId: The profile to use for the request
    /// - Returns: `MedicationDispense`s
    func listMedicationDispenses(
        for id: ErxTask.ID,
        profileId: UUID
    ) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>

    /// Fetch the ErxChargeItem by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxChargeIem ID
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the fetch request
    func fetchChargeItem(by id: ErxChargeItem.ID,
                         profileId: UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>

    /// List all charge items contained in the store
    /// - Parameters:
    ///   - referenceDate: `ChargeItem`s with entered date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the fetch request
    func listAllChargeItems(after referenceDate: String?,
                            profileId: UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>

    /// Deletes a sequence of charge items from the store
    /// - Parameters:
    ///   - chargeItems: The charge items to delete
    ///   - profileId: The profile to use for the request
    func delete(chargeItems: [ErxChargeItem],
                profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError>

    /// Loads All consents of a given profile
    /// Uses the request headers  ACCESS_TOKEN with the containing insurance id
    ///
    /// - Parameter profileId: The profile to use for the request
    /// - Returns: Array of all loaded `ErxConsent`
    func fetchConsents(profileId: UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError>

    /// Send a grant consent request of  an `ErxConsent`
    ///
    /// - Parameters:
    ///   - consent: Consent that contains information about the type of consent
    ///                         and insurance id which the consent will be granted for
    ///   - profileId: The profile to use for the request
    /// - Returns: The `ErxConsent` that was granted
    func grantConsent(_ consent: ErxConsent,
                      profileId: UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError>

    /// Delete an consent of `ErxConsent` to revoke it
    /// - Parameters:
    ///   - category: the `ErxConsent.Category`of the consent to be revoked
    ///   - profileId: The profile to use for the request
    /// - Returns: Publisher for the load request
    func revokeConsent(_ category: ErxConsent.Category,
                       profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError>

    /// Loads All active `EuAccessCode`
    ///
    /// - Parameter profileId: The profile to use for the request
    /// - Returns: Array of all active `EuAccessCode`
    func loadRemoteEuAccessCode(profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>

    ///  Sends an `EuAccessCode` to activate/grand it
    /// - Parameters:
    ///   - accessCode: the `EuAccessCode`to be granted
    ///   - profileId: The profile to use for the request
    /// - Returns: The `EuAccessCode` that was granted
    func grantEuAccessPermission(accessCode: EuAccessCode,
                                 profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>

    ///  Delete active `EuAccessCode` from server
    /// - Parameter profileId: The profile to use for the request
    func deleteEuAccessCode(profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError>
}
