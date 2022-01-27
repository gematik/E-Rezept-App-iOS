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
    let store: MessageDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, MessageDomain.Action>

    init(store: MessageDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        Group {
            Button(action: { viewStore.send(.didSelect) }, label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if !viewStore.isRead {
                            Image(systemName: SFSymbolName.circleFill)
                                .font(Font.subheadline.weight(.semibold))
                                .foregroundColor(Colors.primary500)
                        }
                        Text(viewStore.title)
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Colors.systemLabel)

                    }.padding(.horizontal)

                    Text(viewStore.infoText)
                        .padding(.horizontal)
                        .foregroundColor(Colors.systemLabel)

                    if let buttonText = viewStore.buttonText,
                       let imageName = viewStore.imageName {
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
            })

            EmptyView()
                .sheet(isPresented: viewStore.binding(
                    get: { $0.isPickupCodeViewPresented },
                    send: MessageDomain.Action.dismissPickupCodeView
                )) {
                    IfLetStore(
                        store.scope(
                            state: { $0.pickupCodeViewState },
                            action: MessageDomain.Action.pickupCode(action:)
                        ),
                        then: PickupCodeView.init(store:)
                    )
                }
        }
        .alert(
            self.store.scope(state: \.alertState),
            dismiss: .alertDismissButtonTapped
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    struct ViewState: Equatable {
        let isPickupCodeViewPresented: Bool
        let isRead: Bool
        let title: LocalizedStringKey
        let infoText: LocalizedStringKey
        let buttonText: LocalizedStringKey?
        let imageName: String?

        init(state: MessageDomain.State) {
            isRead = state.communication.isRead
            isPickupCodeViewPresented = state.pickupCodeViewState != nil
            guard let payload = state.communication.payload else {
                title = L10n.msgsTxtFormatErrorTitle
                infoText = L10n.msgsTxtFormatErrorMessage
                buttonText = L10n.msgsBtnFormatError
                imageName = SFSymbolName.arrowRight
                return
            }

            if let text = payload.infoText, !text.isEmpty {
                infoText = LocalizedStringKey(text)
            } else {
                infoText = L10n.msgsTxtEmptyMessage
            }

            switch payload.supplyOptionsType {
            case .onPremise:
                title = L10n.msgsTxtOnPremiseTitle
                if payload.pickUpCodeHR != nil || payload.pickUpCodeDMC != nil {
                    buttonText = L10n.msgsBtnOnPremise
                    imageName = SFSymbolName.qrCode
                } else {
                    buttonText = nil
                    imageName = nil
                }
            case .delivery:
                title = L10n.msgsTxtDeliveryTitle
                buttonText = nil
                imageName = nil
            case .shipment:
                title = L10n.msgsTxtShipmentTitle
                if let urlString = payload.url,
                   !urlString.isEmpty,
                   URL(string: urlString) != nil {
                    buttonText = L10n.msgsBtnShipment
                    imageName = SFSymbolName.arrowUpForward
                } else {
                    buttonText = nil
                    imageName = nil
                }
            }
        }
    }
}
