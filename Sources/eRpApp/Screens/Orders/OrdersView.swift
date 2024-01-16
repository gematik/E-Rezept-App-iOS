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
import SwiftUI

struct OrdersView: View {
    let store: OrdersDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, OrdersDomain.Action>
    // TODO: move dependency into domain and do formatting in the view model // swiftlint:disable:this todo
    @Dependency(\.uiDateFormatter) var uiDateFormatter

    init(store: OrdersDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isLoading: Bool
        let orders: IdentifiedArrayOf<Order>

        let destinationTag: OrdersDomain.Destinations.State.Tag?

        init(state: OrdersDomain.State) {
            isLoading = state.isLoading
            orders = state.orders
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewStore.state.orders.isEmpty || viewStore.isLoading {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewStore.orders) { order in
                                OrderCellView(
                                    title: order.pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text,
                                    subtitle: uiDateFormatter.relativeDate(order.lastUpdated) ?? "",
                                    isNew: order.hasUnreadEntries,
                                    prescriptionCount: order.tasksCount
                                ) {
                                    viewStore.send(.didSelect(order.orderId))
                                }
                            }
                            .redacted(reason: viewStore.isLoading ? .placeholder : .init())
                            .padding(.top)
                            .accessibilityElement(children: .contain)
                            .accessibility(identifier: A11y.orders.list.ordTxtList)
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                } else {
                    NoOrdersView()
                        .padding()
                }

                // Navigation into details
                NavigationLinkStore(
                    store.scope(state: \.$destination, action: OrdersDomain.Action.destination),
                    state: /OrdersDomain.Destinations.State.orderDetail,
                    action: OrdersDomain.Destinations.Action.orderDetail(action:),
                    onTap: { viewStore.send(.setNavigation(tag: .orderDetail)) },
                    destination: OrderDetailView.init(store:),
                    label: { EmptyView() }
                ).accessibility(hidden: true)
            }
            .navigationBarTitle(L10n.ordTxtTitle, displayMode: .automatic)
            .accessibility(identifier: A11y.orders.list.ordTxtTitle)
            .alert(
                store.scope(state: \.$destination, action: OrdersDomain.Action.destination),
                state: /OrdersDomain.Destinations.State.alert,
                action: OrdersDomain.Destinations.Action.alert
            )
            .task {
                await viewStore.send(.task).finish()
            }
            .toolbar {}
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct NoOrdersView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.ordTxtEmptyListTitle)
                    .font(.headline)
                Text(L10n.ordTxtEmptyListMessage)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
            .accessibility(identifier: A11y.orders.list.ordTxtEmptyList)
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrdersView(store: OrdersDomain.Dummies.store)
            OrdersView(store: OrdersDomain.Dummies.storeFor(OrdersDomain.State(orders: [])))
        }
    }
}
