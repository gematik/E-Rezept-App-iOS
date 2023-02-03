// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import Foundation

@testable import eRpKit

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.




















final class MockErxLocalDataStore: ErxLocalDataStore {


    //MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        return fetchTaskByAccessCodeCallsCount > 0
    }
    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, LocalStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, LocalStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        if let fetchTaskByAccessCodeClosure = fetchTaskByAccessCodeClosure {
            return fetchTaskByAccessCodeClosure(id, accessCode)
        } else {
            return fetchTaskByAccessCodeReturnValue
        }
    }

    //MARK: - listAllTasks

    var listAllTasksCallsCount = 0
    var listAllTasksCalled: Bool {
        return listAllTasksCallsCount > 0
    }
    var listAllTasksReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasks() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksCallsCount += 1
        if let listAllTasksClosure = listAllTasksClosure {
            return listAllTasksClosure()
        } else {
            return listAllTasksReturnValue
        }
    }

    //MARK: - fetchLatestLastModifiedForErxTasks

    var fetchLatestLastModifiedForErxTasksCallsCount = 0
    var fetchLatestLastModifiedForErxTasksCalled: Bool {
        return fetchLatestLastModifiedForErxTasksCallsCount > 0
    }
    var fetchLatestLastModifiedForErxTasksReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestLastModifiedForErxTasksClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksCallsCount += 1
        if let fetchLatestLastModifiedForErxTasksClosure = fetchLatestLastModifiedForErxTasksClosure {
            return fetchLatestLastModifiedForErxTasksClosure()
        } else {
            return fetchLatestLastModifiedForErxTasksReturnValue
        }
    }

    //MARK: - save

    var saveTasksUpdateProfileLastAuthenticatedCallsCount = 0
    var saveTasksUpdateProfileLastAuthenticatedCalled: Bool {
        return saveTasksUpdateProfileLastAuthenticatedCallsCount > 0
    }
    var saveTasksUpdateProfileLastAuthenticatedReceivedArguments: (tasks: [ErxTask], updateProfileLastAuthenticated: Bool)?
    var saveTasksUpdateProfileLastAuthenticatedReceivedInvocations: [(tasks: [ErxTask], updateProfileLastAuthenticated: Bool)] = []
    var saveTasksUpdateProfileLastAuthenticatedReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveTasksUpdateProfileLastAuthenticatedClosure: (([ErxTask], Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(tasks: [ErxTask], updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksUpdateProfileLastAuthenticatedCallsCount += 1
        saveTasksUpdateProfileLastAuthenticatedReceivedArguments = (tasks: tasks, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksUpdateProfileLastAuthenticatedReceivedInvocations.append((tasks: tasks, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        if let saveTasksUpdateProfileLastAuthenticatedClosure = saveTasksUpdateProfileLastAuthenticatedClosure {
            return saveTasksUpdateProfileLastAuthenticatedClosure(tasks, updateProfileLastAuthenticated)
        } else {
            return saveTasksUpdateProfileLastAuthenticatedReturnValue
        }
    }

    //MARK: - delete

    var deleteTasksCallsCount = 0
    var deleteTasksCalled: Bool {
        return deleteTasksCallsCount > 0
    }
    var deleteTasksReceivedTasks: [ErxTask]?
    var deleteTasksReceivedInvocations: [[ErxTask]] = []
    var deleteTasksReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteTasksClosure: (([ErxTask]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksCallsCount += 1
        deleteTasksReceivedTasks = tasks
        deleteTasksReceivedInvocations.append(tasks)
        if let deleteTasksClosure = deleteTasksClosure {
            return deleteTasksClosure(tasks)
        } else {
            return deleteTasksReturnValue
        }
    }

    //MARK: - listAllTasksWithoutProfile

    var listAllTasksWithoutProfileCallsCount = 0
    var listAllTasksWithoutProfileCalled: Bool {
        return listAllTasksWithoutProfileCallsCount > 0
    }
    var listAllTasksWithoutProfileReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksWithoutProfileClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksWithoutProfileCallsCount += 1
        if let listAllTasksWithoutProfileClosure = listAllTasksWithoutProfileClosure {
            return listAllTasksWithoutProfileClosure()
        } else {
            return listAllTasksWithoutProfileReturnValue
        }
    }

    //MARK: - listAllCommunications

    var listAllCommunicationsForCallsCount = 0
    var listAllCommunicationsForCalled: Bool {
        return listAllCommunicationsForCallsCount > 0
    }
    var listAllCommunicationsForReceivedProfile: ErxTask.Communication.Profile?
    var listAllCommunicationsForReceivedInvocations: [ErxTask.Communication.Profile] = []
    var listAllCommunicationsForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var listAllCommunicationsForClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        listAllCommunicationsForCallsCount += 1
        listAllCommunicationsForReceivedProfile = profile
        listAllCommunicationsForReceivedInvocations.append(profile)
        if let listAllCommunicationsForClosure = listAllCommunicationsForClosure {
            return listAllCommunicationsForClosure(profile)
        } else {
            return listAllCommunicationsForReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForCommunications

    var fetchLatestTimestampForCommunicationsCallsCount = 0
    var fetchLatestTimestampForCommunicationsCalled: Bool {
        return fetchLatestTimestampForCommunicationsCallsCount > 0
    }
    var fetchLatestTimestampForCommunicationsReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForCommunicationsClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsCallsCount += 1
        if let fetchLatestTimestampForCommunicationsClosure = fetchLatestTimestampForCommunicationsClosure {
            return fetchLatestTimestampForCommunicationsClosure()
        } else {
            return fetchLatestTimestampForCommunicationsReturnValue
        }
    }

    //MARK: - save

    var saveCommunicationsCallsCount = 0
    var saveCommunicationsCalled: Bool {
        return saveCommunicationsCallsCount > 0
    }
    var saveCommunicationsReceivedCommunications: [ErxTask.Communication]?
    var saveCommunicationsReceivedInvocations: [[ErxTask.Communication]] = []
    var saveCommunicationsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveCommunicationsClosure: (([ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsCallsCount += 1
        saveCommunicationsReceivedCommunications = communications
        saveCommunicationsReceivedInvocations.append(communications)
        if let saveCommunicationsClosure = saveCommunicationsClosure {
            return saveCommunicationsClosure(communications)
        } else {
            return saveCommunicationsReturnValue
        }
    }

    //MARK: - allUnreadCommunications

    var allUnreadCommunicationsForCallsCount = 0
    var allUnreadCommunicationsForCalled: Bool {
        return allUnreadCommunicationsForCallsCount > 0
    }
    var allUnreadCommunicationsForReceivedProfile: ErxTask.Communication.Profile?
    var allUnreadCommunicationsForReceivedInvocations: [ErxTask.Communication.Profile] = []
    var allUnreadCommunicationsForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var allUnreadCommunicationsForClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func allUnreadCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsForCallsCount += 1
        allUnreadCommunicationsForReceivedProfile = profile
        allUnreadCommunicationsForReceivedInvocations.append(profile)
        if let allUnreadCommunicationsForClosure = allUnreadCommunicationsForClosure {
            return allUnreadCommunicationsForClosure(profile)
        } else {
            return allUnreadCommunicationsForReturnValue
        }
    }

    //MARK: - fetchAuditEvent

    var fetchAuditEventByCallsCount = 0
    var fetchAuditEventByCalled: Bool {
        return fetchAuditEventByCallsCount > 0
    }
    var fetchAuditEventByReceivedId: ErxAuditEvent.ID?
    var fetchAuditEventByReceivedInvocations: [ErxAuditEvent.ID] = []
    var fetchAuditEventByReturnValue: AnyPublisher<ErxAuditEvent?, LocalStoreError>!
    var fetchAuditEventByClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, LocalStoreError>)?

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, LocalStoreError> {
        fetchAuditEventByCallsCount += 1
        fetchAuditEventByReceivedId = id
        fetchAuditEventByReceivedInvocations.append(id)
        if let fetchAuditEventByClosure = fetchAuditEventByClosure {
            return fetchAuditEventByClosure(id)
        } else {
            return fetchAuditEventByReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    var listAllAuditEventsForTaskIDForCallsCount = 0
    var listAllAuditEventsForTaskIDForCalled: Bool {
        return listAllAuditEventsForTaskIDForCallsCount > 0
    }
    var listAllAuditEventsForTaskIDForReceivedArguments: (taskID: ErxTask.ID, locale: String?)?
    var listAllAuditEventsForTaskIDForReceivedInvocations: [(taskID: ErxTask.ID, locale: String?)] = []
    var listAllAuditEventsForTaskIDForReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    var listAllAuditEventsForTaskIDForClosure: ((ErxTask.ID, String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    func listAllAuditEvents(forTaskID taskID: ErxTask.ID, for locale: String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        listAllAuditEventsForTaskIDForCallsCount += 1
        listAllAuditEventsForTaskIDForReceivedArguments = (taskID: taskID, locale: locale)
        listAllAuditEventsForTaskIDForReceivedInvocations.append((taskID: taskID, locale: locale))
        if let listAllAuditEventsForTaskIDForClosure = listAllAuditEventsForTaskIDForClosure {
            return listAllAuditEventsForTaskIDForClosure(taskID, locale)
        } else {
            return listAllAuditEventsForTaskIDForReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForAuditEvents

    var fetchLatestTimestampForAuditEventsCallsCount = 0
    var fetchLatestTimestampForAuditEventsCalled: Bool {
        return fetchLatestTimestampForAuditEventsCallsCount > 0
    }
    var fetchLatestTimestampForAuditEventsReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForAuditEventsClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForAuditEvents() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForAuditEventsCallsCount += 1
        if let fetchLatestTimestampForAuditEventsClosure = fetchLatestTimestampForAuditEventsClosure {
            return fetchLatestTimestampForAuditEventsClosure()
        } else {
            return fetchLatestTimestampForAuditEventsReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    var listAllAuditEventsForCallsCount = 0
    var listAllAuditEventsForCalled: Bool {
        return listAllAuditEventsForCallsCount > 0
    }
    var listAllAuditEventsForReceivedLocale: String?
    var listAllAuditEventsForReceivedInvocations: [String?] = []
    var listAllAuditEventsForReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    var listAllAuditEventsForClosure: ((String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    func listAllAuditEvents(for locale: String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        listAllAuditEventsForCallsCount += 1
        listAllAuditEventsForReceivedLocale = locale
        listAllAuditEventsForReceivedInvocations.append(locale)
        if let listAllAuditEventsForClosure = listAllAuditEventsForClosure {
            return listAllAuditEventsForClosure(locale)
        } else {
            return listAllAuditEventsForReturnValue
        }
    }

    //MARK: - save

    var saveAuditEventsCallsCount = 0
    var saveAuditEventsCalled: Bool {
        return saveAuditEventsCallsCount > 0
    }
    var saveAuditEventsReceivedAuditEvents: [ErxAuditEvent]?
    var saveAuditEventsReceivedInvocations: [[ErxAuditEvent]] = []
    var saveAuditEventsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveAuditEventsClosure: (([ErxAuditEvent]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, LocalStoreError> {
        saveAuditEventsCallsCount += 1
        saveAuditEventsReceivedAuditEvents = auditEvents
        saveAuditEventsReceivedInvocations.append(auditEvents)
        if let saveAuditEventsClosure = saveAuditEventsClosure {
            return saveAuditEventsClosure(auditEvents)
        } else {
            return saveAuditEventsReturnValue
        }
    }

    //MARK: - listAllMedicationDispenses

    var listAllMedicationDispensesCallsCount = 0
    var listAllMedicationDispensesCalled: Bool {
        return listAllMedicationDispensesCallsCount > 0
    }
    var listAllMedicationDispensesReturnValue: AnyPublisher<[ErxTask.MedicationDispense], LocalStoreError>!
    var listAllMedicationDispensesClosure: (() -> AnyPublisher<[ErxTask.MedicationDispense], LocalStoreError>)?

    func listAllMedicationDispenses() -> AnyPublisher<[ErxTask.MedicationDispense], LocalStoreError> {
        listAllMedicationDispensesCallsCount += 1
        if let listAllMedicationDispensesClosure = listAllMedicationDispensesClosure {
            return listAllMedicationDispensesClosure()
        } else {
            return listAllMedicationDispensesReturnValue
        }
    }

    //MARK: - save

    var saveMedicationDispensesCallsCount = 0
    var saveMedicationDispensesCalled: Bool {
        return saveMedicationDispensesCallsCount > 0
    }
    var saveMedicationDispensesReceivedMedicationDispenses: [ErxTask.MedicationDispense]?
    var saveMedicationDispensesReceivedInvocations: [[ErxTask.MedicationDispense]] = []
    var saveMedicationDispensesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveMedicationDispensesClosure: (([ErxTask.MedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(medicationDispenses: [ErxTask.MedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        saveMedicationDispensesCallsCount += 1
        saveMedicationDispensesReceivedMedicationDispenses = medicationDispenses
        saveMedicationDispensesReceivedInvocations.append(medicationDispenses)
        if let saveMedicationDispensesClosure = saveMedicationDispensesClosure {
            return saveMedicationDispensesClosure(medicationDispenses)
        } else {
            return saveMedicationDispensesReturnValue
        }
    }

}
final class MockErxRemoteDataStore: ErxRemoteDataStore {


    //MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        return fetchTaskByAccessCodeCallsCount > 0
    }
    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        if let fetchTaskByAccessCodeClosure = fetchTaskByAccessCodeClosure {
            return fetchTaskByAccessCodeClosure(id, accessCode)
        } else {
            return fetchTaskByAccessCodeReturnValue
        }
    }

    //MARK: - listAllTasks

    var listAllTasksAfterCallsCount = 0
    var listAllTasksAfterCalled: Bool {
        return listAllTasksAfterCallsCount > 0
    }
    var listAllTasksAfterReceivedReferenceDate: String?
    var listAllTasksAfterReceivedInvocations: [String?] = []
    var listAllTasksAfterReturnValue: AnyPublisher<[ErxTask], RemoteStoreError>!
    var listAllTasksAfterClosure: ((String?) -> AnyPublisher<[ErxTask], RemoteStoreError>)?

    func listAllTasks(after referenceDate: String?) -> AnyPublisher<[ErxTask], RemoteStoreError> {
        listAllTasksAfterCallsCount += 1
        listAllTasksAfterReceivedReferenceDate = referenceDate
        listAllTasksAfterReceivedInvocations.append(referenceDate)
        if let listAllTasksAfterClosure = listAllTasksAfterClosure {
            return listAllTasksAfterClosure(referenceDate)
        } else {
            return listAllTasksAfterReturnValue
        }
    }

    //MARK: - delete

    var deleteTasksCallsCount = 0
    var deleteTasksCalled: Bool {
        return deleteTasksCallsCount > 0
    }
    var deleteTasksReceivedTasks: [ErxTask]?
    var deleteTasksReceivedInvocations: [[ErxTask]] = []
    var deleteTasksReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var deleteTasksClosure: (([ErxTask]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksCallsCount += 1
        deleteTasksReceivedTasks = tasks
        deleteTasksReceivedInvocations.append(tasks)
        if let deleteTasksClosure = deleteTasksClosure {
            return deleteTasksClosure(tasks)
        } else {
            return deleteTasksReturnValue
        }
    }

    //MARK: - redeem

    var redeemOrderCallsCount = 0
    var redeemOrderCalled: Bool {
        return redeemOrderCallsCount > 0
    }
    var redeemOrderReceivedOrder: ErxTaskOrder?
    var redeemOrderReceivedInvocations: [ErxTaskOrder] = []
    var redeemOrderReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    var redeemOrderClosure: ((ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderCallsCount += 1
        redeemOrderReceivedOrder = order
        redeemOrderReceivedInvocations.append(order)
        if let redeemOrderClosure = redeemOrderClosure {
            return redeemOrderClosure(order)
        } else {
            return redeemOrderReturnValue
        }
    }

    //MARK: - listAllCommunications

    var listAllCommunicationsAfterForCallsCount = 0
    var listAllCommunicationsAfterForCalled: Bool {
        return listAllCommunicationsAfterForCallsCount > 0
    }
    var listAllCommunicationsAfterForReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile)?
    var listAllCommunicationsAfterForReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile)] = []
    var listAllCommunicationsAfterForReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    var listAllCommunicationsAfterForClosure: ((String?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterForCallsCount += 1
        listAllCommunicationsAfterForReceivedArguments = (referenceDate: referenceDate, profile: profile)
        listAllCommunicationsAfterForReceivedInvocations.append((referenceDate: referenceDate, profile: profile))
        if let listAllCommunicationsAfterForClosure = listAllCommunicationsAfterForClosure {
            return listAllCommunicationsAfterForClosure(referenceDate, profile)
        } else {
            return listAllCommunicationsAfterForReturnValue
        }
    }

    //MARK: - fetchAuditEvent

    var fetchAuditEventByCallsCount = 0
    var fetchAuditEventByCalled: Bool {
        return fetchAuditEventByCallsCount > 0
    }
    var fetchAuditEventByReceivedId: ErxAuditEvent.ID?
    var fetchAuditEventByReceivedInvocations: [ErxAuditEvent.ID] = []
    var fetchAuditEventByReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    var fetchAuditEventByClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByCallsCount += 1
        fetchAuditEventByReceivedId = id
        fetchAuditEventByReceivedInvocations.append(id)
        if let fetchAuditEventByClosure = fetchAuditEventByClosure {
            return fetchAuditEventByClosure(id)
        } else {
            return fetchAuditEventByReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    var listAllAuditEventsAfterForCallsCount = 0
    var listAllAuditEventsAfterForCalled: Bool {
        return listAllAuditEventsAfterForCallsCount > 0
    }
    var listAllAuditEventsAfterForReceivedArguments: (referenceDate: String?, locale: String?)?
    var listAllAuditEventsAfterForReceivedInvocations: [(referenceDate: String?, locale: String?)] = []
    var listAllAuditEventsAfterForReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAllAuditEventsAfterForClosure: ((String?, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAllAuditEvents(after referenceDate: String?, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterForCallsCount += 1
        listAllAuditEventsAfterForReceivedArguments = (referenceDate: referenceDate, locale: locale)
        listAllAuditEventsAfterForReceivedInvocations.append((referenceDate: referenceDate, locale: locale))
        if let listAllAuditEventsAfterForClosure = listAllAuditEventsAfterForClosure {
            return listAllAuditEventsAfterForClosure(referenceDate, locale)
        } else {
            return listAllAuditEventsAfterForReturnValue
        }
    }

    //MARK: - listAuditEventsNextPage

    var listAuditEventsNextPageOfCallsCount = 0
    var listAuditEventsNextPageOfCalled: Bool {
        return listAuditEventsNextPageOfCallsCount > 0
    }
    var listAuditEventsNextPageOfReceivedPreviousPage: PagedContent<[ErxAuditEvent]>?
    var listAuditEventsNextPageOfReceivedInvocations: [PagedContent<[ErxAuditEvent]>] = []
    var listAuditEventsNextPageOfReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAuditEventsNextPageOfClosure: ((PagedContent<[ErxAuditEvent]>) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAuditEventsNextPage(of previousPage: PagedContent<[ErxAuditEvent]>) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageOfCallsCount += 1
        listAuditEventsNextPageOfReceivedPreviousPage = previousPage
        listAuditEventsNextPageOfReceivedInvocations.append(previousPage)
        if let listAuditEventsNextPageOfClosure = listAuditEventsNextPageOfClosure {
            return listAuditEventsNextPageOfClosure(previousPage)
        } else {
            return listAuditEventsNextPageOfReturnValue
        }
    }

    //MARK: - listMedicationDispenses

    var listMedicationDispensesForCallsCount = 0
    var listMedicationDispensesForCalled: Bool {
        return listMedicationDispensesForCallsCount > 0
    }
    var listMedicationDispensesForReceivedId: ErxTask.ID?
    var listMedicationDispensesForReceivedInvocations: [ErxTask.ID] = []
    var listMedicationDispensesForReturnValue: AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError>!
    var listMedicationDispensesForClosure: ((ErxTask.ID) -> AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError>)?

    func listMedicationDispenses(for id: ErxTask.ID) -> AnyPublisher<[ErxTask.MedicationDispense], RemoteStoreError> {
        listMedicationDispensesForCallsCount += 1
        listMedicationDispensesForReceivedId = id
        listMedicationDispensesForReceivedInvocations.append(id)
        if let listMedicationDispensesForClosure = listMedicationDispensesForClosure {
            return listMedicationDispensesForClosure(id)
        } else {
            return listMedicationDispensesForReturnValue
        }
    }

}
