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

import BundleKit
import Combine
import eRpKit
import FHIRClient
import Foundation
import ModelsR4

extension ErxTaskFHIRDataStore {
    public enum Error: Swift.Error, LocalizedError, Equatable {
        public static func ==(lhs: ErxTaskFHIRDataStore.Error, rhs: ErxTaskFHIRDataStore.Error) -> Bool {
            switch (lhs, rhs) {
            case let (fhirClientError(lhsError), fhirClientError(rhsError)): return lhsError == rhsError
            case (notImplemented, notImplemented): return true
            default: return false
            }
        }

        case fhirClientError(FHIRClient.Error)
        case notImplemented

        public var errorDescription: String? {
            switch self {
            case let .fhirClientError(error):
                return error.localizedDescription
            case .notImplemented:
                return "ErxTaskFHIRDataStore: missing interface implementation"
            }
        }
    }
}

public class ErxTaskFHIRDataStore: ErxTaskDataStore {
    private let fhirClient: FHIRClient

    public init(fhirClient: FHIRClient) {
        self.fhirClient = fhirClient
    }

    public func fetchTask(by id: ErxTask.ID, // swiftlint:disable:this identifier_name
                          accessCode: String?)
        -> AnyPublisher<ErxTask?, Error> {
        fhirClient.fetchTask(by: id, accessCode: accessCode)
            .mapError { Error.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], Error> {
        fhirClient.fetchAllTaskIDs(after: referenceDate)
            .mapError { Error.fhirClientError($0) }
            .first()
            .flatMap { self.collectAndMergeTaskPublishers(taskIds: $0) }
            .eraseToAnyPublisher()
    }

    public func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    private func collectAndMergeTaskPublishers(taskIds: [String]) -> AnyPublisher<[ErxTask], Error> {
        let taskPublishers: [AnyPublisher<ErxTask, Error>] =
            taskIds.map { taskId in
                self.fhirClient
                    .fetchTask(by: taskId, accessCode: nil)
                    .first()
                    .compactMap { $0 }
                    .mapError { Error.fhirClientError($0) }
                    .eraseToAnyPublisher()
            }

        return Publishers.MergeMany(taskPublishers)
            .collect()
            .eraseToAnyPublisher()
    }

    public func save(tasks _: [ErxTask]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, Error> {
        // swiftlint:disable:next todo
        // TODO: Ideally this should delete multiple tasks at once.
        //       But it needs special error handling, if the server only
        //       deleted 2 or 3 prescriptions etc.
        //       So for now this will only accept one ErxTask.

        // In case of error...
        guard tasks.count == 1,
              let id = tasks.first?.id, // swiftlint:disable:this identifier_name
              let accessCode = tasks.first?.accessCode
        else {
            var fhirClientError = FHIRClient.Error.unknown(Error.notImplemented)
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
            let localError = ErxTaskFHIRDataStore.Error.fhirClientError(fhirClientError)

            return Result<Bool, Error>.failure(localError).publisher.eraseToAnyPublisher()
        }

        // In case of success...
        return fhirClient.deleteTask(by: id, accessCode: accessCode)
            .mapError { Error.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, Error> {
        let redeemOrderPublishers: [AnyPublisher<Bool, Error>] =
            orders.map { order in
                self.fhirClient.redeem(order: order)
                    .first()
                    .mapError { Error.fhirClientError($0) }
                    .eraseToAnyPublisher()
            }

        return Publishers.MergeMany(redeemOrderPublishers)
            .collect()
            .map { _ in true } // always returns true or throws an error
            .eraseToAnyPublisher()
    }
}

extension ErxTaskFHIRDataStore: ErxAuditEventDataStore {
    public func fetchAuditEvent(by id: ErxAuditEvent.ID) // swiftlint:disable:this identifier_name
        -> AnyPublisher<ErxAuditEvent?, Error> {
        fhirClient.fetchAuditEvent(by: id)
            .mapError { Error.fhirClientError($0) }
            .eraseToAnyPublisher()
    }

    public func fetchLatestTimestampForAuditEvents() -> AnyPublisher<String?, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func listAllAuditEvents(after referenceDate: String? = nil,
                                   for locale: String? = nil) -> AnyPublisher<[ErxAuditEvent], Error> {
        fhirClient.fetchAllAuditEvents(after: referenceDate, for: locale)
            .mapError { Error.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func listAllAuditEvents(forTaskID _: ErxTask.ID,
                                   for _: String? = nil) -> AnyPublisher<[ErxAuditEvent], Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func save(auditEvents _: [ErxAuditEvent]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }
}

extension ErxTaskFHIRDataStore: ErxCommunicationDataStore {
    public func listAllCommunications(
        after referenceDate: String?,
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], Error> {
        fhirClient.communicationResources(after: referenceDate)
            .mapError { Error.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func listAllUnreadCommunications(
        for _: ErxTask.Communication.Profile
    ) -> AnyPublisher<[ErxTask.Communication], Error> {
        // Can only be implemented by the local store since server has no knowledge about read state
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func save(communications _: [ErxTask.Communication]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func countAllUnreadCommunications(for _: ErxTask.Communication.Profile) -> AnyPublisher<Int, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }
}

extension ErxTaskFHIRDataStore: ErxMedicationDispenseDataStore {
    public func fetchLatestHandOverDateForMedicationDispenses() -> AnyPublisher<String?, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }

    public func listAllMedicationDispenses(
        after referenceDate: String?
    ) -> AnyPublisher<[ErxTask.MedicationDispense], Error> {
        fhirClient.fetchAllMedicationDispenses(after: referenceDate)
            .mapError { Error.fhirClientError($0) }
            .first()
            .eraseToAnyPublisher()
    }

    public func save(medicationDispenses _: [ErxTask.MedicationDispense]) -> AnyPublisher<Bool, Error> {
        Fail(error: Error.notImplemented).eraseToAnyPublisher()
    }
}
