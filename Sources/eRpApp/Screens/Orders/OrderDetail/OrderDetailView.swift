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
import Perception
import SwiftUI

struct OrderDetailView: View {
    @Perception.Bindable var store: StoreOf<OrderDetailDomain>

    init(store: StoreOf<OrderDetailDomain>) {
        self.store = store
    }

    var openUrlSheet: Binding<Bool> { Binding(
        get: { store.openUrlSheetUrl != nil },
        set: { _ in store.send(.showOpenUrlSheet(url: nil)) }
    ) }

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical) {
                    TitleView(
                        title: L10n.ordDetailTxtMessages.key,
                        a11y: ""
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(store.order.timelineEntries) { entry in
                            WithPerceptionTracking {
                                OrderMessageView(store: store, timelineEntry: entry, style: style(for: entry))
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibility(identifier: A11y.orderDetail.list.ordDetailTxtMsgList)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 56)

                    TitleView(
                        title: L10n.ordDetailTxtOrders.key,
                        a11y: ""
                    )
                    .padding(.top, 24)
                    .topBorder(strokeWith: 0.5, color: Colors.separator)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.erxTasks) { task in
                            Button {
                                store.send(.didSelectMedication(task))
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

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .navigationDestination(
                        item: $store.scope(
                            state: \.destination?.prescriptionDetail,
                            action: \.destination.prescriptionDetail
                        )
                    ) { store in
                        PrescriptionDetailView(store: store)
                    }
                    .accessibility(hidden: true)

                // charge item detail

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .smallSheet($store.scope(
                        state: \.destination?.chargeItem,
                        action: \.destination.chargeItem
                    )) { store in
                        ChargeItemView(store: store)
                    }
                    .accessibility(hidden: true)

                // pickup code

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(item: $store.scope(
                        state: \.destination?.pickupCode,
                        action: \.destination.pickupCode
                    )) { store in
                        PickupCodeView(store: store)
                    }
                    .hidden()
                    .accessibility(hidden: true)

                // pharmacy

                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(item: $store.scope(state: \.destination?.pharmacyDetail,
                                              action: \.destination.pharmacyDetail)) { store in
                        if #available(iOS 16, *) {
                            PharmacyDetailView(store: store)
                                .presentationDetents([.fraction(0.53), .large])
                        } else {
                            PharmacyDetailView(store: store)
                        }
                    }
                    .hidden()
                    .accessibility(hidden: true)

                // open url
                Rectangle()
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(isPresented: openUrlSheet) {
                        OpenUrlView(store: store)
                    }
                    .hidden()
                    .accessibility(hidden: true)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(store.order.pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text, displayMode: .inline)
            .accessibility(identifier: A11y.orderDetail.list.ordDetailTitle)
            .alert($store.scope(
                state: \.destination?.alert?.alert,
                action: \.destination.alert
            ))
            .task {
                await store.send(.task).finish()
            }
            .toolbar {
                let hasLocation = store.order.pharmacy?.position != nil
                let hasPhoneContact = store.order.pharmacy?.telecom?.phone != nil
                let hasEmailContact = store.order.pharmacy?.telecom?.email != nil

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            store.send(.openMapApp)
                        }, label: {
                            Text(L10n.ordDetailTxtContactMap)
                        })
                            .disabled(!hasLocation)
                            .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactMap)

                        Button(action: {
                            store.send(.openPhoneApp)
                        }, label: {
                            Text(L10n.ordDetailTxtContactPhone)
                        })
                            .disabled(!hasPhoneContact)
                            .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactPhone)

                        Button(action: {
                            store.send(.openMailApp)
                        }, label: {
                            Text(L10n.ordDetailTxtContactEmail)
                        })
                            .disabled(!hasEmailContact)
                            .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContactEmail)
                    } label: {
                        Label(L10n.ordDetailTxtContact, systemImage: SFSymbolName.ellipsis)
                            .foregroundColor(Colors.primary700)
                            .accessibility(identifier: A11y.orderDetail.list.ordDetailBtnContact)
                            .accessibility(label: Text(L10n.ordDetailTxtContact))
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        store.send(.delegate(.close))
                    }, label: {
                        HStack(spacing: 5) {
                            Image(systemName: SFSymbolName.back)
                                .font(Font.headline.weight(.semibold))
                                .foregroundColor(Colors.primary600)

                            Text(L10n.cdwBtnRcHelpBack)
                                .font(.body)
                                .foregroundColor(Colors.primary600)
                        }
                    })
                }
            }
        }
    }

    private func style(for entry: Order.TimelineEntry) -> OrderMessageView.Indicator.Style {
        switch entry {
        case store.order.timelineEntries.first:
            if store.order.timelineEntries.count == 1 {
                return .single
            }
            return .first
        case store.order.timelineEntries.last:
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
        @Perception.Bindable var store: StoreOf<OrderDetailDomain>

        var body: some View {
            WithPerceptionTracking {
                NavigationStack {
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
                            store.send(.openUrl(url: store.openUrlSheetUrl))
                        }
                        .padding(.horizontal, 32)
                    }
                    .navigationBarItems(trailing: CloseButton { store.send(.showOpenUrlSheet(url: nil)) })
                }
                .accentColor(Colors.primary600)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderDetailView(store: OrderDetailDomain.Dummies.store)
        }
    }
}
