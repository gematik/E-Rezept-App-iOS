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
import eRpKit
import FeatureHelpers
import IdentifiedCollections
import Pharmacy
import UIKit

@Reducer
struct OrdersDomain {
    @Reducer
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
        @Shared var communicationMessage: IdentifiedArrayOf<CommunicationMessage>
        @Presents var destination: Destination.State?
        @Shared(.selectedProfileId) var profileId
    }

    enum Action: Equatable {
        case task
        case loadOrders
        case loadMessages
        case loadEuOrders
        case didSelect(String)

        case resetNavigation
        case destination(PresentationAction<Destination.Action>)

        case response(Response)

        enum Response: Equatable {
            case ordersReceived(Result<IdentifiedArrayOf<Order>, DefaultOrdersRepository.Error>)
            case euOrdersReceived(Result<IdentifiedArrayOf<EuOrder>, DefaultOrdersRepository.Error>)
            case internalCommunicationReceived(Result<IdentifiedArrayOf<InternalCommunication>,
                InternalCommunicationError>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.ordersRepository) var ordersRepository: OrdersRepository
    @Dependency(\.internalCommunicationProtocol) var internalCommunicationProtocol: InternalCommunicationProtocol

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.isLoading = true
            return .merge(
                .send(.loadOrders),
                .send(.loadMessages),
                .send(.loadEuOrders)
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
        case .loadEuOrders:
            return .run { [profileId = state.profileId] send in
                for try await euOrders in ordersRepository.loadEuOrders(profileId: profileId) {
                    await send(.response(.euOrdersReceived(.success(euOrders))))
                }
            }
            catch: { error, send in
                await send(.response(.euOrdersReceived(.failure(error.asOrdersError()))))
            }
        case let .response(.euOrdersReceived(result)):
            switch result {
            case let .success(orders):
                for order in orders {
                    _ = state.$communicationMessage.withLock { messages in
                        messages.updateOrAppend(CommunicationMessage.euOrder(order))
                    }
                }
                let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                    $0.lastUpdated > $1.lastUpdated
                }
                state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                return .none
            }
            state.isLoading = false
            return .none
        case let .response(.ordersReceived(result)):
            switch result {
            case let .success(orders):
                for order in orders {
                    _ = state.$communicationMessage.withLock { messages in
                        messages.updateOrAppend(CommunicationMessage.order(order))
                    }
                }
                let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                    $0.lastUpdated > $1.lastUpdated
                }
                state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
            case let .failure(error):
                state.destination = .alert(.init(for: error))
                return .none
            }
            state.isLoading = false
            return .none
        case let .response(.internalCommunicationReceived(result)):
            switch result {
            case let .success(messages):
                for message in messages {
                    _ = state.$communicationMessage.withLock { messages in
                        messages.updateOrAppend(CommunicationMessage.internalCommunication(message))
                    }
                }
                let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                    $0.lastUpdated > $1.lastUpdated
                }
                state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
            case let .failure(error):
                state.destination = .alert(.init(for: error))
            }
            state.isLoading = false
            return .none
        case let .didSelect(messageId):
            if let message = Shared(state.$communicationMessage[id: messageId]) {
                state.destination = .orderDetail(.init(communicationMessage: message))
            }
            return .none
        case .destination(
            .presented(.orderDetail(.destination(.presented(.euAccessCode(.response(.codeRefreshed(.success)))))))
        ), .destination(.presented(.orderDetail(.response(.euAccessCodeDeletedReceived(.success))))):
            return .send(.loadEuOrders)
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
            State(communicationMessage: Shared(value: [CommunicationMessage.order(Order.Dummies.orderCommunications1),
                                                       CommunicationMessage.order(Order.Dummies.orderCommunications2)]))

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

extension OrdersDomain.Destination.State: Equatable {}
extension OrdersDomain.Destination.Action: Equatable {}
