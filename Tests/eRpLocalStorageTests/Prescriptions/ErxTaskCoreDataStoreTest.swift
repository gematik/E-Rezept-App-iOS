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
        let task = ErxTask(identifier: "id", status: .ready, accessCode: "access")
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

        let task = ErxTask(identifier: "id", status: .ready, accessCode: "access")
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

    func testSaveMedicationDispenses() throws {
        let store = try loadCoreDataStore()

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        let medicationDispense = ErxTask.MedicationDispense(
            taskId: "tastk_id",
            insuranceId: "insurance_id",
            pzn: "pzn_number",
            name: "Medication text",
            dose: "Dose",
            dosageForm: "dosage_form",
            dosageInstruction: "dosage_instructions",
            amount: 8.0,
            telematikId: "telematik_id",
            whenHandedOver: "when_handed_over"
        )
        _ = store.save(medicationDispenses: [medicationDispense])
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

    func testUpdatingMedicationDispenses() throws {
        let store = try loadCoreDataStore()
        var receivedValues = [[ErxTask.MedicationDispense]]()
        var receivedCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // listen to any changes in store
        let cancellable = store.listAllMedicationDispenses(after: nil)
            .dropFirst() // remove the subscription call
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { medicationDispense in
                receivedValues.append(medicationDispense)
            })

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()

        // given: a `MedicationDispense` that has been saved
        let medicationDispense = ErxTask.MedicationDispense(
            taskId: "12345",
            insuranceId: "insurance_id",
            pzn: "pzn_number",
            name: "Initial medication text",
            dose: "Dose",
            dosageForm: "dosage_form",
            dosageInstruction: "dosage_instructions",
            amount: 8.0,
            telematikId: "telematik_id",
            whenHandedOver: "2021-07-23T10:55:04+02:00"
        )
        _ = store.save(medicationDispenses: [medicationDispense])
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

        let updatedMedicationDispense = ErxTask.MedicationDispense(
            taskId: "12345",
            insuranceId: "Updated insurance_id",
            pzn: "Updated pzn_number",
            name: "Updated medication text",
            dose: "Dose",
            dosageForm: "Updated dosage_form",
            dosageInstruction: "Updated dosage_instructions",
            amount: 8.0,
            telematikId: "Updated telematik_id",
            whenHandedOver: "Updated 2021-07-23T10:55:04+02:00"
        )

        // when updating the same medication dispense (when taskId is equal)
        _ = store.save(medicationDispenses: [updatedMedicationDispense])
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
        expect(receivedValues[0].first) == medicationDispense
        expect(receivedValues[1].count) == 1 // must be 1 otherwise update failed
        // then verify that the same medication dispense has been updated
        expect(receivedValues[1].first) == updatedMedicationDispense

        cancellable.cancel()
    }

    func testFetchingLatestMedicationDispense() throws {
        let store = try loadCoreDataStore()

        // given: two medicationDispenses with different dates that has been saved
        let medicationDispense1 = ErxTask.MedicationDispense(
            taskId: "12345",
            insuranceId: "insurance_id",
            pzn: "pzn_number",
            name: "medication text",
            dose: "Dose",
            dosageForm: "dosage_form",
            dosageInstruction: "dosage_instructions",
            amount: 8.0,
            telematikId: "telematik_id",
            whenHandedOver: "2021-07-20T10:55:04+02:00"
        )

        let latestDateString = "2021-07-23T10:55:04+02:00"
        let medicationDispense2 = ErxTask.MedicationDispense(
            taskId: "12346",
            insuranceId: "latest insurance_id",
            pzn: "latest pzn_number",
            name: "latest medication text",
            dose: "latest dose",
            dosageForm: "latest dosage_form",
            dosageInstruction: "latest dosage_instructions",
            amount: 8.0,
            telematikId: "telematik_id",
            whenHandedOver: latestDateString
        )

        var receivedResults = [Bool]()
        var receivedSaveCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        _ = store.save(medicationDispenses: [medicationDispense1, medicationDispense2])
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

        var receivedLatestCompletions = [Subscribers.Completion<ErxTaskCoreDataStore.Error>]()
        // when fetching the latest `handOverDate` of all `MedicationDispense`s
        _ = store.fetchLatestHandOverDateForMedicationDispenses()
            .sink(receiveCompletion: { completion in
                receivedLatestCompletions.append(completion)
            }, receiveValue: { timestamp in
                expect(medicationDispense2.whenHandedOver) == timestamp
            })
        expect(receivedSaveCompletions.count) == 1

        // verify that two medication dispenses have been in store
        _ = store.listAllMedicationDispenses()
            .sink(receiveCompletion: { _ in }, receiveValue: { medicationDispenses in
                expect(medicationDispenses.count) == 2
                expect(medicationDispenses[0]) == medicationDispense1
                expect(medicationDispenses[1]) == medicationDispense2
            })
    }

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
