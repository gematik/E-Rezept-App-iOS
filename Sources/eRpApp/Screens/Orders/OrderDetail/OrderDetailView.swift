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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct OrderDetailView: View {
    let store: OrderDetailDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, OrderDetailDomain.Action>

    init(store: OrderDetailDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                TitleView(
                    title: L10n.ordDetailTxtHistory.key,
                    a11y: ""
                )

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewStore.timelineEntries) { entry in
                        OrderMessageView(store: store, timelineEntry: entry, style: style(for: entry))
                    }
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: A11y.orderDetail.list.ordDetailTxtMsgList)
                }
                .padding(.top, 12)
                .padding(.bottom, 56)

                TitleView(
                    title: L10n.ordDetailTxtOrders.key,
                    a11y: ""
                )
                .padding(.top, 24)
                .topBorder(strokeWith: 0.5, color: Colors.separator)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewStore.erxTasks) { task in
                        Button {
                            viewStore.send(.didSelectMedication(task))
                        } label: {
                            OrderMedicationView(medication: task.medication)
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibility(identifier: A11y.orderDetail.list.ordDetailTxtMedList)
                }
                .padding(.top, 8)
            }

            // prescription details

            NavigationLinkStore(
                store.scope(state: \.$destination, action: OrderDetailDomain.Action.destination),
                state: /OrderDetailDomain.Destinations.State.prescriptionDetail,
                action: OrderDetailDomain.Destinations.Action.prescriptionDetail(action:),
                onTap: { viewStore.send(.setNavigation(tag: .prescriptionDetail)) },
                destination: PrescriptionDetailView.init(store:),
                label: { EmptyView() }
            ).accessibility(hidden: true)

            // charge item detail

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .smallSheet(isPresented: Binding<Bool>(get: {
                    viewStore.destinationTag == .chargeItem
                }, set: { show in
                    if !show {
                        viewStore.send(.setNavigation(tag: nil), animation: .easeInOut)
                    }
                }),
                onDismiss: {},
                content: {
                    IfLetStore(
                        store.scope(state: \.$destination, action: OrderDetailDomain.Action.destination),
                        state: /OrderDetailDomain.Destinations.State.chargeItem,
                        action: OrderDetailDomain.Destinations.Action.chargeItem(action:),
                        then: ChargeItemView.init(store:)
                    )
                })
                .accessibility(hidden: true)

            // pickup code

            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .sheet(isPresented: Binding<Bool>(
                    get: { viewStore.destinationTag == .pickupCode },
                    set: { show in
                        if !show { viewStore.send(.setNavigation(tag: .none)) }
                    }
                )) {
                    IfLetStore(
                        store.scope(state: \.$destination, action: OrderDetailDomain.Action.destination),
                        state: /OrderDetailDomain.Destinations.State.pickupCode,
                        action: OrderDetailDomain.Destinations.Action.pickupCode(action:),
                        then: PickupCodeView.init(store:)
                    )
                }
                .hidden()
                .accessibility(hidden: true)

            // open url
            Rectangle()
                .frame(width: 0, height: 0, alignment: .center)
                .sheet(isPresented: Binding<Bool>(get: {
                    viewStore.openUrlSheetVisible
                }, set: { show in
                    if !show {
                        viewStore.send(.showOpenUrlSheet(url: nil))
                    }
                }),
                onDismiss: {},
                content: {
                    OpenUrlView(store: store)
                })
                .hidden()
                .accessibility(hidden: true)
        }
        .navigationBarTitle(L10n.ordDetailTxtTitle, displayMode: .inline)
        .accessibility(identifier: A11y.orderDetail.list.ordDetailTitle)
        .alert(
            store.scope(state: \.$destination, action: OrderDetailDomain.Action.destination),
            state: /OrderDetailDomain.Destinations.State.alert,
            action: OrderDetailDomain.Destinations.Action.alert
        )
        .task {
            await viewStore.send(.task).finish()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        viewStore.send(.openMapApp)
                    }, label: {
                        Text(L10n.ordDetailTxtContactMap)
                    })
                        .disabled(!viewStore.hasLocation)
                        .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactMap)

                    Button(action: {
                        viewStore.send(.openPhoneApp)
                    }, label: {
                        Text(L10n.ordDetailTxtContactPhone)
                    })
                        .disabled(!viewStore.hasPhoneContact)
                        .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactPhone)

                    Button(action: {
                        viewStore.send(.openMailApp)
                    }, label: {
                        Text(L10n.ordDetailTxtContactEmail)
                    })
                        .disabled(!viewStore.hasEmailContact)
                        .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactEmail)
                } label: {
                    Label(L10n.ordDetailTxtContact, systemImage: SFSymbolName.ellipsis)
                        .foregroundColor(Colors.primary700)
                        .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContact)
                        .accessibility(label: Text(L10n.ordDetailTxtContact))
                }
            }
        }
    }

    private func style(for entry: OrderDetailDomain.State.TimelineEntry) -> OrderMessageView.Indicator.Style {
        switch entry {
        case viewStore.timelineEntries.first:
            if viewStore.timelineEntries.count == 1 {
                return .single
            }
            return .first
        case viewStore.timelineEntries.last:
            return .last
        default:
            return .middle
        }
    }

    struct TitleView: View {
        let title: LocalizedStringKey
        let a11y: String

        var body: some View {
            HStack {
                Text(title, bundle: .module)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .accessibility(identifier: a11y)
                Spacer()
            }
            .padding([.top, .horizontal])
        }
    }

    struct OpenUrlView: View {
        let store: OrderDetailDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, OrderDetailDomain.Action>

        init(store: OrderDetailDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let url: URL?

            init(state: OrderDetailDomain.State) {
                url = state.openUrlSheetUrl
            }
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    Text(L10n.ordDetailSheetTitleShipment)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.subheadline.weight(.semibold))
                        .accessibility(identifier: "")
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    Text(L10n.ordDetailShipmentLinkText)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .font(Font.subheadline)
                        .multilineTextAlignment(.center)
                        .accessibility(identifier: "")
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)

                    PrimaryTextButton(text: L10n.ordDetailShipmentLinkBtn, a11y: "") {
                        viewStore.send(.openUrl(url: viewStore.url))
                    }
                    .padding(.horizontal, 32)
                }
                .navigationBarItems(trailing: CloseButton { viewStore.send(.showOpenUrlSheet(url: nil)) })
            }
            .accentColor(Colors.primary600)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

extension OrderDetailView {
    struct ViewState: Equatable {
        let hasLocation: Bool
        let hasPhoneContact: Bool
        let hasEmailContact: Bool
        let timelineEntries: [OrderDetailDomain.State.TimelineEntry]
        let erxTasks: IdentifiedArrayOf<ErxTask>

        let destinationTag: OrderDetailDomain.Destinations.State.Tag?

        var openUrlSheetVisible: Bool

        init(state: OrderDetailDomain.State) {
            hasLocation = state.order.pharmacy?.position != nil
            hasPhoneContact = state.order.pharmacy?.telecom?.phone != nil
            hasEmailContact = state.order.pharmacy?.telecom?.email != nil
            timelineEntries = state.timelineEntries
            erxTasks = state.erxTasks
            destinationTag = state.destination?.tag
            openUrlSheetVisible = state.openUrlSheetUrl != nil
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderDetailView(store: OrderDetailDomain.Dummies.store)
        }
    }
}
