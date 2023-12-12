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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct OrderMessageView: View {
    @ObservedObject var viewStore: ViewStore<ViewState, OrderDetailDomain.Action>

    init(store: OrderDetailDomain.Store,
         communication: ErxTask.Communication,
         style: Indicator.Style = .middle) {
        // swiftlint:disable:next trailing_closure
        viewStore = ViewStore(store, observe: { ViewState(state: $0, communication: communication, style: style) })
    }

    var body: some View {
        HStack(alignment: .center) {
            Indicator(style: viewStore.style)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewStore.timestamp)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.systemLabel)
                    .padding(.horizontal)

                Text(viewStore.infoText)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .foregroundColor(Colors.systemLabelSecondary)

                if let pickupButtonText = viewStore.pickupButtonText {
                    Button {
                        viewStore.send(.showPickupCode(dmcCode: viewStore.dmcCode, hrCode: viewStore.hrCode))
                    } label: {
                        HStack(spacing: 4) {
                            Text(pickupButtonText)
                                .font(Font.subheadline)
                            Image(systemName: SFSymbolName.chevronRight)
                                .font(Font.subheadline.weight(.semibold))
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundColor(Colors.primary600)
                    }
                }

                if let linkButtonText = viewStore.linkButtonText {
                    Button {
                        viewStore.send(.openUrl(url: viewStore.link))
                    } label: {
                        HStack(spacing: 4) {
                            Text(linkButtonText)
                                .font(Font.subheadline)
                            Image(systemName: SFSymbolName.chevronRight)
                                .font(Font.subheadline.weight(.semibold))
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundColor(Colors.primary600)
                    }
                }

                if let malformedPayload = viewStore.malformedPayload {
                    Button {
                        viewStore.send(.openMail(message: malformedPayload))
                    } label: {
                        HStack(spacing: 4) {
                            Text(L10n.ordDetailBtnError)
                                .font(Font.subheadline)
                            Image(systemName: SFSymbolName.chevronRight)
                                .font(Font.subheadline.weight(.semibold))
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundColor(Colors.alertNegativ)
                    }
                }

                if ![.last, .single].contains(viewStore.style) {
                    Divider()
                        .padding(.top, 8)
                        .padding(.leading)
                        .padding(.bottom)
                } else {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 0)
                        .padding(.top, 8)
                        .padding(.leading)
                        .padding(.bottom)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.leading)
    }

    struct ViewState: Equatable {
        let timestamp: String
        let infoText: LocalizedStringKey
        let linkButtonText: LocalizedStringKey?
        let pickupButtonText: LocalizedStringKey?
        let style: Indicator.Style
        let link: URL?
        let dmcCode: String?
        let hrCode: String?
        var malformedPayload: String?

        init(
            state: OrderDetailDomain.State,
            communication: ErxTask.Communication,
            style: Indicator.Style,
            uiDateFormatter: UIDateFormatter = UIDateFormatter.liveValue
        ) {
            self.style = style
            timestamp = uiDateFormatter.relativeDateAndTime(communication.timestamp) ?? communication.timestamp

            guard communication.profile != .dispReq else {
                infoText = L10n.ordDetailTxtSendTo(
                    L10n.ordDetailTxtPresc(1).text,
                    state.order.pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text
                ).key
                linkButtonText = nil
                pickupButtonText = nil
                link = nil
                hrCode = nil
                dmcCode = nil
                return
            }

            guard let payload = communication.payload else {
                infoText = L10n.ordDetailTxtError.key
                linkButtonText = nil
                pickupButtonText = nil
                link = nil
                hrCode = nil
                dmcCode = nil
                malformedPayload = communication.payloadJSON
                return
            }

            if let text = payload.infoText, !text.isEmpty {
                infoText = LocalizedStringKey(text)
            } else {
                infoText = L10n.ordDetailMsgsTxtEmpty.key
            }

            if !payload.isPickupCodeEmptyOrNil {
                pickupButtonText = L10n.ordDetailBtnOnPremise.key
                hrCode = payload.pickUpCodeHR
                dmcCode = payload.pickUpCodeDMC
            } else {
                pickupButtonText = nil
                hrCode = nil
                dmcCode = nil
            }

            if let urlString = payload.url, !urlString.isEmpty, let url = URL(string: urlString) {
                link = url
                linkButtonText = L10n.ordDetailBtnLink.key
            } else {
                link = nil
                linkButtonText = nil
            }
        }
    }

    struct Indicator: View {
        let offsetY = -15.0
        let style: Indicator.Style

        var body: some View {
            ZStack {
                switch style {
                case .single:
                    VLine(style: .topHalf)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [4]))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY / 2)
                case .first:
                    VLine(style: .bottomHalf)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                case .middle:
                    VLine(style: .full)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                case .last:
                    VLine(style: .topHalf)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Colors.systemGray5)
                        .frame(width: 1)
                        .offset(x: 0.5, y: offsetY)
                }

                Circle()
                    .strokeBorder(Colors.systemGray5, lineWidth: 5)
                    .background(Colors.systemBackground)
                    .frame(width: 16, height: 16)
                    .offset(x: 0, y: offsetY)
            }
        }

        enum Style {
            case single
            case first
            case middle
            case last
        }

        struct VLine: Shape {
            let style: VLine.Style

            func path(in rect: CGRect) -> Path {
                var path = Path()
                var startY = rect.minY
                var endY = rect.maxY
                switch style {
                case .full:
                    break
                case .topHalf:
                    endY = rect.midY
                case .bottomHalf:
                    startY = rect.midY
                }
                path.move(to: CGPoint(x: rect.minX, y: startY))
                path.addLine(to: CGPoint(x: rect.minX, y: endY))
                return path
            }

            enum Style {
                case full
                case topHalf
                case bottomHalf
            }
        }
    }
}

struct OrderMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                communication: ErxTask.Communication(
                    identifier: "4",
                    profile: .reply,
                    taskId: "taskID",
                    userId: "userID",
                    telematikId: "telematikID",
                    timestamp: "2021-05-29T10:59:37.098245933+00:00",
                    payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\", \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
                ),
                style: .first
            )
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                communication: ErxTask.Communication(
                    identifier: "3",
                    profile: .reply,
                    taskId: "taskID",
                    userId: "userID",
                    telematikId: "telematikID",
                    timestamp: "2021-05-29T10:59:37.098245933+00:00",
                    payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"onPremise\" , \"info_text\":\"01 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T01__R01\" , \"pickUpCodeDMC\":\"Test_01___Rezept_01___abcdefg12345\" }" // swiftlint:disable:this line_length
                )
            )
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                communication: ErxTask.Communication(
                    identifier: "2",
                    profile: .reply,
                    taskId: "taskID",
                    userId: "userID",
                    telematikId: "telematikID",
                    timestamp: "2021-05-29T10:59:37.098245933+00:00",
                    payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"shipment\" , \"info_text\":\"10 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T10__R03\" , \"pickUpCodeDMC\":\"Test_10___Rezept_03___abcdefg12345\" , \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
                )
            )
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                communication: ErxTask.Communication(
                    identifier: "2",
                    profile: .reply,
                    taskId: "taskID",
                    userId: "userID",
                    telematikId: "telematikID",
                    timestamp: "2021-05-29T10:59:37.098245933+00:00",
                    payloadJSON: "not a json"
                )
            )
            OrderMessageView(
                store: OrderDetailDomain.Dummies.store,
                communication: ErxTask.Communication(
                    identifier: "1",
                    profile: .dispReq,
                    taskId: "taskID",
                    userId: "userID",
                    telematikId: "telematikID",
                    timestamp: "2021-05-29T09:59:37.098245933+00:00",
                    payloadJSON: ""
                ),
                style: .single
            )
        }
    }
}
