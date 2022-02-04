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
import SwiftUI

struct AppAuthenticationPasswordView: View {
    var store: AppAuthenticationPasswordDomain.Store
    @ObservedObject private var viewStore: ViewStore<ViewState, AppAuthenticationPasswordDomain.Action>

    struct ViewState: Equatable {
        let password: String
        let isEmptyPassword: Bool
        let showUnsuccessfulAttemptMessage: Bool

        init(state: AppAuthenticationPasswordDomain.State) {
            password = state.password
            isEmptyPassword = state.password.isEmpty
            showUnsuccessfulAttemptMessage = !(state.lastMatchResultSuccessful ?? true)
        }
    }

    init(store: AppAuthenticationPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var password: Binding<String> {
        viewStore.binding(get: \.password, send: AppAuthenticationPasswordDomain.Action.setPassword)
    }

    var body: some View {
        VStack(alignment: .leading) {
            SecureFieldWithReveal(L10n.authTxtPasswordPlaceholder,
                                  accessibilityLabelKey: L10n.authTxtPasswordLabel,
                                  text: password,
                                  textContentType: .password) {
                viewStore.send(.loginButtonTapped, animation: .default)
            }
            .padding()
            .font(Font.body)
            .background(Color(.systemBackground))
            .padding(.vertical, 1)
            .background(Colors.systemGray3)
            .accessibility(identifier: A11y.auth.authEdtPasswordInput)

            if viewStore.showUnsuccessfulAttemptMessage {
                UnsuccessfulAttemptMessageView()
                    .padding(.horizontal)
            }

            PrimaryTextButton(
                text: L10n.authBtnPasswordContinue,
                a11y: A11y.auth.authBtnPasswordContinue,
                isEnabled: !viewStore.isEmptyPassword
            ) {
                viewStore.send(.loginButtonTapped, animation: .default)
            }
            .padding()

            if viewStore.showUnsuccessfulAttemptMessage {
                FooterView()
            }
        }
    }

    private struct UnsuccessfulAttemptMessageView: View {
        var body: some View {
            Text(L10n.authTxtPasswordFailure)
                .foregroundColor(Colors.red600)
                .font(.footnote)
                .accessibility(identifier: A11y.auth.authTxtPasswordFailure)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    struct FooterView: View {
        @State var calculatedHeight = CGFloat(100)
        var body: some View {
            VStack {
                LinksAwareTextView(
                    text: L10n.authTxtBiometricsFooter.text,
                    links: [
                        L10n.authTxtBiometricsFooterUrlDisplay.text:
                            L10n.authTxtBiometricsFooterUrlLink.text,
                        L10n.authTxtBiometricsFooterEmailDisplay.text:
                            L10n.authTxtBiometricsFooterEmailLink.text,
                    ],
                    calculatedHeight: $calculatedHeight
                )
                .frame(height: calculatedHeight)
                .padding()
            }.background(Color(.secondarySystemBackground))
        }
    }
}

struct AppAuthenticationPasswordView_Preview: PreviewProvider {
    static var previews: some View {
        AppAuthenticationPasswordView(store: AppAuthenticationPasswordDomain.Dummies.store)

        AppAuthenticationPasswordView(
            store: AppAuthenticationPasswordDomain.Dummies.storeFor(
                AppAuthenticationPasswordDomain.State(
                    password: "ABC",
                    lastMatchResultSuccessful: false
                )
            )
        )
    }
}
