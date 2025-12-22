// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import eRpKit
import OpenSSL
import TrustStore
import Foundation

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


// MARK: - MockProfileDataStore -

final class MockProfileDataStore: ProfileDataStore {
    
   // MARK: - fetchProfile

    var fetchProfileByCallsCount = 0
    var fetchProfileByCalled: Bool {
        fetchProfileByCallsCount > 0
    }
    var fetchProfileByReceivedIdentifier: Profile.ID?
    var fetchProfileByReceivedInvocations: [Profile.ID] = []
    var fetchProfileByReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    var fetchProfileByClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByCallsCount += 1
        fetchProfileByReceivedIdentifier = identifier
        fetchProfileByReceivedInvocations.append(identifier)
        return fetchProfileByClosure.map({ $0(identifier) }) ?? fetchProfileByReturnValue
    }
    
   // MARK: - listAllProfiles

    var listAllProfilesCallsCount = 0
    var listAllProfilesCalled: Bool {
        listAllProfilesCallsCount > 0
    }
    var listAllProfilesReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    var listAllProfilesClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesCallsCount += 1
        return listAllProfilesClosure.map({ $0() }) ?? listAllProfilesReturnValue
    }
    
   // MARK: - save

    var saveProfilesCallsCount = 0
    var saveProfilesCalled: Bool {
        saveProfilesCallsCount > 0
    }
    var saveProfilesReceivedProfiles: [Profile]?
    var saveProfilesReceivedInvocations: [[Profile]] = []
    var saveProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var saveProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesCallsCount += 1
        saveProfilesReceivedProfiles = profiles
        saveProfilesReceivedInvocations.append(profiles)
        return saveProfilesClosure.map({ $0(profiles) }) ?? saveProfilesReturnValue
    }
    
   // MARK: - delete

    var deleteProfilesCallsCount = 0
    var deleteProfilesCalled: Bool {
        deleteProfilesCallsCount > 0
    }
    var deleteProfilesReceivedProfiles: [Profile]?
    var deleteProfilesReceivedInvocations: [[Profile]] = []
    var deleteProfilesReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var deleteProfilesClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesCallsCount += 1
        deleteProfilesReceivedProfiles = profiles
        deleteProfilesReceivedInvocations.append(profiles)
        return deleteProfilesClosure.map({ $0(profiles) }) ?? deleteProfilesReturnValue
    }
    
   // MARK: - update

    var updateProfileIdMutatingCallsCount = 0
    var updateProfileIdMutatingCalled: Bool {
        updateProfileIdMutatingCallsCount > 0
    }
    var updateProfileIdMutatingReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    var updateProfileIdMutatingReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    var updateProfileIdMutatingReturnValue: AnyPublisher<Bool, LocalStoreError>!
    var updateProfileIdMutatingClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError>)?

    func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdMutatingCallsCount += 1
        updateProfileIdMutatingReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdMutatingReceivedInvocations.append((profileId: profileId, mutating: mutating))
        return updateProfileIdMutatingClosure.map({ $0(profileId, mutating) }) ?? updateProfileIdMutatingReturnValue
    }
}
