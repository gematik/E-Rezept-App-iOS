// Generated using Sourcery 1.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit

@testable import Pharmacy

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
final class MockPharmacyLocalDataStore: PharmacyLocalDataStore {


    //MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        return fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        if let fetchPharmacyByClosure = fetchPharmacyByClosure {
            return fetchPharmacyByClosure(telematikId)
        } else {
            return fetchPharmacyByReturnValue
        }
    }

    //MARK: - listPharmacies

    var listPharmaciesCountCallsCount = 0
    var listPharmaciesCountCalled: Bool {
        return listPharmaciesCountCallsCount > 0
    }
    var listPharmaciesCountReceivedCount: Int?
    var listPharmaciesCountReceivedInvocations: [Int?] = []
    var listPharmaciesCountReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    var listPharmaciesCountClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountCallsCount += 1
        listPharmaciesCountReceivedCount = count
        listPharmaciesCountReceivedInvocations.append(count)
        if let listPharmaciesCountClosure = listPharmaciesCountClosure {
            return listPharmaciesCountClosure(count)
        } else {
            return listPharmaciesCountReturnValue
        }
    }

    //MARK: - save

    var savePharmaciesCallsCount = 0
    var savePharmaciesCalled: Bool {
        return savePharmaciesCallsCount > 0
    }
    var savePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var savePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var savePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var savePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesCallsCount += 1
        savePharmaciesReceivedPharmacies = pharmacies
        savePharmaciesReceivedInvocations.append(pharmacies)
        if let savePharmaciesClosure = savePharmaciesClosure {
            return savePharmaciesClosure(pharmacies)
        } else {
            return savePharmaciesReturnValue
        }
    }

    //MARK: - delete

    var deletePharmaciesCallsCount = 0
    var deletePharmaciesCalled: Bool {
        return deletePharmaciesCallsCount > 0
    }
    var deletePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var deletePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var deletePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deletePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesCallsCount += 1
        deletePharmaciesReceivedPharmacies = pharmacies
        deletePharmaciesReceivedInvocations.append(pharmacies)
        if let deletePharmaciesClosure = deletePharmaciesClosure {
            return deletePharmaciesClosure(pharmacies)
        } else {
            return deletePharmaciesReturnValue
        }
    }

    //MARK: - update

    var updateTelematikIdMutatingCallsCount = 0
    var updateTelematikIdMutatingCalled: Bool {
        return updateTelematikIdMutatingCallsCount > 0
    }
    var updateTelematikIdMutatingReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    var updateTelematikIdMutatingReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    var updateTelematikIdMutatingReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    var updateTelematikIdMutatingClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdMutatingCallsCount += 1
        updateTelematikIdMutatingReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdMutatingReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        if let updateTelematikIdMutatingClosure = updateTelematikIdMutatingClosure {
            return updateTelematikIdMutatingClosure(telematikId, mutating)
        } else {
            return updateTelematikIdMutatingReturnValue
        }
    }

}
