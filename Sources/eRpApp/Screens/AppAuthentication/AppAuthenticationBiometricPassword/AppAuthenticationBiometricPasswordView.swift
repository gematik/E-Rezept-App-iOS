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

struct AppAuthenticationBiometricPasswordView: View {
    let store: AppAuthenticationBiometricPasswordDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, AppAuthenticationBiometricPasswordDomain.Action>

    init(store: AppAuthenticationBiometricPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let biometryType: BiometryType
        let showPassword: Bool
        let showUsePasswordMessage: Bool
        let error: AuthenticationChallengeProviderError?

        init(state: AppAuthenticationBiometricPasswordDomain.State) {
            biometryType = state.biometryType
            showPassword = state.showPassword
            showUsePasswordMessage = (state.authenticationResult != .success(true) && state.authenticationResult != nil)
            error = state.errorToDisplay
        }
    }

    var body: some View {
        if !viewStore.showPassword {
            VStack(alignment: .center) {
                if viewStore.showUsePasswordMessage {
                    Text(L10n.authTxtBapPasswordMessage)
                        .font(.subheadline.weight(.regular))
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }

                switch viewStore.biometryType {
                case .faceID:
                    Button(action: {
                        viewStore.send(.startAuthenticationChallenge)
                    }, label: {
                        HStack {
                            Image(systemName: SFSymbolName.faceId)
                                .foregroundColor(.white)
                                .font(Font.body.weight(.bold))
                            Text(L10n.authBtnBapFaceid)
                                .fontWeight(.semibold)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Colors.systemColorWhite)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 64)
                    })
                        .accessibility(identifier: A11y.auth.authBtnBapFaceid)
                        .background(Colors.primary)
                        .cornerRadius(16)
                        .padding()
                case .touchID:
                    Button(action: {
                        viewStore.send(.startAuthenticationChallenge)
                    }, label: {
                        HStack {
                            Image(systemName: SFSymbolName.touchId)
                                .foregroundColor(.white)
                                .font(Font.body.weight(.bold))
                            Text(L10n.authBtnBapTouchid)
                                .fontWeight(.semibold)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Colors.systemColorWhite)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 64)
                    })
                        .accessibility(identifier: A11y.auth.authBtnBapTouchid)
                        .background(Colors.primary)
                        .cornerRadius(16)
                        .padding()
                }

                Button(L10n.authBtnBapChange) {
                    viewStore.send(.switchToPassword(true), animation: .default)
                }.foregroundColor(Colors.primary600)
                    .font(.body.weight(.semibold))
                    .accessibility(identifier: A11y.auth.authBtnBapChange)
            }
            .alert(isPresented: viewStore.binding(
                get: { $0.error != nil },
                send: AppAuthenticationBiometricPasswordDomain.Action.dismissError
            )) {
                Alert(
                    title: Text(L10n.alertErrorTitle),
                    message: Text(viewStore.error?.errorDescription ?? ""),
                    dismissButton: .default(Text(L10n.alertBtnOk))
                )
            }
        } else {
            PasswordView(store: store)
        }
    }
}

struct PasswordView: View {
    let store: AppAuthenticationBiometricPasswordDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, AppAuthenticationBiometricPasswordDomain.Action>

    init(store: AppAuthenticationBiometricPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let biometryType: BiometryType
        let password: String
        let isEmptyPassword: Bool
        let showUnsuccessfulAttemptMessage: Bool

        init(state: AppAuthenticationBiometricPasswordDomain.State) {
            biometryType = state.biometryType
            password = state.password
            isEmptyPassword = state.password.isEmpty
            showUnsuccessfulAttemptMessage = !(state.lastMatchResultSuccessful ?? true)
        }
    }

    var password: Binding<String> {
        viewStore.binding(get: \.password, send: AppAuthenticationBiometricPasswordDomain.Action.setPassword)
    }

    var body: some View {
        VStack(alignment: .center) {
            SecureFieldWithReveal(titleKey: L10n.authTxtPasswordPlaceholder,
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

            Button(action: {
                viewStore.send(.switchToPassword(false), animation: .default)
            }, label: {
                Text(viewStore
                    .biometryType == .faceID ? L10n.authBtnBapBackFaceID : L10n.authBtnBapBackTouchID)
            }).foregroundColor(Colors.primary600)
                .font(.body.weight(.regular))
                .accessibility(identifier: A11y.auth.authBtnBapChange)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding()
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
}

struct AppAuthenticationBiometricPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AppAuthenticationBiometricPasswordView(store: AppAuthenticationBiometricPasswordDomain.Dummies.store)
    }
}
