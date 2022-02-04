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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct MessageRowView: View {
    let viewState: ViewState

    init(communication: ErxTask.Communication) {
        viewState = ViewState(communication: communication)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !viewState.isRead {
                    Image(systemName: SFSymbolName.circleFill)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Colors.primary500)
                }
                Text(viewState.title)
                    .font(Font.body.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.systemLabel)

            }.padding(.horizontal)

            Text(viewState.infoText)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .foregroundColor(Colors.systemLabel)

            if let buttonText = viewState.buttonText,
               let imageName = viewState.imageName {
                HStack {
                    Text(buttonText)
                        .font(Font.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: imageName)
                }
                .padding(.top, 4)
                .padding(.horizontal)
                .foregroundColor(Colors.primary600)
            }

            Divider()
                .padding(.top, 8)
                .padding(.leading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    struct ViewState: Equatable {
        let isRead: Bool
        let title: LocalizedStringKey
        let infoText: LocalizedStringKey
        let buttonText: LocalizedStringKey?
        let imageName: String?

        init(communication: ErxTask.Communication) {
            isRead = communication.isRead
            guard let payload = communication.payload else {
                title = L10n.msgsTxtFormatErrorTitle.key
                infoText = L10n.msgsTxtFormatErrorMessage.key
                buttonText = L10n.msgsBtnFormatError.key
                imageName = SFSymbolName.arrowRight
                return
            }

            if let text = payload.infoText, !text.isEmpty {
                infoText = LocalizedStringKey(text)
            } else {
                infoText = L10n.msgsTxtEmptyMessage.key
            }

            switch payload.supplyOptionsType {
            case .onPremise:
                title = L10n.msgsTxtOnPremiseTitle.key
                if payload.pickUpCodeHR != nil || payload.pickUpCodeDMC != nil {
                    buttonText = L10n.msgsBtnOnPremise.key
                    imageName = SFSymbolName.qrCode
                } else {
                    buttonText = nil
                    imageName = nil
                }
            case .delivery:
                title = L10n.msgsTxtDeliveryTitle.key
                buttonText = nil
                imageName = nil
            case .shipment:
                title = L10n.msgsTxtShipmentTitle.key
                if let urlString = payload.url,
                   !urlString.isEmpty,
                   URL(string: urlString) != nil {
                    buttonText = L10n.msgsBtnShipment.key
                    imageName = SFSymbolName.arrowUpForward
                } else {
                    buttonText = nil
                    imageName = nil
                }
            }
        }
    }
}
