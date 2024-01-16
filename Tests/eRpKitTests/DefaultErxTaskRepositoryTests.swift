//
//  Copyright (c) 2024 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Combine
@testable import eRpKit
import Nimble
import TestUtils
import XCTest

final class DefaultErxTaskRepositoryTests: XCTestCase {
    func testGetPagedTasksEvents() {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()
        let gkvProfilePublisher = Just(Profile(name: "GKV Profile")).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = DefaultErxTaskRepository(
            disk: mockLocalDataStore,
            cloud: mockRemoteDataStore,
            profile: gkvProfilePublisher
        )

        mockLocalDataStore.fetchLatestLastModifiedForErxTasksClosure = {
            if mockLocalDataStore.fetchLatestLastModifiedForErxTasksCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.listAllTasksAfterClosure = { timestamp in
            if timestamp == nil {
                return Just(Fixtures.erxTaskPageA).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.listTasksNextPageOfClosure = { previousPage in
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

        mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.loadRemoteLatestTasks()
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(beTrue())
            })

        expect(mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedCallsCount).to(equal(3))
        expect(mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedReceivedInvocations.count).to(equal(3))
        expect(mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedReceivedInvocations[0]).to(equal(
            (tasks: Fixtures.erxTaskPageA.content, updateProfileLastAuthenticated: true)
        ))
        expect(mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedReceivedInvocations[1]).to(equal(
            (tasks: Fixtures.erxTaskPageB.content, updateProfileLastAuthenticated: true)
        ))
        expect(mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedReceivedInvocations[2]).to(equal(
            (tasks: Fixtures.erxTaskPageC.content, updateProfileLastAuthenticated: true)
        ))
    }

    func testLoadingFromRemoteToCallInCorrectOrderForGKV() throws {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()
        let gkvProfilePublisher = Just(Profile(name: "GKV Profile")).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        let sut = DefaultErxTaskRepository(
            disk: mockLocalDataStore,
            cloud: mockRemoteDataStore,
            profile: gkvProfilePublisher
        )
        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listTasksRemote",
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
        mockLocalDataStore.fetchLatestLastModifiedForErxTasksClosure = {
            actualCallOrder.append("lastModifiedErxTaskLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }
        mockRemoteDataStore.listAllTasksAfterClosure = { _ in
            actualCallOrder.append("listTasksRemote")
            return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }

        // medication dispenses
        mockRemoteDataStore.listMedicationDispensesForClosure = { _ in
            actualCallOrder.append("listMDRemote")
            return Just([Fixtures.medicationDispense1]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }
        mockLocalDataStore.saveMedicationDispensesClosure = { _ in
            actualCallOrder.append("saveMDLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // tasks
        mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedClosure = { _, _ in
            actualCallOrder.append("saveTasksLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockLocalDataStore.listAllTasksClosure = {
            actualCallOrder.append("listAllTasksLocal")
            return Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // communications
        mockLocalDataStore.fetchLatestTimestampForCommunicationsClosure = {
            actualCallOrder.append("latestTimestampCommunicationLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }
        mockRemoteDataStore.listAllCommunicationsAfterForClosure = { _, _ in
            actualCallOrder.append("listAllCommunicationsRemote")
            return Just([]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }
        mockLocalDataStore.saveCommunicationsClosure = { _ in
            actualCallOrder.append("saveCommunicationsLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // audit events
        mockRemoteDataStore.listAllAuditEventsAfterForClosure = { _, _ in
            actualCallOrder.append("listAllAuditEventsRemote")
            return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        }

        let result = try awaitPublisher(sut.loadRemoteAll(for: nil))
        expect(result) == []
        expect(actualCallOrder) == expectedCallOrder
    }

    func testLoadingFromRemoteToCallInCorrectOrderForPKV() throws {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()
        let pkvProfilePublisher = Just(Profile(name: "PKV Profile", insuranceType: .pKV))
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let sut = DefaultErxTaskRepository(
            disk: mockLocalDataStore,
            cloud: mockRemoteDataStore,
            profile: pkvProfilePublisher
        )
        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listTasksRemote",
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
        mockLocalDataStore.fetchLatestLastModifiedForErxTasksClosure = {
            actualCallOrder.append("lastModifiedErxTaskLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }
        mockRemoteDataStore.listAllTasksAfterClosure = { _ in
            actualCallOrder.append("listTasksRemote")
            return Just(PagedContent(content: [Fixtures.taskCompleted], next: nil))
                .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }

        // charge items
        mockLocalDataStore.fetchLatestTimestampForChargeItemsClosure = {
            actualCallOrder.append("fetchLatestTimestampForChargeItemsLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockRemoteDataStore.listAllChargeItemsAfterClosure = { _ in
            actualCallOrder.append("listAllChargeItemsRemote")
            return Just([Fixtures.chargeItem])
                .setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }

        mockLocalDataStore.saveChargeItemsClosure = { _ in
            actualCallOrder.append("saveChargeItemLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // medication dispenses
        mockRemoteDataStore.listMedicationDispensesForClosure = { _ in
            actualCallOrder.append("listMDRemote")
            return Just([Fixtures.medicationDispense1]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }
        mockLocalDataStore.saveMedicationDispensesClosure = { _ in
            actualCallOrder.append("saveMDLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // tasks
        mockLocalDataStore.saveTasksUpdateProfileLastAuthenticatedClosure = { _, _ in
            actualCallOrder.append("saveTasksLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockLocalDataStore.listAllTasksClosure = {
            actualCallOrder.append("listAllTasksLocal")
            return Just([]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // communications
        mockLocalDataStore.fetchLatestTimestampForCommunicationsClosure = {
            actualCallOrder.append("latestTimestampCommunicationLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }
        mockRemoteDataStore.listAllCommunicationsAfterForClosure = { _, _ in
            actualCallOrder.append("listAllCommunicationsRemote")
            return Just([]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
        }
        mockLocalDataStore.saveCommunicationsClosure = { _ in
            actualCallOrder.append("saveCommunicationsLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        // audit events
        mockRemoteDataStore.listAllAuditEventsAfterForClosure = { _, _ in
            actualCallOrder.append("listAllAuditEventsRemote")
            return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        }

        let result = try awaitPublisher(sut.loadRemoteAll(for: nil))
        expect(result) == []
        expect(actualCallOrder) == expectedCallOrder
    }

    func testLoadingCountOfUnreadCommunicationsAndChargeItems() throws {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()
        let pkvProfilePublisher = Just(Profile(name: "PKV Profile", insuranceType: .pKV))
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        let sut = DefaultErxTaskRepository(
            disk: mockLocalDataStore,
            cloud: mockRemoteDataStore,
            profile: pkvProfilePublisher
        )

        let expectedCallOrder = [
            "listAllCommunicationsLocal",
            "listAllChargeItemsLocal",
        ]
        var actualCallOrder = [String]()

        mockLocalDataStore.listAllCommunicationsForClosure = { _ in
            actualCallOrder.append("listAllCommunicationsLocal")
            return Just([Fixtures.communication]).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockLocalDataStore.listAllChargeItemsClosure = {
            actualCallOrder.append("listAllChargeItemsLocal")
            return Just([Fixtures.sparseChargeItemRead, Fixtures.sparseChargeItemNotRead,
                         Fixtures.sparseChargeItemNotRead2])
                .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        let result = try awaitPublisher(sut.countAllUnreadCommunicationsAndChargeItems(for: .all))
        expect(result) == 2
        expect(actualCallOrder) == expectedCallOrder
    }
}

extension DefaultErxTaskRepositoryTests {
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
            )
        )

        static let erxTask1 = ErxTask(identifier: "task1", status: .ready)
        static let erxTask2 = ErxTask(identifier: "task2", status: .ready)
        static let erxTask3 = ErxTask(identifier: "task3", status: .ready)
        static let erxTask4 = ErxTask(identifier: "task4", status: .ready)
        static let erxTask5 = ErxTask(identifier: "task5", status: .ready)
        static let erxTask6 = ErxTask(identifier: "task6", status: .ready)
        static let erxTask7 = ErxTask(identifier: "task7", status: .ready)
        static let erxTask8 = ErxTask(identifier: "task8", status: .ready)
        static let erxTask9 = ErxTask(identifier: "task9", status: .ready)

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
    }
}
