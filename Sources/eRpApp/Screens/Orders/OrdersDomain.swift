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
import ComposableArchitecture
import eRpKit
import IdentifiedCollections
import Pharmacy
import UIKit

@Reducer
struct OrdersDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = orders_detail
        case orderDetail(OrderDetailDomain)
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Never>)
    }

    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var communicationMessage: IdentifiedArrayOf<CommunicationMessage> = []
        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case task
        case loadOrders
        case loadMessages
        case didSelect(String)

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

        case response(Response)

        enum Response: Equatable {
            case ordersReceived(Result<IdentifiedArrayOf<Order>, DefaultOrdersRepository.Error>)
            case internalCommunicationReceived(Result<IdentifiedArrayOf<InternalCommunication>,
                InternalCommunicationError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.ordersRepository) var ordersRepository: OrdersRepository
    @Dependency(\.internalCommunicationProtocol) var internalCommunicationProtocol: InternalCommunicationProtocol

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.isLoading = true
            return .merge(
                .send(.loadOrders),
                .send(.loadMessages)
            )
        case .loadOrders:
            return .run { send in
                for try await orders in ordersRepository.loadAllOrders() {
                    await send(.response(.ordersReceived(.success(orders))))
                }
            }
            catch: { error, send in
                await send(.response(.ordersReceived(.failure(error.asOrdersError()))))
            }
        case .loadMessages:
            return .run { send in
                do {
                    let messages = try await internalCommunicationProtocol.load()
                    await send(.response(.internalCommunicationReceived(.success(messages))))
                } catch {
                    await send(.response(.internalCommunicationReceived(.failure(error
                            .asInternalCommunicationError()))))
                }
            }
        case let .response(.ordersReceived(result)):
            state.isLoading = false
            switch result {
            case let .success(orders):
                for order in orders {
                    state.communicationMessage.updateOrAppend(CommunicationMessage.order(order))
                }
            case let .failure(error):
                state.destination = .alert(.init(for: error))
            }
            return .none
        case let .response(.internalCommunicationReceived(result)):
            state.isLoading = false
            switch result {
            case let .success(messages):
                for message in messages {
                    state.communicationMessage.updateOrAppend(CommunicationMessage.internalCommunication(message))
                }
            case let .failure(error):
                state.destination = .alert(.init(for: error))
            }
            return .none
        case let .didSelect(messageId):
            if let message = state.communicationMessage[id: messageId] {
                state.destination = .orderDetail(.init(communicationMessage: message))
            }
            return .none
        case .resetNavigation,
             .destination(.presented(.orderDetail(.delegate(.close)))):
            state.destination = nil
            return .none
        case .destination:
            return .none
        }
    }
}

extension OrdersDomain {
    enum Dummies {
        static let state =
            State(communicationMessage: [CommunicationMessage.order(Order.Dummies.orderCommunications1),
                                         CommunicationMessage.order(Order.Dummies.orderCommunications2)])

        static let store = StoreOf<OrdersDomain>(
            initialState: state
        ) {
            OrdersDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<OrdersDomain> {
            Store(
                initialState: state
            ) {
                OrdersDomain()
            }
        }
    }
}
