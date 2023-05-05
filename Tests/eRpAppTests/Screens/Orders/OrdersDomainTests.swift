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

final class OrdersDomainTests: XCTestCase {
    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    let mockErxTaskRepository = MockErxTaskRepository(
        saveCommunications: Just(true).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
    )
    let mockPharmacyRepository = MockPharmacyRepository()
    let mockApplication = MockResourceHandler()
    typealias TestStore = ComposableArchitecture.TestStore<
        OrdersDomain.State,
        OrdersDomain.Action,
        OrdersDomain.State,
        OrdersDomain.Action,
        Void
    >

    private func testStore(
        for erxTaskRepository: MockErxTaskRepository,
        and pharmacyRepository: MockPharmacyRepository
    ) -> TestStore {
        TestStore(
            initialState: OrdersDomain.State(orders: []),
            reducer: OrdersDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = DummySessionContainer()
            dependencies.erxTaskRepository = erxTaskRepository
            dependencies.pharmacyRepository = pharmacyRepository
        }
    }

    private func testStore(
        for orders: IdentifiedArrayOf<OrderCommunications>,
        resourceHandler _: ResourceHandler = UnimplementedResourceHandler()
    ) -> TestStore {
        TestStore(
            initialState: OrdersDomain.State(orders: orders),
            reducer: OrdersDomain()
        ) { dependencies in
            dependencies.schedulers = schedulers
            dependencies.userSession = DummySessionContainer()
            dependencies.erxTaskRepository = mockErxTaskRepository
            dependencies.pharmacyRepository = mockPharmacyRepository
        }
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
        return MockPharmacyRepository(
            loadCachedById: pharmacyPublisher,
            savePharmacies: savePublisher
        )
    }

    func testOrdersDomainSubscriptionWithoutMessages() {
        let mockErxTaskRepoAccess = erxTaskRepository(with: [])
        let mockPharmacyRepoAccess = pharmacyRepository(with: [])
        let store = testStore(for: mockErxTaskRepoAccess, and: mockPharmacyRepoAccess)

        store.send(.subscribeToCommunicationChanges)
        store.receive(.response(.communicationChangeReceived([])))
        expect(mockErxTaskRepoAccess.listCommunicationsCallsCount) == 1
    }

    func testOrdersDomainSubscriptionWithMessages() {
        let orderId = "orderId"
        var expected = OrderCommunications(
            orderId: orderId,
            communications: [communicationShipment, communicationOnPremise]
        )

        let mockErxTaskRepoAccess = erxTaskRepository(with: expected.communications.elements)
        let mockPharmacyRepoAccess = pharmacyRepository(with: [pharmacy])
        let store = testStore(for: mockErxTaskRepoAccess, and: mockPharmacyRepoAccess)

        store.send(.subscribeToCommunicationChanges)
        store.receive(.response(.communicationChangeReceived(expected.communications.elements))) { state in
            state.orders = IdentifiedArray(uniqueElements: [expected])
            expect(mockErxTaskRepoAccess.listCommunicationsCallsCount) == 1
            expect(mockErxTaskRepoAccess.saveCommunicationsCallsCount) == 0
        }
        store.receive(.response(.pharmaciesReceived([pharmacy]))) { state in
            expected.pharmacy = self.pharmacy
            state.orders = IdentifiedArray(uniqueElements: [expected])
            expect(mockPharmacyRepoAccess.loadCachedCallsCount) == 1
            expect(mockPharmacyRepoAccess.saveCallsCount) == 0
        }
    }

    func testSelectOrder() {
        let orderId = "orderId"
        let expected = OrderCommunications(
            orderId: orderId,
            communications: [communicationOnPremise, communicationShipment]
        )
        let store = testStore(for: IdentifiedArray(uniqueElements: [expected]))

        store.send(.didSelect(communicationOnPremise.orderId!)) { state in
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
