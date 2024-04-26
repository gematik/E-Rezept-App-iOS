// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit

@testable import Pharmacy

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

    var fetchChargeItemByCallsCount = 0
    var fetchChargeItemByCalled: Bool {
        fetchChargeItemByCallsCount > 0
    }
    var fetchChargeItemByReceivedChargeItemID: ErxSparseChargeItem.ID?
    var fetchChargeItemByReceivedInvocations: [ErxSparseChargeItem.ID] = []
    var fetchChargeItemByReturnValue: AnyPublisher<ErxSparseChargeItem?, LocalStoreError>!
    var fetchChargeItemByClosure: ((ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>)?

    func fetchChargeItem(by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        fetchChargeItemByCallsCount += 1
        fetchChargeItemByReceivedChargeItemID = chargeItemID
        fetchChargeItemByReceivedInvocations.append(chargeItemID)
        return fetchChargeItemByClosure.map({ $0(chargeItemID) }) ?? fetchChargeItemByReturnValue
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
    var listAllChargeItemsReturnValue: AnyPublisher<[ErxSparseChargeItem], LocalStoreError>!
    var listAllChargeItemsClosure: (() -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>)?

    func listAllChargeItems() -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        listAllChargeItemsCallsCount += 1
        return listAllChargeItemsClosure.map({ $0() }) ?? listAllChargeItemsReturnValue
    }
    
   // MARK: - save

    var saveChargeItemsCallsCount = 0
    var saveChargeItemsCalled: Bool {
        saveChargeItemsCallsCount > 0
    }
    var saveChargeItemsReceivedChargeItems: [ErxSparseChargeItem]?
    var saveChargeItemsReceivedInvocations: [[ErxSparseChargeItem]] = []
    var saveChargeItemsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveChargeItemsClosure: (([ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsCallsCount += 1
        saveChargeItemsReceivedChargeItems = chargeItems
        saveChargeItemsReceivedInvocations.append(chargeItems)
        return saveChargeItemsClosure.map({ $0(chargeItems) }) ?? saveChargeItemsReturnValue
    }
    
   // MARK: - delete

    var deleteChargeItemsCallsCount = 0
    var deleteChargeItemsCalled: Bool {
        deleteChargeItemsCallsCount > 0
    }
    var deleteChargeItemsReceivedChargeItems: [ErxSparseChargeItem]?
    var deleteChargeItemsReceivedInvocations: [[ErxSparseChargeItem]] = []
    var deleteChargeItemsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteChargeItemsClosure: (([ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteChargeItemsCallsCount += 1
        deleteChargeItemsReceivedChargeItems = chargeItems
        deleteChargeItemsReceivedInvocations.append(chargeItems)
        return deleteChargeItemsClosure.map({ $0(chargeItems) }) ?? deleteChargeItemsReturnValue
    }
}


// MARK: - MockPharmacyLocalDataStore -

final class MockPharmacyLocalDataStore: PharmacyLocalDataStore {
    
   // MARK: - fetchPharmacy

    var fetchPharmacyByCallsCount = 0
    var fetchPharmacyByCalled: Bool {
        fetchPharmacyByCallsCount > 0
    }
    var fetchPharmacyByReceivedTelematikId: String?
    var fetchPharmacyByReceivedInvocations: [String] = []
    var fetchPharmacyByReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    var fetchPharmacyByClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByCallsCount += 1
        fetchPharmacyByReceivedTelematikId = telematikId
        fetchPharmacyByReceivedInvocations.append(telematikId)
        return fetchPharmacyByClosure.map({ $0(telematikId) }) ?? fetchPharmacyByReturnValue
    }
    
   // MARK: - listPharmacies

    var listPharmaciesCountCallsCount = 0
    var listPharmaciesCountCalled: Bool {
        listPharmaciesCountCallsCount > 0
    }
    var listPharmaciesCountReceivedCount: Int?
    var listPharmaciesCountReceivedInvocations: [Int?] = []
    var listPharmaciesCountReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    var listPharmaciesCountClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountCallsCount += 1
        listPharmaciesCountReceivedCount = count
        listPharmaciesCountReceivedInvocations.append(count)
        return listPharmaciesCountClosure.map({ $0(count) }) ?? listPharmaciesCountReturnValue
    }
    
   // MARK: - save

    var savePharmaciesCallsCount = 0
    var savePharmaciesCalled: Bool {
        savePharmaciesCallsCount > 0
    }
    var savePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var savePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var savePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var savePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesCallsCount += 1
        savePharmaciesReceivedPharmacies = pharmacies
        savePharmaciesReceivedInvocations.append(pharmacies)
        return savePharmaciesClosure.map({ $0(pharmacies) }) ?? savePharmaciesReturnValue
    }
    
   // MARK: - delete

    var deletePharmaciesCallsCount = 0
    var deletePharmaciesCalled: Bool {
        deletePharmaciesCallsCount > 0
    }
    var deletePharmaciesReceivedPharmacies: [PharmacyLocation]?
    var deletePharmaciesReceivedInvocations: [[PharmacyLocation]] = []
    var deletePharmaciesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deletePharmaciesClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesCallsCount += 1
        deletePharmaciesReceivedPharmacies = pharmacies
        deletePharmaciesReceivedInvocations.append(pharmacies)
        return deletePharmaciesClosure.map({ $0(pharmacies) }) ?? deletePharmaciesReturnValue
    }
    
   // MARK: - update

    var updateTelematikIdMutatingCallsCount = 0
    var updateTelematikIdMutatingCalled: Bool {
        updateTelematikIdMutatingCallsCount > 0
    }
    var updateTelematikIdMutatingReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    var updateTelematikIdMutatingReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    var updateTelematikIdMutatingReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    var updateTelematikIdMutatingClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdMutatingCallsCount += 1
        updateTelematikIdMutatingReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdMutatingReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        return updateTelematikIdMutatingClosure.map({ $0(telematikId, mutating) }) ?? updateTelematikIdMutatingReturnValue
    }
}
