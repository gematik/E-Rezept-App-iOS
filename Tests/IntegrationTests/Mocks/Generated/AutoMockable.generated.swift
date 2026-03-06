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
import OpenSSL
import TrustStore

@testable import Pharmacy
























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
public class PharmacyLocalDataStoreMock: PharmacyLocalDataStore {

    public init() {}



    //MARK: - fetchPharmacy

    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedTelematikId: (String)?
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(String)] = []
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<PharmacyLocation?, LocalStoreError>!
    public var fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((String) -> AnyPublisher<PharmacyLocation?, LocalStoreError>)?

    public func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, LocalStoreError> {
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedTelematikId = telematikId
        fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append(telematikId)
        if let fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure = fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorClosure(telematikId)
        } else {
            return fetchPharmacyByTelematikIdStringAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }

    //MARK: - listPharmacies

    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedCount: (Int)?
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(Int)?] = []
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<[PharmacyLocation], LocalStoreError>!
    public var listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError>)?

    public func listPharmacies(count: Int?) -> AnyPublisher<[PharmacyLocation], LocalStoreError> {
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedCount = count
        listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append(count)
        if let listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure = listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorClosure(count)
        } else {
            return listPharmaciesCountIntAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies: ([PharmacyLocation])?
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([PharmacyLocation])] = []
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount += 1
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies = pharmacies
        savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(pharmacies)
        if let savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure = savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure {
            return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure(pharmacies)
        } else {
            return savePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies: ([PharmacyLocation])?
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([PharmacyLocation])] = []
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure: (([PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(pharmacies: [PharmacyLocation]) -> AnyPublisher<Bool, LocalStoreError> {
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedPharmacies = pharmacies
        deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(pharmacies)
        if let deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure = deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure {
            return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorClosure(pharmacies)
        } else {
            return deletePharmaciesPharmacyLocationAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount = 0
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCalled: Bool {
        return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount > 0
    }
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedArguments: (telematikId: String, mutating: (inout PharmacyLocation) -> Void)?
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations: [(telematikId: String, mutating: (inout PharmacyLocation) -> Void)] = []
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReturnValue: AnyPublisher<PharmacyLocation, LocalStoreError>!
    public var updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure: ((String, @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError>)?

    public func update(telematikId: String, mutating: @escaping (inout PharmacyLocation) -> Void) -> AnyPublisher<PharmacyLocation, LocalStoreError> {
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorCallsCount += 1
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedArguments = (telematikId: telematikId, mutating: mutating)
        updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReceivedInvocations.append((telematikId: telematikId, mutating: mutating))
        if let updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure = updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure {
            return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorClosure(telematikId, mutating)
        } else {
            return updateTelematikIdStringMutatingEscapingInoutPharmacyLocationVoidAnyPublisherPharmacyLocationLocalStoreErrorReturnValue
        }
    }


}
public class ProfileDataStoreMock: ProfileDataStore {

    public init() {}



    //MARK: - fetchProfile

    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount = 0
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCalled: Bool {
        return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount > 0
    }
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedIdentifier: (Profile.ID)?
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedInvocations: [(Profile.ID)] = []
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue: AnyPublisher<Profile?, LocalStoreError>!
    public var fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure: ((Profile.ID) -> AnyPublisher<Profile?, LocalStoreError>)?

    public func fetchProfile(by identifier: Profile.ID) -> AnyPublisher<Profile?, LocalStoreError> {
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorCallsCount += 1
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedIdentifier = identifier
        fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReceivedInvocations.append(identifier)
        if let fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure = fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure {
            return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorClosure(identifier)
        } else {
            return fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue
        }
    }

    //MARK: - listAllProfiles

    public var listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount = 0
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorCalled: Bool {
        return listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount > 0
    }
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue: AnyPublisher<[Profile], LocalStoreError>!
    public var listAllProfilesAnyPublisherProfileLocalStoreErrorClosure: (() -> AnyPublisher<[Profile], LocalStoreError>)?

    public func listAllProfiles() -> AnyPublisher<[Profile], LocalStoreError> {
        listAllProfilesAnyPublisherProfileLocalStoreErrorCallsCount += 1
        if let listAllProfilesAnyPublisherProfileLocalStoreErrorClosure = listAllProfilesAnyPublisherProfileLocalStoreErrorClosure {
            return listAllProfilesAnyPublisherProfileLocalStoreErrorClosure()
        } else {
            return listAllProfilesAnyPublisherProfileLocalStoreErrorReturnValue
        }
    }

    //MARK: - save

    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles: ([Profile])?
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([Profile])] = []
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func save(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount += 1
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles = profiles
        saveProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(profiles)
        if let saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure = saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure {
            return saveProfilesProfileAnyPublisherBoolLocalStoreErrorClosure(profiles)
        } else {
            return saveProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - delete

    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles: ([Profile])?
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations: [([Profile])] = []
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure: (([Profile]) -> AnyPublisher<Bool, LocalStoreError>)?

    public func delete(profiles: [Profile]) -> AnyPublisher<Bool, LocalStoreError> {
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorCallsCount += 1
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedProfiles = profiles
        deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReceivedInvocations.append(profiles)
        if let deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure = deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure {
            return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorClosure(profiles)
        } else {
            return deleteProfilesProfileAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }

    //MARK: - update

    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount = 0
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCalled: Bool {
        return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount > 0
    }
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedArguments: (profileId: UUID, mutating: (inout Profile) -> Void)?
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedInvocations: [(profileId: UUID, mutating: (inout Profile) -> Void)] = []
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue: AnyPublisher<Bool, LocalStoreError>!
    public var updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure: ((UUID, @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError>)?

    public func update(profileId: UUID, mutating: @escaping (inout Profile) -> Void) -> AnyPublisher<Bool, LocalStoreError> {
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorCallsCount += 1
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedArguments = (profileId: profileId, mutating: mutating)
        updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReceivedInvocations.append((profileId: profileId, mutating: mutating))
        if let updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure = updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorClosure(profileId, mutating)
        } else {
            return updateProfileIdUUIDMutatingEscapingInoutProfileVoidAnyPublisherBoolLocalStoreErrorReturnValue
        }
    }


}
public class TrustStoreSessionMock: TrustStoreSession {

    public init() {}



    //MARK: - vauCertificate

    public var vauCertificateX509ThrowableError: (any Error)?
    public var vauCertificateX509CallsCount = 0
    public var vauCertificateX509Called: Bool {
        return vauCertificateX509CallsCount > 0
    }
    public var vauCertificateX509ReturnValue: X509!
    public var vauCertificateX509Closure: (() async throws -> X509)?

    public func vauCertificate() async throws -> X509 {
        vauCertificateX509CallsCount += 1
        if let error = vauCertificateX509ThrowableError {
            throw error
        }
        if let vauCertificateX509Closure = vauCertificateX509Closure {
            return try await vauCertificateX509Closure()
        } else {
            return vauCertificateX509ReturnValue
        }
    }

    //MARK: - validate

    public var validateEeCertificateX509BoolThrowableError: (any Error)?
    public var validateEeCertificateX509BoolCallsCount = 0
    public var validateEeCertificateX509BoolCalled: Bool {
        return validateEeCertificateX509BoolCallsCount > 0
    }
    public var validateEeCertificateX509BoolReceivedEeCertificate: (X509)?
    public var validateEeCertificateX509BoolReceivedInvocations: [(X509)] = []
    public var validateEeCertificateX509BoolReturnValue: Bool!
    public var validateEeCertificateX509BoolClosure: ((X509) async throws -> Bool)?

    public func validate(eeCertificate: X509) async throws -> Bool {
        validateEeCertificateX509BoolCallsCount += 1
        validateEeCertificateX509BoolReceivedEeCertificate = eeCertificate
        validateEeCertificateX509BoolReceivedInvocations.append(eeCertificate)
        if let error = validateEeCertificateX509BoolThrowableError {
            throw error
        }
        if let validateEeCertificateX509BoolClosure = validateEeCertificateX509BoolClosure {
            return try await validateEeCertificateX509BoolClosure(eeCertificate)
        } else {
            return validateEeCertificateX509BoolReturnValue
        }
    }

    //MARK: - reset

    public var resetVoidCallsCount = 0
    public var resetVoidCalled: Bool {
        return resetVoidCallsCount > 0
    }
    public var resetVoidClosure: (() -> Void)?

    public func reset() {
        resetVoidCallsCount += 1
        resetVoidClosure?()
    }


}
