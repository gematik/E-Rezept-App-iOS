//
//  Copyright (c) 2023 gematik GmbH
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

/// Interface for the remote data store
public protocol ErxRemoteDataStore {
    /// Fetch the ErxTask by its id and accessCode when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxTask ID
    ///   - accessCode: AccessCode, optional as required by implementing DataStore
    /// - Returns: Publisher for the fetch request
    func fetchTask(by id: ErxTask.ID, accessCode: String?)
        -> AnyPublisher<ErxTask?, RemoteStoreError>

    /// List all tasks contained in the store
    /// - Parameter referenceDate: Tasks with modification date greater or equal  `referenceDate` will be listed.
    ///                            Pass `nil` for listing all
    func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], RemoteStoreError>

    /// Deletes a sequence of tasks from the store
    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError>

    /// Sends a redeem request of  an `ErxTask` for the selected pharmacy
    /// Note: The response does not verify that the pharmacy has accepted the order
    /// - Parameter order: Order that contains informations about the task,  redeem option
    ///                     and the pharmacy where the task should be redeemed
    /// - Returns: The order that has been redeemed
    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>

    /// Load All communications of the given profile
    /// - Parameters:
    ///   - referenceDate: `Communication`s with modification date great or equal  `referenceDate` will be listed.
    ///                     Pass `nil` for listing all
    ///   - profile: Filters for the passed Profile type
    func listAllCommunications(
        after referenceDate: String?,
        for profile: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>

    /// Fetch the ErxAuditEvent by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxAuditEvent ID
    /// - Returns: Publisher for the fetch request
    func fetchAuditEvent(by id: ErxAuditEvent.ID)
        -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>

    /// List all audit events contained in the store
    /// - Parameters:
    ///   - referenceDate: `AuditEvent`s with modification date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    ///   - locale: Location type of the language in which the result should be returned
    func listAllAuditEvents(after referenceDate: String?,
                            for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>

    /// List all audit events contained in the store
    /// - Parameters:
    ///   - referenceDate: `AuditEvent`s with modification date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    ///   - locale: Location type of the language in which the result should be returned
    func listAuditEventsNextPage(of previousPage: PagedContent<[ErxAuditEvent]>, for locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>

    /// List all medication dispenses for a specific `Prescription` /  `ErxTask`
    /// - Parameter id: MedicationDispense for the corresponding `ErxTask.ID` will be fetched.
    /// - Returns: `MedicationDispense`s
    func listMedicationDispenses(
        for id: ErxTask.ID
    ) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>

    /// Fetch the ErxChargeItem by its id when required by `Self`
    ///
    /// - Parameters:
    ///   - id: the ErxChargeIem ID
    /// - Returns: Publisher for the fetch request
    func fetchChargeItem(by id: ErxChargeItem.ID)
        -> AnyPublisher<ErxChargeItem?, RemoteStoreError>

    /// List all charge items contained in the store
    /// - Parameter referenceDate: `ChargeItem`s with entered date great or equal  `referenceDate` will be listed.
    ///                             Pass `nil` for listing all
    /// - Returns: Publisher for the fetch request
    func listAllChargeItems(after referenceDate: String?)
        -> AnyPublisher<[ErxChargeItem], RemoteStoreError>

    /// Loads All consents of a given profile
    /// Uses the request headers  ACCESS_TOKEN with the containing insurance id
    ///
    /// - Returns: Array of all loaded `ErxConsent`
    func fetchConsents() -> AnyPublisher<[ErxConsent], RemoteStoreError>

    /// Send a grant consent request of  an `ErxConsent`
    ///
    /// - Parameter consent: Consent that contains information about the type of consent
    ///                         and insurance id which the consent will be granted for
    /// - Returns: The `ErxConsent` that was granted
    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError>

    /// Delete an consent of `ErxConsent` to revoke it
    /// - Parameters:
    ///   - category: the `ErxConsent.Category`of the consent to be revoked
    /// - Returns: Publisher for the load request
    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError>
}
