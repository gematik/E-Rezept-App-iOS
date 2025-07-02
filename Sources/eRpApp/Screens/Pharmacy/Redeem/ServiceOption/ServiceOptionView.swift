//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct ServiceOptionView: View {
    @Perception.Bindable var store: StoreOf<ServiceOptionDomain>

    var body: some View {
        WithPerceptionTracking {
            HStack(alignment: .top, spacing: 16) {
                if store.availableOptions.contains(.onPremise) {
                    Button(
                        action: { store.send(.redeemOptionTapped(.onPremise)) },
                        label: {
                            Label {
                                Text(L10n.phaDetailBtnPickup)
                            } icon: {
                                Image(asset: Asset.Pharmacy.btnApoLarge)
                                    .resizable()
                                    .padding(4)
                            }
                        }
                    ).buttonStyle(.picture(
                        style: .supplyLarge,
                        isActive: store.selectedOption == .onPremise
                    ))
                        .opacity(store.prescriptions.isEmpty ? 0.25 : 1)
                        .accessibility(identifier: store.redeemOptionProvider?.reservationService
                            .hasServiceAfterLogin == true
                            ? A11y.pharmacyDetail.phaDetailBtnPickupViaLogin
                            : A11y.pharmacyDetail.phaDetailBtnPickup)
                }

                if store.availableOptions.contains(.delivery) {
                    Button(
                        action: { store.send(.redeemOptionTapped(.delivery)) },
                        label: {
                            Label {
                                Text(L10n.phaDetailBtnDelivery)
                            } icon: {
                                Image(asset: Asset.Pharmacy.btnCarLarge)
                                    .resizable()
                                    .padding(4)
                            }
                        }
                    ).buttonStyle(.picture(
                        style: .supplyLarge,
                        isActive: store.selectedOption == .delivery
                    ))
                        .opacity(store.prescriptions.isEmpty ? 0.25 : 1)
                        .accessibility(identifier: store.redeemOptionProvider?.deliveryService
                            .hasServiceAfterLogin == true
                            ? A11y.pharmacyDetail.phaDetailBtnDeliveryViaLogin
                            : A11y.pharmacyDetail.phaDetailBtnDelivery)
                }

                if store.availableOptions.contains(.shipment) {
                    Button(
                        action: { store.send(.redeemOptionTapped(.shipment)) },
                        label: {
                            Label {
                                Text(L10n.phaDetailBtnShipment)
                            } icon: {
                                Image(asset: Asset.Pharmacy.btnLkwLarge)
                                    .resizable()
                                    .padding(4)
                            }
                        }
                    ).buttonStyle(.picture(
                        style: .supplyLarge,
                        isActive: store.selectedOption == .shipment
                    ))
                        .opacity(store.prescriptions.isEmpty ? 0.25 : 1)
                        .accessibility(identifier: store.redeemOptionProvider?.shipmentService
                            .hasServiceAfterLogin == true
                            ? A11y.pharmacyDetail.phaDetailBtnShipmentViaLogin
                            : A11y.pharmacyDetail.phaDetailBtnShipment)
                }

                ForEach(store.availableOptions.count ..< 3, id: \.self) { _ in
                    EmptyServiceView()
                }
            }.frame(maxWidth: .infinity, alignment: .center)
        }
    }

    struct EmptyServiceView: View {
        var body: some View {
            Button(
                action: {},
                label: {
                    Label {
                        Text("")
                    } icon: {
                        Image(systemName: "")
                            .resizable()
                            .padding(4)
                    }
                }
            ).buttonStyle(PictureButtonStyle(style: .supplyLarge, active: false, width: .narrow))
                .hidden()
        }
    }
}
