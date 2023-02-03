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
import SwiftUI

struct RedeemMatrixCodeView: View {
    let store: RedeemMatrixCodeDomain.Store
    @State var originalBrightness: CGFloat?

    init(store: RedeemMatrixCodeDomain.Store) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(L10n.rphTxtTitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.title.bold())
                    .accessibility(identifier: A18n.redeem.matrixCode.rphTxtTitle)
                Text(L10n.rphTxtSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabel)
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibility(identifier: A18n.redeem.matrixCode.rphTxtSubtitle)
                switch viewStore.state.loadingState {
                case .loading:
                    ProgressView()
                        .accessibility(identifier: A18n.redeem.matrixCode.rphImgMatrixcodeLoadingIndicator)
                case let .value(value):
                    Image(uiImage: value)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(Colors.systemColorWhite) // No darkmode to get contrast
                        .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                        .accessibility(identifier: A18n.redeem.matrixCode.rphImgMatrixcode)
                default:
                    EmptyView()
                }

                Spacer()
            }
            .navigationBarItems(
                trailing: CloseButton {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A18n.redeem.matrixCode.rphBtnCloseButton)
            )
            .alert(isPresented: .constant(viewStore.state.isShowAlert)) {
                Alert(
                    title: Text(L10n.rphTxtCloseAlertTitle),
                    message: Text(L10n.rphTxtCloseAlertMessage),
                    primaryButton: Alert.Button.cancel(Text(L10n.rphBtnCloseAlertKeep)) {
                        viewStore.send(.close)
                    },
                    secondaryButton: Alert.Button.destructive(Text(L10n.rphBtnCloseAlertMarkRedeemed)) {
                        viewStore.send(.close)
                    }
                )
            }
            .onAppear {
                originalBrightness = UIScreen.main.brightness
                viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
            }
            .onDisappear {
                if let originalBrightness = originalBrightness {
                    UIScreen.main.brightness = originalBrightness
                }
            }
        }
    }
}

struct RedeemMatrixCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RedeemMatrixCodeView(
                store: RedeemMatrixCodeDomain.Dummies.store
            )
            RedeemMatrixCodeView(
                store: RedeemMatrixCodeDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
        }
    }
}
