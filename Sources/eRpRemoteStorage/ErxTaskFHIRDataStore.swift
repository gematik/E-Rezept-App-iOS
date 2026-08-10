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
import eRpKit
import FHIRClient
import Foundation

public class ErxTaskFHIRDataStore: ErxRemoteDataStore {
    private let factory: (UUID) -> FHIRClient

    public init(fhirClient: FHIRClient) {
        factory = { _ in fhirClient }
    }

    public init(factory: @escaping (UUID) -> FHIRClient) {
        self.factory = factory
    }

    private func client(for profileId: UUID) -> FHIRClient {
        factory(profileId)
    }

    // MARK: - ErxTasks

    public func fetchTask(by id: ErxTask.ID,
                          accessCode: String?,
                          profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        client(for: profileId).fetchTask(by: id, accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func listAllTasks(after referenceDate: String?,
                             profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        client(for: profileId).fetchAllTasks(after: referenceDate)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func listTasksNextPage(of previousPage: eRpKit.PagedContent<[eRpKit.ErxTask]>,
                                  profileId: UUID)
        -> AnyPublisher<eRpKit.PagedContent<[eRpKit.ErxTask]>, eRpKit.RemoteStoreError> {
        client(for: profileId).fetchTasksNextPage(for: previousPage.next)
            .mapError(RemoteStoreError.fhirClient)
            .first()
            .eraseToAnyPublisher()
    }

    public func listDetailedTasks(for tasks: PagedContent<[ErxTask]>,
                                  profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        collectAndCombineLatestTaskPublishers(
            taskIds: PagedContent(content: tasks.content.map(\.identifier), next: tasks.next),
            profileId: profileId
        )
    }

    private func collectAndCombineLatestTaskPublishers(
        taskIds: PagedContent<[String]>,
        profileId: UUID
    ) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        let fhirClient = client(for: profileId)
        let taskPublishers: [AnyPublisher<ErxTask, RemoteStoreError>] =
            taskIds.content.map { taskId in
                fhirClient
                    .fetchTask(by: taskId, accessCode: nil)
                    .first()
                    .compactMap { $0 }
                    .mapError { RemoteStoreError.fhirClient($0) }
                    .eraseToAnyPublisher()
            }

        return taskPublishers
            .combineLatest()
            .first()
            .map { tasks in
                PagedContent(content: tasks, next: taskIds.next)
            }
            .eraseToAnyPublisher()
    }

    public func delete(tasks: [ErxTask],
                       profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        // swiftlint:disable:next todo
        // TODO: Ideally this should delete multiple tasks at once.
        //       But it needs special error handling, if the server only
        //       deleted 2 or 3 prescriptions etc.
        //       So for now this will only accept one ErxTask.

        // In case of error...
        guard tasks.count == 1,
              let id = tasks.first?.id
        else {
            var fhirClientError = FHIRClient.Error.unknown(RemoteStoreError.notImplemented)
            if tasks.isEmpty {
                fhirClientError = FHIRClient.Error.internalError("Can't be deleted: Empty array of ErxTasks!")
            } else if tasks.count > 1 {
                fhirClientError = FHIRClient.Error.internalError(
                    "Can't be deleted: Deletion of multiple elements is not implemented currently!"
                )
            } else {
                fhirClientError = FHIRClient.Error.internalError(
                    "Can't be deleted: ID is missing!"
                )
            }
            let localError = RemoteStoreError.fhirClient(fhirClientError)

            return Result<Bool, RemoteStoreError>.failure(localError).publisher.eraseToAnyPublisher()
        }

        // accessCode is optional for deleting a task
        let accessCode = tasks.first?.accessCode

        // In case of success...
        return client(for: profileId).deleteTask(by: id, accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func markEURedeemable(
        for id: ErxTask.ID,
        byPatientAuthorization: Bool,
        profileId: UUID
    ) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        client(for: profileId).markEURedeemable(for: id, byPatientAuthorization: byPatientAuthorization)
            .first()
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func redeem(order: ErxTaskOrder,
                       profileId: UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        client(for: profileId).redeem(order: order)
            .first()
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - AuditEvent

    public func fetchAuditEvent(by id: ErxAuditEvent.ID,
                                profileId: UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        client(for: profileId).fetchAuditEvent(by: id)
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(
        after referenceDate: String? = nil,
        for locale: String? = nil,
        profileId: UUID
    ) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        client(for: profileId).fetchAllAuditEvents(after: referenceDate, for: locale)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func listAuditEventsNextPage(from url: URL, locale: String?,
                                        profileId: UUID)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        client(for: profileId).fetchAuditEventsNextPage(from: url, locale: locale)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - Communications

    public func listAllCommunications(
        after referenceDate: String?,
        for _: ErxTask.Communication.Profile,
        profileId: UUID
    ) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        client(for: profileId).communicationResources(after: referenceDate)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - MedicationDispense

    public func listMedicationDispenses(
        for taskId: String,
        profileId: UUID
    ) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        client(for: profileId).fetchMedicationDispenses(for: taskId)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - ChargeItem

    public func fetchChargeItem(by id: ErxChargeItem.ID,
                                profileId: UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        client(for: profileId).fetchChargeItem(by: id)
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    public func listAllChargeItems(after referenceDate: String?,
                                   profileId: UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        let fhirClient = client(for: profileId)
        return fhirClient.fetchAllChargeItemIDs(after: referenceDate)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .flatMap { self.collectAndCombineLatestChargeItemPublishers(chargeItemIds: $0, fhirClient: fhirClient) }
            .eraseToAnyPublisher()
    }

    private func collectAndCombineLatestChargeItemPublishers(
        chargeItemIds: [String],
        fhirClient: FHIRClient
    ) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        let chargeItemPublishers: [AnyPublisher<ErxChargeItem, RemoteStoreError>] =
            chargeItemIds.map { chargeItemId in
                fhirClient
                    .fetchChargeItem(by: chargeItemId)
                    .first()
                    .compactMap { $0 }
                    .mapError { RemoteStoreError.fhirClient($0) }
                    .eraseToAnyPublisher()
            }

        return chargeItemPublishers
            .combineLatest()
            .first()
            .eraseToAnyPublisher()
    }

    public func delete(chargeItems: [ErxChargeItem],
                       profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        // swiftlint:disable:next todo
        // TODO: Ideally this should delete multiple tasks at once.
        //       But it needs special error handling, if the server only
        //       deleted 2 or 3 prescriptions etc.
        //       So for now this will only accept one ErxTask.

        // In case of error...
        guard chargeItems.count == 1,
              let id = chargeItems.first?.id,
              let accessCode = chargeItems.first?.accessCode
        else {
            var fhirClientError = FHIRClient.Error.unknown(RemoteStoreError.notImplemented)
            if chargeItems.isEmpty {
                fhirClientError = FHIRClient.Error.internalError("Cannot delete: Empty array of ErxChargeItem!")
            } else if chargeItems.count > 1 {
                fhirClientError = FHIRClient.Error.internalError(
                    "Cannot delete: Deletion of multiple elements is not implemented currently!"
                )
            } else {
                fhirClientError = FHIRClient.Error.internalError(
                    "Cannot delete: ID or accessCode missing?"
                )
            }
            let localError = RemoteStoreError.fhirClient(fhirClientError)

            return Result<Bool, RemoteStoreError>.failure(localError).publisher.eraseToAnyPublisher()
        }

        // In case of success...
        return client(for: profileId).deleteChargeItem(by: id, accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClient($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - Consents

    public func fetchConsents(profileId: UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        client(for: profileId).fetchConsents()
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func grantConsent(
        _ consent: ErxConsent,
        profileId: UUID
    ) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        client(for: profileId).grantConsent(consent)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func revokeConsent(
        _ category: ErxConsent.Category,
        profileId: UUID
    ) -> AnyPublisher<Bool, RemoteStoreError> {
        client(for: profileId).revokeConsent(category)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - EuRedeem

    public func grantEuAccessPermission(
        accessCode: EuAccessCode,
        profileId: UUID
    ) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        client(for: profileId).grantEuAccessPermission(accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func loadRemoteEuAccessCode(profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        client(for: profileId).loadRemoteEuAccessCode()
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func deleteEuAccessCode(profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        client(for: profileId).deleteEuAccessCode()
            .mapError { RemoteStoreError.fhirClient($0) }
            .first()
            .eraseToAnyPublisher()
    }
}
