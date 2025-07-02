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
@testable import eRpFeatures
import eRpKit
import IdentifiedCollections
import ModelsR4
import Nimble
import Pharmacy
import TestUtils
import XCTest

@MainActor
final class DefaultOrdersRepositoryTests: XCTestCase {
    let mockErxTaskRepository = MockErxTaskRepository()
    let mockPharmacyRepository = MockPharmacyRepository()

    private func ordersRepository() -> DefaultOrdersRepository {
        DefaultOrdersRepository(
            erxTaskRepository: mockErxTaskRepository,
            pharmacyRepository: mockPharmacyRepository
        )
    }

    func testLoadAllOrdersWithCommunicationsFromSameOrder() async throws {
        let sut = ordersRepository()
        let communications = ErxTask.Communication.Fixtures.allOrderId1Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData

        mockErxTaskRepository.listCommunicationsPublisher = Just(communications)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        mockErxTaskRepository.loadLocalChargeItemsPublisher = Just(chargeItem.sparseChargeItem)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        mockPharmacyRepository.loadCachedByClosure = { _ in
            Just(nil).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        }

        let expectedOrder = Order(
            orderId: "order_id_1",
            communications: IdentifiedArrayOf(uniqueElements: communications),
            chargeItems: [chargeItem]
        )

        for try await orders in sut.loadAllOrders() {
            expect(orders.count) == 1
            expect(orders.first!).to(equal(expectedOrder))
            expect(self.mockErxTaskRepository.listCommunicationsCallsCount) == 1
            expect(self.mockPharmacyRepository.loadCachedByCallsCount) == 1
            expect(self.mockErxTaskRepository.loadLocalChargeItemsCallsCount) == 3
        }
    }

    func testLoadAllOrdersWithPharmacyRepositoryError() async throws {
        let sut = ordersRepository()
        let expectedError = ["i-03702", "i-57101", "i-20301"]

        let communications = ErxTask.Communication.Fixtures.allOrderId1Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData

        mockErxTaskRepository.listCommunicationsPublisher = Just(communications)
            .setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()

        mockErxTaskRepository.loadLocalChargeItemsPublisher = Just(chargeItem.sparseChargeItem)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        mockPharmacyRepository.loadCachedByClosure = { _ in
            Fail(error: PharmacyRepositoryError.local(.notImplemented)).eraseToAnyPublisher()
        }

        do {
            for try await _ in sut.loadAllOrders() {}
        } catch {
            let orderError = error.asOrdersError()
            expect(orderError.erpErrorCodeList) == expectedError
        }
        expect(self.mockErxTaskRepository.listCommunicationsCallsCount) == 1
        expect(self.mockErxTaskRepository.loadLocalChargeItemsCallsCount) == 0
        expect(self.mockPharmacyRepository.loadCachedByCallsCount) == 1
    }

    func testLoadAllOrdersWithErxRepositoryError() async throws {
        let sut = ordersRepository()
        let expectedError = ["i-03701", "i-20001", "i-20301"]

        mockErxTaskRepository.listCommunicationsPublisher = Fail(error: ErxRepositoryError.local(.notImplemented))
            .eraseToAnyPublisher()

        do {
            for try await _ in sut.loadAllOrders() {}
        } catch {
            let orderError = error.asOrdersError()
            expect(orderError.erpErrorCodeList) == expectedError
        }
        expect(self.mockErxTaskRepository.listCommunicationsCallsCount) == 1
        expect(self.mockPharmacyRepository.loadCachedByCallsCount) == 0
    }

    // Test the grouping of orders with two different order ids produces two groups
    // where the order of communications is as expected
    func testLoadAllOrdersWithCommunicationsFromTwoOrdersWithPharmacies() async throws {
        let sut = ordersRepository()
        let communicationsOrder1 = ErxTask.Communication.Fixtures.allOrderId1Communications
        let communicationsOrder2 = ErxTask.Communication.Fixtures.allOrderId2Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData

        mockErxTaskRepository.listCommunicationsPublisher = Just(communicationsOrder2 + communicationsOrder1)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        mockErxTaskRepository.loadLocalChargeItemsPublisher = Just(chargeItem.sparseChargeItem)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        mockPharmacyRepository.loadCachedByClosure = { telematikId in
            if telematikId == PharmacyLocation.Fixtures.pharmacyA.telematikID {
                Just(PharmacyLocation.Fixtures.pharmacyA).setFailureType(to: PharmacyRepositoryError.self)
                    .eraseToAnyPublisher()
            } else if telematikId == PharmacyLocation.Fixtures.pharmacyB.telematikID {
                Just(PharmacyLocation.Fixtures.pharmacyB).setFailureType(to: PharmacyRepositoryError.self)
                    .eraseToAnyPublisher()
            } else {
                Just(nil).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
            }
        }

        let expectedOrders = IdentifiedArrayOf(uniqueElements: [
            Order(
                orderId: "order_id_1",
                communications: IdentifiedArrayOf(uniqueElements: communicationsOrder1),
                chargeItems: [chargeItem],
                pharmacy: PharmacyLocation.Fixtures.pharmacyA
            ),
            Order(
                orderId: "order_id_2",
                communications: IdentifiedArrayOf(uniqueElements: communicationsOrder2),
                chargeItems: [chargeItem],
                pharmacy: PharmacyLocation.Fixtures.pharmacyB
            ),
        ])
        for try await orders in sut.loadAllOrders() {
            expect(orders.count) == 2
            expect(orders).to(equal(expectedOrders))
            expect(orders).to(nodiff(expectedOrders))
            expect(self.mockErxTaskRepository.listCommunicationsCallsCount) == 1
            expect(self.mockPharmacyRepository.loadCachedByCallsCount) == 2
            expect(self.mockErxTaskRepository.loadLocalChargeItemsCallsCount) == 4 // for 4 different task_ids
        }
    }
}
