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
import eRpStyleKit
import IdentifiedCollections
import Perception
import SwiftUI

struct OrdersView: View {
    @Perception.Bindable var store: StoreOf<OrdersDomain>
    // TODO: move dependency into domain and do formatting in the view model // swiftlint:disable:this todo
    @Dependency(\.uiDateFormatter) var uiDateFormatter

    init(store: StoreOf<OrdersDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    if !store.state.communicationMessage.isEmpty || store.isLoading {
                        ScrollView(.vertical) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(store.communicationMessage) { message in
                                    OrderCellView(
                                        title: message.title,
                                        message: message.latestMessage,
                                        subtitle: uiDateFormatter.relativeDate(message.lastUpdated) ?? "",
                                        isNew: message.hasUnreadMessages,
                                        prescriptionCount: message.order?.tasksCount ?? 0
                                    ) {
                                        store.send(.didSelect(message.id))
                                    }
                                }
                                .redacted(reason: store.isLoading ? .placeholder : .init())
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
                }
                // Navigation into details
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.orderDetail,
                        action: \.destination.orderDetail
                    )
                ) { store in
                    OrderDetailView(store: store)
                }
                .navigationBarTitle(L10n.msgTxtTitle, displayMode: .automatic)
                .accessibility(identifier: A11y.orders.list.msgTxtTitle)
                .alert($store.scope(
                    state: \.destination?.alert?.alert,
                    action: \.destination.alert
                ))
                .task {
                    await store.send(.task).finish()
                }
                .toolbar {}
            }
            .accentColor(Colors.primary600)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    struct NoOrdersView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.msgTxtEmptyListTitle)
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
            OrdersView(store: OrdersDomain.Dummies.storeFor(OrdersDomain.State(communicationMessage: [])))
        }
    }
}
