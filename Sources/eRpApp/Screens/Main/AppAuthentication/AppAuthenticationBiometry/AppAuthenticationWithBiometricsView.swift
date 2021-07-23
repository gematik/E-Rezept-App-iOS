//
//  Copyright (c) 2021 gematik GmbH
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

struct AppAuthenticationWithBiometricsView: View {
    let store: AppAuthenticationBiometricsDomain.Store

    @State private var calculatedHeight: CGFloat = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Image(Asset.authHead)
                        .padding(.vertical)
                    Spacer()
                }

                VStack {
                    Spacer()

                    VStack {
                        Text(L10n.authTxtBiometricsTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        switch viewStore.biometryType {
                        case .faceID:
                            Text(L10n.authTxtBiometricsFaceidStart)
                                .font(.headline)
                                .padding()
                            Text(L10n.authTxtBiometricsFaceidDescription)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                            PrimaryTextButton(text: L10n.authBtnBiometricsFaceid,
                                              a11y: A18n.auth.authBtnBiometricsFaceid,
                                              image: Image(systemName: SFSymbolName.faceId)) {
                                viewStore.send(.startAuthenticationChallenge)
                            }
                            .frame(width: 216,
                                   height: 52,
                                   alignment: .center)
                            .padding()
                        case .touchID:
                            Text(L10n.authTxtBiometricsTouchidStart)
                                .font(.headline)
                                .padding()
                            Text(L10n.authTxtBiometricsTouchidDescription)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                            PrimaryTextButton(text: L10n.authBtnBiometricsTouchid,
                                              a11y: A18n.auth.authBtnBiometricsTouchid,
                                              image: Image(systemName: SFSymbolName.touchId)) {
                                viewStore.send(.startAuthenticationChallenge)
                            }
                            .frame(width: 216,
                                   height: 52,
                                   alignment: .center)
                            .padding()
                        }
                    }
                    .padding()

                    Spacer()

                    LinksAwareTextView(
                        text: NSLocalizedString("auth_txt_biometrics_footer",
                                                comment: ""),
                        links: [
                            NSLocalizedString("auth_txt_biometrics_footer_url_display",
                                              comment: ""):
                                NSLocalizedString("auth_txt_biometrics_footer_url_link",
                                                  comment: ""),
                            NSLocalizedString("auth_txt_biometrics_footer_email_display",
                                              comment: ""):
                                NSLocalizedString("auth_txt_biometrics_footer_email_link",
                                                  comment: ""),
                        ],
                        calculatedHeight: $calculatedHeight
                    )
                    .frame(maxHeight: calculatedHeight)
                }
                .padding()
            }
            .alert(isPresented: viewStore.binding(
                get: { $0.errorToDisplay != nil },
                send: AppAuthenticationBiometricsDomain.Action.dismissError
            )) {
                Alert(
                    title: Text(L10n.alertErrorTitle),
                    message: Text(viewStore.errorToDisplay?.errorDescription ?? ""),
                    dismissButton: .default(Text(L10n.alertBtnOk))
                )
            }
        }
    }
}

struct AppAuthenticationWithBiometricsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppAuthenticationWithBiometricsView(
                store: AppAuthenticationBiometricsDomain.Store(
                    initialState: AppAuthenticationBiometricsDomain.State(biometryType: .faceID),
                    reducer: AppAuthenticationBiometricsDomain.reducer,
                    environment: AppAuthenticationBiometricsDomain.Environment(
                        schedulers: AppContainer.shared.schedulers,
                        authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
                    )
                )
            )
        }.generateVariations()
    }
}
