// Generated using Sourcery 2.0.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import Foundation

@testable import eRpKit

/// AUTO GENERATED – DO NOT EDIT
///
/// Use sourcery to update this file.
/// NOTE: If imports are missing/superfluous then add/remove them in the .sourcery.yml in the project's root.
















// MARK: - MockErxLocalDataStore -

final class MockErxLocalDataStore: ErxLocalDataStore {
    
   // MARK: - fetchTask

    var fetchTaskByAccessCodeCallsCount = 0
    var fetchTaskByAccessCodeCalled: Bool {
        fetchTaskByAccessCodeCallsCount > 0
    }
    var fetchTaskByAccessCodeReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    var fetchTaskByAccessCodeReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    var fetchTaskByAccessCodeReturnValue: AnyPublisher<ErxTask?, LocalStoreError>!
    var fetchTaskByAccessCodeClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, LocalStoreError>)?

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        fetchTaskByAccessCodeCallsCount += 1
        fetchTaskByAccessCodeReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByAccessCodeReceivedInvocations.append((id: id, accessCode: accessCode))
        return fetchTaskByAccessCodeClosure.map({ $0(id, accessCode) }) ?? fetchTaskByAccessCodeReturnValue
    }
    
   // MARK: - listAllTasks

    var listAllTasksCallsCount = 0
    var listAllTasksCalled: Bool {
        listAllTasksCallsCount > 0
    }
    var listAllTasksReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasks() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksCallsCount += 1
        return listAllTasksClosure.map({ $0() }) ?? listAllTasksReturnValue
    }
    
   // MARK: - fetchLatestLastModifiedForErxTasks

    var fetchLatestLastModifiedForErxTasksCallsCount = 0
    var fetchLatestLastModifiedForErxTasksCalled: Bool {
        fetchLatestLastModifiedForErxTasksCallsCount > 0
    }
    var fetchLatestLastModifiedForErxTasksReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestLastModifiedForErxTasksClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksCallsCount += 1
        return fetchLatestLastModifiedForErxTasksClosure.map({ $0() }) ?? fetchLatestLastModifiedForErxTasksReturnValue
    }
    
   // MARK: - save

    var saveTasksUpdateProfileLastAuthenticatedCallsCount = 0
    var saveTasksUpdateProfileLastAuthenticatedCalled: Bool {
        saveTasksUpdateProfileLastAuthenticatedCallsCount > 0
    }
    var saveTasksUpdateProfileLastAuthenticatedReceivedArguments: (tasks: [ErxTask], updateProfileLastAuthenticated: Bool)?
    var saveTasksUpdateProfileLastAuthenticatedReceivedInvocations: [(tasks: [ErxTask], updateProfileLastAuthenticated: Bool)] = []
    var saveTasksUpdateProfileLastAuthenticatedReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveTasksUpdateProfileLastAuthenticatedClosure: (([ErxTask], Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(tasks: [ErxTask], updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksUpdateProfileLastAuthenticatedCallsCount += 1
        saveTasksUpdateProfileLastAuthenticatedReceivedArguments = (tasks: tasks, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksUpdateProfileLastAuthenticatedReceivedInvocations.append((tasks: tasks, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        return saveTasksUpdateProfileLastAuthenticatedClosure.map({ $0(tasks, updateProfileLastAuthenticated) }) ?? saveTasksUpdateProfileLastAuthenticatedReturnValue
    }
    
   // MARK: - delete

    var deleteTasksCallsCount = 0
    var deleteTasksCalled: Bool {
        deleteTasksCallsCount > 0
    }
    var deleteTasksReceivedTasks: [ErxTask]?
    var deleteTasksReceivedInvocations: [[ErxTask]] = []
    var deleteTasksReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteTasksClosure: (([ErxTask]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksCallsCount += 1
        deleteTasksReceivedTasks = tasks
        deleteTasksReceivedInvocations.append(tasks)
        return deleteTasksClosure.map({ $0(tasks) }) ?? deleteTasksReturnValue
    }
    
   // MARK: - listAllTasksWithoutProfile

    var listAllTasksWithoutProfileCallsCount = 0
    var listAllTasksWithoutProfileCalled: Bool {
        listAllTasksWithoutProfileCallsCount > 0
    }
    var listAllTasksWithoutProfileReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksWithoutProfileClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksWithoutProfileCallsCount += 1
        return listAllTasksWithoutProfileClosure.map({ $0() }) ?? listAllTasksWithoutProfileReturnValue
    }
    
   // MARK: - listAllCommunications

    var listAllCommunicationsForCallsCount = 0
    var listAllCommunicationsForCalled: Bool {
        listAllCommunicationsForCallsCount > 0
    }
    var listAllCommunicationsForReceivedProfile: ErxTask.Communication.Profile?
    var listAllCommunicationsForReceivedInvocations: [ErxTask.Communication.Profile] = []
    var listAllCommunicationsForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var listAllCommunicationsForClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        listAllCommunicationsForCallsCount += 1
        listAllCommunicationsForReceivedProfile = profile
        listAllCommunicationsForReceivedInvocations.append(profile)
        return listAllCommunicationsForClosure.map({ $0(profile) }) ?? listAllCommunicationsForReturnValue
    }
    
   // MARK: - fetchLatestTimestampForCommunications

    var fetchLatestTimestampForCommunicationsCallsCount = 0
    var fetchLatestTimestampForCommunicationsCalled: Bool {
        fetchLatestTimestampForCommunicationsCallsCount > 0
    }
    var fetchLatestTimestampForCommunicationsReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForCommunicationsClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsCallsCount += 1
        return fetchLatestTimestampForCommunicationsClosure.map({ $0() }) ?? fetchLatestTimestampForCommunicationsReturnValue
    }
    
   // MARK: - save

    var saveCommunicationsCallsCount = 0
    var saveCommunicationsCalled: Bool {
        saveCommunicationsCallsCount > 0
    }
    var saveCommunicationsReceivedCommunications: [ErxTask.Communication]?
    var saveCommunicationsReceivedInvocations: [[ErxTask.Communication]] = []
    var saveCommunicationsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveCommunicationsClosure: (([ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsCallsCount += 1
        saveCommunicationsReceivedCommunications = communications
        saveCommunicationsReceivedInvocations.append(communications)
        return saveCommunicationsClosure.map({ $0(communications) }) ?? saveCommunicationsReturnValue
    }
    
   // MARK: - allUnreadCommunications

    var allUnreadCommunicationsForCallsCount = 0
    var allUnreadCommunicationsForCalled: Bool {
        allUnreadCommunicationsForCallsCount > 0
    }
    var allUnreadCommunicationsForReceivedProfile: ErxTask.Communication.Profile?
    var allUnreadCommunicationsForReceivedInvocations: [ErxTask.Communication.Profile] = []
    var allUnreadCommunicationsForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var allUnreadCommunicationsForClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func allUnreadCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsForCallsCount += 1
        allUnreadCommunicationsForReceivedProfile = profile
        allUnreadCommunicationsForReceivedInvocations.append(profile)
        return allUnreadCommunicationsForClosure.map({ $0(profile) }) ?? allUnreadCommunicationsForReturnValue
    }
    
   // MARK: - fetchAuditEvent

    var fetchAuditEventByCallsCount = 0
    var fetchAuditEventByCalled: Bool {
        fetchAuditEventByCallsCount > 0
    }
    var fetchAuditEventByReceivedId: ErxAuditEvent.ID?
    var fetchAuditEventByReceivedInvocations: [ErxAuditEvent.ID] = []
    var fetchAuditEventByReturnValue: AnyPublisher<ErxAuditEvent?, LocalStoreError>!
    var fetchAuditEventByClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, LocalStoreError>)?

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, LocalStoreError> {
        fetchAuditEventByCallsCount += 1
        fetchAuditEventByReceivedId = id
        fetchAuditEventByReceivedInvocations.append(id)
        return fetchAuditEventByClosure.map({ $0(id) }) ?? fetchAuditEventByReturnValue
    }
    
   // MARK: - listAllAuditEvents

    var listAllAuditEventsForTaskIDForCallsCount = 0
    var listAllAuditEventsForTaskIDForCalled: Bool {
        listAllAuditEventsForTaskIDForCallsCount > 0
    }
    var listAllAuditEventsForTaskIDForReceivedArguments: (taskID: ErxTask.ID, locale: String?)?
    var listAllAuditEventsForTaskIDForReceivedInvocations: [(taskID: ErxTask.ID, locale: String?)] = []
    var listAllAuditEventsForTaskIDForReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    var listAllAuditEventsForTaskIDForClosure: ((ErxTask.ID, String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    func listAllAuditEvents(forTaskID taskID: ErxTask.ID, for locale: String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        listAllAuditEventsForTaskIDForCallsCount += 1
        listAllAuditEventsForTaskIDForReceivedArguments = (taskID: taskID, locale: locale)
        listAllAuditEventsForTaskIDForReceivedInvocations.append((taskID: taskID, locale: locale))
        return listAllAuditEventsForTaskIDForClosure.map({ $0(taskID, locale) }) ?? listAllAuditEventsForTaskIDForReturnValue
    }
    
   // MARK: - fetchLatestTimestampForAuditEvents

    var fetchLatestTimestampForAuditEventsCallsCount = 0
    var fetchLatestTimestampForAuditEventsCalled: Bool {
        fetchLatestTimestampForAuditEventsCallsCount > 0
    }
    var fetchLatestTimestampForAuditEventsReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForAuditEventsClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForAuditEvents() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForAuditEventsCallsCount += 1
        return fetchLatestTimestampForAuditEventsClosure.map({ $0() }) ?? fetchLatestTimestampForAuditEventsReturnValue
    }
    
   // MARK: - listAllAuditEvents

    var listAllAuditEventsForCallsCount = 0
    var listAllAuditEventsForCalled: Bool {
        listAllAuditEventsForCallsCount > 0
    }
    var listAllAuditEventsForReceivedLocale: String?
    var listAllAuditEventsForReceivedInvocations: [String?] = []
    var listAllAuditEventsForReturnValue: AnyPublisher<[ErxAuditEvent], LocalStoreError>!
    var listAllAuditEventsForClosure: ((String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError>)?

    func listAllAuditEvents(for locale: String?) -> AnyPublisher<[ErxAuditEvent], LocalStoreError> {
        listAllAuditEventsForCallsCount += 1
        listAllAuditEventsForReceivedLocale = locale
        listAllAuditEventsForReceivedInvocations.append(locale)
        return listAllAuditEventsForClosure.map({ $0(locale) }) ?? listAllAuditEventsForReturnValue
    }
    
   // MARK: - save

    var saveAuditEventsCallsCount = 0
    var saveAuditEventsCalled: Bool {
        saveAuditEventsCallsCount > 0
    }
    var saveAuditEventsReceivedAuditEvents: [ErxAuditEvent]?
    var saveAuditEventsReceivedInvocations: [[ErxAuditEvent]] = []
    var saveAuditEventsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveAuditEventsClosure: (([ErxAuditEvent]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(auditEvents: [ErxAuditEvent]) -> AnyPublisher<Bool, LocalStoreError> {
        saveAuditEventsCallsCount += 1
        saveAuditEventsReceivedAuditEvents = auditEvents
        saveAuditEventsReceivedInvocations.append(auditEvents)
        return saveAuditEventsClosure.map({ $0(auditEvents) }) ?? saveAuditEventsReturnValue
    }
    
   // MARK: - listAllMedicationDispenses

    var listAllMedicationDispensesCallsCount = 0
    var listAllMedicationDispensesCalled: Bool {
        listAllMedicationDispensesCallsCount > 0
    }
    var listAllMedicationDispensesReturnValue: AnyPublisher<[ErxMedicationDispense], LocalStoreError>!
    var listAllMedicationDispensesClosure: (() -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>)?

    func listAllMedicationDispenses() -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        listAllMedicationDispensesCallsCount += 1
        return listAllMedicationDispensesClosure.map({ $0() }) ?? listAllMedicationDispensesReturnValue
    }
    
   // MARK: - save

    var saveMedicationDispensesCallsCount = 0
    var saveMedicationDispensesCalled: Bool {
        saveMedicationDispensesCallsCount > 0
    }
    var saveMedicationDispensesReceivedMedicationDispenses: [ErxMedicationDispense]?
    var saveMedicationDispensesReceivedInvocations: [[ErxMedicationDispense]] = []
    var saveMedicationDispensesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveMedicationDispensesClosure: (([ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        saveMedicationDispensesCallsCount += 1
        saveMedicationDispensesReceivedMedicationDispenses = medicationDispenses
        saveMedicationDispensesReceivedInvocations.append(medicationDispenses)
        return saveMedicationDispensesClosure.map({ $0(medicationDispenses) }) ?? saveMedicationDispensesReturnValue
    }
    
   // MARK: - fetchChargeItem

    var fetchChargeItemByFullDetailCallsCount = 0
    var fetchChargeItemByFullDetailCalled: Bool {
        fetchChargeItemByFullDetailCallsCount > 0
    }
    var fetchChargeItemByFullDetailReceivedArguments: (chargeItemID: ErxChargeItem.ID, fullDetail: Bool)?
    var fetchChargeItemByFullDetailReceivedInvocations: [(chargeItemID: ErxChargeItem.ID, fullDetail: Bool)] = []
    var fetchChargeItemByFullDetailReturnValue: AnyPublisher<ErxChargeItem?, LocalStoreError>!
    var fetchChargeItemByFullDetailClosure: ((ErxChargeItem.ID, Bool) -> AnyPublisher<ErxChargeItem?, LocalStoreError>)?

    func fetchChargeItem(by chargeItemID: ErxChargeItem.ID, fullDetail: Bool) -> AnyPublisher<ErxChargeItem?, LocalStoreError> {
        fetchChargeItemByFullDetailCallsCount += 1
        fetchChargeItemByFullDetailReceivedArguments = (chargeItemID: chargeItemID, fullDetail: fullDetail)
        fetchChargeItemByFullDetailReceivedInvocations.append((chargeItemID: chargeItemID, fullDetail: fullDetail))
        return fetchChargeItemByFullDetailClosure.map({ $0(chargeItemID, fullDetail) }) ?? fetchChargeItemByFullDetailReturnValue
    }
    
   // MARK: - fetchLatestTimestampForChargeItems

    var fetchLatestTimestampForChargeItemsCallsCount = 0
    var fetchLatestTimestampForChargeItemsCalled: Bool {
        fetchLatestTimestampForChargeItemsCallsCount > 0
    }
    var fetchLatestTimestampForChargeItemsReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForChargeItemsClosure: (() -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForChargeItems() -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForChargeItemsCallsCount += 1
        return fetchLatestTimestampForChargeItemsClosure.map({ $0() }) ?? fetchLatestTimestampForChargeItemsReturnValue
    }
    
   // MARK: - listAllChargeItems

    var listAllChargeItemsCallsCount = 0
    var listAllChargeItemsCalled: Bool {
        listAllChargeItemsCallsCount > 0
    }
    var listAllChargeItemsReturnValue: AnyPublisher<[ErxChargeItem], LocalStoreError>!
    var listAllChargeItemsClosure: (() -> AnyPublisher<[ErxChargeItem], LocalStoreError>)?

    func listAllChargeItems() -> AnyPublisher<[ErxChargeItem], LocalStoreError> {
        listAllChargeItemsCallsCount += 1
        return listAllChargeItemsClosure.map({ $0() }) ?? listAllChargeItemsReturnValue
    }
    
   // MARK: - save

    var saveChargeItemsCallsCount = 0
    var saveChargeItemsCalled: Bool {
        saveChargeItemsCallsCount > 0
    }
    var saveChargeItemsReceivedChargeItems: [ErxChargeItem]?
    var saveChargeItemsReceivedInvocations: [[ErxChargeItem]] = []
    var saveChargeItemsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveChargeItemsClosure: (([ErxChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsCallsCount += 1
        saveChargeItemsReceivedChargeItems = chargeItems
        saveChargeItemsReceivedInvocations.append(chargeItems)
        return saveChargeItemsClosure.map({ $0(chargeItems) }) ?? saveChargeItemsReturnValue
    }
}


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
        return fetchTaskByAccessCodeClosure.map({ $0(id, accessCode) }) ?? fetchTaskByAccessCodeReturnValue
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
        return listAllTasksAfterClosure.map({ $0(referenceDate) }) ?? listAllTasksAfterReturnValue
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
        return deleteTasksClosure.map({ $0(tasks) }) ?? deleteTasksReturnValue
    }
    
   // MARK: - redeem

    var redeemOrderCallsCount = 0
    var redeemOrderCalled: Bool {
        redeemOrderCallsCount > 0
    }
    var redeemOrderReceivedOrder: ErxTaskOrder?
    var redeemOrderReceivedInvocations: [ErxTaskOrder] = []
    var redeemOrderReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    var redeemOrderClosure: ((ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderCallsCount += 1
        redeemOrderReceivedOrder = order
        redeemOrderReceivedInvocations.append(order)
        return redeemOrderClosure.map({ $0(order) }) ?? redeemOrderReturnValue
    }
    
   // MARK: - listAllCommunications

    var listAllCommunicationsAfterForCallsCount = 0
    var listAllCommunicationsAfterForCalled: Bool {
        listAllCommunicationsAfterForCallsCount > 0
    }
    var listAllCommunicationsAfterForReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile)?
    var listAllCommunicationsAfterForReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile)] = []
    var listAllCommunicationsAfterForReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    var listAllCommunicationsAfterForClosure: ((String?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterForCallsCount += 1
        listAllCommunicationsAfterForReceivedArguments = (referenceDate: referenceDate, profile: profile)
        listAllCommunicationsAfterForReceivedInvocations.append((referenceDate: referenceDate, profile: profile))
        return listAllCommunicationsAfterForClosure.map({ $0(referenceDate, profile) }) ?? listAllCommunicationsAfterForReturnValue
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
        return fetchAuditEventByClosure.map({ $0(id) }) ?? fetchAuditEventByReturnValue
    }
    
   // MARK: - listAllAuditEvents

    var listAllAuditEventsAfterForCallsCount = 0
    var listAllAuditEventsAfterForCalled: Bool {
        listAllAuditEventsAfterForCallsCount > 0
    }
    var listAllAuditEventsAfterForReceivedArguments: (referenceDate: String?, locale: String?)?
    var listAllAuditEventsAfterForReceivedInvocations: [(referenceDate: String?, locale: String?)] = []
    var listAllAuditEventsAfterForReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAllAuditEventsAfterForClosure: ((String?, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAllAuditEvents(after referenceDate: String?, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterForCallsCount += 1
        listAllAuditEventsAfterForReceivedArguments = (referenceDate: referenceDate, locale: locale)
        listAllAuditEventsAfterForReceivedInvocations.append((referenceDate: referenceDate, locale: locale))
        return listAllAuditEventsAfterForClosure.map({ $0(referenceDate, locale) }) ?? listAllAuditEventsAfterForReturnValue
    }
    
   // MARK: - listAuditEventsNextPage

    var listAuditEventsNextPageOfForCallsCount = 0
    var listAuditEventsNextPageOfForCalled: Bool {
        listAuditEventsNextPageOfForCallsCount > 0
    }
    var listAuditEventsNextPageOfForReceivedArguments: (previousPage: PagedContent<[ErxAuditEvent]>, locale: String?)?
    var listAuditEventsNextPageOfForReceivedInvocations: [(previousPage: PagedContent<[ErxAuditEvent]>, locale: String?)] = []
    var listAuditEventsNextPageOfForReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAuditEventsNextPageOfForClosure: ((PagedContent<[ErxAuditEvent]>, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAuditEventsNextPage(of previousPage: PagedContent<[ErxAuditEvent]>, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageOfForCallsCount += 1
        listAuditEventsNextPageOfForReceivedArguments = (previousPage: previousPage, locale: locale)
        listAuditEventsNextPageOfForReceivedInvocations.append((previousPage: previousPage, locale: locale))
        return listAuditEventsNextPageOfForClosure.map({ $0(previousPage, locale) }) ?? listAuditEventsNextPageOfForReturnValue
    }
    
   // MARK: - listMedicationDispenses

    var listMedicationDispensesForCallsCount = 0
    var listMedicationDispensesForCalled: Bool {
        listMedicationDispensesForCallsCount > 0
    }
    var listMedicationDispensesForReceivedId: ErxTask.ID?
    var listMedicationDispensesForReceivedInvocations: [ErxTask.ID] = []
    var listMedicationDispensesForReturnValue: AnyPublisher<[ErxMedicationDispense], RemoteStoreError>!
    var listMedicationDispensesForClosure: ((ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>)?

    func listMedicationDispenses(for id: ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        listMedicationDispensesForCallsCount += 1
        listMedicationDispensesForReceivedId = id
        listMedicationDispensesForReceivedInvocations.append(id)
        return listMedicationDispensesForClosure.map({ $0(id) }) ?? listMedicationDispensesForReturnValue
    }
    
   // MARK: - fetchChargeItem

    var fetchChargeItemByCallsCount = 0
    var fetchChargeItemByCalled: Bool {
        fetchChargeItemByCallsCount > 0
    }
    var fetchChargeItemByReceivedId: ErxChargeItem.ID?
    var fetchChargeItemByReceivedInvocations: [ErxChargeItem.ID] = []
    var fetchChargeItemByReturnValue: AnyPublisher<ErxChargeItem?, RemoteStoreError>!
    var fetchChargeItemByClosure: ((ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>)?

    func fetchChargeItem(by id: ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fetchChargeItemByCallsCount += 1
        fetchChargeItemByReceivedId = id
        fetchChargeItemByReceivedInvocations.append(id)
        return fetchChargeItemByClosure.map({ $0(id) }) ?? fetchChargeItemByReturnValue
    }
    
   // MARK: - listAllChargeItems

    var listAllChargeItemsAfterCallsCount = 0
    var listAllChargeItemsAfterCalled: Bool {
        listAllChargeItemsAfterCallsCount > 0
    }
    var listAllChargeItemsAfterReceivedReferenceDate: String?
    var listAllChargeItemsAfterReceivedInvocations: [String?] = []
    var listAllChargeItemsAfterReturnValue: AnyPublisher<[ErxChargeItem], RemoteStoreError>!
    var listAllChargeItemsAfterClosure: ((String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>)?

    func listAllChargeItems(after referenceDate: String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        listAllChargeItemsAfterCallsCount += 1
        listAllChargeItemsAfterReceivedReferenceDate = referenceDate
        listAllChargeItemsAfterReceivedInvocations.append(referenceDate)
        return listAllChargeItemsAfterClosure.map({ $0(referenceDate) }) ?? listAllChargeItemsAfterReturnValue
    }
    
   // MARK: - fetchConsents

    var fetchConsentsCallsCount = 0
    var fetchConsentsCalled: Bool {
        fetchConsentsCallsCount > 0
    }
    var fetchConsentsReturnValue: AnyPublisher<[ErxConsent], RemoteStoreError>!
    var fetchConsentsClosure: (() -> AnyPublisher<[ErxConsent], RemoteStoreError>)?

    func fetchConsents() -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fetchConsentsCallsCount += 1
        return fetchConsentsClosure.map({ $0() }) ?? fetchConsentsReturnValue
    }
    
   // MARK: - grantConsent

    var grantConsentCallsCount = 0
    var grantConsentCalled: Bool {
        grantConsentCallsCount > 0
    }
    var grantConsentReceivedConsent: ErxConsent?
    var grantConsentReceivedInvocations: [ErxConsent] = []
    var grantConsentReturnValue: AnyPublisher<ErxConsent?, RemoteStoreError>!
    var grantConsentClosure: ((ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError>)?

    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        grantConsentCallsCount += 1
        grantConsentReceivedConsent = consent
        grantConsentReceivedInvocations.append(consent)
        return grantConsentClosure.map({ $0(consent) }) ?? grantConsentReturnValue
    }
    
   // MARK: - revokeConsent

    var revokeConsentCallsCount = 0
    var revokeConsentCalled: Bool {
        revokeConsentCallsCount > 0
    }
    var revokeConsentReceivedCategory: ErxConsent.Category?
    var revokeConsentReceivedInvocations: [ErxConsent.Category] = []
    var revokeConsentReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var revokeConsentClosure: ((ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError>)?

    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError> {
        revokeConsentCallsCount += 1
        revokeConsentReceivedCategory = category
        revokeConsentReceivedInvocations.append(category)
        return revokeConsentClosure.map({ $0(category) }) ?? revokeConsentReturnValue
    }
}
