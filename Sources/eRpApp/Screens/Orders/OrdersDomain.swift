//
//  Copyright (c) 2022 gematik GmbH
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

enum OrdersDomain: Equatable {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that needs to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        OrderDetailDomain.cleanup()
    }

    enum Token: CaseIterable, Hashable {
        case loadCommunications
        case loadPharmacies
    }

    enum Route: Equatable {
        case orderDetail(OrderDetailDomain.State)
        case selectProfile

        enum Tag: Int {
            case orderDetail
            case selectProfile
        }

        var tag: Tag {
            switch self {
            case .orderDetail:
                return .orderDetail
            case .selectProfile:
                return .selectProfile
            }
        }
    }

    struct State: Equatable {
        var orders: IdentifiedArrayOf<OrderCommunications> = []
        var route: Route?
    }

    enum Action: Equatable {
        case subscribeToCommunicationChanges
        case communicationChangeReceived([ErxTask.Communication])
        case pharmaciesReceived([PharmacyLocation])
        case didSelect(String)
        case orderDetail(action: OrderDetailDomain.Action)
        case setNavigation(tag: Route.Tag?)
        case removeSubscription
    }

    struct Environment {
        let schedulers: Schedulers
        let userSession: UserSession
        let fhirDateFormatter: FHIRDateFormatter
        let erxTaskRepository: ErxTaskRepository
        let pharmacyRepository: PharmacyRepository
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .subscribeToCommunicationChanges:
            return environment.erxTaskRepository.loadLocalCommunications(for: .all)
                .catch { _ in Just([ErxTask.Communication]()) }
                .map(OrdersDomain.Action.communicationChangeReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.loadCommunications, cancelInFlight: true)
        case let .communicationChangeReceived(communications):
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
            return environment.loadPharmacies(
                state.orders.filter { $0.pharmacy == nil }
            )
            .cancellable(id: Token.loadPharmacies)
        case let .pharmaciesReceived(pharmacies):
            state.orders.forEach { order in
                guard order.pharmacy == nil else { return }
                state.orders[id: order.id]?.pharmacy = pharmacies.first(where: { $0.telematikID == order.telematikId })
            }
            return .none
        case .removeSubscription:
            return cleanup()
        case let .didSelect(orderId):
            if let order = state.orders[id: orderId] {
                state.route = .orderDetail(
                    .init(order: order)
                )
            }
            return .none
        case .setNavigation(tag: .selectProfile):
            state.route = .selectProfile
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return cleanupSubDomains()
        case .setNavigation,
             .orderDetail:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        messagesReducer,
        domainReducer
    )
}

extension OrdersDomain.Environment {
    func loadPharmacies(_ orders: IdentifiedArrayOf<OrderCommunications>) -> Effect<OrdersDomain.Action, Never> {
        let publishers: [AnyPublisher<PharmacyLocation?, Never>] = orders.map {
            pharmacyRepository.loadCached(by: $0.telematikId)
                .first()
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .collect(publishers.count)
            .map { .pharmaciesReceived($0.compactMap { $0 }) }
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }
}

extension OrdersDomain {
    private static let messagesReducer: Reducer =
        OrderDetailDomain.reducer
            ._pullback(
                state: (\State.route).appending(path: /OrdersDomain.Route.orderDetail),
                action: /OrdersDomain.Action.orderDetail(action:)
            ) {
                .init(
                    schedulers: $0.schedulers,
                    userSession: $0.userSession,
                    fhirDateFormatter: $0.fhirDateFormatter,
                    erxTaskRepository: $0.erxTaskRepository,
                    application: UIApplication.shared
                )
            }
}

extension OrdersDomain {
    enum Dummies {
        static let communicationOnPremise = ErxTask.Communication(
            identifier: "1",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
        )

        static let communicationShipment = ErxTask.Communication(
            identifier: "2",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-28T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"www.das-e-rezept-fuer-deutschland.de\"}",
            // swiftlint:disable:previous line_length
            isRead: true
        )

        static let communicationDelivery = ErxTask.Communication(
            identifier: "3",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            timestamp: "2021-05-29T10:59:37.098245933+00:00",
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
        )

        static let communicationWithOrderId = ErxTask.Communication(
            identifier: "4",
            profile: .reply,
            taskId: "taskID",
            userId: "userID",
            telematikId: "telematikID",
            orderId: "orderId",
            timestamp: "2021-05-26T10:59:37.098245933+00:00",
            // swiftlint:disable:next line_length
            payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}",
            isRead: true
        )

        static let demoSessionContainer = DummyUserSessionContainer()

        static let orders = [
            OrderCommunications(
                orderId: "orderId_1",
                communications: [communicationOnPremise,
                                 communicationShipment,
                                 communicationDelivery]
            ),
            OrderCommunications(
                orderId: "orderId_2",
                communications: [communicationWithOrderId],
                pharmacy: PharmacyLocation.Dummies.pharmacy
            ),
        ]

        static let state =
            State(orders: IdentifiedArray(uniqueElements: orders))
        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            fhirDateFormatter: globals.fhirDateFormatter,
            erxTaskRepository: demoSessionContainer.userSession.erxTaskRepository,
            pharmacyRepository: demoSessionContainer.userSession.pharmacyRepository
        )
        static let store = Store(initialState: state,
                                 reducer: domainReducer,
                                 environment: environment)
        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: OrdersDomain.Reducer.empty,
                  environment: environment)
        }
    }
}
