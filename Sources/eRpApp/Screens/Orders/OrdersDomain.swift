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
import ComposableArchitecture
import eRpKit
import IdentifiedCollections
import Pharmacy
import UIKit

struct OrdersDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var orders: IdentifiedArrayOf<OrderCommunications> = []
        @PresentationState var destination: Destinations.State?
    }

    enum Action: Equatable {
        case subscribeToCommunicationChanges
        case didSelect(String)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(PresentationAction<Destinations.Action>)

        case response(Response)

        enum Response: Equatable {
            case communicationChangeReceived([ErxTask.Communication])
            case pharmaciesReceived([PharmacyLocation])
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = orders_detail
            case orderDetail(OrderDetailDomain.State)
        }

        enum Action: Equatable {
            case orderDetail(action: OrderDetailDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.orderDetail,
                action: /Action.orderDetail(action:)
            ) {
                OrderDetailDomain()
            }
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.ordersRepository) var ordersRepository: ErxTaskRepository
    @Dependency(\.pharmacyRepository) var pharmacyRepository: PharmacyRepository

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .subscribeToCommunicationChanges:
            return .publisher(
                ordersRepository.loadLocalCommunications(for: .all)
                    .catch { _ in Just([ErxTask.Communication]()) }
                    .map { .response(.communicationChangeReceived($0)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.communicationChangeReceived(communications)):
            state.orders = IdentifiedArray(
                uniqueElements: Dictionary(grouping: communications, by: { $0.orderId })
                    .compactMapValues { groupedCommunications -> OrderCommunications in
                        let orderId = groupedCommunications.first?.orderId ?? OrderCommunications.unknownOderId
                        return OrderCommunications(
                            orderId: orderId,
                            communications: groupedCommunications.sorted(),
                            pharmacy: state.orders[id: orderId]?.pharmacy
                        )
                    }
                    .values
                    .sorted()
            )
            return loadPharmacies(
                state.orders.filter { $0.pharmacy == nil }
            )
        case let .response(.pharmaciesReceived(pharmacies)):
            state.orders.forEach { order in
                guard order.pharmacy == nil else { return }
                state.orders[id: order.id]?.pharmacy = pharmacies.first(where: { $0.telematikID == order.telematikId })
            }
            return .none
        case let .didSelect(orderId):
            if let order = state.orders[id: orderId] {
                state.destination = .orderDetail(
                    .init(order: order)
                )
            }
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation,
             .destination:
            return .none
        }
    }
}

extension OrdersDomain {
    func loadPharmacies(_ orders: IdentifiedArrayOf<OrderCommunications>) -> EffectTask<OrdersDomain.Action> {
        let publishers: [AnyPublisher<PharmacyLocation?, Never>] = orders.map {
            pharmacyRepository.loadCached(by: $0.telematikId)
                .first()
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return .publisher(
            Publishers.MergeMany(publishers)
                .collect(publishers.count)
                .map { .response(.pharmaciesReceived($0.compactMap { $0 })) }
                .receive(on: schedulers.main.animation())
                .eraseToAnyPublisher
        )
    }
}

extension OrdersDomain {
    enum Dummies {
        static let state =
            State(orders: IdentifiedArray(uniqueElements: OrderCommunications.Dummies.multipleOrderCommunications))

        static let store = Store(
            initialState: state
        ) {
            OrdersDomain()
        }

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state
            ) {
                OrdersDomain()
            }
        }
    }
}
