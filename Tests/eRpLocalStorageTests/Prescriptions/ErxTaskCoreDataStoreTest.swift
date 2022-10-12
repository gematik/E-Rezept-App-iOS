//
//  Copyright (c) 2022 gematik GmbH
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
            backgroundQueue: .main
        )
    }

    private func loadProfileCoreDataStore() -> ProfileCoreDataStore {
        ProfileCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: .main
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
        factory.loadCoreDataControllerError = LocalStoreError.notImplemented
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
            .failure(LocalStoreError.initialization(error: factory.loadCoreDataControllerError!))

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
        let patient = ErxTask.Patient(name: "Anna", insuranceId: "X123456789")
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

    func testListingOnlyCommunicationsWithRelationshipToProfile() throws {
        // given a profile and communications that do not belong to each other
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], communications: [communication1, communication2])

        // when accessing the store with a profile and saving a communication to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: communication3.taskId, status: .ready)
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile
        try store.add(communications: [communication3])

        // then listing tasks for that profile
        var receivedListAllValues = [[ErxTask.Communication]]()
        let cancellable = store.listAllCommunications(for: .reply)
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { communications in
                receivedListAllValues.append(communications)
            })

        // should only return the communication with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == communication3

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

    // swiftlint:enable line_length

    // MARK: - MedicationDispense

    lazy var medicationDispense1: ErxTask.MedicationDispense = {
        ErxTask.MedicationDispense(
            identifier: "0987654321",
            taskId: "id_1",
            insuranceId: "insurance_id_1",
            pzn: "pzn_number_1",
            name: "Initial medication text 1",
            dose: "Dose 2",
            dosageForm: "dosage_form_1",
            dosageInstruction: "dosage_instructions_1",
            amount: 8.0,
            telematikId: "telematik_id_1",
            whenHandedOver: "2021-07-20T10:55:04+02:00",
            lot: "TOTO-5236-01",
            expiresOn: "2049-07-10T10:55:04+02:00"
        )
    }()

    lazy var medicationDispense2: ErxTask.MedicationDispense = {
        ErxTask.MedicationDispense(
            identifier: "1234567890",
            taskId: "id_2",
            insuranceId: "insurance_id_2",
            pzn: "pzn_number_2",
            name: "Initial medication text 2",
            dose: "Dose 2",
            dosageForm: "dosage_form_2",
            dosageInstruction: "dosage_instructions_2",
            amount: 10.0,
            telematikId: "telematik_id_2",
            whenHandedOver: "2021-07-23T10:55:04+02:00",
            lot: "TOTO-5236-02",
            expiresOn: "2050-07-10T10:55:04+02:00"
        )
    }()

    func testSaveMedicationDispenses() throws {
        let store = loadErxCoreDataStore()
        try store.add(medicationDispenses: [medicationDispense1])
    }

    func testUpdatingMedicationDispenses() throws {
        let store = loadErxCoreDataStore()
        var receivedValues = [[ErxTask.MedicationDispense]]()
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
        try store.add(medicationDispenses: [medicationDispense1])

        let updatedMedicationDispense = ErxTask.MedicationDispense(
            identifier: medicationDispense1.identifier,
            taskId: medicationDispense1.taskId,
            insuranceId: "Updated insurance_id",
            pzn: "Updated pzn_number",
            name: "Updated medication text",
            dose: "Updated Dose",
            dosageForm: "Updated dosage_form",
            dosageInstruction: "Updated dosage_instructions",
            amount: 16.0,
            telematikId: "Updated telematik_id",
            whenHandedOver: "Updated 2021-07-23T10:55:04+02:00",
            lot: "Updated TOTO-5236-01",
            expiresOn: "Updated 2049-07-10T10:55:04+02:00"
        )

        // when updating the same medication dispense (when taskId is equal)
        try store.add(medicationDispenses: [updatedMedicationDispense])

        expect(receivedValues.count) == 2
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first) == medicationDispense1
        expect(receivedValues[1].count) == 1 // must be 1 otherwise update failed
        // then verify that the same medication dispense has been updated
        expect(receivedValues[1].first) == updatedMedicationDispense

        cancellable.cancel()
    }

    func testFetchingMedicationDispense() throws {
        let store = loadErxCoreDataStore()
        // given two medicationDispenses that have been saved
        try store.add(medicationDispenses: [medicationDispense1, medicationDispense2])

        // verify that two medicationDispenses have been in store
        var receivedValues = [ErxTask.MedicationDispense]()
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
        try prepareStores(profiles: [testProfile], medicationDispenses: [medicationDispense2])

        let store = loadErxCoreDataStore(for: testProfile.id)
        let task = ErxTask(identifier: medicationDispense1.taskId, status: .ready)
        try store.add(medicationDispenses: [medicationDispense1])
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile

        // when
        var receivedValues = [ErxTask.MedicationDispense]()
        _ = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { result in
                receivedValues.append(contentsOf: result)
            })

        // then the timestamp of the medicationDispense with a relationship is returned even though
        // there is a newer medicationDispense in store
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first) == medicationDispense1
        expect(self.medicationDispense1.whenHandedOver.date) < medicationDispense2.whenHandedOver.date!
    }

    func testListingOnlyMedicationDispenseWithRelationshipToProfile() throws {
        // given having a profile and communications that do not belong to that profile
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], medicationDispenses: [medicationDispense1])

        // when accessing the store with a profile and saving a communication to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)

        let task = ErxTask(identifier: medicationDispense2.taskId, status: .ready)
        try store.add(medicationDispenses: [medicationDispense2])
        try store.add(tasks: [task]) // there must be a related task with a relationship to the profile

        // then listing medicationDispense for that profile
        var receivedListAllValues = [[ErxTask.MedicationDispense]]()
        let cancellable = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { medicationDispenses in
                receivedListAllValues.append(medicationDispenses)
            })

        // should only return the medicationDispense with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == medicationDispense2

        cancellable.cancel()
    }

    // MARK: - AuditEvents

    lazy var auditEvent1: ErxAuditEvent = {
        ErxAuditEvent(
            identifier: "id_1",
            locale: "locale_1",
            text: "Text 1",
            timestamp: "2021-07-20T10:55:04+02:00",
            taskId: nil
        )
    }()

    lazy var auditEvent2: ErxAuditEvent = {
        ErxAuditEvent(
            identifier: "id_2",
            locale: "locale_2",
            text: "Text 2",
            timestamp: "2021-07-23T10:55:04+02:00",
            taskId: nil
        )
    }()

    lazy var auditEvent3: ErxAuditEvent = {
        ErxAuditEvent(
            identifier: "id_3",
            locale: "locale_3",
            text: "Text 3",
            timestamp: "2021-07-10T10:55:04+02:00",
            taskId: nil
        )
    }()

    func testSaveAuditEvent() throws {
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [auditEvent1])
    }

    func testListAllAuditEvents() throws {
        // given
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [auditEvent1, auditEvent2])

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
        expect(receivedValues.first?[0]) == auditEvent2
        expect(receivedValues.first?[1]) == auditEvent1

        cancellable.cancel()
    }

    func testListAllAuditEventsWithLocale() throws {
        // given
        let store = loadErxCoreDataStore()
        try store.add(auditEvents: [auditEvent1, auditEvent2, auditEvent3])

        // when
        var receivedValues = [[ErxAuditEvent]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllAuditEvents(for: auditEvent1.locale)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })

        // then
        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedValues.first?.count) == 1
        expect(receivedCompletions.count) == 0
        expect(receivedValues.first?[0]) == auditEvent1

        cancellable.cancel()
    }

    func testListingOnlyAuditEventsWithRelationshipToProfile() throws {
        // given
        let testProfile = Profile(name: "TestProfile")
        try prepareStores(profiles: [testProfile], auditEvents: [auditEvent1, auditEvent2])

        // when accessing the store with a profile and saving a communication to that profile
        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(auditEvents: [auditEvent3])

        // then listing tasks for that profile
        var receivedListAllValues = [[ErxAuditEvent]]()
        let cancellable = store.listAllAuditEvents(for: nil)
            .sink(receiveCompletion: { _ in
                fail("did not expect to receive a completion")
            }, receiveValue: { auditEvents in
                receivedListAllValues.append(auditEvents)
            })

        // should only return the communication with a set relationship to that profile
        expect(receivedListAllValues.count).toEventually(equal(1))
        expect(receivedListAllValues.first?.count) == 1
        expect(receivedListAllValues[0].first) == auditEvent3

        cancellable.cancel()
    }

    func testFetchingLatestAuditEvent() throws {
        let store = loadErxCoreDataStore()
        // given
        try store.add(auditEvents: [auditEvent1, auditEvent2])

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
        expect(receivedLatesValues.first) == auditEvent2.timestamp

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
        try prepareStores(profiles: [testProfile], auditEvents: [auditEvent1, auditEvent2])

        let store = loadErxCoreDataStore(for: testProfile.id)
        try store.add(auditEvents: [auditEvent3])

        // when
        var receivedLatesValues = [String?]()
        _ = store.fetchLatestTimestampForAuditEvents()
            .sink(receiveCompletion: { _ in
                fail("unexpected complete")
            }, receiveValue: { timestamp in
                receivedLatesValues.append(timestamp)
            })

        // then the timestamp of the audit event withe a relationship is returned even though
        // there are newer events in store
        expect(receivedLatesValues.count).toEventually(equal(1))
        expect(receivedLatesValues.first) == auditEvent3.timestamp
        expect(self.auditEvent3.timestamp?.date) < auditEvent1.timestamp!.date!
    }

    private func prepareStores(
        with tasks: [ErxTask] = [],
        profiles: [Profile] = [],
        communications: [ErxTask.Communication] = [],
        auditEvents: [ErxAuditEvent] = [],
        medicationDispenses: [ErxTask.MedicationDispense] = []
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

    func add(medicationDispenses: [ErxTask.MedicationDispense]) throws {
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
