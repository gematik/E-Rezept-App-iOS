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
    var mockInternalCommunicationProtocol: MockInternalCommunicationProtocol!

    override func setUp() {
        super.setUp()

        mockOrdersRepository = MockOrdersRepository()
        mockApplication = MockResourceHandler()
        mockInternalCommunicationProtocol = MockInternalCommunicationProtocol()
    }

    private func testStore(for state: OrdersDomain.State) -> TestStore {
        TestStore(initialState: state) {
            OrdersDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.ordersRepository = mockOrdersRepository
            dependencies.resourceHandler = mockApplication
            dependencies.internalCommunicationProtocol = mockInternalCommunicationProtocol
        }
    }

    private func testStore(
        for communicationMessage: IdentifiedArrayOf<CommunicationMessage>
    ) -> TestStore {
        testStore(for: .init(communicationMessage: communicationMessage))
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
        let store = testStore(for: OrdersDomain.State(communicationMessage: []))

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> { $0.yield([]) }

        mockInternalCommunicationProtocol.loadReturnValue = IdentifiedArray(uniqueElements: [])

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)

        await store.receive(.response(.internalCommunicationReceived(.success([])))) {
            $0.isLoading = false
        }

        await store.receive(.response(.ordersReceived(.success([]))))

        expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1

        await task.cancel()
    }

    func testOrdersDomainSubscriptionWithMessages() async {
        let orderId = "orderId"
        let order = Order(
            orderId: orderId,
            communications: [communicationShipment, communicationOnPremise],
            chargeItems: []
        )
        let expected = IdentifiedArray(uniqueElements: [order])

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> { $0.yield(expected)
            }

        let internalCommunication = InternalCommunication(messages: [.init(id: "1",
                                                                           timestamp: Date(),

                                                                           text: "Test Text",
                                                                           version: "",
                                                                           isRead: false)])

        let expectedInternalCommunication = IdentifiedArray(uniqueElements: [internalCommunication])

        mockInternalCommunicationProtocol.loadReturnValue = IdentifiedArray(uniqueElements: [internalCommunication])

        let store = testStore(for: OrdersDomain.State(communicationMessage: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)

        await store
            .receive(.response(.internalCommunicationReceived(.success(expectedInternalCommunication)))) { state in
                state.isLoading = false
                state.communicationMessage
                    .append(contentsOf: IdentifiedArray(uniqueElements: [CommunicationMessage
                            .internalCommunication(internalCommunication)]))
                expect(self.mockInternalCommunicationProtocol.loadCallsCount) == 1
            }

        await store.receive(.response(.ordersReceived(.success(expected)))) { state in
            state.communicationMessage
                .append(contentsOf: IdentifiedArray(uniqueElements: [CommunicationMessage.order(order)]))
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

        mockInternalCommunicationProtocol.loadReturnValue = IdentifiedArray(uniqueElements: [])

        let store = testStore(for: OrdersDomain.State(communicationMessage: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)

        await store.receive(.response(.internalCommunicationReceived(.success([])))) { state in
            state.isLoading = false
        }

        await store.receive(.response(.ordersReceived(.failure(expected)))) { state in
            state.destination = .alert(.init(for: expected))
            expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1
        }

        await task.cancel()
    }

    func testLoadOrdersWithDecodingError() async {
        let expected = InternalCommunicationError.invalidURL

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> { $0.yield([]) }

        mockInternalCommunicationProtocol.loadThrowableError = expected

        let store = testStore(for: OrdersDomain.State(communicationMessage: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)

        await store.receive(.response(.internalCommunicationReceived(.failure(expected)))) { state in
            state.isLoading = false
            state.destination = .alert(.init(for: expected))
        }

        await store.receive(.response(.ordersReceived(.success([]))))

        await task.cancel()
    }

    func testSelectOrder() async {
        let orderId = "orderId"
        let expected = Order(
            orderId: orderId,
            communications: [communicationOnPremise, communicationShipment],
            chargeItems: []
        )
        let store = testStore(for: IdentifiedArray(uniqueElements: [.order(expected)]))

        await store.send(.didSelect(communicationOnPremise.orderId!)) { state in
            state.destination = .orderDetail(.init(communicationMessage: .order(expected)))
        }
    }

    func testCommunicationArrayIsSorted() async {
        let order = Order(
            orderId: "orderId",
            communications: [communicationShipment, communicationOnPremise],
            chargeItems: []
        )
        let expected = IdentifiedArray(uniqueElements: [order])

        mockOrdersRepository
            .loadAllOrdersReturnValue = AsyncThrowingStream<IdentifiedArray<String, Order>, Error> {
                $0.yield(expected)
            }

        let internalCommunication = InternalCommunication(messages: [.init(id: "1",
                                                                           timestamp: Date.distantPast,
                                                                           text: "Test Text",
                                                                           version: "",
                                                                           isRead: false)])

        let expectedInternalCommunication = IdentifiedArray(uniqueElements: [internalCommunication])

        mockInternalCommunicationProtocol.loadReturnValue = expectedInternalCommunication

        let sortedMessages: IdentifiedArrayOf<CommunicationMessage> = [.order(order),
                                                                       .internalCommunication(internalCommunication)]

        let store = testStore(for: OrdersDomain.State(communicationMessage: []))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)

        await store
            .receive(.response(.internalCommunicationReceived(.success(expectedInternalCommunication)))) { state in
                state
                    .communicationMessage =
                    IdentifiedArray(uniqueElements: [CommunicationMessage.internalCommunication(internalCommunication)])
                expect(self.mockInternalCommunicationProtocol.loadCallsCount) == 1
                state.isLoading = false
            }

        await store.receive(.response(.ordersReceived(.success(expected)))) { state in
            state.communicationMessage = sortedMessages
            expect(self.mockOrdersRepository.loadAllOrdersCallsCount) == 1
            state.isLoading = false
        }

        // This should always be the last element if sorted correctly
        expect(store.state.communicationMessage.last) == .internalCommunication(internalCommunication)

        await task.cancel()
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
