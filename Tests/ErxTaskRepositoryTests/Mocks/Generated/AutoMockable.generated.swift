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

    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, accessCode: String?)?
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, accessCode: String?)] = []
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, String?) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, accessCode: accessCode)
        fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, accessCode: accessCode))
        if let fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorClosure = fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorClosure {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorClosure(id, accessCode)
        } else {
            return fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllTasks

    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedReferenceDate: (String)?
    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(String)?] = []
    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listAllTasks(after referenceDate: String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedReferenceDate = referenceDate
        listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append(referenceDate)
        if let listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(referenceDate)
        } else {
            return listAllTasksAfterReferenceDateStringAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listTasksNextPage

    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedPreviousPage: (PagedContent<[ErxTask]>)?
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(PagedContent<[ErxTask]>)] = []
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedPreviousPage = previousPage
        listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append(previousPage)
        if let listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(previousPage)
        } else {
            return listTasksNextPageOfPreviousPagePagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listDetailedTasks

    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount = 0
    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCalled: Bool {
        return listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedTasks: (PagedContent<[ErxTask]>)?
    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations: [(PagedContent<[ErxTask]>)] = []
    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>!
    public var listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure: ((PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError>)?

    public func listDetailedTasks(for tasks: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorCallsCount += 1
        listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedTasks = tasks
        listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReceivedInvocations.append(tasks)
        if let listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure = listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure {
            return listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure(tasks)
        } else {
            return listDetailedTasksForTasksPagedContentErxTaskAnyPublisherPagedContentErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReceivedTasks: ([ErxTask])?
    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [([ErxTask])] = []
    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorClosure: (([ErxTask]) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReceivedTasks = tasks
        deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append(tasks)
        if let deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorClosure = deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorClosure(tasks)
        } else {
            return deleteTasksErxTaskAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - markEURedeemable

    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorCallsCount = 0
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorCalled: Bool {
        return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorCallsCount > 0
    }
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReceivedArguments: (id: ErxTask.ID, byPatientAuthorization: Bool)?
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations: [(id: ErxTask.ID, byPatientAuthorization: Bool)] = []
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReturnValue: AnyPublisher<ErxTask?, RemoteStoreError>!
    public var markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorClosure: ((ErxTask.ID, Bool) -> AnyPublisher<ErxTask?, RemoteStoreError>)?

    public func markEURedeemable(for id: ErxTask.ID, byPatientAuthorization: Bool) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorCallsCount += 1
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReceivedArguments = (id: id, byPatientAuthorization: byPatientAuthorization)
        markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReceivedInvocations.append((id: id, byPatientAuthorization: byPatientAuthorization))
        if let markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorClosure = markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorClosure {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorClosure(id, byPatientAuthorization)
        } else {
            return markEURedeemableForIdErxTaskIDByPatientAuthorizationBoolAnyPublisherErxTaskRemoteStoreErrorReturnValue
        }
    }

    //MARK: - redeem

    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount = 0
    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorCalled: Bool {
        return redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount > 0
    }
    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReceivedOrder: (ErxTaskOrder)?
    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations: [(ErxTaskOrder)] = []
    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue: AnyPublisher<ErxTaskOrder, RemoteStoreError>!
    public var redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorClosure: ((ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError>)?

    public func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorCallsCount += 1
        redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReceivedOrder = order
        redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReceivedInvocations.append(order)
        if let redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorClosure = redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorClosure {
            return redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorClosure(order)
        } else {
            return redeemOrderErxTaskOrderAnyPublisherErxTaskOrderRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllCommunications

    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount = 0
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorCalled: Bool {
        return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount > 0
    }
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments: (referenceDate: String?, profile: ErxTask.Communication.Profile)?
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, profile: ErxTask.Communication.Profile)] = []
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue: AnyPublisher<[ErxTask.Communication], RemoteStoreError>!
    public var listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure: ((String?, ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError>)?

    public func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorCallsCount += 1
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, profile: profile)
        listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, profile: profile))
        if let listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure = listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure(referenceDate, profile)
        } else {
            return listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchAuditEvent

    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount = 0
    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorCalled: Bool {
        return fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedId: (ErxAuditEvent.ID)?
    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations: [(ErxAuditEvent.ID)] = []
    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<ErxAuditEvent?, RemoteStoreError>!
    public var fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorClosure: ((ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError>)?

    public func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorCallsCount += 1
        fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedId = id
        fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReceivedInvocations.append(id)
        if let fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorClosure = fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorClosure {
            return fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorClosure(id)
        } else {
            return fetchAuditEventByIdErxAuditEventIDAnyPublisherErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllAuditEvents

    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (referenceDate: String?, locale: String?)?
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(referenceDate: String?, locale: String?)] = []
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((String?, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAllAuditEvents(after referenceDate: String?, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (referenceDate: referenceDate, locale: locale)
        listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((referenceDate: referenceDate, locale: locale))
        if let listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(referenceDate, locale)
        } else {
            return listAllAuditEventsAfterReferenceDateStringForLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAuditEventsNextPage

    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount = 0
    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCalled: Bool {
        return listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount > 0
    }
    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments: (url: URL, locale: String?)?
    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations: [(url: URL, locale: String?)] = []
    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue: AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>!
    public var listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure: ((URL, String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError>)?

    public func listAuditEventsNextPage(from url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorCallsCount += 1
        listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedArguments = (url: url, locale: locale)
        listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReceivedInvocations.append((url: url, locale: locale))
        if let listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure = listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure {
            return listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure(url, locale)
        } else {
            return listAuditEventsNextPageFromUrlURLLocaleStringAnyPublisherPagedContentErxAuditEventRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listMedicationDispenses

    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount = 0
    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCalled: Bool {
        return listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount > 0
    }
    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedId: (ErxTask.ID)?
    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations: [(ErxTask.ID)] = []
    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue: AnyPublisher<[ErxMedicationDispense], RemoteStoreError>!
    public var listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure: ((ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError>)?

    public func listMedicationDispenses(for id: ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorCallsCount += 1
        listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedId = id
        listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReceivedInvocations.append(id)
        if let listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure = listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure {
            return listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure(id)
        } else {
            return listMedicationDispensesForIdErxTaskIDAnyPublisherErxMedicationDispenseRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchChargeItem

    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedId: (ErxChargeItem.ID)?
    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(ErxChargeItem.ID)] = []
    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<ErxChargeItem?, RemoteStoreError>!
    public var fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError>)?

    public func fetchChargeItem(by id: ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedId = id
        fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append(id)
        if let fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorClosure = fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorClosure(id)
        } else {
            return fetchChargeItemByIdErxChargeItemIDAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - listAllChargeItems

    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorCallsCount = 0
    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorCalled: Bool {
        return listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorCallsCount > 0
    }
    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReceivedReferenceDate: (String)?
    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations: [(String)?] = []
    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReturnValue: AnyPublisher<[ErxChargeItem], RemoteStoreError>!
    public var listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorClosure: ((String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError>)?

    public func listAllChargeItems(after referenceDate: String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorCallsCount += 1
        listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReceivedReferenceDate = referenceDate
        listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReceivedInvocations.append(referenceDate)
        if let listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorClosure = listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorClosure {
            return listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorClosure(referenceDate)
        } else {
            return listAllChargeItemsAfterReferenceDateStringAnyPublisherErxChargeItemRemoteStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReceivedChargeItems: ([ErxChargeItem])?
    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [([ErxChargeItem])] = []
    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorClosure: (([ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError> {
        deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReceivedChargeItems = chargeItems
        deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append(chargeItems)
        if let deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorClosure = deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorClosure(chargeItems)
        } else {
            return deleteChargeItemsErxChargeItemAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - fetchConsents

    public var fetchConsentsAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var fetchConsentsAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return fetchConsentsAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var fetchConsentsAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<[ErxConsent], RemoteStoreError>!
    public var fetchConsentsAnyPublisherErxConsentRemoteStoreErrorClosure: (() -> AnyPublisher<[ErxConsent], RemoteStoreError>)?

    public func fetchConsents() -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        fetchConsentsAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        if let fetchConsentsAnyPublisherErxConsentRemoteStoreErrorClosure = fetchConsentsAnyPublisherErxConsentRemoteStoreErrorClosure {
            return fetchConsentsAnyPublisherErxConsentRemoteStoreErrorClosure()
        } else {
            return fetchConsentsAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantConsent

    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorCallsCount = 0
    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorCalled: Bool {
        return grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorCallsCount > 0
    }
    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReceivedConsent: (ErxConsent)?
    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations: [(ErxConsent)] = []
    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReturnValue: AnyPublisher<ErxConsent?, RemoteStoreError>!
    public var grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorClosure: ((ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError>)?

    public func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorCallsCount += 1
        grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReceivedConsent = consent
        grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReceivedInvocations.append(consent)
        if let grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorClosure = grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorClosure {
            return grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorClosure(consent)
        } else {
            return grantConsentConsentErxConsentAnyPublisherErxConsentRemoteStoreErrorReturnValue
        }
    }

    //MARK: - revokeConsent

    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReceivedCategory: (ErxConsent.Category)?
    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReceivedInvocations: [(ErxConsent.Category)] = []
    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorClosure: ((ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError>)?

    public func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError> {
        revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReceivedCategory = category
        revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReceivedInvocations.append(category)
        if let revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorClosure = revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorClosure {
            return revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorClosure(category)
        } else {
            return revokeConsentCategoryErxConsentCategoryAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }

    //MARK: - loadRemoteEuAccessCode

    public var loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure: (() -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func loadRemoteEuAccessCode() -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        if let loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure = loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure()
        } else {
            return loadRemoteEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - grantEuAccessPermission

    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount = 0
    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCalled: Bool {
        return grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount > 0
    }
    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReceivedAccessCode: (EuAccessCode)?
    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations: [(EuAccessCode)] = []
    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue: AnyPublisher<EuAccessCode?, RemoteStoreError>!
    public var grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure: ((EuAccessCode) -> AnyPublisher<EuAccessCode?, RemoteStoreError>)?

    public func grantEuAccessPermission(accessCode: EuAccessCode) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorCallsCount += 1
        grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReceivedAccessCode = accessCode
        grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReceivedInvocations.append(accessCode)
        if let grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure = grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure {
            return grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorClosure(accessCode)
        } else {
            return grantEuAccessPermissionAccessCodeEuAccessCodeAnyPublisherEuAccessCodeRemoteStoreErrorReturnValue
        }
    }

    //MARK: - deleteEuAccessCode

    public var deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorCallsCount = 0
    public var deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorCalled: Bool {
        return deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorCallsCount > 0
    }
    public var deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorReturnValue: AnyPublisher<Bool, RemoteStoreError>!
    public var deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorClosure: (() -> AnyPublisher<Bool, RemoteStoreError>)?

    public func deleteEuAccessCode() -> AnyPublisher<Bool, RemoteStoreError> {
        deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorCallsCount += 1
        if let deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorClosure = deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorClosure {
            return deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorClosure()
        } else {
            return deleteEuAccessCodeAnyPublisherBoolRemoteStoreErrorReturnValue
        }
    }


}
