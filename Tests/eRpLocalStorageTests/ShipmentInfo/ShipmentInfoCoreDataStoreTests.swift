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
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class ShipmentInfoCoreDataStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var factory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        userDefaults = MockUserDefaults()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent("database/\(UUID().uuidString)/db")
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

    let foregroundQueue: AnySchedulerOf<DispatchQueue> = .immediate
    let backgroundQueue: AnySchedulerOf<DispatchQueue> = .immediate

    private func loadShipmentInfoCoreDataStore() -> ShipmentInfoCoreDataStore {
        ShipmentInfoCoreDataStore(
            userDefaults: userDefaults,
            coreDataControllerFactory: loadFactory(),
            foregroundQueue: foregroundQueue,
            backgroundQueue: backgroundQueue
        )
    }

    private func shipmentInfo(with id: UUID = UUID()) -> ShipmentInfo {
        ShipmentInfo(
            identifier: id,
            name: "Anna Vetter_\(id.uuidString)",
            street: "Benzelrather Str. 29",
            zip: "50226",
            city: "Frechen",
            phone: "+491771234567",
            mail: "anna.vetter@gematik.de"
        )
    }

    func testFetchShipmentInfoByIdSuccess() {
        let sut = loadShipmentInfoCoreDataStore()
        // given
        let input = shipmentInfo()
        sut.add(shipmentInfo: input)

        // when we fetch that entity by id
        var receivedFetchResult: ShipmentInfo?
        let cancellable = sut.fetchShipmentInfo(by: input.identifier)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then it should be the one we expect
        expect(receivedFetchResult).to(equal(input))

        cancellable.cancel()
    }

    func testFetchShipmentInfoByIdFailure() {
        let sut = loadShipmentInfoCoreDataStore()
        // given no Shipment in store

        // when we fetch an entity that is not jet in store
        var receivedNoResult = false
        let cancellable = sut.fetchShipmentInfo(by: UUID())
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // then it should return no entry
        expect(receivedNoResult).to(beTrue())

        cancellable.cancel()
    }

    func testFetchingsSelectedShipmentInfoBeforeSelectionToBeNil() {
        let sut = loadShipmentInfoCoreDataStore()
        let input = shipmentInfo()
        // given an entity is in store while nothing is selected
        sut.add(shipmentInfo: input)

        var selectedShipmentInfoResults = [ShipmentInfo?]()
        // when subscribing to the selectedShipmentInfo
        let cancellable = sut.selectedShipmentInfo
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                selectedShipmentInfoResults.append(result)
            })

        // then nil should be returned
        expect(selectedShipmentInfoResults.count).to(equal(1))
        expect(selectedShipmentInfoResults[0]).to(beNil())

        cancellable.cancel()
    }

    func testFetchingsSelectedShipmentInfoAfterSelectionToBeTheValue() {
        let sut = loadShipmentInfoCoreDataStore()
        let input = shipmentInfo()
        // given the entity is in store and selected
        sut.add(shipmentInfo: input)
        sut.set(selectedShipmentInfoId: input.id)

        // when subscribing to the selectedShipmentInfo
        var selectedShipmentInfoResults = [ShipmentInfo?]()
        let cancellable = sut.selectedShipmentInfo
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                selectedShipmentInfoResults.append(result)
            })

        // then that entity should be returned
        expect(selectedShipmentInfoResults.count).to(equal(1))
        expect(selectedShipmentInfoResults[0]) == input

        cancellable.cancel()
    }

    func testSetSelectedShipmentInfoIdToTriggerThePublisher() {
        let sut = loadShipmentInfoCoreDataStore()
        let input = shipmentInfo()
        // given the entity to be selected is in store
        sut.add(shipmentInfo: input)

        var selectedShipmentInfoResults = [ShipmentInfo?]()
        let cancellable = sut.selectedShipmentInfo
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                selectedShipmentInfoResults.append(result)
            })

        // when setting the selected shipment info to that id
        sut.set(selectedShipmentInfoId: input.id)

        // then there should be an additional value be published
        expect(selectedShipmentInfoResults.count).to(equal(2))
        expect(selectedShipmentInfoResults[0]).to(beNil())
        expect(selectedShipmentInfoResults[1]) == input

        cancellable.cancel()
    }

    func testSetSelectedShipmentInfoIdToAnIdNotInStoreToReturnNil() {
        // given ShipmentInfo is not in store
        let sut = loadShipmentInfoCoreDataStore()

        // when setting the id to something not in store
        sut.set(selectedShipmentInfoId: UUID())

        var selectedShipmentInfoResults = [ShipmentInfo?]()
        let cancellable = sut.selectedShipmentInfo
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                selectedShipmentInfoResults.append(result)
            })

        expect(selectedShipmentInfoResults.count).to(equal(1))
        // then there should be nil
        expect(selectedShipmentInfoResults[0]).to(beNil())

        cancellable.cancel()
    }

    func testListAllShipmentInfos() {
        let sut = loadShipmentInfoCoreDataStore()

        var receivedListAllShipmentInfoValues = [[ShipmentInfo]]()
        let cancellable = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfoValues.append(shipmentInfos)
            })

        let shipmentInfo1 = shipmentInfo()
        sut.add(shipmentInfo: shipmentInfo1)

        let shipmentInfo2 = shipmentInfo()
        let shipmentInfo3 = shipmentInfo()
        sut.add(shipmentInfos: [shipmentInfo2, shipmentInfo3])

        // then there should be only one in store with the updated values
        expect(receivedListAllShipmentInfoValues.count).toEventually(equal(3))
        expect(receivedListAllShipmentInfoValues[0].count).to(equal(0))
        expect(receivedListAllShipmentInfoValues[1].count).to(equal(1))
        expect(receivedListAllShipmentInfoValues[1].first) == shipmentInfo1
        expect(receivedListAllShipmentInfoValues[2].count).to(equal(3))
        expect(receivedListAllShipmentInfoValues[2]).to(contain([shipmentInfo1, shipmentInfo2, shipmentInfo3]))

        cancellable.cancel()
    }

    func testListAllShipmentInfosWithoutAnyEntries() {
        let sut = loadShipmentInfoCoreDataStore()

        var receivedListAllShipmentInfoValues = [[ShipmentInfo]]()
        let cancellable = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfoValues.append(shipmentInfos)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllShipmentInfoValues.count).to(equal(1))
        expect(receivedListAllShipmentInfoValues[0].count).to(equal(0))

        cancellable.cancel()
    }

    func testSavingShipmentInfos() throws {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentInfo1 = shipmentInfo(with: UUID())
        let shipmentInfo2 = shipmentInfo(with: UUID())
        sut.add(shipmentInfos: [shipmentInfo1, shipmentInfo2])
    }

    func testSavingOneShipmentInfo() throws {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentInfo = shipmentInfo(with: UUID())
        sut.add(shipmentInfo: shipmentInfo)
    }

    func testSavingPreviousStoredShipmentInfo() throws {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentId = UUID()
        let shipmentInfo = shipmentInfo(with: shipmentId)
        // given a shipmentInfo in store
        sut.add(shipmentInfo: shipmentInfo)

        let updatedShipment = ShipmentInfo(
            identifier: shipmentId,
            name: shipmentInfo.name,
            street: "New Street",
            zip: shipmentInfo.zip,
            city: shipmentInfo.city,
            phone: shipmentInfo.phone,
            mail: shipmentInfo.mail
        )

        // when updating the shipment info with the same id
        sut.add(shipmentInfo: updatedShipment)

        var receivedListAllShipmentInfoValues = [[ShipmentInfo]]()
        let cancellable = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfoValues.append(shipmentInfos)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllShipmentInfoValues.count).to(equal(1))
        expect(receivedListAllShipmentInfoValues[0].count).to(equal(1))
        let result = receivedListAllShipmentInfoValues[0].first
        expect(result) == updatedShipment

        cancellable.cancel()
    }

    func testDeleteOneShipmentInfo() {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentToDelete = shipmentInfo()
        // given one shipmentInfo in store
        sut.add(shipmentInfo: shipmentToDelete)

        // when deleting a stored shipment Info
        var receivedDeleteResults = [ShipmentInfo?]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = sut.delete(shipmentInfo: shipmentToDelete)
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { shipmentInfo in
                receivedDeleteResults.append(shipmentInfo)
            })
        expect(receivedDeleteResults.count).to(equal(1))
        expect(receivedDeleteResults.first) == shipmentToDelete
        expect(receivedDeleteCompletions.count).to(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then there should be no entry left in store
        var receivedListAllShipmentInfosValues = [[ShipmentInfo]]()
        _ = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfosValues.append(shipmentInfos)
            })

        expect(receivedListAllShipmentInfosValues.count).to(equal(1))
        expect(receivedListAllShipmentInfosValues.first?.count) == 0
    }

    func testDeleteMultipleShipmentInfos() {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentToDelete1 = shipmentInfo()
        let shipmentToDelete2 = shipmentInfo()
        // given two shipmentInfos in store
        sut.add(shipmentInfos: [shipmentToDelete1, shipmentToDelete2])

        // when deleting a stored shipment Info
        var receivedDeleteResults = [ShipmentInfo]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = sut.delete(shipmentInfos: [shipmentToDelete1, shipmentToDelete2])
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { deletedShipmentInfos in
                receivedDeleteResults.append(contentsOf: deletedShipmentInfos)
            })
        expect(receivedDeleteResults.count).toEventually(equal(2))
        expect(receivedDeleteResults.first) == shipmentToDelete1
        expect(receivedDeleteResults.last) == shipmentToDelete2
        expect(receivedDeleteCompletions.count).to(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then there should be no entry left in store
        var receivedListAllShipmentInfosValues = [[ShipmentInfo]]()
        _ = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfosValues.append(shipmentInfos)
            })

        expect(receivedListAllShipmentInfosValues.count).to(equal(1))
        expect(receivedListAllShipmentInfosValues.first?.count) == 0
    }

    func testDeletingTheSelectedShipmentInfo() {
        let sut = loadShipmentInfoCoreDataStore()
        let shipmentToDelete = shipmentInfo()
        // given one shipmentInfo in store which is selected
        sut.add(shipmentInfo: shipmentToDelete)
        sut.set(selectedShipmentInfoId: shipmentToDelete.id)

        var selectedShipmentInfoResults = [ShipmentInfo?]()
        let cancellable = sut.selectedShipmentInfo
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                selectedShipmentInfoResults.append(result)
            })

        expect(selectedShipmentInfoResults.count).to(equal(1))
        expect(selectedShipmentInfoResults[0]) == shipmentToDelete

        // when deleting the selected entity
        var receivedDeleteResults = [ShipmentInfo?]()
        _ = sut.delete(shipmentInfo: shipmentToDelete)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { shipmentInfo in
                receivedDeleteResults.append(shipmentInfo)
            })
        expect(receivedDeleteResults.count).to(equal(1))
        expect(receivedDeleteResults.first) == shipmentToDelete

        expect(selectedShipmentInfoResults.count).toEventually(equal(2))
        // then the selected shipment should return nil
        expect(selectedShipmentInfoResults[1]).to(beNil())

        cancellable.cancel()
    }

    func testUpdateShipmentInfoThatIsInStore() {
        let sut = loadShipmentInfoCoreDataStore()
        let input = shipmentInfo()
        sut.add(shipmentInfo: input)

        var receivedUpdateValues = [ShipmentInfo]()
        var expectedResult: ShipmentInfo?
        _ = sut.update(identifier: input.id) { shipmentInfo in
            shipmentInfo.name = "Updated Name"
            shipmentInfo.street = "123 Fake Street"
            expectedResult = shipmentInfo
        }
        .sink(receiveCompletion: { completion in
            expect(completion) == .finished
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })
        expect(receivedUpdateValues.count).to(equal(1))
        expect(receivedUpdateValues.first) == expectedResult

        // then the input shipment should be updated
        var receivedListAllShipmentInfosValues = [[ShipmentInfo]]()
        let cancellable = sut.listAllShipmentInfos()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { shipmentInfos in
                receivedListAllShipmentInfosValues.append(shipmentInfos)
            })

        expect(receivedListAllShipmentInfosValues.count).to(equal(1))
        expect(receivedListAllShipmentInfosValues.first?.count) == 1
        let result = receivedListAllShipmentInfosValues[0].first!
        expect(result) == expectedResult

        cancellable.cancel()
    }

    func testUpdateShipmentInfoThatIsNotInStore() {
        let sut = loadShipmentInfoCoreDataStore()

        var receivedUpdateCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = sut.update(identifier: UUID()) { shipmentInfo in
            shipmentInfo.name = "Updated Name"
        }
        .sink(receiveCompletion: { completion in
            receivedUpdateCompletions.append(completion)
        }, receiveValue: { _ in
            fail("did not expect to receive a value")
        })
        expect(receivedUpdateCompletions.count).to(equal(1))
        expect(receivedUpdateCompletions.first) == .failure(
            LocalStoreError.write(error: ShipmentInfoCoreDataStore.Error.noMatchingEntity)
        )
    }
}

extension ShipmentInfoCoreDataStore {
    func add(shipmentInfos: [ShipmentInfo]) {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [ShipmentInfo]()

        let cancellable = save(shipmentInfos: shipmentInfos)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { results in
                receivedSaveResults.append(contentsOf: results)
            })

        expect(receivedSaveResults.count).to(equal(shipmentInfos.count))
        expect(receivedSaveResults.last) == shipmentInfos.last
        expect(receivedSaveCompletions.count).to(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }

    func add(shipmentInfo: ShipmentInfo) {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [ShipmentInfo?]()

        let cancellable = save(shipmentInfo: shipmentInfo)
            .sink(receiveCompletion: { completion in
                receivedSaveCompletions.append(completion)
            }, receiveValue: { result in
                receivedSaveResults.append(result)
            })

        expect(receivedSaveResults.count).toEventually(equal(1))
        expect(receivedSaveResults.last) == shipmentInfo
        expect(receivedSaveCompletions.count).to(equal(1))
        expect(receivedSaveCompletions.first) == .finished

        cancellable.cancel()
    }
}
