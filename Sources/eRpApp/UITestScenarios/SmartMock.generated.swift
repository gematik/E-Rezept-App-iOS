// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
/// Use sourcery to update this file.

#if DEBUG

import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import HTTPClient
import IdentifiedCollections
import IDP
import IDPLive
import OpenSSL
import Pharmacy

// MARK: - SmartMockErxLocalDataStore -

class SmartMockErxLocalDataStore: ErxLocalDataStore, SmartMock {
    private var wrapped: ErxLocalDataStore
    private var isRecording: Bool

    init(wrapped: ErxLocalDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        fetchTaskByAccessCodeRecordings = mocks?.fetchTaskByAccessCodeRecordings ?? .delegate
        listAllTasksOfRecordings = mocks?.listAllTasksOfRecordings ?? .delegate
        fetchLatestLastModifiedForErxTasksOfRecordings = mocks?.fetchLatestLastModifiedForErxTasksOfRecordings ?? .delegate
        saveTasksInUpdateProfileLastAuthenticatedRecordings = mocks?.saveTasksInUpdateProfileLastAuthenticatedRecordings ?? .delegate
        deleteTasksInRecordings = mocks?.deleteTasksInRecordings ?? .delegate
        listAllTasksWithoutProfileRecordings = mocks?.listAllTasksWithoutProfileRecordings ?? .delegate
        listAllCommunicationsForRecordings = mocks?.listAllCommunicationsForRecordings ?? .delegate
        fetchLatestTimestampForCommunicationsOfRecordings = mocks?.fetchLatestTimestampForCommunicationsOfRecordings ?? .delegate
        saveCommunicationsOfRecordings = mocks?.saveCommunicationsOfRecordings ?? .delegate
        allUnreadCommunicationsOfForRecordings = mocks?.allUnreadCommunicationsOfForRecordings ?? .delegate
        listAllMedicationDispensesOfRecordings = mocks?.listAllMedicationDispensesOfRecordings ?? .delegate
        saveMedicationDispensesRecordings = mocks?.saveMedicationDispensesRecordings ?? .delegate
        fetchChargeItemOfByRecordings = mocks?.fetchChargeItemOfByRecordings ?? .delegate
        fetchLatestTimestampForChargeItemsOfRecordings = mocks?.fetchLatestTimestampForChargeItemsOfRecordings ?? .delegate
        listAllChargeItemsOfRecordings = mocks?.listAllChargeItemsOfRecordings ?? .delegate
        saveChargeItemsOfRecordings = mocks?.saveChargeItemsOfRecordings ?? .delegate
        deleteOfChargeItemsRecordings = mocks?.deleteOfChargeItemsRecordings ?? .delegate
        updateDiGaInfoRecordings = mocks?.updateDiGaInfoRecordings ?? .delegate
        saveEuCommunicationsProfileIdRecordings = mocks?.saveEuCommunicationsProfileIdRecordings ?? .delegate
        listAllEuCommunicationCountryCodeProfileIdRecordings = mocks?.listAllEuCommunicationCountryCodeProfileIdRecordings ?? .delegate
        deleteEuCommunicationsProfileIdRecordings = mocks?.deleteEuCommunicationsProfileIdRecordings ?? .delegate
        loadLatestActiveEuCommunicationProfileIdRecordings = mocks?.loadLatestActiveEuCommunicationProfileIdRecordings ?? .delegate
    }

    var fetchTaskByAccessCodeRecordings: MockAnswer<ErxTask?>

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchTask(
                    by: id,
                    accessCode: accessCode
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchTaskByAccessCodeRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchTaskByAccessCodeRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchTask(
                    by: id,
                    accessCode: accessCode
            )
        }
    }

    var listAllTasksOfRecordings: MockAnswer<[ErxTask]>

    func listAllTasks(of profileId: UUID?) -> AnyPublisher<[ErxTask], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllTasks(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllTasksOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllTasksOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllTasks(
                    of: profileId
            )
        }
    }

    var fetchLatestLastModifiedForErxTasksOfRecordings: MockAnswer<String?>

    func fetchLatestLastModifiedForErxTasks(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestLastModifiedForErxTasks(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestLastModifiedForErxTasksOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestLastModifiedForErxTasksOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestLastModifiedForErxTasks(
                    of: profileId
            )
        }
    }

    var saveTasksInUpdateProfileLastAuthenticatedRecordings: MockAnswer<Bool>

    func save(tasks: [ErxTask], in profileId: UUID?, updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    tasks: tasks,
                    in: profileId,
                    updateProfileLastAuthenticated: updateProfileLastAuthenticated
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveTasksInUpdateProfileLastAuthenticatedRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveTasksInUpdateProfileLastAuthenticatedRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    tasks: tasks,
                    in: profileId,
                    updateProfileLastAuthenticated: updateProfileLastAuthenticated
            )
        }
    }

    var deleteTasksInRecordings: MockAnswer<Bool>

    func delete(tasks: [ErxTask], in profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    tasks: tasks,
                    in: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteTasksInRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteTasksInRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    tasks: tasks,
                    in: profileId
            )
        }
    }

    var listAllTasksWithoutProfileRecordings: MockAnswer<[ErxTask]>

    func listAllTasksWithoutProfile() -> AnyPublisher<[ErxTask], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllTasksWithoutProfile(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllTasksWithoutProfileRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllTasksWithoutProfileRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllTasksWithoutProfile(
            )
        }
    }

    var listAllCommunicationsForRecordings: MockAnswer<[ErxTask.Communication]>

    func listAllCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllCommunications(
                    for: profile
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllCommunicationsForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllCommunicationsForRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllCommunications(
                    for: profile
            )
        }
    }

    var fetchLatestTimestampForCommunicationsOfRecordings: MockAnswer<String?>

    func fetchLatestTimestampForCommunications(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestTimestampForCommunications(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestTimestampForCommunicationsOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestTimestampForCommunicationsOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestTimestampForCommunications(
                    of: profileId
            )
        }
    }

    var saveCommunicationsOfRecordings: MockAnswer<Bool>

    func save(communications: [ErxTask.Communication], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    communications: communications,
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveCommunicationsOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveCommunicationsOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    communications: communications,
                    of: profileId
            )
        }
    }

    var allUnreadCommunicationsOfForRecordings: MockAnswer<[ErxTask.Communication]>

    func allUnreadCommunications(of profileId: UUID?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.allUnreadCommunications(
                    of: profileId,
                    for: profile
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.allUnreadCommunicationsOfForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = allUnreadCommunicationsOfForRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.allUnreadCommunications(
                    of: profileId,
                    for: profile
            )
        }
    }

    var listAllMedicationDispensesOfRecordings: MockAnswer<[ErxMedicationDispense]>

    func listAllMedicationDispenses(of profileId: UUID?) -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllMedicationDispenses(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllMedicationDispensesOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllMedicationDispensesOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllMedicationDispenses(
                    of: profileId
            )
        }
    }

    var saveMedicationDispensesRecordings: MockAnswer<Bool>

    func save(medicationDispenses: [ErxMedicationDispense]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    medicationDispenses: medicationDispenses
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveMedicationDispensesRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveMedicationDispensesRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    medicationDispenses: medicationDispenses
            )
        }
    }

    var fetchChargeItemOfByRecordings: MockAnswer<ErxSparseChargeItem?>

    func fetchChargeItem(of profileId: UUID?, by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchChargeItem(
                    of: profileId,
                    by: chargeItemID
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchChargeItemOfByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchChargeItemOfByRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchChargeItem(
                    of: profileId,
                    by: chargeItemID
            )
        }
    }

    var fetchLatestTimestampForChargeItemsOfRecordings: MockAnswer<String?>

    func fetchLatestTimestampForChargeItems(of profileId: UUID?) -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestTimestampForChargeItems(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestTimestampForChargeItemsOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestTimestampForChargeItemsOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestTimestampForChargeItems(
                    of: profileId
            )
        }
    }

    var listAllChargeItemsOfRecordings: MockAnswer<[ErxSparseChargeItem]>

    func listAllChargeItems(of profileId: UUID?) -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllChargeItems(
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllChargeItemsOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllChargeItemsOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllChargeItems(
                    of: profileId
            )
        }
    }

    var saveChargeItemsOfRecordings: MockAnswer<Bool>

    func save(chargeItems: [ErxSparseChargeItem], of profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    chargeItems: chargeItems,
                    of: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveChargeItemsOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveChargeItemsOfRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    chargeItems: chargeItems,
                    of: profileId
            )
        }
    }

    var deleteOfChargeItemsRecordings: MockAnswer<Bool>

    func delete(of profileId: UUID?, chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    of: profileId,
                    chargeItems: chargeItems
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteOfChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteOfChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    of: profileId,
                    chargeItems: chargeItems
            )
        }
    }

    var updateDiGaInfoRecordings: MockAnswer<Bool>

    func update(diGaInfo: DiGaInfo) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.update(
                    diGaInfo: diGaInfo
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.updateDiGaInfoRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = updateDiGaInfoRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.update(
                    diGaInfo: diGaInfo
            )
        }
    }

    var saveEuCommunicationsProfileIdRecordings: MockAnswer<Bool>

    func save(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    euCommunications: euCommunications,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveEuCommunicationsProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveEuCommunicationsProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    euCommunications: euCommunications,
                    profileId: profileId
            )
        }
    }

    var listAllEuCommunicationCountryCodeProfileIdRecordings: MockAnswer<[EuCommunication]>

    func listAllEuCommunication(countryCode: String?, profileId: UUID?) -> AnyPublisher<[EuCommunication], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllEuCommunication(
                    countryCode: countryCode,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllEuCommunicationCountryCodeProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllEuCommunicationCountryCodeProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllEuCommunication(
                    countryCode: countryCode,
                    profileId: profileId
            )
        }
    }

    var deleteEuCommunicationsProfileIdRecordings: MockAnswer<Bool>

    func delete(euCommunications: [EuCommunication], profileId: UUID?) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    euCommunications: euCommunications,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteEuCommunicationsProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteEuCommunicationsProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    euCommunications: euCommunications,
                    profileId: profileId
            )
        }
    }

    var loadLatestActiveEuCommunicationProfileIdRecordings: MockAnswer<EuCommunication?>

    func loadLatestActiveEuCommunication(profileId: UUID?) -> AnyPublisher<EuCommunication?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.loadLatestActiveEuCommunication(
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.loadLatestActiveEuCommunicationProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = loadLatestActiveEuCommunicationProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.loadLatestActiveEuCommunication(
                    profileId: profileId
            )
        }
    }

    struct Mocks: VerifiableMock {
        var fetchTaskByAccessCodeRecordings: MockAnswer<ErxTask?>? = .delegate
        var listAllTasksOfRecordings: MockAnswer<[ErxTask]>? = .delegate
        var fetchLatestLastModifiedForErxTasksOfRecordings: MockAnswer<String?>? = .delegate
        var saveTasksInUpdateProfileLastAuthenticatedRecordings: MockAnswer<Bool>? = .delegate
        var deleteTasksInRecordings: MockAnswer<Bool>? = .delegate
        var listAllTasksWithoutProfileRecordings: MockAnswer<[ErxTask]>? = .delegate
        var listAllCommunicationsForRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var fetchLatestTimestampForCommunicationsOfRecordings: MockAnswer<String?>? = .delegate
        var saveCommunicationsOfRecordings: MockAnswer<Bool>? = .delegate
        var allUnreadCommunicationsOfForRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var listAllMedicationDispensesOfRecordings: MockAnswer<[ErxMedicationDispense]>? = .delegate
        var saveMedicationDispensesRecordings: MockAnswer<Bool>? = .delegate
        var fetchChargeItemOfByRecordings: MockAnswer<ErxSparseChargeItem?>? = .delegate
        var fetchLatestTimestampForChargeItemsOfRecordings: MockAnswer<String?>? = .delegate
        var listAllChargeItemsOfRecordings: MockAnswer<[ErxSparseChargeItem]>? = .delegate
        var saveChargeItemsOfRecordings: MockAnswer<Bool>? = .delegate
        var deleteOfChargeItemsRecordings: MockAnswer<Bool>? = .delegate
        var updateDiGaInfoRecordings: MockAnswer<Bool>? = .delegate
        var saveEuCommunicationsProfileIdRecordings: MockAnswer<Bool>? = .delegate
        var listAllEuCommunicationCountryCodeProfileIdRecordings: MockAnswer<[EuCommunication]>? = .delegate
        var deleteEuCommunicationsProfileIdRecordings: MockAnswer<Bool>? = .delegate
        var loadLatestActiveEuCommunicationProfileIdRecordings: MockAnswer<EuCommunication?>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "fetchTaskByAccessCodeRecordings",
                "listAllTasksOfRecordings",
                "fetchLatestLastModifiedForErxTasksOfRecordings",
                "saveTasksInUpdateProfileLastAuthenticatedRecordings",
                "deleteTasksInRecordings",
                "listAllTasksWithoutProfileRecordings",
                "listAllCommunicationsForRecordings",
                "fetchLatestTimestampForCommunicationsOfRecordings",
                "saveCommunicationsOfRecordings",
                "allUnreadCommunicationsOfForRecordings",
                "listAllMedicationDispensesOfRecordings",
                "saveMedicationDispensesRecordings",
                "fetchChargeItemOfByRecordings",
                "fetchLatestTimestampForChargeItemsOfRecordings",
                "listAllChargeItemsOfRecordings",
                "saveChargeItemsOfRecordings",
                "deleteOfChargeItemsRecordings",
                "updateDiGaInfoRecordings",
                "saveEuCommunicationsProfileIdRecordings",
                "listAllEuCommunicationCountryCodeProfileIdRecordings",
                "deleteEuCommunicationsProfileIdRecordings",
                "loadLatestActiveEuCommunicationProfileIdRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "ErxLocalDataStore",
            Mocks(
                fetchTaskByAccessCodeRecordings: fetchTaskByAccessCodeRecordings,
                listAllTasksOfRecordings: listAllTasksOfRecordings,
                fetchLatestLastModifiedForErxTasksOfRecordings: fetchLatestLastModifiedForErxTasksOfRecordings,
                saveTasksInUpdateProfileLastAuthenticatedRecordings: saveTasksInUpdateProfileLastAuthenticatedRecordings,
                deleteTasksInRecordings: deleteTasksInRecordings,
                listAllTasksWithoutProfileRecordings: listAllTasksWithoutProfileRecordings,
                listAllCommunicationsForRecordings: listAllCommunicationsForRecordings,
                fetchLatestTimestampForCommunicationsOfRecordings: fetchLatestTimestampForCommunicationsOfRecordings,
                saveCommunicationsOfRecordings: saveCommunicationsOfRecordings,
                allUnreadCommunicationsOfForRecordings: allUnreadCommunicationsOfForRecordings,
                listAllMedicationDispensesOfRecordings: listAllMedicationDispensesOfRecordings,
                saveMedicationDispensesRecordings: saveMedicationDispensesRecordings,
                fetchChargeItemOfByRecordings: fetchChargeItemOfByRecordings,
                fetchLatestTimestampForChargeItemsOfRecordings: fetchLatestTimestampForChargeItemsOfRecordings,
                listAllChargeItemsOfRecordings: listAllChargeItemsOfRecordings,
                saveChargeItemsOfRecordings: saveChargeItemsOfRecordings,
                deleteOfChargeItemsRecordings: deleteOfChargeItemsRecordings,
                updateDiGaInfoRecordings: updateDiGaInfoRecordings,
                saveEuCommunicationsProfileIdRecordings: saveEuCommunicationsProfileIdRecordings,
                listAllEuCommunicationCountryCodeProfileIdRecordings: listAllEuCommunicationCountryCodeProfileIdRecordings,
                deleteEuCommunicationsProfileIdRecordings: deleteEuCommunicationsProfileIdRecordings,
                loadLatestActiveEuCommunicationProfileIdRecordings: loadLatestActiveEuCommunicationProfileIdRecordings
            )
        )
    }
}


// MARK: - SmartMockErxRemoteDataStore -

class SmartMockErxRemoteDataStore: ErxRemoteDataStore, SmartMock {
    private var wrapped: ErxRemoteDataStore
    private var isRecording: Bool

    init(wrapped: ErxRemoteDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        fetchTaskByAccessCodeProfileIdRecordings = mocks?.fetchTaskByAccessCodeProfileIdRecordings ?? .delegate
        listAllTasksAfterProfileIdRecordings = mocks?.listAllTasksAfterProfileIdRecordings ?? .delegate
        listTasksNextPageOfProfileIdRecordings = mocks?.listTasksNextPageOfProfileIdRecordings ?? .delegate
        listDetailedTasksForProfileIdRecordings = mocks?.listDetailedTasksForProfileIdRecordings ?? .delegate
        deleteTasksProfileIdRecordings = mocks?.deleteTasksProfileIdRecordings ?? .delegate
        markEURedeemableForByPatientAuthorizationProfileIdRecordings = mocks?.markEURedeemableForByPatientAuthorizationProfileIdRecordings ?? .delegate
        redeemOrderProfileIdRecordings = mocks?.redeemOrderProfileIdRecordings ?? .delegate
        listAllCommunicationsAfterForProfileIdRecordings = mocks?.listAllCommunicationsAfterForProfileIdRecordings ?? .delegate
        fetchAuditEventByProfileIdRecordings = mocks?.fetchAuditEventByProfileIdRecordings ?? .delegate
        listAllAuditEventsAfterForProfileIdRecordings = mocks?.listAllAuditEventsAfterForProfileIdRecordings ?? .delegate
        listAuditEventsNextPageFromLocaleProfileIdRecordings = mocks?.listAuditEventsNextPageFromLocaleProfileIdRecordings ?? .delegate
        listMedicationDispensesForProfileIdRecordings = mocks?.listMedicationDispensesForProfileIdRecordings ?? .delegate
        fetchChargeItemByProfileIdRecordings = mocks?.fetchChargeItemByProfileIdRecordings ?? .delegate
        listAllChargeItemsAfterProfileIdRecordings = mocks?.listAllChargeItemsAfterProfileIdRecordings ?? .delegate
        deleteChargeItemsProfileIdRecordings = mocks?.deleteChargeItemsProfileIdRecordings ?? .delegate
        fetchConsentsProfileIdRecordings = mocks?.fetchConsentsProfileIdRecordings ?? .delegate
        grantConsentProfileIdRecordings = mocks?.grantConsentProfileIdRecordings ?? .delegate
        revokeConsentProfileIdRecordings = mocks?.revokeConsentProfileIdRecordings ?? .delegate
        loadRemoteEuAccessCodeProfileIdRecordings = mocks?.loadRemoteEuAccessCodeProfileIdRecordings ?? .delegate
        grantEuAccessPermissionAccessCodeProfileIdRecordings = mocks?.grantEuAccessPermissionAccessCodeProfileIdRecordings ?? .delegate
        deleteEuAccessCodeProfileIdRecordings = mocks?.deleteEuAccessCodeProfileIdRecordings ?? .delegate
    }

    var fetchTaskByAccessCodeProfileIdRecordings: MockAnswer<ErxTask?>

    func fetchTask(by id: ErxTask.ID, accessCode: String?, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchTask(
                    by: id,
                    accessCode: accessCode,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchTaskByAccessCodeProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchTaskByAccessCodeProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchTask(
                    by: id,
                    accessCode: accessCode,
                    profileId: profileId
            )
        }
    }

    var listAllTasksAfterProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listAllTasks(after referenceDate: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllTasks(
                    after: referenceDate,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllTasksAfterProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllTasksAfterProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllTasks(
                    after: referenceDate,
                    profileId: profileId
            )
        }
    }

    var listTasksNextPageOfProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listTasksNextPage(
                    of: previousPage,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listTasksNextPageOfProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listTasksNextPageOfProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listTasksNextPage(
                    of: previousPage,
                    profileId: profileId
            )
        }
    }

    var listDetailedTasksForProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listDetailedTasks(for tasks: PagedContent<[ErxTask]>, profileId: UUID) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listDetailedTasks(
                    for: tasks,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listDetailedTasksForProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listDetailedTasksForProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listDetailedTasks(
                    for: tasks,
                    profileId: profileId
            )
        }
    }

    var deleteTasksProfileIdRecordings: MockAnswer<Bool>

    func delete(tasks: [ErxTask], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    tasks: tasks,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteTasksProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteTasksProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    tasks: tasks,
                    profileId: profileId
            )
        }
    }

    var markEURedeemableForByPatientAuthorizationProfileIdRecordings: MockAnswer<ErxTask?>

    func markEURedeemable(for id: ErxTask.ID, byPatientAuthorization: Bool, profileId: UUID) -> AnyPublisher<ErxTask?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.markEURedeemable(
                    for: id,
                    byPatientAuthorization: byPatientAuthorization,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.markEURedeemableForByPatientAuthorizationProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = markEURedeemableForByPatientAuthorizationProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.markEURedeemable(
                    for: id,
                    byPatientAuthorization: byPatientAuthorization,
                    profileId: profileId
            )
        }
    }

    var redeemOrderProfileIdRecordings: MockAnswer<ErxTaskOrder>

    func redeem(order: ErxTaskOrder, profileId: UUID) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.redeem(
                    order: order,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.redeemOrderProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = redeemOrderProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.redeem(
                    order: order,
                    profileId: profileId
            )
        }
    }

    var listAllCommunicationsAfterForProfileIdRecordings: MockAnswer<[ErxTask.Communication]>

    func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile, profileId: UUID) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllCommunications(
                    after: referenceDate,
                    for: profile,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllCommunicationsAfterForProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllCommunicationsAfterForProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllCommunications(
                    after: referenceDate,
                    for: profile,
                    profileId: profileId
            )
        }
    }

    var fetchAuditEventByProfileIdRecordings: MockAnswer<ErxAuditEvent?>

    func fetchAuditEvent(by id: ErxAuditEvent.ID, profileId: UUID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchAuditEvent(
                    by: id,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchAuditEventByProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchAuditEventByProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchAuditEvent(
                    by: id,
                    profileId: profileId
            )
        }
    }

    var listAllAuditEventsAfterForProfileIdRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>

    func listAllAuditEvents(after referenceDate: String?, for locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllAuditEvents(
                    after: referenceDate,
                    for: locale,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllAuditEventsAfterForProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllAuditEventsAfterForProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllAuditEvents(
                    after: referenceDate,
                    for: locale,
                    profileId: profileId
            )
        }
    }

    var listAuditEventsNextPageFromLocaleProfileIdRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>

    func listAuditEventsNextPage(from url: URL, locale: String?, profileId: UUID) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAuditEventsNextPage(
                    from: url,
                    locale: locale,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAuditEventsNextPageFromLocaleProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAuditEventsNextPageFromLocaleProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAuditEventsNextPage(
                    from: url,
                    locale: locale,
                    profileId: profileId
            )
        }
    }

    var listMedicationDispensesForProfileIdRecordings: MockAnswer<[ErxMedicationDispense]>

    func listMedicationDispenses(for id: ErxTask.ID, profileId: UUID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listMedicationDispenses(
                    for: id,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listMedicationDispensesForProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listMedicationDispensesForProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listMedicationDispenses(
                    for: id,
                    profileId: profileId
            )
        }
    }

    var fetchChargeItemByProfileIdRecordings: MockAnswer<ErxChargeItem?>

    func fetchChargeItem(by id: ErxChargeItem.ID, profileId: UUID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchChargeItem(
                    by: id,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchChargeItemByProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchChargeItemByProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchChargeItem(
                    by: id,
                    profileId: profileId
            )
        }
    }

    var listAllChargeItemsAfterProfileIdRecordings: MockAnswer<[ErxChargeItem]>

    func listAllChargeItems(after referenceDate: String?, profileId: UUID) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllChargeItems(
                    after: referenceDate,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllChargeItemsAfterProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllChargeItemsAfterProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllChargeItems(
                    after: referenceDate,
                    profileId: profileId
            )
        }
    }

    var deleteChargeItemsProfileIdRecordings: MockAnswer<Bool>

    func delete(chargeItems: [ErxChargeItem], profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    chargeItems: chargeItems,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteChargeItemsProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteChargeItemsProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    chargeItems: chargeItems,
                    profileId: profileId
            )
        }
    }

    var fetchConsentsProfileIdRecordings: MockAnswer<[ErxConsent]>

    func fetchConsents(profileId: UUID) -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchConsents(
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchConsentsProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchConsentsProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchConsents(
                    profileId: profileId
            )
        }
    }

    var grantConsentProfileIdRecordings: MockAnswer<ErxConsent?>

    func grantConsent(_ consent: ErxConsent, profileId: UUID) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.grantConsent(
                    consent,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.grantConsentProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = grantConsentProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.grantConsent(
                    consent,
                    profileId: profileId
            )
        }
    }

    var revokeConsentProfileIdRecordings: MockAnswer<Bool>

    func revokeConsent(_ category: ErxConsent.Category, profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.revokeConsent(
                    category,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.revokeConsentProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = revokeConsentProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.revokeConsent(
                    category,
                    profileId: profileId
            )
        }
    }

    var loadRemoteEuAccessCodeProfileIdRecordings: MockAnswer<EuAccessCode?>

    func loadRemoteEuAccessCode(profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.loadRemoteEuAccessCode(
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.loadRemoteEuAccessCodeProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = loadRemoteEuAccessCodeProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.loadRemoteEuAccessCode(
                    profileId: profileId
            )
        }
    }

    var grantEuAccessPermissionAccessCodeProfileIdRecordings: MockAnswer<EuAccessCode?>

    func grantEuAccessPermission(accessCode: EuAccessCode, profileId: UUID) -> AnyPublisher<EuAccessCode?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.grantEuAccessPermission(
                    accessCode: accessCode,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.grantEuAccessPermissionAccessCodeProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = grantEuAccessPermissionAccessCodeProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.grantEuAccessPermission(
                    accessCode: accessCode,
                    profileId: profileId
            )
        }
    }

    var deleteEuAccessCodeProfileIdRecordings: MockAnswer<Bool>

    func deleteEuAccessCode(profileId: UUID) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.deleteEuAccessCode(
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteEuAccessCodeProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteEuAccessCodeProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.deleteEuAccessCode(
                    profileId: profileId
            )
        }
    }

    struct Mocks: VerifiableMock {
        var fetchTaskByAccessCodeProfileIdRecordings: MockAnswer<ErxTask?>? = .delegate
        var listAllTasksAfterProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var listTasksNextPageOfProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var listDetailedTasksForProfileIdRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var deleteTasksProfileIdRecordings: MockAnswer<Bool>? = .delegate
        var markEURedeemableForByPatientAuthorizationProfileIdRecordings: MockAnswer<ErxTask?>? = .delegate
        var redeemOrderProfileIdRecordings: MockAnswer<ErxTaskOrder>? = .delegate
        var listAllCommunicationsAfterForProfileIdRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var fetchAuditEventByProfileIdRecordings: MockAnswer<ErxAuditEvent?>? = .delegate
        var listAllAuditEventsAfterForProfileIdRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>? = .delegate
        var listAuditEventsNextPageFromLocaleProfileIdRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>? = .delegate
        var listMedicationDispensesForProfileIdRecordings: MockAnswer<[ErxMedicationDispense]>? = .delegate
        var fetchChargeItemByProfileIdRecordings: MockAnswer<ErxChargeItem?>? = .delegate
        var listAllChargeItemsAfterProfileIdRecordings: MockAnswer<[ErxChargeItem]>? = .delegate
        var deleteChargeItemsProfileIdRecordings: MockAnswer<Bool>? = .delegate
        var fetchConsentsProfileIdRecordings: MockAnswer<[ErxConsent]>? = .delegate
        var grantConsentProfileIdRecordings: MockAnswer<ErxConsent?>? = .delegate
        var revokeConsentProfileIdRecordings: MockAnswer<Bool>? = .delegate
        var loadRemoteEuAccessCodeProfileIdRecordings: MockAnswer<EuAccessCode?>? = .delegate
        var grantEuAccessPermissionAccessCodeProfileIdRecordings: MockAnswer<EuAccessCode?>? = .delegate
        var deleteEuAccessCodeProfileIdRecordings: MockAnswer<Bool>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "fetchTaskByAccessCodeProfileIdRecordings",
                "listAllTasksAfterProfileIdRecordings",
                "listTasksNextPageOfProfileIdRecordings",
                "listDetailedTasksForProfileIdRecordings",
                "deleteTasksProfileIdRecordings",
                "markEURedeemableForByPatientAuthorizationProfileIdRecordings",
                "redeemOrderProfileIdRecordings",
                "listAllCommunicationsAfterForProfileIdRecordings",
                "fetchAuditEventByProfileIdRecordings",
                "listAllAuditEventsAfterForProfileIdRecordings",
                "listAuditEventsNextPageFromLocaleProfileIdRecordings",
                "listMedicationDispensesForProfileIdRecordings",
                "fetchChargeItemByProfileIdRecordings",
                "listAllChargeItemsAfterProfileIdRecordings",
                "deleteChargeItemsProfileIdRecordings",
                "fetchConsentsProfileIdRecordings",
                "grantConsentProfileIdRecordings",
                "revokeConsentProfileIdRecordings",
                "loadRemoteEuAccessCodeProfileIdRecordings",
                "grantEuAccessPermissionAccessCodeProfileIdRecordings",
                "deleteEuAccessCodeProfileIdRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "ErxRemoteDataStore",
            Mocks(
                fetchTaskByAccessCodeProfileIdRecordings: fetchTaskByAccessCodeProfileIdRecordings,
                listAllTasksAfterProfileIdRecordings: listAllTasksAfterProfileIdRecordings,
                listTasksNextPageOfProfileIdRecordings: listTasksNextPageOfProfileIdRecordings,
                listDetailedTasksForProfileIdRecordings: listDetailedTasksForProfileIdRecordings,
                deleteTasksProfileIdRecordings: deleteTasksProfileIdRecordings,
                markEURedeemableForByPatientAuthorizationProfileIdRecordings: markEURedeemableForByPatientAuthorizationProfileIdRecordings,
                redeemOrderProfileIdRecordings: redeemOrderProfileIdRecordings,
                listAllCommunicationsAfterForProfileIdRecordings: listAllCommunicationsAfterForProfileIdRecordings,
                fetchAuditEventByProfileIdRecordings: fetchAuditEventByProfileIdRecordings,
                listAllAuditEventsAfterForProfileIdRecordings: listAllAuditEventsAfterForProfileIdRecordings,
                listAuditEventsNextPageFromLocaleProfileIdRecordings: listAuditEventsNextPageFromLocaleProfileIdRecordings,
                listMedicationDispensesForProfileIdRecordings: listMedicationDispensesForProfileIdRecordings,
                fetchChargeItemByProfileIdRecordings: fetchChargeItemByProfileIdRecordings,
                listAllChargeItemsAfterProfileIdRecordings: listAllChargeItemsAfterProfileIdRecordings,
                deleteChargeItemsProfileIdRecordings: deleteChargeItemsProfileIdRecordings,
                fetchConsentsProfileIdRecordings: fetchConsentsProfileIdRecordings,
                grantConsentProfileIdRecordings: grantConsentProfileIdRecordings,
                revokeConsentProfileIdRecordings: revokeConsentProfileIdRecordings,
                loadRemoteEuAccessCodeProfileIdRecordings: loadRemoteEuAccessCodeProfileIdRecordings,
                grantEuAccessPermissionAccessCodeProfileIdRecordings: grantEuAccessPermissionAccessCodeProfileIdRecordings,
                deleteEuAccessCodeProfileIdRecordings: deleteEuAccessCodeProfileIdRecordings
            )
        )
    }
}


// MARK: - SmartMockIDPSession -

class SmartMockIDPSession: IDPSession, SmartMock {
    private var wrapped: IDPSession
    private var isRecording: Bool

    init(wrapped: IDPSession, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        requestChallengeRecordings = mocks?.requestChallengeRecordings ?? .delegate
        verifyRecordings = mocks?.verifyRecordings ?? .delegate
        exchangeTokenChallengeSessionIdTokenValidatorRecordings = mocks?.exchangeTokenChallengeSessionIdTokenValidatorRecordings ?? .delegate
        refreshTokenRecordings = mocks?.refreshTokenRecordings ?? .delegate
        pairDeviceWithTokenRecordings = mocks?.pairDeviceWithTokenRecordings ?? .delegate
        unregisterDeviceTokenRecordings = mocks?.unregisterDeviceTokenRecordings ?? .delegate
        listDevicesTokenRecordings = mocks?.listDevicesTokenRecordings ?? .delegate
        altVerifyRecordings = mocks?.altVerifyRecordings ?? .delegate
        loadDirectoryKKAppsRecordings = mocks?.loadDirectoryKKAppsRecordings ?? .delegate
        startExtAuthEntryRecordings = mocks?.startExtAuthEntryRecordings ?? .delegate
        extAuthVerifyAndExchangeIdTokenValidatorRecordings = mocks?.extAuthVerifyAndExchangeIdTokenValidatorRecordings ?? .delegate
        isLoggedInRecordings = mocks?.isLoggedInRecordings ?? .delegate
        autoRefreshedTokenRecordings = mocks?.autoRefreshedTokenRecordings ?? .delegate
    }

    var isLoggedInRecordings: MockAnswer<Bool>

    var isLoggedIn: AnyPublisher<Bool, IDPError> {
        guard !isRecording else {
            return wrapped.isLoggedIn
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.isLoggedInRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = isLoggedInRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.isLoggedIn
        }
    }
    var autoRefreshedTokenRecordings: MockAnswer<IDPToken?>

    var autoRefreshedToken: AnyPublisher<IDPToken?, IDPError> {
        guard !isRecording else {
            return wrapped.autoRefreshedToken
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.autoRefreshedTokenRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = autoRefreshedTokenRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.autoRefreshedToken
        }
    }
    func invalidateAccessToken() {
        wrapped.invalidateAccessToken(
            )
    }

    var requestChallengeRecordings: MockAnswer<IDPChallengeSession>

    func requestChallenge() -> AnyPublisher<IDPChallengeSession, IDPError> {
        guard !isRecording else {
            let result = wrapped.requestChallenge(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.requestChallengeRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = requestChallengeRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.requestChallenge(
            )
        }
    }

    var verifyRecordings: MockAnswer<IDPExchangeToken>

    func verify(_ signedChallenge: SignedChallenge) -> AnyPublisher<IDPExchangeToken, IDPError> {
        guard !isRecording else {
            let result = wrapped.verify(
                    signedChallenge
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.verifyRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = verifyRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.verify(
                    signedChallenge
            )
        }
    }

    var exchangeTokenChallengeSessionIdTokenValidatorRecordings: MockAnswer<IDPToken>

    func exchange(token: IDPExchangeToken, challengeSession: ChallengeSession, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        guard !isRecording else {
            let result = wrapped.exchange(
                    token: token,
                    challengeSession: challengeSession,
                    idTokenValidator: idTokenValidator
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.exchangeTokenChallengeSessionIdTokenValidatorRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = exchangeTokenChallengeSessionIdTokenValidatorRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.exchange(
                    token: token,
                    challengeSession: challengeSession,
                    idTokenValidator: idTokenValidator
            )
        }
    }

    var refreshTokenRecordings: MockAnswer<IDPToken>

    func refresh(token: IDPToken) -> AnyPublisher<IDPToken, IDPError> {
        guard !isRecording else {
            let result = wrapped.refresh(
                    token: token
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.refreshTokenRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = refreshTokenRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.refresh(
                    token: token
            )
        }
    }

    var pairDeviceWithTokenRecordings: MockAnswer<PairingEntry>

    func pairDevice(with registrationData: RegistrationData, token: IDPToken) -> AnyPublisher<PairingEntry, IDPError> {
        guard !isRecording else {
            let result = wrapped.pairDevice(
                    with: registrationData,
                    token: token
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.pairDeviceWithTokenRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = pairDeviceWithTokenRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.pairDevice(
                    with: registrationData,
                    token: token
            )
        }
    }

    var unregisterDeviceTokenRecordings: MockAnswer<Bool>

    func unregisterDevice(_ keyIdentifier: String, token: IDPToken) -> AnyPublisher<Bool, IDPError> {
        guard !isRecording else {
            let result = wrapped.unregisterDevice(
                    keyIdentifier,
                    token: token
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.unregisterDeviceTokenRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = unregisterDeviceTokenRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.unregisterDevice(
                    keyIdentifier,
                    token: token
            )
        }
    }

    var listDevicesTokenRecordings: MockAnswer<PairingEntries>

    func listDevices(token: IDPToken) -> AnyPublisher<PairingEntries, IDPError> {
        guard !isRecording else {
            let result = wrapped.listDevices(
                    token: token
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listDevicesTokenRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listDevicesTokenRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listDevices(
                    token: token
            )
        }
    }

    var altVerifyRecordings: MockAnswer<IDPExchangeToken>

    func altVerify(_ signedChallenge: SignedAuthenticationData) -> AnyPublisher<IDPExchangeToken, IDPError> {
        guard !isRecording else {
            let result = wrapped.altVerify(
                    signedChallenge
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.altVerifyRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = altVerifyRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.altVerify(
                    signedChallenge
            )
        }
    }

    var loadDirectoryKKAppsRecordings: MockAnswer<KKAppDirectory>

    func loadDirectoryKKApps() -> AnyPublisher<KKAppDirectory, IDPError> {
        guard !isRecording else {
            let result = wrapped.loadDirectoryKKApps(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.loadDirectoryKKAppsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = loadDirectoryKKAppsRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.loadDirectoryKKApps(
            )
        }
    }

    var startExtAuthEntryRecordings: MockAnswer<URL>

    func startExtAuth(entry: KKAppDirectory.Entry) -> AnyPublisher<URL, IDPError> {
        guard !isRecording else {
            let result = wrapped.startExtAuth(
                    entry: entry
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.startExtAuthEntryRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = startExtAuthEntryRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.startExtAuth(
                    entry: entry
            )
        }
    }

    var extAuthVerifyAndExchangeIdTokenValidatorRecordings: MockAnswer<IDPToken>

    func extAuthVerifyAndExchange(_ url: URL, idTokenValidator: @escaping (TokenPayload.IDTokenPayload) -> Result<Bool, Error>) -> AnyPublisher<IDPToken, IDPError> {
        guard !isRecording else {
            let result = wrapped.extAuthVerifyAndExchange(
                    url,
                    idTokenValidator: idTokenValidator
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.extAuthVerifyAndExchangeIdTokenValidatorRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = extAuthVerifyAndExchangeIdTokenValidatorRecordings.next() {
            return Just(value)
                .setFailureType(to: IDPError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.extAuthVerifyAndExchange(
                    url,
                    idTokenValidator: idTokenValidator
            )
        }
    }




    struct Mocks: VerifiableMock {
        var requestChallengeRecordings: MockAnswer<IDPChallengeSession>? = .delegate
        var verifyRecordings: MockAnswer<IDPExchangeToken>? = .delegate
        var exchangeTokenChallengeSessionIdTokenValidatorRecordings: MockAnswer<IDPToken>? = .delegate
        var refreshTokenRecordings: MockAnswer<IDPToken>? = .delegate
        var pairDeviceWithTokenRecordings: MockAnswer<PairingEntry>? = .delegate
        var unregisterDeviceTokenRecordings: MockAnswer<Bool>? = .delegate
        var listDevicesTokenRecordings: MockAnswer<PairingEntries>? = .delegate
        var altVerifyRecordings: MockAnswer<IDPExchangeToken>? = .delegate
        var loadDirectoryKKAppsRecordings: MockAnswer<KKAppDirectory>? = .delegate
        var startExtAuthEntryRecordings: MockAnswer<URL>? = .delegate
        var extAuthVerifyAndExchangeIdTokenValidatorRecordings: MockAnswer<IDPToken>? = .delegate
        var isLoggedInRecordings: MockAnswer<Bool>? = .delegate
        var autoRefreshedTokenRecordings: MockAnswer<IDPToken?>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "requestChallengeRecordings",
                "verifyRecordings",
                "exchangeTokenChallengeSessionIdTokenValidatorRecordings",
                "refreshTokenRecordings",
                "pairDeviceWithTokenRecordings",
                "unregisterDeviceTokenRecordings",
                "listDevicesTokenRecordings",
                "altVerifyRecordings",
                "loadDirectoryKKAppsRecordings",
                "startExtAuthEntryRecordings",
                "extAuthVerifyAndExchangeIdTokenValidatorRecordings",
                "isLoggedInRecordings",
                "autoRefreshedTokenRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "IDPSession",
            Mocks(
                requestChallengeRecordings: requestChallengeRecordings,
                verifyRecordings: verifyRecordings,
                exchangeTokenChallengeSessionIdTokenValidatorRecordings: exchangeTokenChallengeSessionIdTokenValidatorRecordings,
                refreshTokenRecordings: refreshTokenRecordings,
                pairDeviceWithTokenRecordings: pairDeviceWithTokenRecordings,
                unregisterDeviceTokenRecordings: unregisterDeviceTokenRecordings,
                listDevicesTokenRecordings: listDevicesTokenRecordings,
                altVerifyRecordings: altVerifyRecordings,
                loadDirectoryKKAppsRecordings: loadDirectoryKKAppsRecordings,
                startExtAuthEntryRecordings: startExtAuthEntryRecordings,
                extAuthVerifyAndExchangeIdTokenValidatorRecordings: extAuthVerifyAndExchangeIdTokenValidatorRecordings
,
                isLoggedInRecordings:isLoggedInRecordings,
                autoRefreshedTokenRecordings:autoRefreshedTokenRecordings
            )
        )
    }
}


// MARK: - SmartMockRedeemService -

class SmartMockRedeemService: RedeemService, SmartMock {
    private var wrapped: RedeemService
    private var isRecording: Bool

    init(wrapped: RedeemService, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        redeemProfileIdRecordings = mocks?.redeemProfileIdRecordings ?? .delegate
        redeemDiGaProfileIdRecordings = mocks?.redeemDiGaProfileIdRecordings ?? .delegate
    }

    var redeemProfileIdRecordings: MockAnswer<IdentifiedArrayOf<OrderResponse>>

    func redeem(_ orders: [OrderRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        guard !isRecording else {
            let result = wrapped.redeem(
                    orders,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.redeemProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = redeemProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.redeem(
                    orders,
                    profileId: profileId
            )
        }
    }

    var redeemDiGaProfileIdRecordings: MockAnswer<IdentifiedArrayOf<OrderDiGaResponse>>

    func redeemDiGa(_ orders: [OrderDiGaRequest], profileId: UUID) -> AnyPublisher<IdentifiedArrayOf<OrderDiGaResponse>, RedeemServiceError> {
        guard !isRecording else {
            let result = wrapped.redeemDiGa(
                    orders,
                    profileId: profileId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.redeemDiGaProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = redeemDiGaProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.redeemDiGa(
                    orders,
                    profileId: profileId
            )
        }
    }

    struct Mocks: VerifiableMock {
        var redeemProfileIdRecordings: MockAnswer<IdentifiedArrayOf<OrderResponse>>? = .delegate
        var redeemDiGaProfileIdRecordings: MockAnswer<IdentifiedArrayOf<OrderDiGaResponse>>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "redeemProfileIdRecordings",
                "redeemDiGaProfileIdRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "RedeemService",
            Mocks(
                redeemProfileIdRecordings: redeemProfileIdRecordings,
                redeemDiGaProfileIdRecordings: redeemDiGaProfileIdRecordings
            )
        )
    }
}


// MARK: - SmartMockUserDataStore -

class SmartMockUserDataStore: UserDataStore, SmartMock {
    private var wrapped: UserDataStore
    private var isRecording: Bool

    init(wrapped: UserDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        hideOnboardingRecordings = mocks?.hideOnboardingRecordings ?? .delegate
        isOnboardingHiddenRecordings = mocks?.isOnboardingHiddenRecordings ?? .delegate
        onboardingDateRecordings = mocks?.onboardingDateRecordings ?? .delegate
        onboardingVersionRecordings = mocks?.onboardingVersionRecordings ?? .delegate
        hideCardWallIntroRecordings = mocks?.hideCardWallIntroRecordings ?? .delegate
        serverEnvironmentConfigurationRecordings = mocks?.serverEnvironmentConfigurationRecordings ?? .delegate
        serverEnvironmentNameRecordings = mocks?.serverEnvironmentNameRecordings ?? .delegate
        appSecurityOptionRecordings = mocks?.appSecurityOptionRecordings ?? .delegate
        failedAppAuthenticationsRecordings = mocks?.failedAppAuthenticationsRecordings ?? .delegate
        ignoreDeviceNotSecuredWarningPermanentlyRecordings = mocks?.ignoreDeviceNotSecuredWarningPermanentlyRecordings ?? .delegate
        selectedProfileIdRecordings = mocks?.selectedProfileIdRecordings ?? .delegate
        latestCompatibleModelVersionRecordings = mocks?.latestCompatibleModelVersionRecordings ?? .delegate
        appStartCounterRecordings = mocks?.appStartCounterRecordings ?? .delegate
        readInternalCommunicationsRecordings = mocks?.readInternalCommunicationsRecordings ?? .delegate
        hideWelcomeMessageRecordings = mocks?.hideWelcomeMessageRecordings ?? .delegate
        hideEURedeemInstructionsRecordings = mocks?.hideEURedeemInstructionsRecordings ?? .delegate
    }

    var hideOnboardingRecordings: MockAnswer<Bool>

    var hideOnboarding: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideOnboarding
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideOnboardingRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideOnboardingRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideOnboarding
        }
    }
    var isOnboardingHiddenRecordings: MockAnswer<Bool>
    var isOnboardingHidden: Bool {
        guard !isRecording else {
            let result = wrapped.isOnboardingHidden
            isOnboardingHiddenRecordings.record(result)
            return result
        }
        if let first = isOnboardingHiddenRecordings.next() {
            return first
        }
        return wrapped.isOnboardingHidden
    }
    var onboardingDateRecordings: MockAnswer<Date?>

    var onboardingDate: AnyPublisher<Date?, Never> {
        guard !isRecording else {
            return wrapped.onboardingDate
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.onboardingDateRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = onboardingDateRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.onboardingDate
        }
    }
    var onboardingVersionRecordings: MockAnswer<String?>

    var onboardingVersion: AnyPublisher<String?, Never> {
        guard !isRecording else {
            return wrapped.onboardingVersion
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.onboardingVersionRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = onboardingVersionRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.onboardingVersion
        }
    }
    var hideCardWallIntroRecordings: MockAnswer<Bool>

    var hideCardWallIntro: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideCardWallIntro
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideCardWallIntroRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideCardWallIntroRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideCardWallIntro
        }
    }
    var serverEnvironmentConfigurationRecordings: MockAnswer<String?>

    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> {
        guard !isRecording else {
            return wrapped.serverEnvironmentConfiguration
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.serverEnvironmentConfigurationRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = serverEnvironmentConfigurationRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.serverEnvironmentConfiguration
        }
    }
    var serverEnvironmentNameRecordings: MockAnswer<String?>
    var serverEnvironmentName: String? {
        guard !isRecording else {
            let result = wrapped.serverEnvironmentName
            serverEnvironmentNameRecordings.record(result)
            return result
        }
        if let first = serverEnvironmentNameRecordings.next() {
            return first
        }
        return wrapped.serverEnvironmentName
    }
    var appSecurityOptionRecordings: MockAnswer<AppSecurityOption>

    var appSecurityOption: AnyPublisher<AppSecurityOption, Never> {
        guard !isRecording else {
            return wrapped.appSecurityOption
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.appSecurityOptionRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = appSecurityOptionRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.appSecurityOption
        }
    }
    var failedAppAuthenticationsRecordings: MockAnswer<Int>

    var failedAppAuthentications: AnyPublisher<Int, Never> {
        guard !isRecording else {
            return wrapped.failedAppAuthentications
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.failedAppAuthenticationsRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = failedAppAuthenticationsRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.failedAppAuthentications
        }
    }
    var ignoreDeviceNotSecuredWarningPermanentlyRecordings: MockAnswer<Bool>

    var ignoreDeviceNotSecuredWarningPermanently: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.ignoreDeviceNotSecuredWarningPermanently
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.ignoreDeviceNotSecuredWarningPermanentlyRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = ignoreDeviceNotSecuredWarningPermanentlyRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.ignoreDeviceNotSecuredWarningPermanently
        }
    }
    var selectedProfileIdRecordings: MockAnswer<UUID?>

    var selectedProfileId: AnyPublisher<UUID?, Never> {
        guard !isRecording else {
            return wrapped.selectedProfileId
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.selectedProfileIdRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = selectedProfileIdRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.selectedProfileId
        }
    }
    var latestCompatibleModelVersionRecordings: MockAnswer<ModelVersion>
    var latestCompatibleModelVersion: ModelVersion {
        set {
            if isRecording {
                latestCompatibleModelVersionRecordings.record(newValue)
            }
            wrapped.latestCompatibleModelVersion = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.latestCompatibleModelVersion
                latestCompatibleModelVersionRecordings.record(result)
                return result
            }

            if let first = latestCompatibleModelVersionRecordings.next() {
                return first
            }
            return wrapped.latestCompatibleModelVersion
        }
    }
    var appStartCounterRecordings: MockAnswer<Int>
    var appStartCounter: Int {
        set {
            if isRecording {
                appStartCounterRecordings.record(newValue)
            }
            wrapped.appStartCounter = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.appStartCounter
                appStartCounterRecordings.record(result)
                return result
            }

            if let first = appStartCounterRecordings.next() {
                return first
            }
            return wrapped.appStartCounter
        }
    }
    var readInternalCommunicationsRecordings: MockAnswer<[String]>

    var readInternalCommunications: AnyPublisher<[String], Never> {
        guard !isRecording else {
            return wrapped.readInternalCommunications
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.readInternalCommunicationsRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = readInternalCommunicationsRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.readInternalCommunications
        }
    }
    var hideWelcomeMessageRecordings: MockAnswer<Bool>

    var hideWelcomeMessage: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideWelcomeMessage
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideWelcomeMessageRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideWelcomeMessageRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideWelcomeMessage
        }
    }
    var hideEURedeemInstructionsRecordings: MockAnswer<Bool>

    var hideEURedeemInstructions: AnyPublisher<Bool, Never> {
        guard !isRecording else {
            return wrapped.hideEURedeemInstructions
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.hideEURedeemInstructionsRecordings.record(value)
                })
                .eraseToAnyPublisher()
        }
        if let value = hideEURedeemInstructionsRecordings.next() {
            return Just(value)
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.hideEURedeemInstructions
        }
    }
    func set(onboardingDate: Date?) {
        wrapped.set(
                    onboardingDate: onboardingDate
            )
    }

    func set(hideOnboarding: Bool) {
        wrapped.set(
                    hideOnboarding: hideOnboarding
            )
    }

    func set(onboardingVersion: String?) {
        wrapped.set(
                    onboardingVersion: onboardingVersion
            )
    }

    func set(hideCardWallIntro: Bool) {
        wrapped.set(
                    hideCardWallIntro: hideCardWallIntro
            )
    }

    func set(serverEnvironmentConfiguration: String?) {
        wrapped.set(
                    serverEnvironmentConfiguration: serverEnvironmentConfiguration
            )
    }

    func set(appSecurityOption: AppSecurityOption) {
        wrapped.set(
                    appSecurityOption: appSecurityOption
            )
    }

    func set(failedAppAuthentications: Int) {
        wrapped.set(
                    failedAppAuthentications: failedAppAuthentications
            )
    }

    func set(ignoreDeviceNotSecuredWarningPermanently: Bool) {
        wrapped.set(
                    ignoreDeviceNotSecuredWarningPermanently: ignoreDeviceNotSecuredWarningPermanently
            )
    }

    func set(selectedProfileId: UUID) {
        wrapped.set(
                    selectedProfileId: selectedProfileId
            )
    }

    func wipeAll() {
        wrapped.wipeAll(
            )
    }

    func markInternalCommunicationAsRead(messageId: String) {
        wrapped.markInternalCommunicationAsRead(
                    messageId: messageId
            )
    }

    func set(hideWelcomeMessage: Bool) {
        wrapped.set(
                    hideWelcomeMessage: hideWelcomeMessage
            )
    }

    func set(hideEURedeemInstructions: Bool) {
        wrapped.set(
                    hideEURedeemInstructions: hideEURedeemInstructions
            )
    }

    /// AnyObject
    struct Mocks: VerifiableMock {
        var hideOnboardingRecordings: MockAnswer<Bool>? = .delegate
        var isOnboardingHiddenRecordings: MockAnswer<Bool>? = .delegate
        var onboardingDateRecordings: MockAnswer<Date?>? = .delegate
        var onboardingVersionRecordings: MockAnswer<String?>? = .delegate
        var hideCardWallIntroRecordings: MockAnswer<Bool>? = .delegate
        var serverEnvironmentConfigurationRecordings: MockAnswer<String?>? = .delegate
        var serverEnvironmentNameRecordings: MockAnswer<String?>? = .delegate
        var appSecurityOptionRecordings: MockAnswer<AppSecurityOption>? = .delegate
        var failedAppAuthenticationsRecordings: MockAnswer<Int>? = .delegate
        var ignoreDeviceNotSecuredWarningPermanentlyRecordings: MockAnswer<Bool>? = .delegate
        var selectedProfileIdRecordings: MockAnswer<UUID?>? = .delegate
        var latestCompatibleModelVersionRecordings: MockAnswer<ModelVersion>? = .delegate
        var appStartCounterRecordings: MockAnswer<Int>? = .delegate
        var readInternalCommunicationsRecordings: MockAnswer<[String]>? = .delegate
        var hideWelcomeMessageRecordings: MockAnswer<Bool>? = .delegate
        var hideEURedeemInstructionsRecordings: MockAnswer<Bool>? = .delegate

        static var expectedKeys: Set<String> {
            [
                "hideOnboardingRecordings",
                "isOnboardingHiddenRecordings",
                "onboardingDateRecordings",
                "onboardingVersionRecordings",
                "hideCardWallIntroRecordings",
                "serverEnvironmentConfigurationRecordings",
                "serverEnvironmentNameRecordings",
                "appSecurityOptionRecordings",
                "failedAppAuthenticationsRecordings",
                "ignoreDeviceNotSecuredWarningPermanentlyRecordings",
                "selectedProfileIdRecordings",
                "latestCompatibleModelVersionRecordings",
                "appStartCounterRecordings",
                "readInternalCommunicationsRecordings",
                "hideWelcomeMessageRecordings",
                "hideEURedeemInstructionsRecordings",
            ]
        }
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "UserDataStore",
            Mocks(
                hideOnboardingRecordings:hideOnboardingRecordings,
                isOnboardingHiddenRecordings: isOnboardingHiddenRecordings,
                onboardingDateRecordings:onboardingDateRecordings,
                onboardingVersionRecordings:onboardingVersionRecordings,
                hideCardWallIntroRecordings:hideCardWallIntroRecordings,
                serverEnvironmentConfigurationRecordings:serverEnvironmentConfigurationRecordings,
                serverEnvironmentNameRecordings: serverEnvironmentNameRecordings,
                appSecurityOptionRecordings:appSecurityOptionRecordings,
                failedAppAuthenticationsRecordings:failedAppAuthenticationsRecordings,
                ignoreDeviceNotSecuredWarningPermanentlyRecordings:ignoreDeviceNotSecuredWarningPermanentlyRecordings,
                selectedProfileIdRecordings:selectedProfileIdRecordings,
                latestCompatibleModelVersionRecordings: latestCompatibleModelVersionRecordings,
                appStartCounterRecordings: appStartCounterRecordings,
                readInternalCommunicationsRecordings:readInternalCommunicationsRecordings,
                hideWelcomeMessageRecordings:hideWelcomeMessageRecordings,
                hideEURedeemInstructionsRecordings:hideEURedeemInstructionsRecordings
            )
        )
    }
}


#endif
