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
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import Nimble
import Pharmacy
import XCTest

@MainActor
final class OrdersDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<OrdersDomain>

    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    var mockOrdersRepository: MockOrdersRepository!
    var mockApplication: MockResourceHandler!

    override func setUp() {
        super.setUp()

        mockOrdersRepository = MockOrdersRepository()
        mockApplication = MockResourceHandler()
    }

    private func testStore(for state: OrdersDomain.State) -> TestStore {
        TestStore(initialState: state) {
            OrdersDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.ordersRepository = mockOrdersRepository
            dependencies.resourceHandler = mockApplication
        }
    }

    private func testStore(
        for orders: IdentifiedArrayOf<Order>
    ) -> TestStore {
        testStore(for: .init(orders: orders))
    }

    private func erxTaskRepository(with communications: [ErxTask.Communication]) -> MockErxTaskRepository {
        let communicationPublisher = Just<[ErxTask.Communication]>(communications)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        let savePublisher = Just(true)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        return MockErxTaskRepository(listCommunications: communicationPublisher,
                                     saveCommunications: savePublisher)
    }

    private func pharmacyRepository(with pharmacies: [PharmacyLocation]) -> MockPharmacyRepository {
        let pharmacyPublisher = Just<PharmacyLocation?>(pharmacies.first)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let savePublisher = Just(true)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let mock = MockPharmacyRepository()
        mock.loadCachedByReturnValue = pharmacyPublisher
        mock.savePharmaciesReturnValue = savePublisher
        return mock
    }

    func testOrdersDomainSubscriptionWithoutMessages() async {
        let store = testStore(for: OrdersDomain.State(orders: []))

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> { $0.yield([]) }

        let task = await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(.response(.ordersReceived(.success([])))) {
            $0.isLoading = false
        }
        expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1

        await task.cancel()
    }

    func testOrdersDomainSubscriptionWithMessages() async {
        let orderId = "orderId"
        let expected = IdentifiedArray(
            uniqueElements: [Order(
                orderId: orderId,
                communications: [communicationShipment, communicationOnPremise],
                chargeItems: []
            )]
        )

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> { $0.yield(expected)
            }
        let store = testStore(for: OrdersDomain.State(orders: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(.response(.ordersReceived(.success(expected)))) { state in
            state.isLoading = false
            state.orders = expected
            expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1
        }

        await task.cancel()
    }

    func testLoadOrdersWithError() async {
        let expected = DefaultOrdersRepository.Error.erxRepository(.local(.notImplemented))

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> {
                $0.finish(throwing: expected)
            }

        let store = testStore(for: OrdersDomain.State(orders: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }
        await store.receive(.response(.ordersReceived(.failure(expected)))) { state in
            state.isLoading = false
            state.destination = .alert(.init(for: expected))
            expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1
        }

        await task.cancel()
    }

    func testSelectOrder() async {
        let orderId = "orderId"
        let expected = Order(
            orderId: orderId,
            communications: [communicationOnPremise, communicationShipment],
            chargeItems: []
        )
        let store = testStore(for: IdentifiedArray(uniqueElements: [expected]))

        await store.send(.didSelect(communicationOnPremise.orderId!)) { state in
            state.destination = .orderDetail(.init(order: expected))
        }
    }

    let pharmacy = PharmacyLocation(
        id: "123",
        status: .some(.active),
        telematikID: "telematikID",
        name: "",
        types: [],
        hoursOfOperation: []
    )

    let communicationOnPremise = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        orderId: "orderId",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\",\"pickUpCodeHR\":\"4711\",\"pickUpCodeDMC\":\"DMC-4711-and-more\" }" // swiftlint:disable:this line_length
    )

    let communicationShipment = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        orderId: "orderId",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://www.das-e-rezept-fuer-deutschland.de\"}"
        // swiftlint:disable:previous line_length
    )
}
