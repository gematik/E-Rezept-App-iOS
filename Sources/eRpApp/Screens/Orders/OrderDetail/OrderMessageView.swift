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
    let viewState: ViewState

    init(communication: ErxTask.Communication,
         pharmacyName: String? = nil,
         style: Indicator.Style = .middle) {
        viewState = ViewState(
            communication: communication,
            pharmacyName: pharmacyName,
            style: style
        )
    }

    var body: some View {
        HStack(alignment: .center) {
            Indicator(style: viewState.style)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewState.timestamp)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.systemLabel)
                    .padding(.horizontal)

                Text(viewState.infoText)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .foregroundColor(Colors.systemLabelSecondary)

                if let buttonText = viewState.buttonText {
                    HStack(spacing: 4) {
                        Text(buttonText)
                            .font(Font.subheadline)
                        Image(systemName: SFSymbolName.chevronRight)
                            .font(Font.subheadline.weight(.semibold))
                    }
                    .padding(.top, 4)
                    .padding(.horizontal)
                    .foregroundColor(Colors.primary600)
                }

                if ![.last, .single].contains(viewState.style) {
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
        let buttonText: LocalizedStringKey?
        let style: Indicator.Style

        init(communication: ErxTask.Communication,
             pharmacyName: String?,
             style: Indicator.Style) {
            self.style = style

            if let date = OrderMessageView.uiFormattedDateTime(dateTimeString: communication.timestamp) {
                timestamp = date
            } else {
                timestamp = communication.timestamp
            }

            guard communication.profile != .dispReq else {
                infoText = L10n.ordDetailTxtSendTo(
                    L10n.ordDetailTxtPresc(1).text,
                    pharmacyName ?? L10n.ordTxtNoPharmacyName.text
                ).key
                buttonText = nil
                return
            }

            guard let payload = communication.payload else {
                infoText = L10n.ordDetailTxtError.key
                buttonText = L10n.ordDetailBtnError.key
                return
            }

            if let text = payload.infoText, !text.isEmpty {
                infoText = LocalizedStringKey(text)
            } else {
                infoText = L10n.ordDetailMsgsTxtEmpty.key
            }

            switch payload.supplyOptionsType {
            case .onPremise:
                if !payload.isPickupCodeEmptyOrNil {
                    buttonText = L10n.ordDetailBtnOnPremise.key
                } else {
                    buttonText = nil
                }
            case .delivery:
                buttonText = nil
            case .shipment:
                if let urlString = payload.url,
                   !urlString.isEmpty,
                   URL(string: urlString) != nil {
                    buttonText = L10n.ordDetailBtnShipment.key
                } else {
                    buttonText = nil
                }
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

    private static func uiFormattedDateTime(dateTimeString: String?) -> String? {
        if let dateTimeString = dateTimeString,
           let dateTime = globals.fhirDateFormatter.date(from: dateTimeString,
                                                         format: .yearMonthDayTimeMilliSeconds) {
            return uiDateFormatter.string(from: dateTime)
        }
        return dateTimeString
    }

    static var uiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

struct OrderMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            OrderMessageView(communication: ErxTask.Communication(
                identifier: "4",
                profile: .reply,
                taskId: "taskID",
                userId: "userID",
                telematikId: "telematikID",
                timestamp: "2021-05-29T10:59:37.098245933+00:00",
                payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\"}" // swiftlint:disable:this line_length
            ),
            style: .first)
            OrderMessageView(communication: ErxTask.Communication(
                identifier: "3",
                profile: .reply,
                taskId: "taskID",
                userId: "userID",
                telematikId: "telematikID",
                timestamp: "2021-05-29T10:59:37.098245933+00:00",
                payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"onPremise\" , \"info_text\":\"01 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T01__R01\" , \"pickUpCodeDMC\":\"Test_01___Rezept_01___abcdefg12345\" , \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
            ))
            OrderMessageView(communication: ErxTask.Communication(
                identifier: "2",
                profile: .reply,
                taskId: "taskID",
                userId: "userID",
                telematikId: "telematikID",
                timestamp: "2021-05-29T10:59:37.098245933+00:00",
                payloadJSON: "{\"version\":\"1\" , \"supplyOptionsType\":\"shipment\" , \"info_text\":\"10 Info/Para + HRcode/Para + DMC/Para + URL/Para\" , \"pickUpCodeHR\":\"T10__R03\" , \"pickUpCodeDMC\":\"Test_10___Rezept_03___abcdefg12345\" , \"url\":\"https://www.tree.fm/forest/33\"}" // swiftlint:disable:this line_length
            ),
            style: .last)
            OrderMessageView(communication: ErxTask.Communication(
                identifier: "1",
                profile: .dispReq,
                taskId: "taskID",
                userId: "userID",
                telematikId: "telematikID",
                timestamp: "2021-05-29T09:59:37.098245933+00:00",
                payloadJSON: ""
            ),
            pharmacyName: "Delphin Apotheke",
            style: .single)
        }
    }
}
