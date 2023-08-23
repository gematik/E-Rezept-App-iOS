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
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import TestUtils
import XCTest

// swiftlint:disable file_length
final class ErxTaskCoreDataStoreTest: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var coreDataFactory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("testDB")
    }

    override func tearDown() {
        // important to destory the store so that each test starts with an empty database
        if let controller = try? coreDataFactory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = coreDataFactory else {
            #if os(macOS)
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: FileProtectionType(rawValue: "none")
            )

            #else
            let factory = LocalStoreFactory(
                url: databaseFile,
                fileProtection: .completeUnlessOpen
            )
            #endif
            coreDataFactory = factory
            return factory
        }
        return factory
    }

    private func loadErxCoreDataStore(for profileId: UUID? = nil) -> ErxTaskCoreDataStore {
        ErxTaskCoreDataStore(
            profileId: profileId,
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: .immediate,
            backgroundQueue: .main
        )
    }

    private func loadProfileCoreDataStore() -> ProfileCoreDataStore {
        ProfileCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: .immediate,
            backgroundQueue: .immediate
        )
    }

    // MARK: - ErxTasks

    lazy var task1: ErxTask = {
        ErxTask(identifier: "id_1",
                status: .ready,
                flowType: ErxTask.FlowType.pharmacyOnly,
                lastModified: "2021-07-10T10:55:04+02:00")
    }()

    lazy var task2: ErxTask = {
        ErxTask(identifier: "id_2",
                status: .ready,
                flowType: ErxTask.FlowType.pharmacyOnly,
                lastModified: "2021-07-20T10:55:04+02:00")
    }()

    func testSaveTasks() throws {
        let store = loadErxCoreDataStore()
        let task = ErxTask(
            identifier: "id",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "access"
        )
        try store.add(tasks: [task])
    }

    func testSavingTaskWithAllPropertiesSet() throws {
        let store = loadErxCoreDataStore()
        // given
        let taskToFetch = ErxTask.Fixtures.taskWithAllFieldsFilled
        // medication dispenses must be stored before tasks
        try store.add(medicationDispenses: taskToFetch.medicationDispenses)
        try store.add(tasks: [taskToFetch])
        try store.add(communications: taskToFetch.communications)

        // when
        var receivedFetchResult: ErxTask?
        let cancellable = store.fetchTask(by: taskToFetch.identifier, accessCode: nil)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then
        expect(receivedFetchResult).toEventually(equal(taskToFetch))

        cancellable.cancel()
    }

    func testUpdatingPreviouslySavedTask() throws {
        let store = loadErxCoreDataStore()
        let task = ErxTask(
            identifier: "id",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "access"
        )
        try store.add(tasks: [task])

        let updatedTask = ErxTask(
            identifier: "id",
            status: .ready,
            flowType: ErxTask.FlowType.pharmacyOnly,
            accessCode: "new access code"
        )

        // when updating a previously saved task with same id
        try store.add(tasks: [updatedTask])

        var receivedListAllTasksValues = [[ErxTask]]()
        let cancellable = store.listAllTasks()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { erxTasks in
                receivedListAllTasksValues.append(erxTasks)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllTasksValues.count).toEventually(equal(1))
        expect(receivedListAllTasksValues[0].count).to(equal(1))
        let result = receivedListAllTasksValues[0].first
        expect(result) == updatedTask

        cancellable.cancel()
    }

    func testSaveTasksWithFailingLoadingDatabase() throws {
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerThrowableError = LocalStoreError.notImplemented
        let store = ErxTaskCoreDataStore(
            profileId: nil,
            coreDataControllerFactory: factory,
            backgroundQueue: .main
        )

        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = store.save(tasks: [task1], updateProfileLastAuthenticated: false)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                fail("did not expect to receive a value")
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(0))
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) ==
            .failure(LocalStoreError.initialization(error: factory.loadCoreDataControllerThrowableError!))

        cancellable.cancel()
    }

    func testFetchTaskByIdCodeSuccess() throws {
        let store = loadErxCoreDataStore()
        // given
        let taskToFetch = ErxTask(identifier: "id_1", status: .ready, flowType: ErxTask.FlowType.pharmacyOnly)
        try store.add(tasks: [taskToFetch])

        // when
        var receivedFetchResult: ErxTask?
        let cancellable = store.fetchTask(by: taskToFetch.identifier, accessCode: nil)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then
        expect(receivedFetchResult).toEventually(equal(taskToFetch))

        cancellable.cancel()
    }

    func testFetchTaskByIdWithAccessCodeSuccess() throws {
        let store = loadErxCoreDataStore()
        // given
        let taskToFetch = ErxTask(
            identifier: "id_1",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "accessCode_1"
        )
        try store.add(tasks: [taskToFetch])

        // when
        var receivedFetchResult: ErxTask?
        let cancellable = store.fetchTask(by: taskToFetch.identifier, accessCode: taskToFetch.accessCode)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then
        expect(receivedFetchResult).toEventually(equal(taskToFetch))

        cancellable.cancel()
    }

    func testFetchTaskByIdNoResults() throws {
        let store = loadErxCoreDataStore()
        let taskToFetch = ErxTask(identifier: "id_1", status: .ready, flowType: .pharmacyOnly)

        var receivedNoResult = false
        // when fetching a profile that has not been added to the store
        let cancellable = store.fetchTask(by: taskToFetch.identifier, accessCode: nil)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // then it should return none
        expect(receivedNoResult).toEventually(beTrue())

        cancellable.cancel()
    }

    func testFetchTaskByIdWithRelationshipToProfile() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        let tasks = [ErxTask(identifier: "id1", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode1"),
                     ErxTask(identifier: "id2", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode2")]
        try prepareStores(with: tasks, profiles: [testProfile])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let taskRelatedToProfile = ErxTask(identifier: "id3", status: .ready, flowType: .pharmacyOnly)
        try store.add(tasks: [taskRelatedToProfile])

        // when
        var receivedValue: ErxTask?
        let cancellable = store.fetchTask(by: taskRelatedToProfile.identifier, accessCode: nil)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedValue = result
            })

        // then
        expect(receivedValue).toEventually(equal(taskRelatedToProfile))

        cancellable.cancel()
    }

    func testFetchTaskByIdWhichDoesNotBelongToProfile() throws {
        // given
        let tasks = [ErxTask(identifier: "id1", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode1"),
                     ErxTask(identifier: "id2", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode2")]
        try prepareStores(with: tasks, profiles: [])

        // when setting the profile of the store
        let store = loadErxCoreDataStore(for: Profile(name: "TestProfile").identifier)

        var receivedValue: ErxTask?
        let cancellable = store.fetchTask(by: tasks[0].identifier, accessCode: nil)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedValue = result
            })

        // than the task should be fetched even it did not have a relationship to the profile
        expect(receivedValue).toEventually(equal(tasks[0]))

        cancellable.cancel()
    }

    func testSaveTaskWithProfileRelationshipToSameInsuranceId() throws {
        // given
        let patient = ErxPatient(name: "Anna", insuranceId: "X123456789")
        let testProfile = Profile(name: "Anna", insuranceId: patient.insuranceId)
        let profileStore = loadProfileCoreDataStore()
        try profileStore.add(profiles: [testProfile])
        let tasks = [ErxTask(identifier: "id1", status: .ready, flowType: .pharmacyOnly, patient: patient)]

        // when
        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(tasks: tasks)

        var receivedProfile: Profile?
        let cancellable = profileStore.fetchProfile(by: testProfile.id)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedProfile = result
            })

        // then
        expect(receivedProfile?.erxTasks).toEventually(equal(tasks))

        cancellable.cancel()
    }

    func testListAllTasks() throws {
        // given
        let store = loadErxCoreDataStore()
        let task = ErxTask(identifier: "id", status: .ready, flowType: .pharmacyOnly, accessCode: "access")
        try store.add(tasks: [task])

        // when
        var receivedValues = [[ErxTask]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllTasks()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedCompletions.count) == 0

        // then
        expect(receivedValues.first?[0]) == task

        cancellable.cancel()
    }

    func testFetchingLatestTask() throws {
        let store = loadErxCoreDataStore()
        // given
        try store.add(tasks: [task1, task2, ErxTask(identifier: "taskId_3", status: .ready, flowType: .pharmacyOnly)])
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestLastModifiedForErxTasks()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        expect(receivedLatesValues.count).toEventually(equal(1))
        // then the latest date has to be returned
        expect(receivedLatesValues.first) == task2.lastModified

        // verify that two erxTasks have been in store
        var receivedValues = [[ErxTask]]()
        let cancellable = store.listAllTasks()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { erxTasks in
                receivedValues.append(erxTasks)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues[0].count) == 3

        cancellable.cancel()
    }

    func testFetchingLatestTaskWithProfileRelationship() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(
            with: [task2, ErxTask(identifier: "taskId_3", status: .ready, flowType: .pharmacyOnly)],
            profiles: [testProfile]
        )

        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(tasks: [task1])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestLastModifiedForErxTasks()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then lastModified of the task with a relationship is returned even though
        // there is a newer task in store
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == communication1.timestamp
        expect(self.task1.lastModified?.date) < task2.lastModified!.date!
    }

    func testListingOnlyTasksWithRelationshipToProfile() throws {
        // given having a profile in store
        let testProfile = Profile(name: "TestProfile")
        // and having tasks that do not belong to that profile
        let tasks = [ErxTask(identifier: "id1", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode1"),
                     ErxTask(identifier: "id2", status: .ready, flowType: .pharmacyOnly, accessCode: "accessCode2")]
        try prepareStores(with: tasks, profiles: [testProfile])

        // when accessing the store with a profile and saving a task to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)
        let taskWithProfile = ErxTask(
            identifier: "id3",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "accessCode3"
        )
        try store.add(tasks: [taskWithProfile])

        // then listing tasks for that profile
        var receivedListAllValues = [[ErxTask]]()
        let cancellable = store.listAllTasks()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { tasks in
                receivedListAllValues.append(tasks)
            })

        // should only return the task with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == taskWithProfile

        cancellable.cancel()
    }

    func testListingAllTasksWithoutProfile() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        let tasks = [
            ErxTask(identifier: "id1",
                    status: .ready,
                    flowType: .pharmacyOnly,
                    authoredOn: "2021-07-10T10:55:04+02:00"),
            ErxTask(
                identifier: "id2",
                status: .ready,
                flowType: .pharmacyOnly,
                authoredOn: "2021-07-12T10:55:04+02:00"
            ),
        ]
        try prepareStores(with: tasks, profiles: [testProfile])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let taskWithProfile = ErxTask(
            identifier: "id3",
            status: .ready,
            flowType: .pharmacyOnly,
            accessCode: "accessCode3"
        )
        try store.add(tasks: [taskWithProfile])

        var receivedListAllValues = [[ErxTask]]()
        let cancellable = store.listAllTasksWithoutProfile()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { tasks in
                receivedListAllValues.append(tasks)
            })

        // then only the tasks without profile relationship should be returned
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 2
        expect(receivedListAllValues[0]).to(contain(tasks[0]))
        expect(receivedListAllValues[0]).to(contain(tasks[1]))

        cancellable.cancel()
    }

    // MARK: - Communications

    // swiftlint:disable line_length
    lazy var communication0: ErxTask.Communication = {
        let payload = ErxTaskOrder.Payload(
            version: String(1),
            supplyOptionsType: .shipment,
            name: "Name_0",
            address: [],
            hint: "",
            phone: ""
        )

        var payloadJSONString: String {
            guard let data = try? JSONEncoder().encode(payload) else {
                return ""
            }
            return String(data: data, encoding: .utf8) ?? ""
        }

        return ErxTask.Communication(
            identifier: "id_0",
            profile: .dispReq,
            taskId: "taskID_1",
            userId: "insuranceIdentifier_1",
            telematikId: "TelematikId_1",
            orderId: "OrderId_01",
            timestamp: "2021-07-10T10:55:04+02:00",
            payloadJSON: payloadJSONString
        )
    }()

    lazy var communication1: ErxTask.Communication = {
        let payloadJSON =
            "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
        return ErxTask.Communication(
            identifier: "id_1",
            profile: .reply,
            taskId: "taskID_1",
            userId: "insuranceIdentifier_1",
            telematikId: "TelematikId_1",
            timestamp: "2021-07-10T10:55:04+02:00",
            payloadJSON: payloadJSON
        )
    }()

    lazy var communication2: ErxTask.Communication = {
        let payloadJSON =
            "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
        return ErxTask.Communication(
            identifier: "id_2",
            profile: .reply,
            taskId: "taskID_2",
            userId: "insuranceIdentifier_2",
            telematikId: "TelematikId_2",
            timestamp: "2021-07-20T10:55:04+02:00",
            payloadJSON: payloadJSON
        )
    }()

    lazy var communication3: ErxTask.Communication = {
        let payloadJSON =
            "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
        return ErxTask.Communication(
            identifier: "id_3",
            profile: .reply,
            taskId: "taskID_3",
            userId: "insuranceIdentifier_3",
            telematikId: "TelematikId_3",
            timestamp: "2021-07-23T10:55:04+02:00",
            payloadJSON: payloadJSON
        )
    }()

    func testSaveCommunicationReply() throws {
        let store = loadErxCoreDataStore()
        try store.add(communications: [communication1])
    }

    func testListAllCommunicationReplies() throws {
        // given
        let store = loadErxCoreDataStore()
        try store.add(communications: [communication1])

        // when
        var receivedValues = [[ErxTask.Communication]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllCommunications(for: .reply)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { communication in
                receivedValues.append(communication)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first?.count).toEventually(equal(1))
        expect(receivedCompletions.count) == 0
        // then
        expect(receivedValues.first?[0]) == communication1

        cancellable.cancel()
    }

    func testUpdatingCommunicationReply() throws {
        let store = loadErxCoreDataStore()

        // listen to any changes in store
        var receivedValues = [[ErxTask.Communication]]()
        let cancellable = store.listAllCommunications(for: .reply)
            .dropFirst() // remove the subscription call
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { communication in
                receivedValues.append(communication)
            })

        try store.add(communications: [communication1])

        // when updating the same communication
        let updatedCommunication = ErxTask.Communication(
            identifier: communication1.identifier,
            profile: .reply,
            taskId: "updated",
            userId: "updated",
            telematikId: "updated",
            timestamp: "updated",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Updated\",\"url\": \"updated\"}",
            isRead: true
        )

        try store.add(communications: [updatedCommunication])

        expect(receivedValues.count) == 2
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first) == communication1
        expect(receivedValues[1].count) == 1 // must be 1 otherwise update failed
        // then verify that only `isRead` has been updated
        expect(receivedValues[1].first?.isRead) == true
        expect(receivedValues[1].first?.taskId) == communication1.taskId
        expect(receivedValues[1].first?.insuranceId) == communication1.insuranceId
        expect(receivedValues[1].first?.telematikId) == communication1.telematikId
        expect(receivedValues[1].first?.timestamp) == communication1.timestamp
        expect(receivedValues[1].first?.payloadJSON) == communication1.payloadJSON

        cancellable.cancel()
    }

    func testPreventingOverwriteOfCommunicationIsRead() throws {
        let store = loadErxCoreDataStore()
        // given: when having a communication that has isRead == true
        let communication = ErxTask.Communication(
            identifier: "id_1",
            profile: .reply,
            taskId: "taskID",
            userId: "insuranceIdentifier",
            telematikId: "TelematikId",
            timestamp: "timestamp",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}",
            isRead: true
        )

        try store.add(communications: [communication])

        // when trying to set it to false
        let updatedCommunication = ErxTask.Communication(
            identifier: communication.identifier,
            profile: .reply,
            taskId: "updated",
            userId: "updated",
            telematikId: "updated",
            timestamp: "updated",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Updated\",\"url\": \"\"}",
            isRead: false
        )

        try store.add(communications: [updatedCommunication])

        // listen to any changes in store
        var receivedValues = [[ErxTask.Communication]]()
        let cancellable = store.listAllCommunications(for: .reply)
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { communications in
                receivedValues.append(communications)
            })

        // then verify that nothing has been updated
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first) == communication
        expect(receivedValues[0].first?.isRead) == true

        cancellable.cancel()
    }

    func testFetchingLatestCommunication() throws {
        let store = loadErxCoreDataStore()
        // given
        try store.add(communications: [communication1, communication3])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestTimestampForCommunications()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == communication3.timestamp

        // verify that two entities have been in store
        var receivedValues = [[ErxTask.Communication]]()
        let cancellable = store.listAllCommunications(for: .all)
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { communications in
                receivedValues.append(communications)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues[0].count) == 2

        cancellable.cancel()
    }

    func testFetchingLatestCommunicationTimestampWithProfileRelationship() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], communications: [communication2, communication3])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: communication1.taskId, status: .ready)
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile
        try store.add(communications: [communication1])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestTimestampForCommunications()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then the timestamp of the communication with a relationship is returned even though
        // there is a newer communication in store
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == communication1.timestamp
        expect(self.communication1.timestamp.date) < communication3.timestamp.date!
    }

    func testSaveCommunicationDisReqAndReplyWithOrderID() throws {
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], communications: [])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: communication1.taskId, status: .ready)
        try store.add(tasks: [task])
        try store.add(communications: [communication0, communication1])

        var receivedValues = [ErxTask.Communication]()
        let cancellable = store.listAllCommunications(for: .all)
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { communications in
                receivedValues = communications
            })

        expect(receivedValues.count).toEventually(equal(2))
        expect(receivedValues.first?.orderId).to(equal(receivedValues.last?.orderId))

        cancellable.cancel()
    }

    func testSaveCommunicationReplyAfterDisReqWithOrderID() throws {
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], communications: [])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: communication1.taskId, status: .ready)
        try store.add(tasks: [task])
        try store.add(communications: [communication0])

        var receivedValues = [ErxTask.Communication]()
        let cancellable = store.listAllCommunications(for: .all)
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { communications in
                receivedValues = communications
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first?.orderId).to(equal(communication0.orderId))

        try store.add(communications: [communication1])
        expect(receivedValues.count).toEventually(equal(2))
        expect(receivedValues.first?.orderId).to(equal(receivedValues.last?.orderId))

        cancellable.cancel()
    }

    // swiftlint:enable line_length

    // MARK: - MedicationDispense

    func testSaveMedicationDispenses() throws {
        let store = loadErxCoreDataStore()
        try store.add(medicationDispenses: [ErxTask.Fixtures.medicationDispense])
    }

    func testUpdatingMedicationDispenses() throws {
        let store = loadErxCoreDataStore()
        var receivedValues = [[ErxMedicationDispense]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()

        // listen to any changes in store
        let cancellable = store.listAllMedicationDispenses()
            .dropFirst() // remove the subscription call
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { medicationDispense in
                receivedValues.append(medicationDispense)
            })

        // given: a `MedicationDispense` that has been saved
        try store.add(medicationDispenses: [ErxTask.Fixtures.medicationDispense])

        let updatedMedicationDispense = ErxMedicationDispense(
            identifier: ErxTask.Fixtures.medicationDispense.identifier,
            taskId: ErxTask.Fixtures.medicationDispense.taskId,
            insuranceId: "Updated insurance_id",
            dosageInstruction: "Updated dosage_instructions",
            telematikId: "Updated telematik_id",
            whenHandedOver: "Updated 2021-07-23T10:55:04+02:00",
            quantity: .init(value: "updated"),
            noteText: "Updated text",
            medication: .init(
                name: "updated name",
                profile: .unknown,
                drugCategory: .btm,
                pzn: "updated pzn",
                isVaccine: true,
                amount: .init(numerator: .init(value: "42")),
                dosageForm: "updated form",
                normSizeCode: "updated does",
                batch: .init(
                    lotNumber: "updated charge num.",
                    expiresOn: "Updated 2049-07-10T10:55:04+02:00"
                ),
                packaging: "updated package",
                manufacturingInstructions: "updated manu",
                ingredients: [.init(text: "updated text",
                                    number: "updated number",
                                    form: "updated form",
                                    strength: nil,
                                    strengthFreeText: nil)]
            )
        )

        // when updating the same medication dispense (when taskId is equal)
        try store.add(medicationDispenses: [updatedMedicationDispense])

        expect(receivedValues.count) == 2
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first) == ErxTask.Fixtures.medicationDispense
        expect(receivedValues[1].count) == 1 // must be 1 otherwise update failed
        // then verify that the same medication dispense has been updated
        expect(receivedValues[1].first) == updatedMedicationDispense

        cancellable.cancel()
    }

    func testFetchingMedicationDispense() throws {
        let store = loadErxCoreDataStore()
        // given two medicationDispenses that have been saved
        try store.add(medicationDispenses: [
            ErxTask.Fixtures.medicationDispense,
            ErxTask.Fixtures.medicationDispenseWithPZN,
        ])

        // verify that two medicationDispenses have been in store
        var receivedValues = [ErxMedicationDispense]()
        let cancellable = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { medicationDispense in
                receivedValues.append(contentsOf: medicationDispense)
            })

        expect(receivedValues.count).toEventually(equal(2))
        cancellable.cancel()
    }

    func testFetchingMedicationDispensesWithProfileRelationship() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], medicationDispenses: [ErxTask.Fixtures.medicationDispenseWithPZN])
        let medicationDispense = ErxTask.Fixtures.medicationDispense

        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: medicationDispense.taskId, status: .ready)
        try store.add(medicationDispenses: [ErxTask.Fixtures.medicationDispense])
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile

        // when
        var receivedValues = [ErxMedicationDispense]()
        _ = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { result in
                receivedValues.append(contentsOf: result)
            })

        // then the timestamp of the medicationDispense with a relationship is returned even though
        // there is a newer medicationDispense in store
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first) == ErxTask.Fixtures.medicationDispense
        expect(medicationDispense.whenHandedOver!.date) < ErxTask.Fixtures.medicationDispenseWithPZN.whenHandedOver!
            .date!
    }

    func testListingOnlyMedicationDispenseWithRelationshipToProfile() throws {
        // given having a profile and communications that do not belong to that profile
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], medicationDispenses: [ErxTask.Fixtures.medicationDispense])

        // when accessing the store with a profile and saving a communication to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)

        let task = ErxTask(identifier: ErxTask.Fixtures.medicationDispenseWithPZN.taskId, status: .ready)
        try store.add(medicationDispenses: [ErxTask.Fixtures.medicationDispenseWithPZN])
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile

        // then listing medicationDispense for that profile
        var receivedListAllValues = [[ErxMedicationDispense]]()
        let cancellable = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { medicationDispenses in
                receivedListAllValues.append(medicationDispenses)
            })

        // should only return the medicationDispense with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == ErxTask.Fixtures.medicationDispenseWithPZN

        cancellable.cancel()
    }

    // MARK: - ChargeItems

    func testSaveChargeItems() throws {
        let store = loadErxCoreDataStore()
        let item = ErxSparseChargeItem(
            identifier: "id_12345",
            fhirData: Data(),
            enteredDate: "2023-01-12T14:42:32+00:00"
        )
        try store.add(chargeItems: [item])
    }

    func testSavingSparseChargeItem() throws {
        let store = loadErxCoreDataStore()
        // given
        let chargeItemToFetch = ErxSparseChargeItem.Fixtures.chargeItem
        try store.add(chargeItems: [chargeItemToFetch])

        // when
        var receivedFetchResult = [ErxSparseChargeItem]()
        let cancellable = store.listAllChargeItems()
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then
        expect(receivedFetchResult.first).toEventually(equal(chargeItemToFetch))

        cancellable.cancel()
    }

    func testListingOnlyChargeItemsWithRelationshipToProfile() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], chargeItems: [ErxSparseChargeItem.Fixtures.chargeItem1,
                                                                 ErxSparseChargeItem.Fixtures.chargeItem2])

        // when accessing the store with a profile and saving a charge item to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(chargeItems: [ErxSparseChargeItem.Fixtures.chargeItem3])

        // then listing tasks for that profile
        var receivedListAllValues = [[ErxSparseChargeItem]]()
        let cancellable = store.listAllChargeItems()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { result in
                receivedListAllValues.append(result)
            })

        // should only return the charge item with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == ErxSparseChargeItem.Fixtures.chargeItem3

        cancellable.cancel()
    }

    func testFetchingLatestChargeItem() throws {
        let store = loadErxCoreDataStore()
        // given
        try store.add(chargeItems: [ErxSparseChargeItem.Fixtures.chargeItem1,
                                    ErxSparseChargeItem.Fixtures.chargeItem2])

        var receivedLatesValues = [String?]()
        // when fetching the latest `enteredDate` of all `ChargeItem`s
        _ = store.fetchLatestTimestampForChargeItems()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        expect(receivedLatesValues.count).toEventually(equal(1))
        // then the latest date has to be returned
        expect(receivedLatesValues.first) == ErxSparseChargeItem.Fixtures.chargeItem2.enteredDate

        // verify that two chargeItems have been in store
        var receivedValues = [[ErxSparseChargeItem]]()
        let cancellable = store.listAllChargeItems()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { chargeItems in
                receivedValues.append(chargeItems)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues[0].count) == 2

        cancellable.cancel()
    }

    func testFetchingLatestChargeItemWithProfileRelationship() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], chargeItems: [ErxSparseChargeItem.Fixtures.chargeItem1,
                                                                 ErxSparseChargeItem.Fixtures.chargeItem2])

        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(chargeItems: [ErxSparseChargeItem.Fixtures.chargeItem3])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestTimestampForChargeItems()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then the timestamp of the charge item with a relationship is returned even though
        // there are newer events in store
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == ErxSparseChargeItem.Fixtures.chargeItem3.enteredDate
        expect(ErxSparseChargeItem.Fixtures.chargeItem3.enteredDate?.date) < ErxSparseChargeItem.Fixtures.chargeItem1
            .enteredDate!
            .date!
    }

    func testFetchChargeItemByIDWithFullDetail() throws {
        let store = loadErxCoreDataStore()
        // given
        let chargeItemToFetch = ErxChargeItem.Fixtures.chargeItemWithFHIRData
        try store.add(chargeItems: [chargeItemToFetch.sparseChargeItem])

        // when
        var receivedFetchResult: ErxSparseChargeItem?
        let cancellable = store.fetchChargeItem(by: chargeItemToFetch.identifier)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then
        expect(receivedFetchResult?.identifier).toEventually(equal(chargeItemToFetch.identifier))
        expect(receivedFetchResult?.chargeItem) == chargeItemToFetch
        expect(receivedFetchResult?.chargeItem).to(nodiff(chargeItemToFetch))

        cancellable.cancel()
    }

    // MARK: - AuditEvents

    func testSaveAuditEvent() throws {
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent1])
    }

    func testListAllAuditEvents() throws {
        // given
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent1, ErxAuditEvent.Fixtures.auditEvent2])

        // when
        var receivedValues = [[ErxAuditEvent]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllAuditEvents(for: nil)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })

        // then
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first?.count) == 2
        expect(receivedCompletions.count) == 0
        expect(receivedValues.first?[0]) == ErxAuditEvent.Fixtures.auditEvent2
        expect(receivedValues.first?[1]) == ErxAuditEvent.Fixtures.auditEvent1

        cancellable.cancel()
    }

    func testListAllAuditEventsWithLocale() throws {
        // given
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent1,
                                    ErxAuditEvent.Fixtures.auditEvent2,
                                    ErxAuditEvent.Fixtures.auditEvent3])

        // when
        var receivedValues = [[ErxAuditEvent]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllAuditEvents(for: ErxAuditEvent.Fixtures.auditEvent1.locale)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })

        // then
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first?.count) == 1
        expect(receivedCompletions.count) == 0
        expect(receivedValues.first?[0]) == ErxAuditEvent.Fixtures.auditEvent1

        cancellable.cancel()
    }

    func testListingOnlyAuditEventsWithRelationshipToProfile() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], auditEvents: [ErxAuditEvent.Fixtures.auditEvent1,
                                                                 ErxAuditEvent.Fixtures.auditEvent2])

        // when accessing the store with a profile and saving a audit event to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent3])

        // then listing tasks for that profile
        var receivedListAllValues = [[ErxAuditEvent]]()
        let cancellable = store.listAllAuditEvents(for: nil)
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { auditEvents in
                receivedListAllValues.append(auditEvents)
            })

        // should only return the audit event with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == ErxAuditEvent.Fixtures.auditEvent3

        cancellable.cancel()
    }

    func testFetchingLatestAuditEvent() throws {
        let store = loadErxCoreDataStore()
        // given
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent1,
                                    ErxAuditEvent.Fixtures.auditEvent2])

        var receivedLatesValues = [String?]()
        // when fetching the latest `handOverDate` of all `MedicationDispense`s
        _ = store.fetchLatestTimestampForAuditEvents()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        expect(receivedLatesValues.count).toEventually(equal(1))
        // then the latest date has to be returned
        expect(receivedLatesValues.first) == ErxAuditEvent.Fixtures.auditEvent2.timestamp

        // verify that two auditEvents have been in store
        var receivedValues = [[ErxAuditEvent]]()
        let cancellable = store.listAllAuditEvents(for: nil)
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { auditEvents in
                receivedValues.append(auditEvents)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues[0].count) == 2

        cancellable.cancel()
    }

    func testFetchingLatestAuditEventWithProfileRelationship() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], auditEvents: [ErxAuditEvent.Fixtures.auditEvent1,
                                                                 ErxAuditEvent.Fixtures.auditEvent2])

        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(auditEvents: [ErxAuditEvent.Fixtures.auditEvent3])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestTimestampForAuditEvents()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then the timestamp of the audit event with a relationship is returned even though
        // there are newer events in store
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == ErxAuditEvent.Fixtures.auditEvent3.timestamp
        expect(ErxAuditEvent.Fixtures.auditEvent3.timestamp?.date) < ErxAuditEvent.Fixtures.auditEvent1.timestamp!.date!
    }

    private func prepareStores(
        with tasks: [ErxTask] = [],
        profiles: [Profile] = [],
        communications: [ErxTask.Communication] = [],
        auditEvents: [ErxAuditEvent] = [],
        medicationDispenses: [ErxMedicationDispense] = [],
        chargeItems: [ErxSparseChargeItem] = []
    ) throws {
        if !profiles.isEmpty {
            try loadProfileCoreDataStore().add(profiles: profiles)
        }
        let erxTaskStore = loadErxCoreDataStore()
        if !tasks.isEmpty {
            try erxTaskStore.add(tasks: tasks)
        }
        if !communications.isEmpty {
            try erxTaskStore.add(communications: communications)
        }
        if !auditEvents.isEmpty {
            try erxTaskStore.add(auditEvents: auditEvents)
        }
        if !medicationDispenses.isEmpty {
            try erxTaskStore.add(medicationDispenses: medicationDispenses)
        }
        if !chargeItems.isEmpty {
            try erxTaskStore.add(chargeItems: chargeItems)
        }
    }
}

extension ErxTaskCoreDataStore {
    func add(tasks: [ErxTask]) throws {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = save(tasks: tasks, updateProfileLastAuthenticated: false)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(1))
        expect(receivedSaveResults.last).to(beTrue())
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(communications: [ErxTask.Communication]) throws {
        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = save(communications: communications)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(medicationDispenses: [ErxMedicationDispense]) throws {
        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = save(medicationDispenses: medicationDispenses)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(chargeItems: [ErxSparseChargeItem]) throws {
        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = save(chargeItems: chargeItems)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(auditEvents: [ErxAuditEvent]) throws {
        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = save(auditEvents: auditEvents)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }
}

// swiftlint:enable file_length
