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
import SwiftUI

struct OrdersView: View {
    let store: OrdersDomain.Store
    let profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, OrdersDomain.Action>

    init(store: OrdersDomain.Store, profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
        self.profileSelectionToolbarItemStore = profileSelectionToolbarItemStore
    }

    struct ViewState: Equatable {
        let orders: IdentifiedArrayOf<OrderCommunications>

        let routeTag: OrdersDomain.Route.Tag?

        init(state: OrdersDomain.State) {
            orders = state.orders
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewStore.state.orders.isEmpty {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewStore.orders) { order in
                                OrderCellView(
                                    title: order.pharmacy?.name,
                                    subtitle: Self.uiFormattedDate(dateString: order.lastUpdated) ?? "",
                                    isNew: order.hasNewCommunications,
                                    prescriptionCount: order.prescriptionCount
                                ) {
                                    viewStore.send(.didSelect(order.orderId))
                                }
                            }
                            .padding(.top)
                            .accessibilityElement(children: .contain)
                            .accessibility(identifier: A11y.orders.list.ordTxtList)
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                } else {
                    NoOdersView()
                        .padding()
                }

                // Navigation into details
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: (\OrdersDomain.State.route)
                                .appending(path: /OrdersDomain.Route.orderDetail)
                                .extract(from:),
                            action: OrdersDomain.Action.orderDetail(action:)
                        )
                    ) { scopedStore in
                        OrderDetailView(store: scopedStore)
                    },
                    tag: OrdersDomain.Route.Tag.orderDetail,
                    selection: viewStore.binding(
                        get: \.routeTag,
                        send: OrdersDomain.Action.setNavigation
                    )
                ) {
                    EmptyView()
                }.accessibility(hidden: true)

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: Binding<Bool>(
                        get: { viewStore.routeTag == .selectProfile },
                        set: { show in
                            if !show {
                                viewStore.send(.setNavigation(tag: nil))
                            }
                        }
                    ),
                    onDismiss: {},
                    content: {
                        ProfileSelectionView(
                            store: profileSelectionToolbarItemStore
                                .scope(state: \.profileSelectionState,
                                       action: ProfileSelectionToolbarItemDomain.Action.profileSelection(action:))
                        )
                    })
                    .hidden()
                    .accessibility(hidden: true)
            }
            .navigationBarTitle(L10n.ordTxtTitle, displayMode: .automatic)
            .accessibility(identifier: A11y.orders.list.ordTxtTitle)
            .onAppear { viewStore.send(.subscribeToCommunicationChanges) }
            .onDisappear { viewStore.send(.removeSubscription) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserProfileSelectionToolbarItem(store: profileSelectionToolbarItemStore) {
                        viewStore.send(.setNavigation(tag: .selectProfile))
                    }
                    .embedToolbarContent()
                    .accessibility(identifier: A18n.mainScreen.erxBtnProfile)
                }
            }
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private static func uiFormattedDate(dateString: String?) -> String? {
        if let dateString = dateString,
           let date = globals.fhirDateFormatter.date(from: dateString,
                                                     format: .yearMonthDay) {
            return globals.uiDateFormatter.string(from: date)
        }
        return dateString
    }

    struct NoOdersView: View {
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

struct OdersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrdersView(store: OrdersDomain.Dummies.store,
                       profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store)
            OrdersView(store: OrdersDomain.Dummies.storeFor(OrdersDomain.State(orders: [])),
                       profileSelectionToolbarItemStore: ProfileSelectionToolbarItemDomain.Dummies.store)
        }
    }
}
