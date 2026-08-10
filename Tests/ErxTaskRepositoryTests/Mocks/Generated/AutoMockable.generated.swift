// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import Combine
import eRpKit
import Foundation

@testable import ErxTaskRepository
























public class ErxLocalDataStoreMock: ErxLocalDataStore {

    public init() {}



    //MARK: - fetchTask

    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<ErxTask?, LocalStoreError>!
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, LocalStoreError>)?

    public func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReceivedInvocations.append((id: id, accessCode: accessCode))
        if let fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure = fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure(id, accessCode)
        } else {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasks

    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    public var listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxTask], LocalStoreError>)?

    public func listAllTasks(of profileId: UUID?) -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedProfileId = profileId
        listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure = listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure {
            return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure(profileId)
        } else {
            return listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestLastModifiedForErxTasks

    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestLastModifiedForErxTasks(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)?
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?, updateProfileLastAuthenticated: Bool)] = []
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask], UUID?, Bool) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(tasks: [ErxTask], in profileId: UUID?, updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated)
        saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId, updateProfileLastAuthenticated: updateProfileLastAuthenticated))
        if let saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure = saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure {
            return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure(tasks, profileId, updateProfileLastAuthenticated)
        } else {
            return saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID?)?
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID?)] = []
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(tasks: [ErxTask], in profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(tasks, profileId)
        } else {
            return deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasksWithoutProfile

    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount = 0
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCalled: Bool {
        return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount > 0
    }
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorReturnValue: AnyPublisher<[ErxTask], LocalStoreError>!
    public var listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure: (() -> AnyPublisher<[ErxTask], LocalStoreError>)?

    public func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorCallsCount += 1
        if let listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure = listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure {
            return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorClosure()
        } else {
            return listAllTasksWithoutProfileAnyPublisherErxTaskLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllCommunications

    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount = 0
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCalled: Bool {
        return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount > 0
    }
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedProfile: (ErxTask.Communication.Profile)?
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations: [(ErxTask.Communication.Profile)] = []
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    public var listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure: ((ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    public func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount += 1
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedProfile = profile
        listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations.append(profile)
        if let listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure = listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure {
            return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure(profile)
        } else {
            return listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForCommunications

    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestTimestampForCommunications(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (communications: [ErxTask.Communication], profileId: UUID?)?
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(communications: [ErxTask.Communication], profileId: UUID?)] = []
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxTask.Communication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(communications: [ErxTask.Communication], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (communications: communications, profileId: profileId)
        saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((communications: communications, profileId: profileId))
        if let saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(communications, profileId)
        } else {
            return saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - allUnreadCommunications

    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount = 0
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCalled: Bool {
        return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount > 0
    }
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedArguments: (profileId: UUID?, profile: ErxTask.Communication.Profile)?
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations: [(profileId: UUID?, profile: ErxTask.Communication.Profile)] = []
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], LocalStoreError>!
    public var allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure: ((UUID?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError>)?

    public func allUnreadCommunications(of profileId: UUID?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorCallsCount += 1
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedArguments = (profileId: profileId, profile: profile)
        allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReceivedInvocations.append((profileId: profileId, profile: profile))
        if let allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure = allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure {
            return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure(profileId, profile)
        } else {
            return allUnreadCommunicationsOfProfileIdUUIDForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllMedicationDispenses

    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount = 0
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCalled: Bool {
        return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount > 0
    }
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReturnValue: AnyPublisher<[ErxMedicationDispense], LocalStoreError>!
    public var listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError>)?

    public func listAllMedicationDispenses(of profileId: UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorCallsCount += 1
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedProfileId = profileId
        listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure = listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure {
            return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorClosure(profileId)
        } else {
            return listAllMedicationDispensesOfProfileIdUUIDAnyPublisherErxMedicationDispenseLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedMedicationDispenses: ([ErxMedicationDispense])?
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([ErxMedicationDispense])] = []
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure: (([ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedMedicationDispenses = medicationDispenses
        saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(medicationDispenses)
        if let saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure = saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure {
            return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure(medicationDispenses)
        } else {
            return saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchChargeItem

    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount = 0
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCalled: Bool {
        return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount > 0
    }
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedArguments: (profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)?
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations: [(profileId: UUID?, chargeItemID: ErxSparseChargeItem.ID)] = []
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue: AnyPublisher<ErxSparseChargeItem?, LocalStoreError>!
    public var fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure: ((UUID?, ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError>)?

    public func fetchChargeItem(of profileId: UUID?, by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount += 1
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedArguments = (profileId: profileId, chargeItemID: chargeItemID)
        fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations.append((profileId: profileId, chargeItemID: chargeItemID))
        if let fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure = fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure {
            return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure(profileId, chargeItemID)
        } else {
            return fetchChargeItemOfProfileIdUUIDByChargeItemIDErxSparseChargeItemIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue
        }
    }

    //MARK: - fetchLatestTimestampForChargeItems

    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount = 0
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCalled: Bool {
        return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount > 0
    }
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId: (UUID)?
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue: AnyPublisher<String?, LocalStoreError>!
    public var fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<String?, LocalStoreError>)?

    public func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount += 1
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedProfileId = profileId
        fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReceivedInvocations.append(profileId)
        if let fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure {
            return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure(profileId)
        } else {
            return fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllChargeItems

    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount = 0
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCalled: Bool {
        return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount > 0
    }
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedProfileId: (UUID)?
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue: AnyPublisher<[ErxSparseChargeItem], LocalStoreError>!
    public var listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError>)?

    public func listAllChargeItems(of profileId: UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorCallsCount += 1
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedProfileId = profileId
        listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReceivedInvocations.append(profileId)
        if let listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure = listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure {
            return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure(profileId)
        } else {
            return listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (chargeItems: [ErxSparseChargeItem], profileId: UUID?)?
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(chargeItems: [ErxSparseChargeItem], profileId: UUID?)] = []
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([ErxSparseChargeItem], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        if let saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(chargeItems, profileId)
        } else {
            return saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedArguments: (profileId: UUID?, chargeItems: [ErxSparseChargeItem])?
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(profileId: UUID?, chargeItems: [ErxSparseChargeItem])] = []
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure: ((UUID?, [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(of profileId: UUID?, chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedArguments = (profileId: profileId, chargeItems: chargeItems)
        deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((profileId: profileId, chargeItems: chargeItems))
        if let deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure = deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure {
            return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorClosure(profileId, chargeItems)
        } else {
            return deleteOfProfileIdUUIDChargeItemsErxSparseChargeItemAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedDiGaInfo: (DiGaInfo)?
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(DiGaInfo)] = []
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure: ((DiGaInfo) -> AnyPublisher<Bool, LocalStoreError>)?

    public func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorCallsCount += 1
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedDiGaInfo = diGaInfo
        updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(diGaInfo)
        if let updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure = updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure {
            return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorClosure(diGaInfo)
        } else {
            return updateDiGaInfoDiGaInfoAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (euCommunications: [EuCommunication], profileId: UUID?)?
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(euCommunications: [EuCommunication], profileId: UUID?)] = []
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([EuCommunication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (euCommunications: euCommunications, profileId: profileId)
        saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((euCommunications: euCommunications, profileId: profileId))
        if let saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(euCommunications, profileId)
        } else {
            return saveEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllEuCommunication

    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount = 0
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCalled: Bool {
        return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount > 0
    }
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedArguments: (countryCode: String?, profileId: UUID?)?
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations: [(countryCode: String?, profileId: UUID?)] = []
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue: AnyPublisher<[EuCommunication], LocalStoreError>!
    public var listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure: ((String?, UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError>)?

    public func listAllEuCommunication(countryCode: String?, profileId: UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError> {
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount += 1
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedArguments = (countryCode: countryCode, profileId: profileId)
        listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations.append((countryCode: countryCode, profileId: profileId))
        if let listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure = listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure {
            return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure(countryCode, profileId)
        } else {
            return listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments: (euCommunications: [EuCommunication], profileId: UUID?)?
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(euCommunications: [EuCommunication], profileId: UUID?)] = []
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure: (([EuCommunication], UUID?) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedArguments = (euCommunications: euCommunications, profileId: profileId)
        deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((euCommunications: euCommunications, profileId: profileId))
        if let deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure {
            return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure(euCommunications, profileId)
        } else {
            return deleteEuCommunicationsEuCommunicationProfileIdUUIDAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - loadLatestActiveEuCommunication

    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount = 0
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCalled: Bool {
        return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount > 0
    }
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedProfileId: (UUID)?
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations: [(UUID)?] = []
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue: AnyPublisher<EuCommunication?, LocalStoreError>!
    public var loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure: ((UUID?) -> AnyPublisher<EuCommunication?, LocalStoreError>)?

    public func loadLatestActiveEuCommunication(profileId: UUID?) -> AnyPublisher<EuCommunication?, LocalStoreError> {
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorCallsCount += 1
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedProfileId = profileId
        loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReceivedInvocations.append(profileId)
        if let loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure = loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure {
            return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure(profileId)
        } else {
            return loadLatestActiveEuCommunicationProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorReturnValue
        }
    }


}
public class ErxRemoteDataStoreMock: ErxRemoteDataStore {

    public init() {}



    //MARK: - fetchTask

    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, accessCode: String?, profileId: UUID)?
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, accessCode: String?, profileId: UUID)] = []
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, String?, UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func fetchTask(by id: ErxTask.ID, accessCode: String?, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, accessCode: accessCode, profileId: profileId)
        fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, accessCode: accessCode, profileId: profileId))
        if let fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure = fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure {
            return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure(id, accessCode, profileId)
        } else {
            return fetchTaskByIdErxTaskIDAccessCodeStringProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasks

    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (referenceDate: String?, profileId: UUID)?
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profileId: UUID)] = []
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((String?, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listAllTasks(after referenceDate: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profileId: profileId)
        listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profileId: profileId))
        if let listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(referenceDate, profileId)
        } else {
            return listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listTasksNextPage

    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (previousPage: PagedContent<[ErxTask]>, profileId: UUID)?
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(previousPage: PagedContent<[ErxTask]>, profileId: UUID)] = []
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (previousPage: previousPage, profileId: profileId)
        listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((previousPage: previousPage, profileId: profileId))
        if let listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(previousPage, profileId)
        } else {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listDetailedTasks

    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments: (tasks: PagedContent<[ErxTask]>, profileId: UUID)?
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(tasks: PagedContent<[ErxTask]>, profileId: UUID)] = []
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>, UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listDetailedTasks(for tasks: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(tasks, profileId)
        } else {
            return listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (tasks: [ErxTask], profileId: UUID)?
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(tasks: [ErxTask], profileId: UUID)] = []
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: (([ErxTask], UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(tasks: [ErxTask], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (tasks: tasks, profileId: profileId)
        deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((tasks: tasks, profileId: profileId))
        if let deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(tasks, profileId)
        } else {
            return deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - markEURedeemable

    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID)?
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID)] = []
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, Bool, UUID) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func markEURedeemable(for id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, byPatientAuthorization: byPatientAuthorization, profileId: profileId)
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, byPatientAuthorization: byPatientAuthorization, profileId: profileId))
        if let markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure = markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorClosure(id, byPatientAuthorization, profileId)
        } else {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolProfileIdUUIDAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - redeem

    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount = 0
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCalled: Bool {
        return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount > 0
    }
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedArguments: (order: ErxTaskOrder, profileId: UUID)?
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations: [(order: ErxTaskOrder, profileId: UUID)] = []
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    public var redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure: ((ErxTaskOrder, UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    public func redeem(order: ErxTaskOrder, profileId: UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount += 1
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedArguments = (order: order, profileId: profileId)
        redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations.append((order: order, profileId: profileId))
        if let redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure = redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure {
            return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorClosure(order, profileId)
        } else {
            return redeemOrderErxTaskOrderProfileIdUUIDAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllCommunications

    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount = 0
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCalled: Bool {
        return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount > 0
    }
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile, profileId: UUID)?
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile, profileId: UUID)] = []
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure: ((String?, ErxTask.Communication.Profile, UUID) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    public func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile, profileId: UUID) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount += 1
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profile: profile, profileId: profileId)
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profile: profile, profileId: profileId))
        if let listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure = listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure(referenceDate, profile, profileId)
        } else {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchAuditEvent

    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount = 0
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCalled: Bool {
        return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedArguments: (id: ErxAuditEvent.ID, profileId: UUID)?
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations: [(id: ErxAuditEvent.ID, profileId: UUID)] = []
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    public var fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure: ((ErxAuditEvent.ID, UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    public func fetchAuditEvent(by id: ErxAuditEvent.ID, profileId: UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount += 1
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure = fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure {
            return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorClosure(id, profileId)
        } else {
            return fetchAuditEventByIdErxAuditEventIDProfileIdUUIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (referenceDate: String?, locale: String?, profileId: UUID)?
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, locale: String?, profileId: UUID)] = []
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((String?, String?, UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAllAuditEvents(after referenceDate: String?, for locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, locale: locale, profileId: profileId)
        listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, locale: locale, profileId: profileId))
        if let listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(referenceDate, locale, profileId)
        } else {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAuditEventsNextPage

    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (url: URL, locale: String?, profileId: UUID)?
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(url: URL, locale: String?, profileId: UUID)] = []
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((URL, String?, UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAuditEventsNextPage(from url: URL, locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (url: url, locale: locale, profileId: profileId)
        listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((url: url, locale: locale, profileId: profileId))
        if let listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(url, locale, profileId)
        } else {
            return listAuditEventsNextPageFromUrlURLLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listMedicationDispenses

    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount = 0
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCalled: Bool {
        return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount > 0
    }
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, profileId: UUID)?
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, profileId: UUID)] = []
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue: AnyPublisher<[ErxMedicationDispense], RemoteStoreError>!
    public var listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure: ((ErxTask.ID, UUID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>)?

    public func listMedicationDispenses(for id: ErxTask.ID, profileId: UUID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount += 1
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure = listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure {
            return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure(id, profileId)
        } else {
            return listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchChargeItem

    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments: (id: ErxChargeItem.ID, profileId: UUID)?
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(id: ErxChargeItem.ID, profileId: UUID)] = []
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<ErxChargeItem?, RemoteStoreError>!
    public var fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((ErxChargeItem.ID, UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>)?

    public func fetchChargeItem(by id: ErxChargeItem.ID, profileId: UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments = (id: id, profileId: profileId)
        fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append((id: id, profileId: profileId))
        if let fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure = fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure(id, profileId)
        } else {
            return fetchChargeItemByIdErxChargeItemIDProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllChargeItems

    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments: (referenceDate: String?, profileId: UUID)?
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profileId: UUID)] = []
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<[ErxChargeItem], RemoteStoreError>!
    public var listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((String?, UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>)?

    public func listAllChargeItems(after referenceDate: String?, profileId: UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profileId: profileId)
        listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profileId: profileId))
        if let listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure = listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure(referenceDate, profileId)
        } else {
            return listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (chargeItems: [ErxChargeItem], profileId: UUID)?
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(chargeItems: [ErxChargeItem], profileId: UUID)] = []
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: (([ErxChargeItem], UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(chargeItems: [ErxChargeItem], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (chargeItems: chargeItems, profileId: profileId)
        deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((chargeItems: chargeItems, profileId: profileId))
        if let deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(chargeItems, profileId)
        } else {
            return deleteChargeItemsErxChargeItemProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchConsents

    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedProfileId: (UUID)?
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<[ErxConsent], RemoteStoreError>!
    public var fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError>)?

    public func fetchConsents(profileId: UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedProfileId = profileId
        fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations.append(profileId)
        if let fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure = fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure {
            return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure(profileId)
        } else {
            return fetchConsentsProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantConsent

    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedArguments: (consent: ErxConsent, profileId: UUID)?
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations: [(consent: ErxConsent, profileId: UUID)] = []
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<ErxConsent?, RemoteStoreError>!
    public var grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure: ((ErxConsent, UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError>)?

    public func grantConsent(_ consent: ErxConsent, profileId: UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedArguments = (consent: consent, profileId: profileId)
        grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations.append((consent: consent, profileId: profileId))
        if let grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure = grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure {
            return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorClosure(consent, profileId)
        } else {
            return grantConsentConsentErxConsentProfileIdUUIDAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - revokeConsent

    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments: (category: ErxConsent.Category, profileId: UUID)?
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(category: ErxConsent.Category, profileId: UUID)] = []
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: ((ErxConsent.Category, UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func revokeConsent(_ category: ErxConsent.Category, profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedArguments = (category: category, profileId: profileId)
        revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append((category: category, profileId: profileId))
        if let revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(category, profileId)
        } else {
            return revokeConsentCategoryErxConsentCategoryProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - loadRemoteEuAccessCode

    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedProfileId: (UUID)?
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func loadRemoteEuAccessCode(profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedProfileId = profileId
        loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations.append(profileId)
        if let loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure = loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure(profileId)
        } else {
            return loadRemoteEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantEuAccessPermission

    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedArguments: (accessCode: EuAccessCode, profileId: UUID)?
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations: [(accessCode: EuAccessCode, profileId: UUID)] = []
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure: ((EuAccessCode, UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func grantEuAccessPermission(accessCode: EuAccessCode, profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedArguments = (accessCode: accessCode, profileId: profileId)
        grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations.append((accessCode: accessCode, profileId: profileId))
        if let grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure = grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorClosure(accessCode, profileId)
        } else {
            return grantEuAccessPermissionAccessCodeEuAccessCodeProfileIdUUIDAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - deleteEuAccessCode

    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedProfileId: (UUID)?
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(UUID)] = []
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure: ((UUID) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func deleteEuAccessCode(profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedProfileId = profileId
        deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append(profileId)
        if let deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure(profileId)
        } else {
            return deleteEuAccessCodeProfileIdUUIDAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }


}
