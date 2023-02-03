//
//  Copyright (c) 2023 gematik GmbH
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
    func testGetPagedAuditEvents() {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()

        let sut = DefaultErxTaskRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)

        mockLocalDataStore.fetchLatestTimestampForAuditEventsClosure = {
            if mockLocalDataStore.fetchLatestTimestampForAuditEventsCallsCount == 1 {
                return Just(nil)
                    .setFailureType(to: LocalStoreError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: LocalStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.listAllAuditEventsAfterForClosure = { timestamp, _ in
            if timestamp == nil {
                return Just(Fixtures.auditEventPageA).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockRemoteDataStore.listAuditEventsNextPageOfClosure = { previousPage in
            guard let next = previousPage.next else {
                return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
            }
            if next == Fixtures.auditEventPageA.next {
                return Just(Fixtures.auditEventPageB).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else if next == Fixtures.auditEventPageB.next {
                return Just(Fixtures.auditEventPageC).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: RemoteStoreError.notImplemented).eraseToAnyPublisher()
            }
        }

        mockLocalDataStore.saveAuditEventsReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.loadRemoteLatestAuditEvents(for: nil)
            .first()
            .test(failure: { _ in
            }, expectations: { result in
                expect(result).to(beTrue())
            })

        expect(mockLocalDataStore.saveAuditEventsCallsCount).to(equal(3))
        expect(mockLocalDataStore.saveAuditEventsReceivedInvocations).to(equal([Fixtures.auditEventPageA.content,
                                                                                Fixtures.auditEventPageB.content,
                                                                                Fixtures.auditEventPageC.content]))
    }

    func testLoadingFromRemoteToCallInCorrectOrder() throws {
        let mockLocalDataStore = MockErxLocalDataStore()
        let mockRemoteDataStore = MockErxRemoteDataStore()

        let sut = DefaultErxTaskRepository(disk: mockLocalDataStore, cloud: mockRemoteDataStore)
        let expectedCallOrder = [
            "lastModifiedErxTaskLocal",
            "listTasksRemote",
            "listMDRemote",
            "saveMDLocal",
            "saveTasksLocal",
            "latestTimestampCommunicationLocal",
            "listAllCommunicationsRemote",
            "saveCommunicationsLocal",
            "latestTimestampAuditEventLocal",
            "listAllAuditEventsRemote",
            "saveAuditEventsLocal",
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
            return Just([Fixtures.taskCompleted]).setFailureType(to: RemoteStoreError.self).eraseToAnyPublisher()
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
        mockLocalDataStore.fetchLatestTimestampForAuditEventsClosure = {
            actualCallOrder.append("latestTimestampAuditEventLocal")
            return Just(nil).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        mockRemoteDataStore.listAllAuditEventsAfterForClosure = { _, _ in
            actualCallOrder.append("listAllAuditEventsRemote")
            return Just(PagedContent(content: [], next: nil)).setFailureType(to: RemoteStoreError.self)
                .eraseToAnyPublisher()
        }

        mockLocalDataStore.saveAuditEventsClosure = { _ in
            actualCallOrder.append("saveAuditEventsLocal")
            return Just(true).setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        }

        let result = try awaitPublisher(sut.loadRemoteAll(for: nil))
        expect(result) == []
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

        static let medicationDispense1 = ErxTask.MedicationDispense(
            identifier: "6543212345-2",
            taskId: "6543212345",
            insuranceId: "987652345",
            pzn: "123124",
            name: nil,
            dose: nil,
            dosageForm: nil,
            dosageInstruction: nil,
            amount: 1,
            telematikId: "1234521231234345456",
            whenHandedOver: "2022-02-02",
            lot: nil,
            expiresOn: nil
        )
    }
}
