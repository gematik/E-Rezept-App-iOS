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

import BundleKit
import Combine
import eRpKit
import FHIRClient
import Foundation

public class ErxTaskFHIRDataStore: ErxRemoteDataStore {
    private let fhirClient: FHIRClient

    public init(fhirClient: FHIRClient) {
        self.fhirClient = fhirClient
    }

    // MARK: - ErxTasks

    public func fetchTask(by id: ErxTask.ID,
                          accessCode: String?)
        -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fhirClient.fetchTask(by: id, accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], RemoteStoreError> {
        fhirClient.fetchAllTaskIDs(after: referenceDate)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .flatMap { self.collectAndCombineLatestTaskPublishers(taskIds: $0) }
            .eraseToAnyPublisher()
    }

    private func collectAndCombineLatestTaskPublishers(
        taskIds: [String]
    ) -> AnyPublisher<[ErxTask], RemoteStoreError> {
        let taskPublishers: [AnyPublisher<ErxTask, RemoteStoreError>] =
            taskIds.map { taskId in
                self.fhirClient
                    .fetchTask(by: taskId, accessCode: nil)
                    .first()
                    .compactMap { $0 }
                    .mapError { RemoteStoreError.fhirClientError($0) }
                    .eraseToAnyPublisher()
            }

        return taskPublishers
            .combineLatest()
            .first()
            .eraseToAnyPublisher()
    }

    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        // swiftlint:disable:next todo
        // TODO: Ideally this should delete multiple tasks at once.
        //       But it needs special error handling, if the server only
        //       deleted 2 or 3 prescriptions etc.
        //       So for now this will only accept one ErxTask.

        // In case of error...
        guard tasks.count == 1,
              let id = tasks.first?.id,
              let accessCode = tasks.first?.accessCode
        else {
            var fhirClientError = FHIRClient.Error.unknown(RemoteStoreError.notImplemented)
            if tasks.isEmpty {
                fhirClientError = FHIRClient.Error.internalError("Cannot delete: Empty array of ErxTasks!")
            } else if tasks.count > 1 {
                fhirClientError = FHIRClient.Error.internalError(
                    "Cannot delete: Deletion of multiple elements is not implemented currently!"
                )
            } else {
                fhirClientError = FHIRClient.Error.internalError(
                    "Cannot delete: ID oder accessCode missing?"
                )
            }
            let localError = RemoteStoreError.fhirClientError(fhirClientError)

            return Result<Bool, RemoteStoreError>.failure(localError).publisher.eraseToAnyPublisher()
        }

        // In case of success...
        return fhirClient.deleteTask(by: id, accessCode: accessCode)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        fhirClient.redeem(order: order)
            .first()
            .mapError { RemoteStoreError.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - AuditEvent

    public func fetchAuditEvent(by id: ErxAuditEvent.ID)
        -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fhirClient.fetchAuditEvent(by: id)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(
        after referenceDate: String? = nil,
        for locale: String? = nil
    ) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        fhirClient.fetchAllAuditEvents(after: referenceDate, for: locale)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func listAuditEventsNextPage(of previousPage: PagedContent<[ErxAuditEvent]>, for locale: String?)
        -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        fhirClient.fetchAuditEventsNextPage(of: previousPage, for: locale)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - Communications

    public func listAllCommunications(
        after referenceDate: String?,
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        fhirClient.communicationResources(after: referenceDate)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - MedicationDispense

    public func listMedicationDispenses(
        for taskId: String
    ) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        fhirClient.fetchMedicationDispenses(for: taskId)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - ChargeItem

    public func fetchChargeItem(by id: ErxChargeItem.ID)
        -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fhirClient.fetchChargeItem(by: id)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func listAllChargeItems(after referenceDate: String?)
        -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        fhirClient.fetchAllChargeItemIDs(after: referenceDate)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .flatMap { self.collectAndCombineLatestChargeItemPublishers(chargeItemIds: $0) }
            .eraseToAnyPublisher()
    }

    private func collectAndCombineLatestChargeItemPublishers(
        chargeItemIds: [String]
    ) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        let chargeItemPublishers: [AnyPublisher<ErxChargeItem, RemoteStoreError>] =
            chargeItemIds.map { chargeItemId in
                self.fhirClient
                    .fetchChargeItem(by: chargeItemId)
                    .first()
                    .compactMap { $0 }
                    .mapError { RemoteStoreError.fhirClientError($0) }
                    .eraseToAnyPublisher()
            }

        return chargeItemPublishers
            .combineLatest()
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - Consents

    public func fetchConsents()
        -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fhirClient.fetchConsents()
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func grantConsent(
        _ consent: ErxConsent
    ) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        fhirClient.grantConsent(consent)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func revokeConsent(
        _ category: ErxConsent.Category
    ) -> AnyPublisher<Bool, RemoteStoreError> {
        fhirClient.revokeConsent(category)
            .mapError { RemoteStoreError.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }
}
