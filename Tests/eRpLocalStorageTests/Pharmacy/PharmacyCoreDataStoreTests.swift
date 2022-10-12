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
import CombineSchedulers
import CoreData
import eRpKit
@testable import eRpLocalStorage
import Foundation
import Nimble
import XCTest

final class PharmacyCoreDataStoreTests: XCTestCase {
    private var databaseFile: URL!
    private let fileManager = FileManager.default
    private var factory: CoreDataControllerFactory?

    override func setUp() {
        super.setUp()
        databaseFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        if let controller = try? factory?.loadCoreDataController() {
            expect(try controller.destroyPersistentStore(at: self.databaseFile)).toNot(throwError())
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

    private func loadPharmacyCoreDataStore(for _: UUID? = nil) -> PharmacyCoreDataStore {
        PharmacyCoreDataStore(
            coreDataControllerFactory: loadFactory(),
            backgroundQueue: AnyScheduler.main
        )
    }

    private lazy var pharmacySimple: PharmacyLocation = {
        let position = PharmacyLocation.Position(
            latitude: 52.52249912396821024,
            longitude: -13.38754943050812048
        )
        let telecom = PharmacyLocation.Telecom(
            phone: "09876543",
            fax: "123456789",
            email: "app-feedback@gematik.de",
            web: "https://www.das-e-rezept-fuer-deutschland.de"
        )

        return PharmacyLocation(
            id: "1234",
            status: .active,
            telematikID: "T.S-1",
            name: "Simple Pharmacy",
            types: [],
            position: position,
            telecom: telecom,
            hoursOfOperation: []
        )
    }()

    private lazy var pharmacyWithTypeAndHours: PharmacyLocation = {
        PharmacyLocation(
            id: "4567",
            status: .active,
            telematikID: "T.S-1-23",
            name: "Pharmacy with type and hours",
            types: [.pharm, .outpharm],
            hoursOfOperation: [.init(
                daysOfWeek: ["mon"],
                openingTime: "08:00:00",
                closingTime: "18:30:00"
            )]
        )
    }()

    func testSavingPharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        try store.add(pharmacies: [pharmacySimple])
    }

    func testSavingPharmacyWillNotStoreAllValues() throws {
        let store = loadPharmacyCoreDataStore()
        try store.add(pharmacies: [pharmacyWithTypeAndHours, pharmacySimple])

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()
        let cancellable = store.listAllPharmacies()
            .sink(receiveCompletion: { completion in
                receivedCompletions.append(completion)
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        expect(receivedCompletions.count) == 0
        expect(receivedListAllPharmacyValues.count).toEventually(equal(1))
        // then two pharmacies should be received (without saving status, types and hoursOfOperation) for know
        expect(receivedListAllPharmacyValues[0].count) == 2
        let first = receivedListAllPharmacyValues[0].first(where: { $0.telematikID == pharmacySimple.telematikID })
        expect(first?.id).to(equal(pharmacySimple.id))
        expect(first?.status).to(beNil())
        expect(first?.created).to(equal(pharmacySimple.created))
        expect(first?.name).to(equal(pharmacySimple.name))
        expect(first?.types).to(equal(pharmacySimple.types))
        // Position should be present here
        guard let lat = first?.position?.latitude?.doubleValue,
              let long = first?.position?.longitude?.doubleValue,
              let pharmacySimpleLat = pharmacySimple.position?.latitude?.doubleValue,
              let pharmacySimpleLong = pharmacySimple.position?.longitude?.doubleValue else {
            throw LocalStoreError.notImplemented
        }
        expect(lat).to(beCloseTo(pharmacySimpleLat))
        expect(long).to(beCloseTo(pharmacySimpleLong))
        expect(first?.telecom).to(equal(pharmacySimple.telecom))
        expect(first?.hoursOfOperation).to(equal(pharmacySimple.hoursOfOperation))

        let second = receivedListAllPharmacyValues[0]
            .first(where: { $0.telematikID == pharmacyWithTypeAndHours.telematikID })
        expect(second?.id).to(equal(pharmacyWithTypeAndHours.id))
        expect(second?.status).to(beNil())
        expect(second?.created).to(equal(pharmacyWithTypeAndHours.created))
        expect(second?.name).to(equal(pharmacyWithTypeAndHours.name))
        expect(second?.types).to(beEmpty())
        expect(second?.position).to(beNil())
        expect(second?.telecom).to(beNil())
        expect(second?.hoursOfOperation).to(beEmpty())

        cancellable.cancel()
    }

    func testSavePharmacyWithFailingLoadingDatabase() throws {
        let factory = MockCoreDataControllerFactory()
        factory.loadCoreDataControllerError = LocalStoreError.notImplemented
        let store = PharmacyCoreDataStore(
            coreDataControllerFactory: factory,
            backgroundQueue: AnyScheduler.main
        )

        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = store.save(pharmacies: [pharmacySimple])
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

    func testUpdatingPharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        let updatedPharmacy = PharmacyLocation(
            id: pharmacySimple.id,
            status: nil,
            telematikID: "S.0815",
            name: "New Pharmacy",
            types: [],
            hoursOfOperation: []
        )
        try store.add(pharmacies: [updatedPharmacy])

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        let cancellable = store.listAllPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect completion")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        // then there should be only one in store with the updated values
        expect(receivedListAllPharmacyValues.count).toEventually(equal(1))
        expect(receivedListAllPharmacyValues[0].count) == 1
        let result = receivedListAllPharmacyValues[0].first
        expect(result?.status).to(beNil())
        expect(result?.created).to(equal(pharmacySimple.created))
        expect(result?.telematikID) == updatedPharmacy.telematikID
        expect(result?.name) == updatedPharmacy.name

        cancellable.cancel()
    }

    func testDeletePharmacy() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when deleting pharmacy
        var receivedDeleteResults = [Bool]()
        var receivedDeleteCompletions = [Subscribers.Completion<LocalStoreError>]()
        _ = store.delete(pharmacies: [pharmacySimple])
            .sink(receiveCompletion: { completion in
                receivedDeleteCompletions.append(completion)
            }, receiveValue: { result in
                receivedDeleteResults.append(result)
            })
        expect(receivedDeleteResults.count).toEventually(equal(1))
        expect(receivedDeleteResults.first).to(beTrue())
        expect(receivedDeleteCompletions.count).toEventually(equal(1))
        expect(receivedDeleteCompletions.first) == .finished

        // then
        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        _ = store.listAllPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        expect(receivedListAllPharmacyValues.count).toEventually(equal(1))
        // there should be no pharmacy left in store
        expect(receivedListAllPharmacyValues.first?.count) == 0
    }

    func testFetchPharmacyByTelematikIdSuccess() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when we fetch that pharmacy
        var receivedFetchResult: PharmacyLocation?
        let cancellable = store.fetchPharmacy(by: pharmacySimple.telematikID)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedFetchResult = result
            })

        // then it should be the one we expect
        expect(receivedFetchResult).toEventually(equal(pharmacySimple))

        cancellable.cancel()
    }

    func testFetchPharmacyByTelematikIdNoResults() throws {
        let store = loadPharmacyCoreDataStore()

        var receivedNoResult = false
        // when fetching a pharmacy that has not been added to the store
        let cancellable = store.fetchPharmacy(by: pharmacySimple.telematikID)
            .sink(receiveCompletion: { completion in
                expect(completion) == .finished
            }, receiveValue: { result in
                receivedNoResult = result == nil
            })

        // then it should return none
        expect(receivedNoResult).toEventually(beTrue())

        cancellable.cancel()
    }

    func testUpdatePharmacyWithMatchingInStore() throws {
        let store = loadPharmacyCoreDataStore()
        // given
        try store.add(pharmacies: [pharmacySimple])

        // when
        var receivedUpdateValues = [Bool]()
        var expectedResult: PharmacyLocation?
        _ = store.update(identifier: pharmacySimple.id) { pharmacy in
            pharmacy.status = .suspended
            pharmacy.name = "Updated Pharmacy"
            pharmacy.telematikID = "---"
            expectedResult = pharmacy
        }
        .sink(receiveCompletion: { completion in
            expect(completion) == .finished
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedUpdateValues.count).toEventually(equal(1))

        var receivedListAllPharmacyValues = [[PharmacyLocation]]()
        // we observe all store changes
        let cancellable = store.listAllPharmacies()
            .sink(receiveCompletion: { _ in
                fail("did not expect to complete")
            }, receiveValue: { pharmacies in
                receivedListAllPharmacyValues.append(pharmacies)
            })

        // then
        expect(receivedListAllPharmacyValues.count).toEventually(equal(1))
        expect(receivedListAllPharmacyValues.first?.count) == 1
        expect(receivedListAllPharmacyValues.first?.first) == expectedResult

        cancellable.cancel()
    }

    func testUpdatePharmacyWithoutMatchingInStore() throws {
        let store = loadPharmacyCoreDataStore()
        var receivedUpdateValues = [Bool]()
        var receivedCompletions = [Subscribers.Completion<LocalStoreError>]()

        let cancellable = store.update(identifier: pharmacySimple.id) { _ in
            fail("should not be called if an error fetching pharmacy occurs")
        }
        .sink(receiveCompletion: { completion in
            receivedCompletions.append(completion)
        }, receiveValue: { result in
            receivedUpdateValues.append(result)
        })

        expect(receivedCompletions.count).toEventually(equal(1))
        let expectedError = LocalStoreError.write(error: PharmacyCoreDataStore.Error.noMatchingEntity)
        expect(receivedCompletions.first) == .failure(expectedError)
        expect(receivedUpdateValues.count).toEventually(equal(0))

        cancellable.cancel()
    }
}

extension PharmacyCoreDataStore {
    func add(pharmacies: [PharmacyLocation]) throws {
        var receivedSaveCompletions = [Subscribers.Completion<LocalStoreError>]()
        var receivedSaveResults = [Bool]()

        let cancellable = save(pharmacies: pharmacies)
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
}
