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
import eRpStyleKit
import Foundation
import SwiftUI

struct AppAuthenticationView: View {
    @Perception.Bindable var store: StoreOf<AppAuthenticationDomain>

    var body: some View {
        // GeometryReader is needed to expand ScrollView content to full screen
        GeometryReader { geometry in
            ScrollView {
                WithPerceptionTracking {
                    VStack {
                        HStack {
                            Image(decorative: Asset.LaunchAssets.logoGematik)
                                .padding()
                            Spacer()
                        }

                        // [REQ:BSI-eRp-ePA:O.Pass_4#2] Display of failed login attempts counter
                        if store.failedAuthenticationsCount != 0 {
                            HintView<AppAuthenticationDomain.Action>(
                                hint: Hint(
                                    id: A11y.auth.authTxtFailedLoginHint,
                                    title: L10n.authTxtFailedLoginHintTitle.text,
                                    message: L10n.authTxtFailedLoginHintMsg(store.failedAuthenticationsCount).text,
                                    image: .init(name: Asset.Illustrations.girlRedCircle.name),
                                    style: Hint.Style.important,
                                    imageStyle: Hint.ImageStyle.topAligned
                                )
                            )
                            .padding()
                        } else {
                            Spacer()
                        }

                        Text(L10n.authTxtBiometricsTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                            .padding(.bottom, 1)

                        Text(L10n.authTxtSubtitle)
                            .foregroundColor(Colors.textSecondary)
                            .padding(.bottom)

                        VStack {
                            if let store = store.scope(state: \.subdomain, action: \.subdomain) {
                                switch store.case {
                                case let .biometrics(store):
                                    AppAuthenticationWithBiometricsView(store: store)
                                case let .password(store):
                                    AppAuthenticationPasswordView(store: store)
                                case let .biometricAndPassword(store):
                                    AppAuthenticationBiometricPasswordView(store: store)
                                }
                            }
                        }

                        Spacer()

                        if store.showGroupShot {
                            Image(asset: Asset.Illustrations.groupShot)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }.task {
            await store.send(.task).finish()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct AppAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AppAuthenticationView(
            store: AppAuthenticationDomain.Dummies.storeFor(
                AppAuthenticationDomain.State(
                    subdomain: .biometrics(
                        .init(
                            biometryType: .faceID,
                            startImmediateAuthenticationChallenge: false,
                            authenticationResult: .success(true)
                        )
                    ),
                    failedAuthenticationsCount: 3
                )
            )
        )

        AppAuthenticationView(
            store: AppAuthenticationDomain.Dummies.storeFor(
                AppAuthenticationDomain.State(
                    subdomain: .password(.init())
                )
            )
        )
    }
}
