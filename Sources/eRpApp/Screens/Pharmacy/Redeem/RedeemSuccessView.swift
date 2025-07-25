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
import Perception
import SwiftUI

struct RedeemSuccessView: View {
    let store: StoreOf<RedeemSuccessDomain>

    init(store: StoreOf<RedeemSuccessDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 16) {
                    if let url = videoURLforSource(store.redeemOption) {
                        LoopingVideoPlayerContainerView(withURL: url)
                            .frame(
                                minWidth: 160,
                                idealWidth: 240,
                                maxWidth: 300,
                                minHeight: 160,
                                idealHeight: 240,
                                maxHeight: 300
                            )
                            .clipShape(Circle())
                            .padding(.vertical, 8)
                    }

                    Text(titlelForSource(store.redeemOption), bundle: .module)
                        .font(Font.title3.bold())

                    ContentView(option: store.state.redeemOption)

                    Spacer()

                    LoadingPrimaryButton(text: L10n.rdmSccBtnReturnToMain,
                                         isLoading: false) {
                        store.send(.closeButtonTapped)
                    }
                    .accessibility(identifier: A11y.pharmacyRedeem.phaRedeemBtnRedeem)
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(L10n.phaSuccessRedeemTitle)
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }
    }

    private func videoURLforSource(_ option: RedeemOption) -> URL? {
        var videoName = ""

        switch option {
        case .onPremise:
            videoName = "animation_reservierung"
        case .delivery:
            videoName = "animation_botendienst"
        case .shipment:
            videoName = "animation_versand"
        }

        guard let bundle = Bundle.module.path(forResource: videoName,
                                              ofType: "mp4") else {
            return nil
        }

        return URL(fileURLWithPath: bundle)
    }

    private func titlelForSource(_ option: RedeemOption) -> LocalizedStringKey {
        switch option {
        case .onPremise:
            return L10n.rdmSccTxtOnpremiseTitle.key
        case .delivery:
            return L10n.rdmSccTxtDeliveryTitle.key
        case .shipment:
            return L10n.rdmSccTxtShipmentTitle.key
        }
    }

    private struct ContentView: View {
        let option: RedeemOption
        var body: some View {
            switch option {
            case .delivery:
                Text(L10n.rdmSccTxtDeliveryContent)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            case .onPremise:
                Text(L10n.rdmSccTxtOnpremiseContent)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            case .shipment:
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: SFSymbolName.numbers1circleFill)
                            .foregroundColor(Colors.primary700)
                            .font(Font.title3.bold())
                        Text(L10n.rdmSccTxtShipmentContent1)
                    }
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: SFSymbolName.numbers2circleFill)
                            .foregroundColor(Colors.primary700)
                            .font(Font.title3.bold())

                        Text(L10n.rdmSccTxtShipmentContent2)
                    }
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: SFSymbolName.numbers3circleFill)
                            .foregroundColor(Colors.primary700)
                            .font(Font.title3.bold())
                        Text(L10n.rdmSccTxtShipmentContent3)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct RedeemSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .shipment))
            }

            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .shipment))
                    .preferredColorScheme(.dark)
            }
            .environment(\.sizeCategory, .extraExtraExtraLarge)

            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .delivery))
            }
            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .delivery))
                    .preferredColorScheme(.dark)
            }

            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .onPremise))
            }
            NavigationStack {
                RedeemSuccessView(store: RedeemSuccessDomain.Dummies.store(with: .onPremise))
                    .preferredColorScheme(.dark)
            }
        }
    }
}
