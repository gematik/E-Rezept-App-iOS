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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import ErxTaskRepository
import IdentifiedCollections
import ModelsR4
import Nimble
import Pharmacy
import TestUtils
import XCTest

@MainActor
final class DefaultOrdersRepositoryTests: XCTestCase {
    func testLoadAllOrdersWithCommunicationsFromSameOrder() async throws {
        let communications = ErxTask.Communication.Fixtures.allOrderId1Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData
        let sut = DefaultOrdersRepository()

        let expectedOrder = Order(
            orderId: "order_id_1",
            communications: IdentifiedArrayOf(uniqueElements: communications),
            chargeItems: [chargeItem]
        )

        try await withDependencies { dependencies in
            dependencies.erxTaskRepository.loadLocalCommunications = { _ in communications }
            dependencies.erxTaskRepository.loadLocalChargeItem = { _, _ in chargeItem.sparseChargeItem }
            dependencies.pharmacyRepository.loadCached = { _ in nil }
        } operation: {
            for try await orders in sut.loadAllOrders() {
                expect(orders.count) == 1
                expect(orders.first!).to(equal(expectedOrder))
            }
        }
    }

    func testLoadAllOrdersWithPharmacyRepositoryError() async throws {
        let communications = ErxTask.Communication.Fixtures.allOrderId1Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData

        let sut = DefaultOrdersRepository()
        let expectedError = ["i-03702", "i-57101", "i-20301"]

        await withDependencies { dependencies in
            dependencies.erxTaskRepository.loadLocalCommunications = { _ in communications }
            dependencies.erxTaskRepository.loadLocalChargeItem = { _, _ in chargeItem.sparseChargeItem }
            dependencies.pharmacyRepository.loadCached = { _ in
                throw PharmacyRepositoryError.local(.notImplemented)
            }
        } operation: {
            do {
                for try await _ in sut.loadAllOrders() {}
            } catch {
                let orderError = error.asOrdersError()
                expect(orderError.erpErrorCodeList) == expectedError
            }
        }
    }

    func testLoadAllOrdersWithErxRepositoryError() async throws {
        let sut = DefaultOrdersRepository()
        let expectedError = ["i-03701", "i-20001", "i-20301"]

        await withDependencies { dependencies in
            dependencies.erxTaskRepository.loadLocalCommunications = { _ in
                throw ErxRepositoryError.local(.notImplemented)
            }
        } operation: {
            do {
                for try await _ in sut.loadAllOrders() {}
            } catch {
                let orderError = error.asOrdersError()
                expect(orderError.erpErrorCodeList) == expectedError
            }
        }
    }

    // Test the grouping of orders with two different order ids produces two groups
    // where the order of communications is as expected
    func testLoadAllOrdersWithCommunicationsFromTwoOrdersWithPharmacies() async throws {
        let communicationsOrder1 = ErxTask.Communication.Fixtures.allOrderId1Communications
        let communicationsOrder2 = ErxTask.Communication.Fixtures.allOrderId2Communications
        let chargeItem = ErxChargeItem.Fixtures.chargeItemWithFHIRData

        let sut = DefaultOrdersRepository()

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
        try await withDependencies { dependencies in
            dependencies.erxTaskRepository.loadLocalCommunications = { _ in
                communicationsOrder2 + communicationsOrder1
            }
            dependencies.erxTaskRepository.loadLocalChargeItem = { _, _ in chargeItem.sparseChargeItem }
            dependencies.pharmacyRepository.loadCached = { telematikId in
                if telematikId == PharmacyLocation.Fixtures.pharmacyA.telematikID {
                    return PharmacyLocation.Fixtures.pharmacyA
                } else if telematikId == PharmacyLocation.Fixtures.pharmacyB.telematikID {
                    return PharmacyLocation.Fixtures.pharmacyB
                } else {
                    return nil
                }
            }
        } operation: {
            for try await orders in sut.loadAllOrders() {
                expect(orders.count) == 2
                expect(orders).to(equal(expectedOrders))
                expect(orders).to(nodiff(expectedOrders))
            }
        }
    }
}
