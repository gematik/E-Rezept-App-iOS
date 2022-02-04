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
@testable import eRpKit

// MARK: - MockErxRemoteDataStore -

final class MockErxRemoteDataStore: ErxRemoteDataStore {
    // MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        fetchTaskByAccessCodeCallsCount > 0
    }

    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        return fetchTaskByAccessCodeClosure.map { $0(id, accessCode) } ?? fetchTaskByAccessCodeReturnValue
    }

    // MARK: - listAllTasks

    var listAllTasksAfterCallsCount = 0
    var listAllTasksAfterCalled: Bool {
        listAllTasksAfterCallsCount > 0
    }

    var listAllTasksAfterReceivedReferenceDate: String?
    var listAllTasksAfterReceivedInvocations: [String?] = []
    var listAllTasksAfterReturnValue: AnyPublisher<[ErxTask], RemoteStoreError>!
    var listAllTasksAfterClosure: ((String?) -> AnyPublisher<[ErxTask], RemoteStoreError>)?

    func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], RemoteStoreError> {
        listAllTasksAfterCallsCount += 1
        listAllTasksAfterReceivedReferenceDate = referenceDate
        listAllTasksAfterReceivedInvocations.append(referenceDate)
        return listAllTasksAfterClosure.map { $0(referenceDate) } ?? listAllTasksAfterReturnValue
    }

    // MARK: - delete

    var deleteTasksCallsCount = 0
    var deleteTasksCalled: Bool {
        deleteTasksCallsCount > 0
    }

    var deleteTasksReceivedTasks: [ErxTask]?
    var deleteTasksReceivedInvocations: [[ErxTask]] = []
    var deleteTasksReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var deleteTasksClosure: (([ErxTask]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksCallsCount += 1
        deleteTasksReceivedTasks = tasks
        deleteTasksReceivedInvocations.append(tasks)
        return deleteTasksClosure.map { $0(tasks) } ?? deleteTasksReturnValue
    }

    // MARK: - redeem

    var redeemOrdersCallsCount = 0
    var redeemOrdersCalled: Bool {
        redeemOrdersCallsCount > 0
    }

    var redeemOrdersReceivedOrders: [ErxTaskOrder]?
    var redeemOrdersReceivedInvocations: [[ErxTaskOrder]] = []
    var redeemOrdersReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var redeemOrdersClosure: (([ErxTaskOrder]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func redeem(orders: [ErxTaskOrder]) -> AnyPublisher<Bool, RemoteStoreError> {
        redeemOrdersCallsCount += 1
        redeemOrdersReceivedOrders = orders
        redeemOrdersReceivedInvocations.append(orders)
        return redeemOrdersClosure.map { $0(orders) } ?? redeemOrdersReturnValue
    }

    // MARK: - listAllCommunications

    var listAllCommunicationsAfterForCallsCount = 0
    var listAllCommunicationsAfterForCalled: Bool {
        listAllCommunicationsAfterForCallsCount > 0
    }

    var listAllCommunicationsAfterForReceivedArguments: (
        referenceDate: String?,
        profile: ErxTask.Communication.Profile
    )?
    var listAllCommunicationsAfterForReceivedInvocations: [(referenceDate: String?,
                                                            profile: ErxTask.Communication.Profile)] = []
    var listAllCommunicationsAfterForReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    var listAllCommunicationsAfterForClosure: ((String?, ErxTask.Communication.Profile)
        -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    func listAllCommunications(after referenceDate: String?,
                               for profile: ErxTask.Communication.Profile) -> AnyPublisher<
        [ErxTask.Communication],
        RemoteStoreError
    > {
        listAllCommunicationsAfterForCallsCount += 1
        listAllCommunicationsAfterForReceivedArguments = (referenceDate: referenceDate, profile: profile)
        listAllCommunicationsAfterForReceivedInvocations.append((referenceDate: referenceDate, profile: profile))
        return listAllCommunicationsAfterForClosure
            .map { $0(referenceDate, profile) } ?? listAllCommunicationsAfterForReturnValue
    }

    // MARK: - fetchAuditEvent

    var fetchAuditEventByCallsCount = 0
    var fetchAuditEventByCalled: Bool {
        fetchAuditEventByCallsCount > 0
    }

    var fetchAuditEventByReceivedId: ErxAuditEvent.ID?
    var fetchAuditEventByReceivedInvocations: [ErxAuditEvent.ID] = []
    var fetchAuditEventByReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    var fetchAuditEventByClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByCallsCount += 1
        fetchAuditEventByReceivedId = id
        fetchAuditEventByReceivedInvocations.append(id)
        return fetchAuditEventByClosure.map { $0(id) } ?? fetchAuditEventByReturnValue
    }

    // MARK: - listAllAuditEvents

    var listAllAuditEventsAfterForCallsCount = 0
    var listAllAuditEventsAfterForCalled: Bool {
        listAllAuditEventsAfterForCallsCount > 0
    }

    var listAllAuditEventsAfterForReceivedArguments: (referenceDate: String?, locale: String?)?
    var listAllAuditEventsAfterForReceivedInvocations: [(referenceDate: String?, locale: String?)] = []
    var listAllAuditEventsAfterForReturnValue: AnyPublisher<[ErxAuditEvent], RemoteStoreError>!
    var listAllAuditEventsAfterForClosure: ((String?, String?) -> AnyPublisher<[ErxAuditEvent], RemoteStoreError>)?

    func listAllAuditEvents(after referenceDate: String?,
                            for locale: String?) -> AnyPublisher<[ErxAuditEvent], RemoteStoreError> {
        listAllAuditEventsAfterForCallsCount += 1
        listAllAuditEventsAfterForReceivedArguments = (referenceDate: referenceDate, locale: locale)
        listAllAuditEventsAfterForReceivedInvocations.append((referenceDate: referenceDate, locale: locale))
        return listAllAuditEventsAfterForClosure
            .map { $0(referenceDate, locale) } ?? listAllAuditEventsAfterForReturnValue
    }

    // MARK: - listAllMedicationDispenses

    var listAllMedicationDispensesAfterCallsCount = 0
    var listAllMedicationDispensesAfterCalled: Bool {
        listAllMedicationDispensesAfterCallsCount > 0
    }

    var listAllMedicationDispensesAfterReceivedReferenceDate: String?
    var listAllMedicationDispensesAfterReceivedInvocations: [String?] = []
    var listAllMedicationDispensesAfterReturnValue: AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError>!
    var listAllMedicationDispensesAfterClosure: ((String?)
        -> AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError>)?

    func listAllMedicationDispenses(after referenceDate: String?)
        -> AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError> {
        listAllMedicationDispensesAfterCallsCount += 1
        listAllMedicationDispensesAfterReceivedReferenceDate = referenceDate
        listAllMedicationDispensesAfterReceivedInvocations.append(referenceDate)
        return listAllMedicationDispensesAfterClosure
            .map { $0(referenceDate) } ?? listAllMedicationDispensesAfterReturnValue
    }
}
