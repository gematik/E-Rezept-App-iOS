// Generated using Sourcery — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
/// Use sourcery to update this file.

#if DEBUG

import Combine
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import Foundation
import IdentifiedCollections
import IDP
import OpenSSL
import Pharmacy

// MARK: - SmartMockErxRemoteDataStore -

class SmartMockErxRemoteDataStore: ErxRemoteDataStore, SmartMock {
    private var wrapped: ErxRemoteDataStore
    private var isRecording: Bool

    init(wrapped: ErxRemoteDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        fetchTaskByAccessCodeRecordings = mocks?.fetchTaskByAccessCodeRecordings ?? .delegate
        listAllTasksAfterRecordings = mocks?.listAllTasksAfterRecordings ?? .delegate
        listTasksNextPageOfRecordings = mocks?.listTasksNextPageOfRecordings ?? .delegate
        listDetailedTasksForRecordings = mocks?.listDetailedTasksForRecordings ?? .delegate
        deleteTasksRecordings = mocks?.deleteTasksRecordings ?? .delegate
        redeemOrderRecordings = mocks?.redeemOrderRecordings ?? .delegate
        listAllCommunicationsAfterForRecordings = mocks?.listAllCommunicationsAfterForRecordings ?? .delegate
        fetchAuditEventByRecordings = mocks?.fetchAuditEventByRecordings ?? .delegate
        listAllAuditEventsAfterForRecordings = mocks?.listAllAuditEventsAfterForRecordings ?? .delegate
        listAuditEventsNextPageFromLocaleRecordings = mocks?.listAuditEventsNextPageFromLocaleRecordings ?? .delegate
        listMedicationDispensesForRecordings = mocks?.listMedicationDispensesForRecordings ?? .delegate
        fetchChargeItemByRecordings = mocks?.fetchChargeItemByRecordings ?? .delegate
        listAllChargeItemsAfterRecordings = mocks?.listAllChargeItemsAfterRecordings ?? .delegate
        deleteChargeItemsRecordings = mocks?.deleteChargeItemsRecordings ?? .delegate
        fetchConsentsRecordings = mocks?.fetchConsentsRecordings ?? .delegate
        grantConsentRecordings = mocks?.grantConsentRecordings ?? .delegate
        revokeConsentRecordings = mocks?.revokeConsentRecordings ?? .delegate
    }

    var fetchTaskByAccessCodeRecordings: MockAnswer<ErxTask?>

    func fetchTask(by id: ErxTask.ID, accessCode: String?) -> AnyPublisher<ErxTask?, RemoteStoreError> {
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
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchTask(
                    by: id,
                    accessCode: accessCode
            )
        }
    }

    var listAllTasksAfterRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listAllTasks(after referenceDate: String?) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllTasks(
                    after: referenceDate
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllTasksAfterRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllTasksAfterRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllTasks(
                    after: referenceDate
            )
        }
    }

    var listTasksNextPageOfRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listTasksNextPage(of previousPage: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listTasksNextPage(
                    of: previousPage
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listTasksNextPageOfRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listTasksNextPageOfRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listTasksNextPage(
                    of: previousPage
            )
        }
    }

    var listDetailedTasksForRecordings: MockAnswer<PagedContent<[ErxTask]>>

    func listDetailedTasks(for tasks: PagedContent<[ErxTask]>) -> AnyPublisher<PagedContent<[ErxTask]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listDetailedTasks(
                    for: tasks
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listDetailedTasksForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listDetailedTasksForRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listDetailedTasks(
                    for: tasks
            )
        }
    }

    var deleteTasksRecordings: MockAnswer<Bool>

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    tasks: tasks
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteTasksRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteTasksRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    tasks: tasks
            )
        }
    }

    var redeemOrderRecordings: MockAnswer<ErxTaskOrder>

    func redeem(order: ErxTaskOrder) -> AnyPublisher<ErxTaskOrder, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.redeem(
                    order: order
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.redeemOrderRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = redeemOrderRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.redeem(
                    order: order
            )
        }
    }

    var listAllCommunicationsAfterForRecordings: MockAnswer<[ErxTask.Communication]>

    func listAllCommunications(after referenceDate: String?, for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllCommunications(
                    after: referenceDate,
                    for: profile
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllCommunicationsAfterForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllCommunicationsAfterForRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllCommunications(
                    after: referenceDate,
                    for: profile
            )
        }
    }

    var fetchAuditEventByRecordings: MockAnswer<ErxAuditEvent?>

    func fetchAuditEvent(by id: ErxAuditEvent.ID) -> AnyPublisher<ErxAuditEvent?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchAuditEvent(
                    by: id
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchAuditEventByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchAuditEventByRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchAuditEvent(
                    by: id
            )
        }
    }

    var listAllAuditEventsAfterForRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>

    func listAllAuditEvents(after referenceDate: String?, for locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllAuditEvents(
                    after: referenceDate,
                    for: locale
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllAuditEventsAfterForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllAuditEventsAfterForRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllAuditEvents(
                    after: referenceDate,
                    for: locale
            )
        }
    }

    var listAuditEventsNextPageFromLocaleRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>

    func listAuditEventsNextPage(from url: URL, locale: String?) -> AnyPublisher<PagedContent<[ErxAuditEvent]>, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAuditEventsNextPage(
                    from: url,
                    locale: locale
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAuditEventsNextPageFromLocaleRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAuditEventsNextPageFromLocaleRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAuditEventsNextPage(
                    from: url,
                    locale: locale
            )
        }
    }

    var listMedicationDispensesForRecordings: MockAnswer<[ErxMedicationDispense]>

    func listMedicationDispenses(for id: ErxTask.ID) -> AnyPublisher<[ErxMedicationDispense], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listMedicationDispenses(
                    for: id
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listMedicationDispensesForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listMedicationDispensesForRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listMedicationDispenses(
                    for: id
            )
        }
    }

    var fetchChargeItemByRecordings: MockAnswer<ErxChargeItem?>

    func fetchChargeItem(by id: ErxChargeItem.ID) -> AnyPublisher<ErxChargeItem?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchChargeItem(
                    by: id
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchChargeItemByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchChargeItemByRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchChargeItem(
                    by: id
            )
        }
    }

    var listAllChargeItemsAfterRecordings: MockAnswer<[ErxChargeItem]>

    func listAllChargeItems(after referenceDate: String?) -> AnyPublisher<[ErxChargeItem], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllChargeItems(
                    after: referenceDate
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllChargeItemsAfterRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllChargeItemsAfterRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllChargeItems(
                    after: referenceDate
            )
        }
    }

    var deleteChargeItemsRecordings: MockAnswer<Bool>

    func delete(chargeItems: [ErxChargeItem]) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    chargeItems: chargeItems
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    chargeItems: chargeItems
            )
        }
    }

    var fetchConsentsRecordings: MockAnswer<[ErxConsent]>

    func fetchConsents() -> AnyPublisher<[ErxConsent], RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchConsents(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchConsentsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchConsentsRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchConsents(
            )
        }
    }

    var grantConsentRecordings: MockAnswer<ErxConsent?>

    func grantConsent(_ consent: ErxConsent) -> AnyPublisher<ErxConsent?, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.grantConsent(
                    consent
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.grantConsentRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = grantConsentRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.grantConsent(
                    consent
            )
        }
    }

    var revokeConsentRecordings: MockAnswer<Bool>

    func revokeConsent(_ category: ErxConsent.Category) -> AnyPublisher<Bool, RemoteStoreError> {
        guard !isRecording else {
            let result = wrapped.revokeConsent(
                    category
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.revokeConsentRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = revokeConsentRecordings.next() {
            return Just(value)
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.revokeConsent(
                    category
            )
        }
    }

    struct Mocks: Codable {
        var fetchTaskByAccessCodeRecordings: MockAnswer<ErxTask?>? = .delegate
        var listAllTasksAfterRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var listTasksNextPageOfRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var listDetailedTasksForRecordings: MockAnswer<PagedContent<[ErxTask]>>? = .delegate
        var deleteTasksRecordings: MockAnswer<Bool>? = .delegate
        var redeemOrderRecordings: MockAnswer<ErxTaskOrder>? = .delegate
        var listAllCommunicationsAfterForRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var fetchAuditEventByRecordings: MockAnswer<ErxAuditEvent?>? = .delegate
        var listAllAuditEventsAfterForRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>? = .delegate
        var listAuditEventsNextPageFromLocaleRecordings: MockAnswer<PagedContent<[ErxAuditEvent]>>? = .delegate
        var listMedicationDispensesForRecordings: MockAnswer<[ErxMedicationDispense]>? = .delegate
        var fetchChargeItemByRecordings: MockAnswer<ErxChargeItem?>? = .delegate
        var listAllChargeItemsAfterRecordings: MockAnswer<[ErxChargeItem]>? = .delegate
        var deleteChargeItemsRecordings: MockAnswer<Bool>? = .delegate
        var fetchConsentsRecordings: MockAnswer<[ErxConsent]>? = .delegate
        var grantConsentRecordings: MockAnswer<ErxConsent?>? = .delegate
        var revokeConsentRecordings: MockAnswer<Bool>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "ErxRemoteDataStore",
            Mocks(
                fetchTaskByAccessCodeRecordings: fetchTaskByAccessCodeRecordings,
                listAllTasksAfterRecordings: listAllTasksAfterRecordings,
                listTasksNextPageOfRecordings: listTasksNextPageOfRecordings,
                listDetailedTasksForRecordings: listDetailedTasksForRecordings,
                deleteTasksRecordings: deleteTasksRecordings,
                redeemOrderRecordings: redeemOrderRecordings,
                listAllCommunicationsAfterForRecordings: listAllCommunicationsAfterForRecordings,
                fetchAuditEventByRecordings: fetchAuditEventByRecordings,
                listAllAuditEventsAfterForRecordings: listAllAuditEventsAfterForRecordings,
                listAuditEventsNextPageFromLocaleRecordings: listAuditEventsNextPageFromLocaleRecordings,
                listMedicationDispensesForRecordings: listMedicationDispensesForRecordings,
                fetchChargeItemByRecordings: fetchChargeItemByRecordings,
                listAllChargeItemsAfterRecordings: listAllChargeItemsAfterRecordings,
                deleteChargeItemsRecordings: deleteChargeItemsRecordings,
                fetchConsentsRecordings: fetchConsentsRecordings,
                grantConsentRecordings: grantConsentRecordings,
                revokeConsentRecordings: revokeConsentRecordings
            )
        )
    }
}


// MARK: - SmartMockErxTaskCoreDataStore -

class SmartMockErxTaskCoreDataStore: ErxTaskCoreDataStore, SmartMock {
    private var wrapped: ErxTaskCoreDataStore
    private var isRecording: Bool

    init(wrapped: ErxTaskCoreDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        fetchTaskByAccessCodeRecordings = mocks?.fetchTaskByAccessCodeRecordings ?? .delegate
        listAllTasksRecordings = mocks?.listAllTasksRecordings ?? .delegate
        fetchLatestLastModifiedForErxTasksRecordings = mocks?.fetchLatestLastModifiedForErxTasksRecordings ?? .delegate
        saveTasksUpdateProfileLastAuthenticatedRecordings = mocks?.saveTasksUpdateProfileLastAuthenticatedRecordings ?? .delegate
        deleteTasksRecordings = mocks?.deleteTasksRecordings ?? .delegate
        listAllTasksWithoutProfileRecordings = mocks?.listAllTasksWithoutProfileRecordings ?? .delegate
        listAllCommunicationsForRecordings = mocks?.listAllCommunicationsForRecordings ?? .delegate
        fetchLatestTimestampForCommunicationsRecordings = mocks?.fetchLatestTimestampForCommunicationsRecordings ?? .delegate
        saveCommunicationsRecordings = mocks?.saveCommunicationsRecordings ?? .delegate
        allUnreadCommunicationsForRecordings = mocks?.allUnreadCommunicationsForRecordings ?? .delegate
        listAllMedicationDispensesRecordings = mocks?.listAllMedicationDispensesRecordings ?? .delegate
        saveMedicationDispensesRecordings = mocks?.saveMedicationDispensesRecordings ?? .delegate
        fetchChargeItemByRecordings = mocks?.fetchChargeItemByRecordings ?? .delegate
        fetchLatestTimestampForChargeItemsRecordings = mocks?.fetchLatestTimestampForChargeItemsRecordings ?? .delegate
        listAllChargeItemsRecordings = mocks?.listAllChargeItemsRecordings ?? .delegate
        saveChargeItemsRecordings = mocks?.saveChargeItemsRecordings ?? .delegate
        deleteChargeItemsRecordings = mocks?.deleteChargeItemsRecordings ?? .delegate
    }

    /// ErxLocalDataStore
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

    var listAllTasksRecordings: MockAnswer<[ErxTask]>

    func listAllTasks() -> AnyPublisher<[ErxTask], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllTasks(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllTasksRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllTasksRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllTasks(
            )
        }
    }

    var fetchLatestLastModifiedForErxTasksRecordings: MockAnswer<String?>

    func fetchLatestLastModifiedForErxTasks() -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestLastModifiedForErxTasks(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestLastModifiedForErxTasksRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestLastModifiedForErxTasksRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestLastModifiedForErxTasks(
            )
        }
    }

    var saveTasksUpdateProfileLastAuthenticatedRecordings: MockAnswer<Bool>

    func save(tasks: [ErxTask], updateProfileLastAuthenticated: Bool) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    tasks: tasks,
                    updateProfileLastAuthenticated: updateProfileLastAuthenticated
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveTasksUpdateProfileLastAuthenticatedRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveTasksUpdateProfileLastAuthenticatedRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    tasks: tasks,
                    updateProfileLastAuthenticated: updateProfileLastAuthenticated
            )
        }
    }

    var deleteTasksRecordings: MockAnswer<Bool>

    func delete(tasks: [ErxTask]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    tasks: tasks
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteTasksRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteTasksRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    tasks: tasks
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

    var fetchLatestTimestampForCommunicationsRecordings: MockAnswer<String?>

    func fetchLatestTimestampForCommunications() -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestTimestampForCommunications(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestTimestampForCommunicationsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestTimestampForCommunicationsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestTimestampForCommunications(
            )
        }
    }

    var saveCommunicationsRecordings: MockAnswer<Bool>

    func save(communications: [ErxTask.Communication]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    communications: communications
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveCommunicationsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveCommunicationsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    communications: communications
            )
        }
    }

    var allUnreadCommunicationsForRecordings: MockAnswer<[ErxTask.Communication]>

    func allUnreadCommunications(for profile: ErxTask.Communication.Profile) -> AnyPublisher<[ErxTask.Communication], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.allUnreadCommunications(
                    for: profile
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.allUnreadCommunicationsForRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = allUnreadCommunicationsForRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.allUnreadCommunications(
                    for: profile
            )
        }
    }

    var listAllMedicationDispensesRecordings: MockAnswer<[ErxMedicationDispense]>

    func listAllMedicationDispenses() -> AnyPublisher<[ErxMedicationDispense], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllMedicationDispenses(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllMedicationDispensesRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllMedicationDispensesRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllMedicationDispenses(
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

    var fetchChargeItemByRecordings: MockAnswer<ErxSparseChargeItem?>

    func fetchChargeItem(by chargeItemID: ErxSparseChargeItem.ID) -> AnyPublisher<ErxSparseChargeItem?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchChargeItem(
                    by: chargeItemID
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchChargeItemByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchChargeItemByRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchChargeItem(
                    by: chargeItemID
            )
        }
    }

    var fetchLatestTimestampForChargeItemsRecordings: MockAnswer<String?>

    func fetchLatestTimestampForChargeItems() -> AnyPublisher<String?, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.fetchLatestTimestampForChargeItems(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchLatestTimestampForChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchLatestTimestampForChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchLatestTimestampForChargeItems(
            )
        }
    }

    var listAllChargeItemsRecordings: MockAnswer<[ErxSparseChargeItem]>

    func listAllChargeItems() -> AnyPublisher<[ErxSparseChargeItem], LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.listAllChargeItems(
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.listAllChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = listAllChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.listAllChargeItems(
            )
        }
    }

    var saveChargeItemsRecordings: MockAnswer<Bool>

    func save(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.save(
                    chargeItems: chargeItems
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.saveChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = saveChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.save(
                    chargeItems: chargeItems
            )
        }
    }

    var deleteChargeItemsRecordings: MockAnswer<Bool>

    func delete(chargeItems: [ErxSparseChargeItem]) -> AnyPublisher<Bool, LocalStoreError> {
        guard !isRecording else {
            let result = wrapped.delete(
                    chargeItems: chargeItems
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.deleteChargeItemsRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = deleteChargeItemsRecordings.next() {
            return Just(value)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.delete(
                    chargeItems: chargeItems
            )
        }
    }

    struct Mocks: Codable {
        var fetchTaskByAccessCodeRecordings: MockAnswer<ErxTask?>? = .delegate
        var listAllTasksRecordings: MockAnswer<[ErxTask]>? = .delegate
        var fetchLatestLastModifiedForErxTasksRecordings: MockAnswer<String?>? = .delegate
        var saveTasksUpdateProfileLastAuthenticatedRecordings: MockAnswer<Bool>? = .delegate
        var deleteTasksRecordings: MockAnswer<Bool>? = .delegate
        var listAllTasksWithoutProfileRecordings: MockAnswer<[ErxTask]>? = .delegate
        var listAllCommunicationsForRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var fetchLatestTimestampForCommunicationsRecordings: MockAnswer<String?>? = .delegate
        var saveCommunicationsRecordings: MockAnswer<Bool>? = .delegate
        var allUnreadCommunicationsForRecordings: MockAnswer<[ErxTask.Communication]>? = .delegate
        var listAllMedicationDispensesRecordings: MockAnswer<[ErxMedicationDispense]>? = .delegate
        var saveMedicationDispensesRecordings: MockAnswer<Bool>? = .delegate
        var fetchChargeItemByRecordings: MockAnswer<ErxSparseChargeItem?>? = .delegate
        var fetchLatestTimestampForChargeItemsRecordings: MockAnswer<String?>? = .delegate
        var listAllChargeItemsRecordings: MockAnswer<[ErxSparseChargeItem]>? = .delegate
        var saveChargeItemsRecordings: MockAnswer<Bool>? = .delegate
        var deleteChargeItemsRecordings: MockAnswer<Bool>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "ErxTaskCoreDataStore",
            Mocks(
                fetchTaskByAccessCodeRecordings: fetchTaskByAccessCodeRecordings,
                listAllTasksRecordings: listAllTasksRecordings,
                fetchLatestLastModifiedForErxTasksRecordings: fetchLatestLastModifiedForErxTasksRecordings,
                saveTasksUpdateProfileLastAuthenticatedRecordings: saveTasksUpdateProfileLastAuthenticatedRecordings,
                deleteTasksRecordings: deleteTasksRecordings,
                listAllTasksWithoutProfileRecordings: listAllTasksWithoutProfileRecordings,
                listAllCommunicationsForRecordings: listAllCommunicationsForRecordings,
                fetchLatestTimestampForCommunicationsRecordings: fetchLatestTimestampForCommunicationsRecordings,
                saveCommunicationsRecordings: saveCommunicationsRecordings,
                allUnreadCommunicationsForRecordings: allUnreadCommunicationsForRecordings,
                listAllMedicationDispensesRecordings: listAllMedicationDispensesRecordings,
                saveMedicationDispensesRecordings: saveMedicationDispensesRecordings,
                fetchChargeItemByRecordings: fetchChargeItemByRecordings,
                fetchLatestTimestampForChargeItemsRecordings: fetchLatestTimestampForChargeItemsRecordings,
                listAllChargeItemsRecordings: listAllChargeItemsRecordings,
                saveChargeItemsRecordings: saveChargeItemsRecordings,
                deleteChargeItemsRecordings: deleteChargeItemsRecordings
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





    struct Mocks: Codable {
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


// MARK: - SmartMockPharmacyRemoteDataStore -

class SmartMockPharmacyRemoteDataStore: PharmacyRemoteDataStore, SmartMock {
    private var wrapped: PharmacyRemoteDataStore
    private var isRecording: Bool

    init(wrapped: PharmacyRemoteDataStore, mocks: Mocks?, isRecording: Bool = false) {
        self.wrapped = wrapped
        self.isRecording = isRecording

        searchPharmaciesByPositionFilterRecordings = mocks?.searchPharmaciesByPositionFilterRecordings ?? .delegate
        fetchPharmacyByRecordings = mocks?.fetchPharmacyByRecordings ?? .delegate
        loadAvsCertificatesForRecordings = mocks?.loadAvsCertificatesForRecordings ?? .delegate
    }

    var searchPharmaciesByPositionFilterRecordings: MockAnswer<[PharmacyLocation]>

    func searchPharmacies(by searchTerm: String, position: Position?, filter: [String: String]) -> AnyPublisher<[PharmacyLocation], PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.searchPharmacies(
                    by: searchTerm,
                    position: position,
                    filter: filter
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.searchPharmaciesByPositionFilterRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = searchPharmaciesByPositionFilterRecordings.next() {
            return Just(value)
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.searchPharmacies(
                    by: searchTerm,
                    position: position,
                    filter: filter
            )
        }
    }

    var fetchPharmacyByRecordings: MockAnswer<PharmacyLocation?>

    func fetchPharmacy(by telematikId: String) -> AnyPublisher<PharmacyLocation?, PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.fetchPharmacy(
                    by: telematikId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.fetchPharmacyByRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = fetchPharmacyByRecordings.next() {
            return Just(value)
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.fetchPharmacy(
                    by: telematikId
            )
        }
    }

    var loadAvsCertificatesForRecordings: MockAnswer<[SerializableX509]>

    func loadAvsCertificates(for locationId: String) -> AnyPublisher<[X509], PharmacyFHIRDataSource.Error> {
        guard !isRecording else {
            let result = wrapped.loadAvsCertificates(
                    for: locationId
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.loadAvsCertificatesForRecordings.record(SerializableX509.from(value))
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = loadAvsCertificatesForRecordings.next() {
            return Just(value.unwrap())
                .setFailureType(to: PharmacyFHIRDataSource.Error.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.loadAvsCertificates(
                    for: locationId
            )
        }
    }

    struct Mocks: Codable {
        var searchPharmaciesByPositionFilterRecordings: MockAnswer<[PharmacyLocation]>? = .delegate
        var fetchPharmacyByRecordings: MockAnswer<PharmacyLocation?>? = .delegate
        var loadAvsCertificatesForRecordings: MockAnswer<[SerializableX509]>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "PharmacyRemoteDataStore",
            Mocks(
                searchPharmaciesByPositionFilterRecordings: searchPharmaciesByPositionFilterRecordings,
                fetchPharmacyByRecordings: fetchPharmacyByRecordings,
                loadAvsCertificatesForRecordings: loadAvsCertificatesForRecordings
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

        redeemRecordings = mocks?.redeemRecordings ?? .delegate
    }

    var redeemRecordings: MockAnswer<IdentifiedArrayOf<OrderResponse>>

    func redeem(_ orders: [OrderRequest]) -> AnyPublisher<IdentifiedArrayOf<OrderResponse>, RedeemServiceError> {
        guard !isRecording else {
            let result = wrapped.redeem(
                    orders
            )
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.redeemRecordings.record(value)
                })
                .eraseToAnyPublisher()
            return result
        }
        if let value = redeemRecordings.next() {
            return Just(value)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        } else {
            return wrapped.redeem(
                    orders
            )
        }
    }

    struct Mocks: Codable {
        var redeemRecordings: MockAnswer<IdentifiedArrayOf<OrderResponse>>? = .delegate
    }
    func recordedData() throws -> CodableMock {
        return try CodableMock(
            "RedeemService",
            Mocks(
                redeemRecordings: redeemRecordings
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
        hideWelcomeDrawerRecordings = mocks?.hideWelcomeDrawerRecordings ?? .delegate
        readInternalCommunicationsRecordings = mocks?.readInternalCommunicationsRecordings ?? .delegate
        hideWelcomeMessageRecordings = mocks?.hideWelcomeMessageRecordings ?? .delegate
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
    var hideWelcomeDrawerRecordings: MockAnswer<Bool>
    var hideWelcomeDrawer: Bool {
        set {
            if isRecording {
                hideWelcomeDrawerRecordings.record(newValue)
            }
            wrapped.hideWelcomeDrawer = newValue }
        get {
            guard !isRecording else {
                let result = wrapped.hideWelcomeDrawer
                hideWelcomeDrawerRecordings.record(result)
                return result
            }

            if let first = hideWelcomeDrawerRecordings.next() {
                return first
            }
            return wrapped.hideWelcomeDrawer
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

    /// AnyObject
    struct Mocks: Codable {
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
        var hideWelcomeDrawerRecordings: MockAnswer<Bool>? = .delegate
        var readInternalCommunicationsRecordings: MockAnswer<[String]>? = .delegate
        var hideWelcomeMessageRecordings: MockAnswer<Bool>? = .delegate
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
                hideWelcomeDrawerRecordings: hideWelcomeDrawerRecordings,
                readInternalCommunicationsRecordings:readInternalCommunicationsRecordings,
                hideWelcomeMessageRecordings:hideWelcomeMessageRecordings
            )
        )
    }
}


struct SerializableX509: Codable {
    let payload: X509
    init(with payload: X509) {
        self.payload = payload
    }
    static func from(_ list: Array<X509>) -> Array<SerializableX509> {
        list.map { SerializableX509(with: $0) }
    }

    static func from(_ value: X509) -> SerializableX509 {
        SerializableX509(with: value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(payload.derBytes ?? nil)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let x509Data = try container.decode(Data.self)
        payload = try X509(der: x509Data)
    }
    func unwrap() -> X509 {
        return payload
    }
}

struct SerializableResult<T: Codable, E: Swift.Error & Codable>: Codable {
    let payload: Result<T, E>
    init(with payload: Result<T, E>) {
        self.payload = payload
    }
    static func from(_ list: Array<Result<T, E>>) -> Array<Self> {
        list.map { Self(with: $0) }
    }

    static func from(_ value: Result<T, E>) -> Self {
        Self(with: value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.payload {
        case .success(let value):
            try container.encode(value)
        case .failure(let error):
            try container.encode(error)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let success = try? container.decode(T.self) {
            payload = .success(success)
        } else if let failure = try? container.decode(E.self) {
            payload = .failure(failure)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode Result")
        }
    }
    func unwrap() -> Result<T, E> {
        return payload
    }
}

extension Array where Element == SerializableX509 {
    func unwrap() -> [X509] {
        map(\.payload)
    }
}

extension Array {
    func unwrap<T: Codable, E: Codable & Swift.Error>() -> [Result<T, E>] where Element == SerializableResult<T, E> {
        map(\.payload)
    }
}

#endif
