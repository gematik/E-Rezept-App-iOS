//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import Dependencies
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import ErxTaskRepository
import Nimble
import TestUtils
import XCTest

@MainActor
final class ErxTaskRepositoryTests: XCTestCase {
    func testGetPagedTasksEvents() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        let gkvProfile = Profile(name: "GKV Profile")

        mockLocalDataStore
            .fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                if mockLocalDataStore
                    .fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorCallsCount == 1 {
                    return Just(.none)
                        .setFailureType(to: LocalStoreError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
                }
            }
        mockRemoteDataStore
            .listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { sparseTask, _ in
                if sparseTask.next == Fixtures.erxTaskPageA.next {
                    return Just(Fixtures.erxTaskPageA).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else if sparseTask.next == Fixtures.erxTaskPageB.next {
                    return Just(Fixtures.erxTaskPageB).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else if sparseTask.next == Fixtures.erxTaskPageC.next {
                    return Just(Fixtures.erxTaskPageC).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

        mockRemoteDataStore
            .listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { timestamp, _ in
                if timestamp == nil {
                    return Just(Fixtures.erxTaskPageA).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

        mockRemoteDataStore
            .listTasksNextPageOfPreviousPagePagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { previousPage, _ in
                guard let next = previousPage.next else {
                    return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
                }
                if next == Fixtures.erxTaskPageA.next {
                    return Just(Fixtures.erxTaskPageB).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else if next == Fixtures.erxTaskPageB.next {
                    return Just(Fixtures.erxTaskPageC).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
                }
            }

        mockLocalDataStore
            .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReturnValue =
            Just(true)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
        } operation: {
            try await ErxTaskRepository.loadRemoteLatestTasks(gkvProfile.identifier)

            expect(mockLocalDataStore
                .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorCallsCount)
                .to(equal(3))
            expect(mockLocalDataStore
                .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations
                .count).to(equal(3))
            expect(mockLocalDataStore
                .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations[
                    0
                ])
                .to(equal(
                    (tasks: Fixtures.erxTaskPageA.content, gkvProfile.identifier, updateProfileLastAuthenticated: true)
                ))
            expect(mockLocalDataStore
                .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations[
                    1
                ])
                .to(equal(
                    (tasks: Fixtures.erxTaskPageB.content, gkvProfile.identifier, updateProfileLastAuthenticated: true)
                ))
            expect(mockLocalDataStore
                .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorReceivedInvocations[
                    2
                ])
                .to(equal(
                    (tasks: Fixtures.erxTaskPageC.content, gkvProfile.identifier, updateProfileLastAuthenticated: true)
                ))
        }
    }

    func testLoadingFromRemoteToCallInCorrectOrderForGKV() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        let gkvProfile = Profile(name: "GKV Profile")
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(gkvProfile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listTasksRemote",
            "listDetailedTasksRemote",
            "listMDRemote",
            "saveMDLocal",
            "saveTasksLocal",
            "latestTimestampCommunicationLocal",
            "listAllCommunicationsRemote",
            "saveCommunicationsLocal",
            "listAllTasksLocal",
        ]
        var actualCallOrder = [String]()

        // tasks
        mockLocalDataStore
            .fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("lastModifiedErxTaskLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listTasksRemote")
                return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                    .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listDetailedTasksRemote")
                return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                    .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }

        // medication dispenses
        mockRemoteDataStore
            .listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listMDRemote")
                return Just([Fixtures.medicationDispense1]).setFailureType(to: RemoteStoreError.self)
                    .eraseToAnyPublisher()
            }
        mockLocalDataStore.saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure = { _ in
            actualCallOrder.append("saveMDLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // tasks
        mockLocalDataStore
            .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("saveTasksLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore.listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure = { _ in
            actualCallOrder.append("listAllTasksLocal")
            return Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // communications
        mockLocalDataStore
            .fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("latestTimestampCommunicationLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllCommunicationsRemote")
                return Just([]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }
        mockLocalDataStore
            .saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
                actualCallOrder.append("saveCommunicationsLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        // audit events
        mockRemoteDataStore
            .listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllAuditEventsRemote")
                return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                    .eraseToAnyPublisher()
            }

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
        } operation: {
            let result = try await sut.loadRemoteAllTasks(nil, nil)
            expect(result) == []
            expect(actualCallOrder) == expectedCallOrder
        }
    }

    func testLoadingFromRemoteToCallInCorrectOrderForPKV() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        let pkvProfile = Profile(name: "PKV Profile", insuranceType: .pKV)
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(pkvProfile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listTasksRemote",
            "listDetailedTasksRemote",
            "listMDRemote",
            "saveMDLocal",
            "saveTasksLocal",
            "latestTimestampCommunicationLocal",
            "listAllCommunicationsRemote",
            "saveCommunicationsLocal",
            "fetchLatestTimestampForChargeItemsLocal",
            "listAllChargeItemsRemote",
            "saveChargeItemLocal",
            "listAllTasksLocal",
        ]
        var actualCallOrder = [String]()

        // tasks
        mockLocalDataStore
            .fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("lastModifiedErxTaskLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listTasksRemote")
                return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                    .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listDetailedTasksRemote")
                return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                    .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }

        // charge items
        mockLocalDataStore
            .fetchLatestTimestampForChargeItemsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("fetchLatestTimestampForChargeItemsLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockRemoteDataStore
            .listAllChargeItemsAfterReferenceDateStringProfileIdUUIDAnyPublisherErxChargeItemRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listAllChargeItemsRemote")
                return Just([Fixtures.chargeItem])
                    .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore
            .saveChargeItemsErxSparseChargeItemOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
                actualCallOrder.append("saveChargeItemLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        // medication dispenses
        mockRemoteDataStore
            .listMedicationDispensesForIdErxTaskIDProfileIdUUIDAnyPublisherErxMedicationDispenseRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listMDRemote")
                return Just([Fixtures.medicationDispense1]).setFailureType(to: RemoteStoreError.self)
                    .eraseToAnyPublisher()
            }
        mockLocalDataStore.saveMedicationDispensesErxMedicationDispenseAnyPublisherBoolLocalStoreErrorClosure = { _ in
            actualCallOrder.append("saveMDLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // tasks
        mockLocalDataStore
            .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("saveTasksLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore.listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure = { _ in
            actualCallOrder.append("listAllTasksLocal")
            return Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // communications
        mockLocalDataStore
            .fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("latestTimestampCommunicationLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllCommunicationsRemote")
                return Just([]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }
        mockLocalDataStore
            .saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
                actualCallOrder.append("saveCommunicationsLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        // audit events
        mockRemoteDataStore
            .listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllAuditEventsRemote")
                return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                    .eraseToAnyPublisher()
            }

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
        } operation: {
            let result = try await sut.loadRemoteAllTasks(nil, pkvProfile.identifier)
            expect(result) == []
            expect(actualCallOrder) == expectedCallOrder
        }
    }

    func testLoadingCountOfUnreadCommunicationsAndChargeItems() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        let pkvProfile = Profile(name: "PKV Profile", insuranceType: .pKV)
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(pkvProfile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let expectedCallOrder = [
            "listAllCommunicationsLocal",
            "listAllEuCommunicationsLocal",
            "listAllChargeItemsLocal",
        ]
        var actualCallOrder = [String]()

        mockLocalDataStore
            .listAllCommunicationsForProfileErxTaskCommunicationProfileAnyPublisherErxTaskCommunicationLocalStoreErrorClosure =
            { _ in
                actualCallOrder.append("listAllCommunicationsLocal")
                return Just([Fixtures.communication]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore
            .listAllEuCommunicationCountryCodeStringProfileIdUUIDAnyPublisherEuCommunicationLocalStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listAllEuCommunicationsLocal")
                return Just([Fixtures.euCommunication]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore
            .listAllChargeItemsOfProfileIdUUIDAnyPublisherErxSparseChargeItemLocalStoreErrorClosure = { _ in
                actualCallOrder.append("listAllChargeItemsLocal")
                return Just([Fixtures.sparseChargeItemRead, Fixtures.sparseChargeItemNotRead,
                             Fixtures.sparseChargeItemNotRead2])
                    .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
        } operation: {
            let stream = sut.countAllUnreadCommunicationsAndChargeItems(pkvProfile.identifier, .all)
            var iterator = stream.makeAsyncIterator()
            let result = try await iterator.next()
            expect(result) == 3
            expect(actualCallOrder) == expectedCallOrder
        }
    }

    func testDeleteTask() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        var actualCallOrder = [String]()
        let profile = Profile(name: "Profile")
        let asyncCallCounter = TestActor()
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        mockLocalDataStore.deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
            actualCallOrder.append("deleteLocalTasksCalled")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockRemoteDataStore.deleteTasksErxTaskProfileIdUUIDAnyPublisherBoolRemoteStoreErrorClosure = { _, _ in
            actualCallOrder.append("deleteRemoteTasksCalled")
            return Just(true).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }
        let expectedCallOrder = [
            "deleteRemoteTasksCalled",
            "deleteLocalTasksCalled",
        ]

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
            dependencies.medicationScheduleRepository.delete = { _ in
                await asyncCallCounter.increaseCount()
            }
        } operation: {
            try await sut.deleteTask([Fixtures.erxTaskWithSchedule], profile.identifier)
            let actualDeleteCalls = await asyncCallCounter.actualCallCount()
            expect(actualDeleteCalls).to(equal(1))
            expect(actualCallOrder) == expectedCallOrder
        }
    }

    func testDeleteScannedTask() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        var actualCallOrder = [String]()
        let profile = Profile(name: "Profile")
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let asyncCallCounter = TestActor()

        mockLocalDataStore.deleteTasksErxTaskInProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
            actualCallOrder.append("deleteLocalTasksCalled")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        let expectedCallOrder = [
            "deleteLocalTasksCalled",
        ]

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
            dependencies.medicationScheduleRepository.delete = { _ in
                await asyncCallCounter.increaseCount()
            }
        } operation: {
            try await sut.deleteTask([Fixtures.scannedTaskWithMedicationSchedule], profile.identifier)
            expect(actualCallOrder) == expectedCallOrder
            let actualDeleteCalls = await asyncCallCounter.actualCallCount()
            expect(actualDeleteCalls).to(equal(1))
        }
    }

    func testUpdateCancelledTask() async throws {
        let mockLocalDataStore = ErxLocalDataStoreMock()
        let mockRemoteDataStore = ErxRemoteDataStoreMock()
        var actualCallOrder = [String]()
        let profile = Profile(name: "Profile")
        let profileDataStoreMock = ProfileDataStoreMock()
        profileDataStoreMock
            .fetchProfileByIdentifierProfileIDAnyPublisherProfileLocalStoreErrorReturnValue = Just(profile)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let task = ErxTask(identifier: "1234-5678-9098", status: .ready, flowType: .pharmacyOnly)

        // tasks
        mockLocalDataStore
            .fetchLatestLastModifiedForErxTasksOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("lastModifiedErxTaskLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockRemoteDataStore
            .listAllTasksAfterReferenceDateStringProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listAllTasksRemote")
                return Just(PagedContent(
                    content: [ErxTask(identifier: task.identifier, status: .cancelled, flowType: .pharmacyOnly)],
                    next: nil
                ))
                .setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
            }

        mockRemoteDataStore
            .listDetailedTasksForTasksPagedContentErxTaskProfileIdUUIDAnyPublisherPagedContentErxTaskRemoteStoreErrorClosure =
            { _, _ in
                actualCallOrder.append("listDetailedTasksRemote")
                return Just(PagedContent(
                    content: [task],
                    next: nil
                ))
                .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore.fetchTaskByIdErxTaskIDAccessCodeStringAnyPublisherErxTaskLocalStoreErrorClosure = { _, _ in
            actualCallOrder.append("fetchTaskByAccessCodeLocal")
            return Just(task)
                .setFailureType(to: LocalStoreError.self)
                .eraseToAnyPublisher()
        }

        mockLocalDataStore
            .saveTasksErxTaskInProfileIdUUIDUpdateProfileLastAuthenticatedBoolAnyPublisherBoolLocalStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("saveTasksLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        mockLocalDataStore.listAllTasksOfProfileIdUUIDAnyPublisherErxTaskLocalStoreErrorClosure = { _ in
            actualCallOrder.append("listAllTasksLocal")
            return Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // communications
        mockLocalDataStore
            .fetchLatestTimestampForCommunicationsOfProfileIdUUIDAnyPublisherStringLocalStoreErrorClosure = { _ in
                actualCallOrder.append("latestTimestampCommunicationLocal")
                return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }
        mockRemoteDataStore
            .listAllCommunicationsAfterReferenceDateStringForProfileErxTaskCommunicationProfileProfileIdUUIDAnyPublisherErxTaskCommunicationRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllCommunicationsRemote")
                return Just([]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            }
        mockLocalDataStore
            .saveCommunicationsErxTaskCommunicationOfProfileIdUUIDAnyPublisherBoolLocalStoreErrorClosure = { _, _ in
                actualCallOrder.append("saveCommunicationsLocal")
                return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
            }

        // audit events
        mockRemoteDataStore
            .listAllAuditEventsAfterReferenceDateStringForLocaleStringProfileIdUUIDAnyPublisherPagedContentErxAuditEventRemoteStoreErrorClosure =
            { _, _, _ in
                actualCallOrder.append("listAllAuditEventsRemote")
                return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                    .eraseToAnyPublisher()
            }

        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listAllTasksRemote",
            "fetchTaskByAccessCodeLocal",
            "listDetailedTasksRemote",
            "saveTasksLocal",
            "latestTimestampCommunicationLocal",
            "listAllCommunicationsRemote",
            "saveCommunicationsLocal",
            "listAllTasksLocal",
        ]

        let sut = ErxTaskRepository.liveValue

        try await withDependencies { dependencies in
            dependencies.erxLocalDataStore = mockLocalDataStore
            dependencies.erxRemoteDataStore = mockRemoteDataStore
            dependencies.profileDataStore = profileDataStoreMock
        } operation: {
            let result = try await sut.loadRemoteAllTasks(nil, profile.identifier)
            expect(result).to(beEmpty())
            expect(actualCallOrder) == expectedCallOrder
        }
    }

    actor TestActor {
        private var callCount = 0

        func increaseCount() {
            callCount += 1
        }

        func actualCallCount() -> Int {
            callCount
        }
    }
}

extension ErxTaskRepositoryTests {
    enum Fixtures {
        static let taskCompleted = ErxTask(identifier: "6543212345", status: .completed, flowType: .pharmacyOnly)

        static let auditEvent1 = ErxAuditEvent(identifier: "auditEvent1", timestamp: "2021-01-21T09:00:00Z")
        static let auditEvent2 = ErxAuditEvent(identifier: "auditEvent2", timestamp: "2021-01-21T10:00:00Z")
        static let auditEvent3 = ErxAuditEvent(identifier: "auditEvent3", timestamp: "2021-01-21T11:00:00Z")
        static let auditEvent4 = ErxAuditEvent(identifier: "auditEvent4", timestamp: "2021-01-21T12:00:00Z")
        static let auditEvent5 = ErxAuditEvent(identifier: "auditEvent5", timestamp: "2021-01-21T13:00:00Z")
        static let auditEvent6 = ErxAuditEvent(identifier: "auditEvent6", timestamp: "2021-01-21T14:00:00Z")
        static let auditEvent7 = ErxAuditEvent(identifier: "auditEvent7", timestamp: "2021-01-21T15:00:00Z")
        static let auditEvent8 = ErxAuditEvent(identifier: "auditEvent8", timestamp: "2021-01-21T16:00:00Z")
        static let auditEvent9 = ErxAuditEvent(identifier: "auditEvent9", timestamp: "2021-01-21T17:00:00Z")

        static let auditEventPageA: PagedContent<[ErxAuditEvent]> = PagedContent(content: [
            auditEvent1,
            auditEvent2,
            auditEvent3,
            auditEvent4,
            auditEvent5,
        ], next: URL(string: "https://localhost/page/2"))
        static let auditEventPageB: PagedContent<[ErxAuditEvent]> = PagedContent(content: [
            auditEvent6,
            auditEvent7,
            auditEvent8,
            auditEvent9,
        ], next: URL(string: "https://localhost/page/3"))
        static let auditEventPageC: PagedContent<[ErxAuditEvent]> = PagedContent(content: [
            auditEvent9,
        ], next: nil)

        static let medicationDispense1 = ErxMedicationDispense(
            identifier: "6543212345-2",
            taskId: "6543212345",
            insuranceId: "987652345",
            dosageInstruction: nil,
            telematikId: "1234521231234345456",
            whenHandedOver: "2022-02-02",
            quantity: .init(value: "1"),
            noteText: "pharmacist note",
            medication: .init(
                name: nil,
                profile: .pzn,
                drugCategory: .avm,
                pzn: "123124",
                isVaccine: false,
                amount: ErxMedication.Ratio(numerator: .init(value: "1")),
                dosageForm: nil,
                normSizeCode: nil,
                batch: .init(
                    lotNumber: "Charge number X",
                    expiresOn: "2021-01-21T09:00:00Z"
                ),
                packaging: nil,
                manufacturingInstructions: nil,
                ingredients: []
            ),
            epaMedication: nil,
            diGaDispense: nil
        )

        static let erxTask1 = ErxTask(identifier: "task1", status: .ready, flowType: .pharmacyOnly)
        static let erxTask2 = ErxTask(identifier: "task2", status: .ready, flowType: .pharmacyOnly)
        static let erxTask3 = ErxTask(identifier: "task3", status: .ready, flowType: .pharmacyOnly)
        static let erxTask4 = ErxTask(identifier: "task4", status: .ready, flowType: .pharmacyOnly)
        static let erxTask5 = ErxTask(identifier: "task5", status: .ready, flowType: .pharmacyOnly)
        static let erxTask6 = ErxTask(identifier: "task6", status: .ready, flowType: .pharmacyOnly)
        static let erxTask7 = ErxTask(identifier: "task7", status: .ready, flowType: .pharmacyOnly)
        static let erxTask8 = ErxTask(identifier: "task8", status: .ready, flowType: .pharmacyOnly)
        static let erxTask9 = ErxTask(identifier: "task9", status: .ready, flowType: .pharmacyOnly)

        static let scannedTaskWithMedicationSchedule = ErxTask(
            identifier: "scannedTask",
            status: .ready,
            flowType: .pharmacyOnly,
            source: .scanner,
            medicationSchedule: medicationSchedule
        )

        static let erxTaskPageA: PagedContent<[ErxTask]> = PagedContent(content: [
            erxTask1,
            erxTask2,
            erxTask3,
            erxTask5,
        ], next: URL(string: "https://localhost/page/2"))

        static let erxTaskPageB: PagedContent<[ErxTask]> = PagedContent(content: [
            erxTask5,
            erxTask6,
            erxTask7,
            erxTask8,
        ], next: URL(string: "https://localhost/page/3"))

        static let erxTaskPageC: PagedContent<[ErxTask]> = PagedContent(content: [
            erxTask9,
        ], next: nil)

        static let communication = ErxTask.Communication(
            identifier: "com id",
            profile: .reply,
            taskId: "task id 13",
            userId: "user id",
            telematikId: "telematik id",
            timestamp: "",
            payloadJSON: "",
            isRead: false
        )

        static let euCommunication = EuCommunication(
            id: UUID(),
            eventType: .createdAccessCode,
            taskId: "task id 13",
            orderId: "order id",
            timestamp: Date(),
            isRead: false,
            countryCode: "DE"
        )

        static let chargeItem = ErxChargeItem(identifier: "id 12", fhirData: Data(), taskId: "task id 12")

        static let sparseChargeItemRead = ErxSparseChargeItem(
            identifier: "task id 13",
            taskId: "task id 12",
            fhirData: Data(),
            isRead: true
        )
        static let sparseChargeItemNotRead = ErxSparseChargeItem(
            identifier: "task id 13",
            taskId: "task id 13",
            fhirData: Data(),
            isRead: false
        )

        static let sparseChargeItemNotRead2 = ErxSparseChargeItem(
            identifier: "task id 14",
            taskId: "task id 14",
            fhirData: Data(),
            isRead: false
        )

        static let erxTaskWithSchedule = ErxTask(
            identifier: "task1",
            status: .ready,
            flowType: .pharmacyOnly,
            medicationSchedule: medicationSchedule
        )

        static let medicationSchedule: MedicationSchedule = .init(
            start: Date(),
            end: Date(),
            title: "",
            dosageInstructions: "",
            taskId: "",
            isActive: true,
            entries: []
        )
    }
}
