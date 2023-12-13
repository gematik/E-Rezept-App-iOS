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
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

@MainActor
final class OrdersDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<OrdersDomain>

    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    var mockOrdersRepository: MockErxTaskRepository!
    var mockPharmacyRepository: MockPharmacyRepository!
    var mockApplication: MockResourceHandler!

    override func setUp() {
        super.setUp()

        mockOrdersRepository = MockErxTaskRepository()
        mockPharmacyRepository = MockPharmacyRepository()
        mockApplication = MockResourceHandler()
    }

    private func testStore(for state: OrdersDomain.State) -> TestStore {
        TestStore(initialState: state) {
            OrdersDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.ordersRepository = mockOrdersRepository
            dependencies.pharmacyRepository = mockPharmacyRepository
            dependencies.resourceHandler = mockApplication
        }
    }

    private func testStore(
        for orders: IdentifiedArrayOf<OrderCommunications>
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
        let mockErxTaskRepoAccess = erxTaskRepository(with: [])
        let mockPharmacyRepoAccess = pharmacyRepository(with: [])
        mockOrdersRepository = mockErxTaskRepoAccess
        mockPharmacyRepository = mockPharmacyRepoAccess
        let store = testStore(for: OrdersDomain.State(orders: []))

        await store.send(.subscribeToCommunicationChanges)
        await store.receive(.response(.communicationChangeReceived([])))
        expect(mockErxTaskRepoAccess.listCommunicationsCallsCount) == 1
    }

    func testOrdersDomainSubscriptionWithMessages() async {
        let orderId = "orderId"
        var expected = OrderCommunications(
            orderId: orderId,
            communications: [communicationShipment, communicationOnPremise]
        )

        let mockErxTaskRepoAccess = erxTaskRepository(with: expected.communications.elements)
        let mockPharmacyRepoAccess = pharmacyRepository(with: [pharmacy])
        mockOrdersRepository = mockErxTaskRepoAccess
        mockPharmacyRepository = mockPharmacyRepoAccess
        let store = testStore(for: OrdersDomain.State(orders: []))

        await store.send(.subscribeToCommunicationChanges)
        await store.receive(.response(.communicationChangeReceived(expected.communications.elements))) { state in
            state.orders = IdentifiedArray(uniqueElements: [expected])
            expect(mockErxTaskRepoAccess.listCommunicationsCallsCount) == 1
            expect(mockErxTaskRepoAccess.saveCommunicationsCallsCount) == 0
        }
        await store.receive(.response(.pharmaciesReceived([pharmacy]))) { state in
            expected.pharmacy = self.pharmacy
            state.orders = IdentifiedArray(uniqueElements: [expected])
            expect(mockPharmacyRepoAccess.loadCachedByCallsCount) == 1
            expect(mockPharmacyRepoAccess.savePharmaciesCallsCount) == 0
        }
    }

    func testSelectOrder() async {
        let orderId = "orderId"
        let expected = OrderCommunications(
            orderId: orderId,
            communications: [communicationOnPremise, communicationShipment]
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
