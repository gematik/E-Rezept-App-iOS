// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import Foundation

@testable import ErxTaskRepository

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

    var listAllTasksOfCallsCount = 0
    var listAllTasksOfCalled: Bool {
        listAllTasksOfCallsCount > 0
    }
    var listAllTasksOfReceivedProfileId: UUID?
    var listAllTasksOfReceivedInvocations: [UUID?] = []
    var listAllTasksOfReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    var listAllTasksOfClosure: ((UUID?) -> AnyPublisher<[ErxTask], LocalStoreError>)?

    func listAllTasks(of profileId: UUID?) -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksOfCallsCount += 1
        listAllTasksOfReceivedProfileId = profileId
        listAllTasksOfReceivedInvocations.append(profileId)
        return listAllTasksOfClosure.map({ $0(profileId) }) ?? listAllTasksOfReturnValue
    }
    
   // MARK: - fetchLatestLastModifiedForErxTasks

    var fetchLatestLastModifiedForErxTasksOfCallsCount = 0
    var fetchLatestLastModifiedForErxTasksOfCalled: Bool {
        fetchLatestLastModifiedForErxTasksOfCallsCount > 0
    }
    var fetchLatestLastModifiedForErxTasksOfReceivedProfileId: UUID?
    var fetchLatestLastModifiedForErxTasksOfReceivedInvocations: [UUID?] = []
    var fetchLatestLastModifiedForErxTasksOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestLastModifiedForErxTasksOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestLastModifiedForErxTasks(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksOfCallsCount += 1
        fetchLatestLastModifiedForErxTasksOfReceivedProfileId = profileId
        fetchLatestLastModifiedForErxTasksOfReceivedInvocations.append(profileId)
        return fetchLatestLastModifiedForErxTasksOfClosure.map({ $0(profileId) }) ?? fetchLatestLastModifiedForErxTasksOfReturnValue
    }
    
   // MARK: - save

    var saveTasksInUpdateProfileLastAuthenticatedCallsCount = 0
    var saveTasksInUpdateProfileLastAuthenticatedCalled: Bool {
        saveTasksInUpdateProfileLastAuthenticatedCallsCount > 0
    }
    var saveTasksInUpdateProfileLastAuthenticatedReceivedArguments: (tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)?
    var saveTasksInUpdateProfileLastAuthenticatedReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)] = []
    var saveTasksInUpdateProfileLastAuthenticatedReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveTasksInUpdateProfileLastAuthenticatedClosure: (([ErxTask], UUID?, Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(tasks: [ErxTask], in profileId: UUID?, updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksInUpdateProfileLastAuthenticatedCallsCount += 1
        saveTasksInUpdateProfileLastAuthenticatedReceivedArguments = (tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksInUpdateProfileLastAuthenticatedReceivedInvocations.append((tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        return saveTasksInUpdateProfileLastAuthenticatedClosure.map({ $0(tasks, profileId, updateProfileLastAuthenticated) }) ?? saveTasksInUpdateProfileLastAuthenticatedReturnValue
    }
    
   // MARK: - delete

    var deleteTasksInCallsCount = 0
    var deleteTasksInCalled: Bool {
        deleteTasksInCallsCount > 0
    }
    var deleteTasksInReceivedArguments: (tasks: [ErxTask], profileId: UUID?)?
    var deleteTasksInReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?)] = []
    var deleteTasksInReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteTasksInClosure: (([ErxTask], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(tasks: [ErxTask], in profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksInCallsCount += 1
        deleteTasksInReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksInReceivedInvocations.append((tasks: tasks, profileId: profileId))
        return deleteTasksInClosure.map({ $0(tasks, profileId) }) ?? deleteTasksInReturnValue
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

    var fetchLatestTimestampForCommunicationsOfCallsCount = 0
    var fetchLatestTimestampForCommunicationsOfCalled: Bool {
        fetchLatestTimestampForCommunicationsOfCallsCount > 0
    }
    var fetchLatestTimestampForCommunicationsOfReceivedProfileId: UUID?
    var fetchLatestTimestampForCommunicationsOfReceivedInvocations: [UUID?] = []
    var fetchLatestTimestampForCommunicationsOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForCommunicationsOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForCommunications(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsOfCallsCount += 1
        fetchLatestTimestampForCommunicationsOfReceivedProfileId = profileId
        fetchLatestTimestampForCommunicationsOfReceivedInvocations.append(profileId)
        return fetchLatestTimestampForCommunicationsOfClosure.map({ $0(profileId) }) ?? fetchLatestTimestampForCommunicationsOfReturnValue
    }
    
   // MARK: - save

    var saveCommunicationsOfCallsCount = 0
    var saveCommunicationsOfCalled: Bool {
        saveCommunicationsOfCallsCount > 0
    }
    var saveCommunicationsOfReceivedArguments: (communications: [ErxTask.Communication], profileId: UUID?)?
    var saveCommunicationsOfReceivedInvocations: [(communications: [ErxTask.Communication], profileId: UUID?)] = []
    var saveCommunicationsOfReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveCommunicationsOfClosure: (([ErxTask.Communication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(communications: [ErxTask.Communication], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsOfCallsCount += 1
        saveCommunicationsOfReceivedArguments = (communications: communications, profileId: profileId)
        saveCommunicationsOfReceivedInvocations.append((communications: communications, profileId: profileId))
        return saveCommunicationsOfClosure.map({ $0(communications, profileId) }) ?? saveCommunicationsOfReturnValue
    }
    
   // MARK: - allUnreadCommunications

    var allUnreadCommunicationsOfForCallsCount = 0
    var allUnreadCommunicationsOfForCalled: Bool {
        allUnreadCommunicationsOfForCallsCount > 0
    }
    var allUnreadCommunicationsOfForReceivedArguments: (profileId: UUID?, profile: ErxTask.Communication.Profile)?
    var allUnreadCommunicationsOfForReceivedInvocations: [(profileId: UUID?, profile: ErxTask.Communication.Profile)] = []
    var allUnreadCommunicationsOfForReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    var allUnreadCommunicationsOfForClosure: ((UUID?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    func allUnreadCommunications(of profileId: UUID?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsOfForCallsCount += 1
        allUnreadCommunicationsOfForReceivedArguments = (profileId: profileId, profile: profile)
        allUnreadCommunicationsOfForReceivedInvocations.append((profileId: profileId, profile: profile))
        return allUnreadCommunicationsOfForClosure.map({ $0(profileId, profile) }) ?? allUnreadCommunicationsOfForReturnValue
    }
    
   // MARK: - listAllMedicationDispenses

    var listAllMedicationDispensesOfCallsCount = 0
    var listAllMedicationDispensesOfCalled: Bool {
        listAllMedicationDispensesOfCallsCount > 0
    }
    var listAllMedicationDispensesOfReceivedProfileId: UUID?
    var listAllMedicationDispensesOfReceivedInvocations: [UUID?] = []
    var listAllMedicationDispensesOfReturnValue: AnyPublisher<[ErxMedicationDispense], LocalStoreError>!
    var listAllMedicationDispensesOfClosure: ((UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>)?

    func listAllMedicationDispenses(of profileId: UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        listAllMedicationDispensesOfCallsCount += 1
        listAllMedicationDispensesOfReceivedProfileId = profileId
        listAllMedicationDispensesOfReceivedInvocations.append(profileId)
        return listAllMedicationDispensesOfClosure.map({ $0(profileId) }) ?? listAllMedicationDispensesOfReturnValue
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

    var fetchChargeItemOfByCallsCount = 0
    var fetchChargeItemOfByCalled: Bool {
        fetchChargeItemOfByCallsCount > 0
    }
    var fetchChargeItemOfByReceivedArguments: (profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)?
    var fetchChargeItemOfByReceivedInvocations: [(profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)] = []
    var fetchChargeItemOfByReturnValue: AnyPublisher<ErxSparseChargeItem?, LocalStoreError>!
    var fetchChargeItemOfByClosure: ((UUID?, ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>)?

    func fetchChargeItem(of profileId: UUID?, by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        fetchChargeItemOfByCallsCount += 1
        fetchChargeItemOfByReceivedArguments = (profileId: profileId, chargeItemID: chargeItemID)
        fetchChargeItemOfByReceivedInvocations.append((profileId: profileId, chargeItemID: chargeItemID))
        return fetchChargeItemOfByClosure.map({ $0(profileId, chargeItemID) }) ?? fetchChargeItemOfByReturnValue
    }
    
   // MARK: - fetchLatestTimestampForChargeItems

    var fetchLatestTimestampForChargeItemsOfCallsCount = 0
    var fetchLatestTimestampForChargeItemsOfCalled: Bool {
        fetchLatestTimestampForChargeItemsOfCallsCount > 0
    }
    var fetchLatestTimestampForChargeItemsOfReceivedProfileId: UUID?
    var fetchLatestTimestampForChargeItemsOfReceivedInvocations: [UUID?] = []
    var fetchLatestTimestampForChargeItemsOfReturnValue: AnyPublisher<String?, LocalStoreError>!
    var fetchLatestTimestampForChargeItemsOfClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForChargeItemsOfCallsCount += 1
        fetchLatestTimestampForChargeItemsOfReceivedProfileId = profileId
        fetchLatestTimestampForChargeItemsOfReceivedInvocations.append(profileId)
        return fetchLatestTimestampForChargeItemsOfClosure.map({ $0(profileId) }) ?? fetchLatestTimestampForChargeItemsOfReturnValue
    }
    
   // MARK: - listAllChargeItems

    var listAllChargeItemsOfCallsCount = 0
    var listAllChargeItemsOfCalled: Bool {
        listAllChargeItemsOfCallsCount > 0
    }
    var listAllChargeItemsOfReceivedProfileId: UUID?
    var listAllChargeItemsOfReceivedInvocations: [UUID?] = []
    var listAllChargeItemsOfReturnValue: AnyPublisher<[ErxSparseChargeItem], LocalStoreError>!
    var listAllChargeItemsOfClosure: ((UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>)?

    func listAllChargeItems(of profileId: UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        listAllChargeItemsOfCallsCount += 1
        listAllChargeItemsOfReceivedProfileId = profileId
        listAllChargeItemsOfReceivedInvocations.append(profileId)
        return listAllChargeItemsOfClosure.map({ $0(profileId) }) ?? listAllChargeItemsOfReturnValue
    }
    
   // MARK: - save

    var saveChargeItemsOfCallsCount = 0
    var saveChargeItemsOfCalled: Bool {
        saveChargeItemsOfCallsCount > 0
    }
    var saveChargeItemsOfReceivedArguments: (chargeItems: [ErxSparseChargeItem], profileId: UUID?)?
    var saveChargeItemsOfReceivedInvocations: [(chargeItems: [ErxSparseChargeItem], profileId: UUID?)] = []
    var saveChargeItemsOfReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveChargeItemsOfClosure: (([ErxSparseChargeItem], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsOfCallsCount += 1
        saveChargeItemsOfReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        saveChargeItemsOfReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        return saveChargeItemsOfClosure.map({ $0(chargeItems, profileId) }) ?? saveChargeItemsOfReturnValue
    }
    
   // MARK: - delete

    var deleteOfChargeItemsCallsCount = 0
    var deleteOfChargeItemsCalled: Bool {
        deleteOfChargeItemsCallsCount > 0
    }
    var deleteOfChargeItemsReceivedArguments: (profileId: UUID?, chargeItems: [ErxSparseChargeItem])?
    var deleteOfChargeItemsReceivedInvocations: [(profileId: UUID?, chargeItems: [ErxSparseChargeItem])] = []
    var deleteOfChargeItemsReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteOfChargeItemsClosure: ((UUID?, [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(of profileId: UUID?, chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteOfChargeItemsCallsCount += 1
        deleteOfChargeItemsReceivedArguments = (profileId: profileId, chargeItems: chargeItems)
        deleteOfChargeItemsReceivedInvocations.append((profileId: profileId, chargeItems: chargeItems))
        return deleteOfChargeItemsClosure.map({ $0(profileId, chargeItems) }) ?? deleteOfChargeItemsReturnValue
    }
    
   // MARK: - update

    var updateDiGaInfoCallsCount = 0
    var updateDiGaInfoCalled: Bool {
        updateDiGaInfoCallsCount > 0
    }
    var updateDiGaInfoReceivedDiGaInfo: DiGaInfo?
    var updateDiGaInfoReceivedInvocations: [DiGaInfo] = []
    var updateDiGaInfoReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateDiGaInfoClosure: ((DiGaInfo) -> AnyPublisher<Bool, LocalStoreError>)?

    func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        updateDiGaInfoCallsCount += 1
        updateDiGaInfoReceivedDiGaInfo = diGaInfo
        updateDiGaInfoReceivedInvocations.append(diGaInfo)
        return updateDiGaInfoClosure.map({ $0(diGaInfo) }) ?? updateDiGaInfoReturnValue
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
    var listAllTasksAfterReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listAllTasksAfterClosure: ((String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listAllTasks(after referenceDate: String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listAllTasksAfterCallsCount += 1
        listAllTasksAfterReceivedReferenceDate = referenceDate
        listAllTasksAfterReceivedInvocations.append(referenceDate)
        return listAllTasksAfterClosure.map({ $0(referenceDate) }) ?? listAllTasksAfterReturnValue
    }
    
   // MARK: - listTasksNextPage

    var listTasksNextPageOfCallsCount = 0
    var listTasksNextPageOfCalled: Bool {
        listTasksNextPageOfCallsCount > 0
    }
    var listTasksNextPageOfReceivedPreviousPage: PagedContent<[ErxTask]>?
    var listTasksNextPageOfReceivedInvocations: [PagedContent<[ErxTask]>] = []
    var listTasksNextPageOfReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listTasksNextPageOfClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listTasksNextPageOfCallsCount += 1
        listTasksNextPageOfReceivedPreviousPage = previousPage
        listTasksNextPageOfReceivedInvocations.append(previousPage)
        return listTasksNextPageOfClosure.map({ $0(previousPage) }) ?? listTasksNextPageOfReturnValue
    }
    
   // MARK: - listDetailedTasks

    var listDetailedTasksForCallsCount = 0
    var listDetailedTasksForCalled: Bool {
        listDetailedTasksForCallsCount > 0
    }
    var listDetailedTasksForReceivedTasks: PagedContent<[ErxTask]>?
    var listDetailedTasksForReceivedInvocations: [PagedContent<[ErxTask]>] = []
    var listDetailedTasksForReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    var listDetailedTasksForClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    func listDetailedTasks(for tasks: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listDetailedTasksForCallsCount += 1
        listDetailedTasksForReceivedTasks = tasks
        listDetailedTasksForReceivedInvocations.append(tasks)
        return listDetailedTasksForClosure.map({ $0(tasks) }) ?? listDetailedTasksForReturnValue
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

    var listAuditEventsNextPageFromLocaleCallsCount = 0
    var listAuditEventsNextPageFromLocaleCalled: Bool {
        listAuditEventsNextPageFromLocaleCallsCount > 0
    }
    var listAuditEventsNextPageFromLocaleReceivedArguments: (url: URL, locale: String?)?
    var listAuditEventsNextPageFromLocaleReceivedInvocations: [(url: URL, locale: String?)] = []
    var listAuditEventsNextPageFromLocaleReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    var listAuditEventsNextPageFromLocaleClosure: ((URL, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    func listAuditEventsNextPage(from url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageFromLocaleCallsCount += 1
        listAuditEventsNextPageFromLocaleReceivedArguments = (url: url, locale: locale)
        listAuditEventsNextPageFromLocaleReceivedInvocations.append((url: url, locale: locale))
        return listAuditEventsNextPageFromLocaleClosure.map({ $0(url, locale) }) ?? listAuditEventsNextPageFromLocaleReturnValue
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
    
   // MARK: - delete

    var deleteChargeItemsCallsCount = 0
    var deleteChargeItemsCalled: Bool {
        deleteChargeItemsCallsCount > 0
    }
    var deleteChargeItemsReceivedChargeItems: [ErxChargeItem]?
    var deleteChargeItemsReceivedInvocations: [[ErxChargeItem]] = []
    var deleteChargeItemsReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    var deleteChargeItemsClosure: (([ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError>)?

    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteChargeItemsCallsCount += 1
        deleteChargeItemsReceivedChargeItems = chargeItems
        deleteChargeItemsReceivedInvocations.append(chargeItems)
        return deleteChargeItemsClosure.map({ $0(chargeItems) }) ?? deleteChargeItemsReturnValue
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
