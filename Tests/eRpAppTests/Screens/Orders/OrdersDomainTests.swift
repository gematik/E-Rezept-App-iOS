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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import FeatureHelpers
import Nimble
import Pharmacy
import XCTest

@MainActor
final class OrdersDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<OrdersDomain>

    let schedulers = Schedulers(uiScheduler: DispatchQueue.immediate.eraseToAnyScheduler())
    var mockOrdersRepository: OrdersRepositoryMock!
    var mockInternalCommunicationProtocol: InternalCommunicationProtocolMock!

    override func setUp() {
        super.setUp()

        mockOrdersRepository = OrdersRepositoryMock()
        mockInternalCommunicationProtocol = InternalCommunicationProtocolMock()
    }

    private func testStore(for state: OrdersDomain.State) -> TestStore {
        TestStore(initialState: state) {
            OrdersDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = schedulers
            dependencies.ordersRepository = mockOrdersRepository
            dependencies.internalCommunicationProtocol = mockInternalCommunicationProtocol
        }
    }

    private func testStore(
        for communicationMessage: IdentifiedArrayOf<CommunicationMessage>
    ) -> TestStore {
        testStore(for: .init(communicationMessage: Shared(value: communicationMessage)))
    }

    func testOrdersDomainSubscriptionWithoutMessages() async {
        let store = testStore(for: OrdersDomain.State(communicationMessage: Shared(value: [])))

        mockOrdersRepository
            .loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, EuOrder>,
                Error
            > {
                $0.yield([])
            }

        mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue = AsyncThrowingStream<
                IdentifiedArray<String, Order>,
                Error
            > { $0.yield([]) }

        mockInternalCommunicationProtocol
            .loadIdentifiedArrayStringInternalCommunicationReturnValue = IdentifiedArray(uniqueElements: [])

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)
        await store.receive(.loadEuOrders)

        await store.receive(.response(.internalCommunicationReceived(.success([])))) {
            $0.isLoading = false
        }

        await store.receive(.response(.ordersReceived(.success([]))))

        await store.receive(.response(.euOrdersReceived(.success([]))))

        expect(self.mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCallsCount) == 1

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
            .loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, EuOrder>,
                Error
            > {
                $0.yield([])
            }

        mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue = AsyncThrowingStream<
                IdentifiedArray<String, Order>,
                Error
            > { $0.yield(expected)
            }

        let internalCommunication = InternalCommunication(messages: [
            .init(id: "1",
                  timestamp: Date(),
                  text: "Test Text",
                  version: "",
                  isRead: false),
        ])

        let expectedInternalCommunication = IdentifiedArray(uniqueElements: [internalCommunication])

        mockInternalCommunicationProtocol
            .loadIdentifiedArrayStringInternalCommunicationReturnValue =
            IdentifiedArray(uniqueElements: [internalCommunication])

        let store = testStore(for: OrdersDomain.State(communicationMessage: Shared(value: [])))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)
        await store.receive(.loadEuOrders)

        await store
            .receive(.response(.internalCommunicationReceived(.success(expectedInternalCommunication)))) { state in
                state.isLoading = false
                state.$communicationMessage.withLock {
                    $0.append(contentsOf: IdentifiedArray(uniqueElements: [CommunicationMessage
                            .internalCommunication(internalCommunication)]))
                }
                expect(
                    self.mockInternalCommunicationProtocol.loadIdentifiedArrayStringInternalCommunicationCallsCount
                ) == 1
            }

        await store.receive(.response(.ordersReceived(.success(expected))))

        await store.receive(.response(.euOrdersReceived(.success([]))))

        await task.cancel()
    }

    func testLoadOrdersWithError() async {
        let expected = DefaultOrdersRepository.Error.erxRepository(.local(.notImplemented))

        mockOrdersRepository
            .loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, EuOrder>,
                Error
            > {
                $0.yield([])
            }

        mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, Order>,
                Error
            > {
                $0.finish(throwing: expected)
            }

        mockInternalCommunicationProtocol
            .loadIdentifiedArrayStringInternalCommunicationReturnValue = IdentifiedArray(uniqueElements: [])

        let store = testStore(for: OrdersDomain.State(communicationMessage: Shared(value: [])))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)
        await store.receive(.loadEuOrders)

        await store.receive(.response(.internalCommunicationReceived(.success([])))) { state in
            state.isLoading = false
        }

        await store.receive(.response(.euOrdersReceived(.success([]))))

        await store.receive(.response(.ordersReceived(.failure(expected)))) { state in
            state.destination = .alert(.init(for: expected))
            expect(self.mockOrdersRepository
                .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorCallsCount) == 1
        }

        await task.cancel()
    }

    func testLoadOrdersWithDecodingError() async {
        let expected = InternalCommunicationError.invalidURL

        mockOrdersRepository
            .loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, EuOrder>,
                Error
            > {
                $0.yield([])
            }

        mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, Order>,
                Error
            > { $0.yield([]) }

        mockInternalCommunicationProtocol.loadIdentifiedArrayStringInternalCommunicationThrowableError = expected

        let store = testStore(for: OrdersDomain.State(communicationMessage: Shared(value: [])))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)
        await store.receive(.loadEuOrders)

        await store.receive(.response(.internalCommunicationReceived(.failure(expected)))) { state in
            state.isLoading = false
            state.destination = .alert(.init(for: expected))
        }

        await store.receive(.response(.ordersReceived(.success([]))))

        await store.receive(.response(.euOrdersReceived(.success([]))))

        await task.cancel()
    }

    func testSelectOrder() async throws {
        let orderId = "orderId"
        let expected = Order(
            orderId: orderId,
            communications: [communicationOnPremise, communicationShipment],
            chargeItems: []
        )
        let store = testStore(for: IdentifiedArray(uniqueElements: [.order(expected)]))

        try await store.send(.didSelect(XCTUnwrap(communicationOnPremise.orderId))) { state in
            state.destination = .orderDetail(.init(communicationMessage: Shared(value: .order(expected))))
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
            .loadEuOrdersProfileIdUUIDAsyncThrowingStreamIdentifiedArrayStringEuOrderSwiftErrorReturnValue =
            AsyncThrowingStream<
                IdentifiedArray<String, EuOrder>,
                Error
            > {
                $0.yield([])
            }

        mockOrdersRepository
            .loadAllOrdersAsyncThrowingStreamIdentifiedArrayStringOrderSwiftErrorReturnValue = AsyncThrowingStream<
                IdentifiedArray<String, Order>,
                Error
            > {
                $0.yield(expected)
            }

        let internalCommunication = InternalCommunication(messages: [.init(id: "1",
                                                                           timestamp: Date.distantPast,
                                                                           text: "Test Text",
                                                                           version: "",
                                                                           isRead: false)])

        let expectedInternalCommunication = IdentifiedArray(uniqueElements: [internalCommunication])

        mockInternalCommunicationProtocol
            .loadIdentifiedArrayStringInternalCommunicationReturnValue = expectedInternalCommunication

        let sortedMessages: IdentifiedArrayOf<CommunicationMessage> = [.order(order),
                                                                       .internalCommunication(internalCommunication)]

        let store = testStore(for: OrdersDomain.State(communicationMessage: Shared(value: [])))

        let task = await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.loadOrders)
        await store.receive(.loadMessages)
        await store.receive(.loadEuOrders)

        await store
            .receive(.response(.internalCommunicationReceived(.success(expectedInternalCommunication)))) { state in
                state.$communicationMessage.withLock {
                    $0 = sortedMessages
                }
                expect(
                    self.mockInternalCommunicationProtocol.loadIdentifiedArrayStringInternalCommunicationCallsCount
                ) ==
                    1
                state.isLoading = false
            }

        await store.receive(.response(.ordersReceived(.success(expected))))

        await store.receive(.response(.euOrdersReceived(.success([]))))

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
