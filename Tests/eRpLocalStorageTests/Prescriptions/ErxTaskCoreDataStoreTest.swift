//
//  Copyright (c) 2021 gematik GmbH
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

final class ErxTaskCoreDataStoreTest: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        if fileManager.fileExists(atPath: databaseFile.absoluteString) {
            expect(try self.fileManager.removeItem(at: self.databaseFile)).toNot(throwError())
        }

        super.tearDown()
    }

    func testListAllTasks() throws {
        let store = try loadCoreDataStore()

        var receivedValues = [[ErxTask]]()
        var receivedCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        let cancellable = store.listAllTasks()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { list in
                receivedValues.append(list)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedCompletions.count) == 0

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        let task = ErxTask(identifier: "id", accessCode: "access")
        _ = store.save(tasks: [task])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true

        expect(receivedValues.count).toEventually(equal(2))
        expect(receivedCompletions.count) == 0

        expect(receivedValues.last?[0].id) == "id"
        expect(receivedValues.last?[0].accessCode) == "access"

        cancellable.cancel()
    }

    func testSaveTasks() throws {
        let store = try loadCoreDataStore()

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        let task = ErxTask(identifier: "id", accessCode: "access")
        _ = store.save(tasks: [task])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true
    }

    // swiftlint:disable line_length
    func testSaveCommunicationReply() throws {
        let store = try loadCoreDataStore()

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        let communication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "taskID",
            userId: "insuranceIdentifer",
            telematikId: "TelematikId",
            timestamp: "timestamp",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
        )
        _ = store.save(communications: [communication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true
    }

    func testListAllCommunicationReplies() throws {
        let store = try loadCoreDataStore()

        var receivedValues = [[ErxTask.Communication]]()
        var receivedCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        let cancellable = store.listAllCommunications(for: .reply)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { communication in
                receivedValues.append(communication)
            })

        expect(receivedValues.count).toEventually(equal(1))
        expect(receivedCompletions.count) == 0

        let payloadJSON =
            "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}"
        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        let communication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "taskID",
            userId: "insuranceIdentifer",
            telematikId: "TelematikId",
            timestamp: "timestamp",
            payloadJSON: payloadJSON
        )
        _ = store.save(communications: [communication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true

        expect(receivedValues.count).toEventually(equal(2))
        expect(receivedCompletions.count) == 0
        expect(receivedValues.last?[0].identifier) == "identifer"
        expect(receivedValues.last?[0].profile) == .reply
        expect(receivedValues.last?[0].telematikId) == "TelematikId"
        expect(receivedValues.last?[0].insuranceId) == "insuranceIdentifer"
        expect(receivedValues.last?[0].timestamp) == "timestamp"
        expect(receivedValues.last?[0].payloadJSON) == payloadJSON
        expect(receivedValues.last?[0].isRead) == false // this should be nil -> needs rework

        cancellable.cancel()
    }

    func testUpdatingCommunicationReply() throws {
        let store = try loadCoreDataStore()
        var receivedValues = [[ErxTask.Communication]]()
        var receivedCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // listen to any changes in store
        let cancellable = store.listAllCommunications(for: .reply)
            .dropFirst() // remove the subscription call
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { communication in
                receivedValues.append(communication)
            })

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // given: a communication that has been saved
        let communication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "taskID",
            userId: "user kvnr",
            telematikId: "TelematikId",
            timestamp: "timestamp",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}",
            isRead: false
        )
        _ = store.save(communications: [communication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true

        // when updating the same communication
        let updatedCommunication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "updated",
            userId: "updated",
            telematikId: "updated",
            timestamp: "updated",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"Updated\",\"url\": \"updated\"}",
            isRead: true
        )

        _ = store.save(communications: [updatedCommunication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(2))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 2
        expect {
            if case .finished = receivedSaveCompletions[1] {
                return true
            } else {
                return false
            }
        } == true

        expect(receivedValues.count) == 2
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first) == communication
        expect(receivedValues[1].count) == 1 // must be 1 otherwise update failed
        // then verify that only `isRead` has been updated
        expect(receivedValues[1].first?.isRead) == true
        expect(receivedValues[1].first?.taskId) == communication.taskId
        expect(receivedValues[1].first?.insuranceId) == communication.insuranceId
        expect(receivedValues[1].first?.telematikId) == communication.telematikId
        expect(receivedValues[1].first?.timestamp) == communication.timestamp
        expect(receivedValues[1].first?.payloadJSON) == communication.payloadJSON

        cancellable.cancel()
    }

    func testPreventingOverwriteOfCommunicationIsRead() throws {
        let store = try loadCoreDataStore()

        var receivedValues = [[ErxTask.Communication]]()
        var receivedCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // listen to any changes in store
        let cancellable = store.listAllCommunications(for: .reply)
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { communication in
                // omit first call that
                if !communication.isEmpty {
                    receivedValues.append(communication)
                }
            })

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // given: when having a communication that has isRead == true
        let communication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "taskID",
            userId: "insuranceIdentifer",
            telematikId: "TelematikId",
            timestamp: "timestamp",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurden! Diese Nachricht hat keine Url.\",\"url\": \"\"}",
            isRead: true
        )
        _ = store.save(communications: [communication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(1))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 1
        expect {
            if case .finished = receivedSaveCompletions[0] {
                return true
            } else {
                return false
            }
        } == true

        // when trying to set it to false
        let updatedCommunication = ErxTask.Communication(
            identifier: "identifer",
            profile: .reply,
            taskId: "updated",
            userId: "updated",
            telematikId: "updated",
            timestamp: "updated",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Updated\",\"url\": \"\"}",
            isRead: false
        )

        _ = store.save(communications: [updatedCommunication])
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedResults.append(result)
            })

        expect(receivedResults.count).toEventually(equal(2))
        expect(receivedResults.last) == true
        expect(receivedSaveCompletions.count) == 2
        expect {
            if case .finished = receivedSaveCompletions[1] {
                return true
            } else {
                return false
            }
        } == true

        // then there is no change since the value did not change (only 1 receivedValue)
        expect(receivedValues.count) == 1
        expect(receivedValues[0].count) == 1
        expect(receivedValues[0].first?.isRead) == true

        cancellable.cancel()
    }

    // swiftlint:enable line_length

    func loadCoreDataStore() throws -> ErxTaskCoreDataStore {
        #if os(macOS)
        return try ErxTaskCoreDataStore(
            url: databaseFile,
            fileProtection: FileProtectionType(rawValue: "none"),
            backgroundQueue: DispatchQueue.main
        )
        #else
        return try ErxTaskCoreDataStore(
            url: databaseFile,
            fileProtection: .completeUnlessOpen,
            backgroundQueue: DispatchQueue.main
        )
        #endif
    }
}
