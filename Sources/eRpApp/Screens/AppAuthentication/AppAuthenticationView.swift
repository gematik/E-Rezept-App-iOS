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
import Foundation
import SwiftUI

struct AppAuthenticationView: View {
    let store: AppAuthenticationDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, AppAuthenticationDomain.Action>

    init(store: AppAuthenticationDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let showFailedAuthenticationsHint: Bool
        let failedAuthentications: Int
        let hintTitle: String
        let hintMessage: String

        init(state: AppAuthenticationDomain.State) {
            showFailedAuthenticationsHint = state.failedAuthenticationsCount != 0
            failedAuthentications = state.failedAuthenticationsCount
            hintTitle = L10n.authTxtFailedLoginHintTitle.text
            hintMessage = L10n.authTxtFailedLoginHintMsg(state.failedAuthenticationsCount).text
        }
    }

    var body: some View {
        // GeometryReader is needed to expand ScrollView content to full screen
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    HStack {
                        Image(decorative: Asset.LaunchAssets.logoGematik)
                            .padding()
                        Spacer()
                    }

                    if viewStore.showFailedAuthenticationsHint {
                        HintView<AppAuthenticationDomain.Action>(
                            hint: Hint(
                                id: A11y.auth.authTxtFailedLoginHint,
                                title: viewStore.hintTitle,
                                message: viewStore.hintMessage,
                                image: .init(name: Asset.Illustrations.girlRedCircle.name),
                                style: Hint.Style.important,
                                imageStyle: Hint.ImageStyle.topAligned
                            )
                        )
                        .padding()
                    }

                    Spacer()

                    Text(L10n.authTxtBiometricsTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()

                    VStack {
                        IfLetStore(
                            store.scope(
                                state: \.biometrics,
                                action: AppAuthenticationDomain.Action.biometrics(action:)
                            )
                        ) {
                            AppAuthenticationWithBiometricsView(store: $0)
                        }

                        IfLetStore(
                            store.scope(
                                state: \.password,
                                action: AppAuthenticationDomain.Action.password(action:)
                            )
                        ) {
                            AppAuthenticationPasswordView(store: $0)
                        }

                        IfLetStore(
                            store.scope(
                                state: \.biometricAndPassword,
                                action: AppAuthenticationDomain.Action.biometricAndPassword(action:)
                            )
                        ) {
                            AppAuthenticationBiometricPasswordView(store: $0)
                        }
                    }

                    Spacer()

                    Image(Asset.Illustrations.groupShot.name)
                        .resizable()
                        .scaledToFit()
                }
                .frame(minHeight: geometry.size.height)
            }
        }.onAppear {
            viewStore.send(.onAppear)
        }
        .onDisappear {
            viewStore.send(.removeSubscriptions)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct AppAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AppAuthenticationView(
            store: AppAuthenticationDomain.Dummies.storeFor(
                AppAuthenticationDomain.State(
                    biometrics: AppAuthenticationBiometricsDomain.State(
                        biometryType: .faceID,
                        startImmediateAuthenticationChallenge: false,
                        authenticationResult: .success(true)
                    ),
                    failedAuthenticationsCount: 3
                )
            )
        )

        AppAuthenticationView(
            store: AppAuthenticationDomain.Dummies.storeFor(
                AppAuthenticationDomain.State(
                    password: AppAuthenticationPasswordDomain.State()
                )
            )
        )
    }
}
