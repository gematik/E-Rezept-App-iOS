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
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class AVSTransactionCoreDataStoreTests: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var factory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("database/\(UUID().uuidString)")
    }

    override func tearDown() {
        let folderUrl = databaseFile.deletingLastPathComponent()
        if fileManager.fileExists(atPath: folderUrl.path) {
            expect(try self.fileManager.removeItem(at: folderUrl)).toNot(throwError())
        } else {
            fail("temporary database could not be deleted")
        }

        super.tearDown()
    }

    private func loadFactory() -> CoreDataControllerFactory {
        guard let factory = factory else {
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
            self.factory = factory
            return factory
        }

        return factory
    }

    let coreDataBackgroundQueue: AnySchedulerOf<DispatchQueue> = AnyScheduler.main

    private func loadAVSTransactionCoreDataStore() -> AVSTransactionCoreDataStore {
        AVSTransactionCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: coreDataBackgroundQueue
        )
    }

    private let profileUUID = UUID()
    private var date = Date()

    private func loadErxTaskCoreDataStore() -> ErxTaskCoreDataStore {
        ErxTaskCoreDataStore(
            profileId: profileUUID,
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: coreDataBackgroundQueue,
            dateProvider: { self.date }
        )
    }

    private func avsTransaction(with id: UUID = UUID(), taskId: String = "") -> AVSTransaction {
        AVSTransaction(
            transactionID: id,
            httpStatusCode: true,
            groupedRedeemTime: Date(),
            groupedRedeemID: UUID(),
            telematikID: nil,
            taskId: taskId
        )
    }

    func testFetchAVSTransactionByIdSuccess() {
        let sut = loadAVSTransactionCoreDataStore()
        // given
        let input = avsTransaction()
        sut.add(avsTransaction: input)

        // when we fetch that entity by id
        var receivedFetchResult: AVSTransaction?
        let cancellable = sut.fetchAVSTransaction(by: input.transactionID)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then it should be the one we expect
        expect(receivedFetchResult).toEventually(equal(input))

        cancellable.cancel()
    }

    func testFetchAVSTransactionByIdFailure() {
        let sut = loadAVSTransactionCoreDataStore()
        // given no AVSTransaction in store

        // when we fetch an entity that is not jet in store
        var receivedNoResult = false
        let cancellable = sut.fetchAVSTransaction(by: UUID())
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // then it should return no entry
        expect(receivedNoResult).toEventually(beTrue())

        cancellable.cancel()
    }

    func testListAllAVSTransactions() {
        let sut = loadAVSTransactionCoreDataStore()

        var receivedListAllAVSTransactionValues = [[AVSTransaction]]()
        let cancellable = sut.listAllAVSTransactions()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { avsTransactions in
                receivedListAllAVSTransactionValues.append(avsTransactions)
            })

        let avsTransaction1 = avsTransaction()
        sut.add(avsTransaction: avsTransaction1)

        let avsTransaction2 = avsTransaction()
        let avsTransaction3 = avsTransaction()
        sut.add(avsTransactions: [avsTransaction2, avsTransaction3])

        // then there should be only one in store with the updated values
        expect(receivedListAllAVSTransactionValues.count).toEventually(equal(3))
        expect(receivedListAllAVSTransactionValues[0].count).to(equal(0))
        expect(receivedListAllAVSTransactionValues[1].count).to(equal(1))
        expect(receivedListAllAVSTransactionValues[1].first) == avsTransaction1
        expect(receivedListAllAVSTransactionValues[2].count).to(equal(3))
        expect(receivedListAllAVSTransactionValues[2]).to(contain([avsTransaction1, avsTransaction2, avsTransaction3]))

        cancellable.cancel()
    }

    func testListAllAVSTransactionsWithoutAnyEntries() {
        let sut = loadAVSTransactionCoreDataStore()

        var receivedListAllAVSTransactionValues = [[AVSTransaction]]()
        let cancellable = sut.listAllAVSTransactions()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { avsTransactions in
                receivedListAllAVSTransactionValues.append(avsTransactions)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllAVSTransactionValues.count).toEventually(equal(1))
        expect(receivedListAllAVSTransactionValues[0].count).to(equal(0))

        cancellable.cancel()
    }

    func testSavingAVSTransactions() throws {
        let sut = loadAVSTransactionCoreDataStore()
        let avsTransaction1 = avsTransaction(with: UUID())
        let avsTransaction2 = avsTransaction(with: UUID())
        sut.add(avsTransactions: [avsTransaction1, avsTransaction2])
    }

    func testSavingOneAVSTransaction() throws {
        let sut = loadAVSTransactionCoreDataStore()
        let avsTransaction = avsTransaction(with: UUID())
        sut.add(avsTransaction: avsTransaction)
    }

    func testSavingPreviousStoredAVSTransaction() throws {
        let sut = loadAVSTransactionCoreDataStore()
        let avsTransactionId = UUID()
        let avsTransaction = avsTransaction(with: avsTransactionId)
        // given a avsTransaction in store
        sut.add(avsTransaction: avsTransaction)

        let updatedAVSTransaction = AVSTransaction(
            transactionID: avsTransactionId,
            httpStatusCode: avsTransaction.httpStatusCode,
            groupedRedeemTime: avsTransaction.groupedRedeemTime,
            groupedRedeemID: avsTransaction.groupedRedeemID,
            telematikID: avsTransaction.telematikID,
            taskId: ""
        )

        // when updating the avsTransaction with the same id
        sut.add(avsTransaction: updatedAVSTransaction)

        var receivedListAllAVSTransactionValues = [[AVSTransaction]]()
        let cancellable = sut.listAllAVSTransactions()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { avsTransactions in
                receivedListAllAVSTransactionValues.append(avsTransactions)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllAVSTransactionValues.count).toEventually(equal(1))
        expect(receivedListAllAVSTransactionValues[0].count).to(equal(1))
        let result = receivedListAllAVSTransactionValues[0].first
        expect(result) == updatedAVSTransaction

        cancellable.cancel()
    }

    func testSavingAVSTransactionUpdatesErxTask() {
        let task = ErxTask(identifier: "12345", status: .ready, source: .scanner)

        let erxTaskStore = loadErxTaskCoreDataStore()
        _ = erxTaskStore.save(
            tasks: [task],
            updateProfileLastAuthenticated: false
        )
        .sink { result in
            print(result)
        } receiveValue: { value in
            print(value)
        }

        let sut = loadAVSTransactionCoreDataStore()

        let avsTransaction = avsTransaction(with: UUID(), taskId: "12345")

        sut.add(avsTransaction: avsTransaction)

        var success = false

        date = avsTransaction.groupedRedeemTime.addingTimeInterval(60)

        _ = erxTaskStore.fetchTask(by: "12345", accessCode: nil)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { task in
                success = true
                expect(task?.identifier).to(equal("12345"))
                expect(task?.status).to(equal(.inProgress))
            })

        expect(success).to(beTrue())
        date = avsTransaction.groupedRedeemTime.addingTimeInterval(601)
        success = false

        _ = erxTaskStore.fetchTask(by: "12345", accessCode: nil)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { task in
                success = true
                expect(task?.identifier).to(equal("12345"))
                expect(task?.status).to(equal(.completed))
            })

        expect(success).to(beTrue())
    }

    func testDeleteOneAVSTransaction() {
        let sut = loadAVSTransactionCoreDataStore()
        let avsTransactionToDelete = avsTransaction()
        // given one avsTransaction in store
        sut.add(avsTransaction: avsTransactionToDelete)

        // when deleting a stored avsTransaction
        var receivedDeleteResults = [AVSTransaction?]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = sut.delete(avsTransaction: avsTransactionToDelete)
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { avsTransaction in
                receivedDeleteResults.append(avsTransaction)
            })
        expect(receivedDeleteResults.count).toEventually(equal(1))
        expect(receivedDeleteResults.first) == avsTransactionToDelete
        expect(receivedDeleteCompletions.count).toEventually(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then there should be no entry left in store
        var receivedListAllAVSTransactionsValues = [[AVSTransaction]]()
        _ = sut.listAllAVSTransactions()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { avsTransactions in
                receivedListAllAVSTransactionsValues.append(avsTransactions)
            })

        expect(receivedListAllAVSTransactionsValues.count).toEventually(equal(1))
        expect(receivedListAllAVSTransactionsValues.first?.count) == 0
    }

    func testDeleteMultipleAVSTransactions() {
        let sut = loadAVSTransactionCoreDataStore()
        let avsTransactionToDelete1 = avsTransaction()
        let avsTransactionToDelete2 = avsTransaction()
        // given two avsTransactions in store
        sut.add(avsTransactions: [avsTransactionToDelete1, avsTransactionToDelete2])

        // when deleting a stored avsTransaction
        var receivedDeleteResults = [AVSTransaction]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = sut.delete(avsTransactions: [avsTransactionToDelete1, avsTransactionToDelete2])
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { deletedAVSTransactions in
                receivedDeleteResults.append(contentsOf: deletedAVSTransactions)
            })
        expect(receivedDeleteResults.count).toEventually(equal(2))
        expect(receivedDeleteResults.first) == avsTransactionToDelete1
        expect(receivedDeleteResults.last) == avsTransactionToDelete2
        expect(receivedDeleteCompletions.count).toEventually(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then there should be no entry left in store
        var receivedListAllAVSTransactionsValues = [[AVSTransaction]]()
        _ = sut.listAllAVSTransactions()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { avsTransactions in
                receivedListAllAVSTransactionsValues.append(avsTransactions)
            })

        expect(receivedListAllAVSTransactionsValues.count).toEventually(equal(1))
        expect(receivedListAllAVSTransactionsValues.first?.count) == 0
    }
}

extension AVSTransactionCoreDataStore {
    func add(avsTransactions: [AVSTransaction]) {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [AVSTransaction]()

        let cancellable = save(avsTransactions: avsTransactions)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { results in
                receivedSaveResults.append(contentsOf: results)
            })

        expect(receivedSaveResults.count).toEventually(equal(avsTransactions.count))
        expect(receivedSaveResults.last) == avsTransactions.last
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(avsTransaction: AVSTransaction) {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [AVSTransaction?]()

        let cancellable = save(avsTransaction: avsTransaction)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(1))
        expect(receivedSaveResults.last) == avsTransaction
        expect(receivedSaveCompletions.count).toEventually(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }
}
