//
//  Copyright (c) 2024 gematik GmbH
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
import eRpStyleKit
import SwiftUI

extension AppAuthenticationBiometricPasswordDomain.State {
    var showUsePasswordMessage: Bool {
        authenticationResult != .success(true) && authenticationResult != nil
    }
}

struct AppAuthenticationBiometricPasswordView: View {
    @Perception.Bindable var store: StoreOf<AppAuthenticationBiometricPasswordDomain>

    var body: some View {
        WithPerceptionTracking {
            if !store.showPassword {
                VStack(alignment: .center) {
                    if store.showUsePasswordMessage {
                        Text(L10n.authTxtBapPasswordMessage)
                            .font(.subheadline.weight(.regular))
                            .foregroundColor(Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                    }

                    switch store.biometryType {
                    case .faceID:
                        Button(action: {
                            store.send(.startAuthenticationChallenge)
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
                            store.send(.startAuthenticationChallenge)
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
                        store.send(.switchToPassword(true), animation: .default)
                    }.foregroundColor(Colors.primary700)
                        .font(.body.weight(.semibold))
                        .accessibility(identifier: A11y.auth.authBtnBapChange)
                }
                .onAppear {
                    if store.startImmediateAuthenticationChallenge {
                        store.send(.startAuthenticationChallenge)
                    }
                }
                .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            } else {
                PasswordView(store: store)
            }
        }
    }
}

extension AppAuthenticationBiometricPasswordDomain.State {
    var showUnsuccessfulAttemptMessage: Bool {
        !(lastMatchResultSuccessful ?? true)
    }
}

struct PasswordView: View {
    @Perception.Bindable var store: StoreOf<AppAuthenticationBiometricPasswordDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                SecureFieldWithReveal(titleKey: L10n.authTxtPasswordPlaceholder,
                                      accessibilityLabelKey: L10n.authTxtPasswordLabel,
                                      text: $store.password.sending(\.setPassword),
                                      textContentType: .password) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()
                .font(Font.body)
                .background(Color(.systemBackground))
                .padding(.vertical, 1)
                .background(Colors.systemGray3)
                .accessibility(identifier: A11y.auth.authEdtPasswordInput)

                if store.showUnsuccessfulAttemptMessage {
                    UnsuccessfulAttemptMessageView()
                        .padding(.horizontal)
                }

                PrimaryTextButton(
                    text: L10n.authBtnPasswordContinue,
                    a11y: A11y.auth.authBtnPasswordContinue,
                    isEnabled: !store.password.isEmpty
                ) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()

                Button(action: {
                    store.send(.switchToPassword(false), animation: .default)
                }, label: {
                    Text(store
                        .biometryType == .faceID ? L10n.authBtnBapBackFaceID : L10n.authBtnBapBackTouchID)
                }).foregroundColor(Colors.primary700)
                    .font(.body.weight(.regular))
                    .accessibility(identifier: A11y.auth.authBtnBapChange)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding()
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
}

struct AppAuthenticationBiometricPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AppAuthenticationBiometricPasswordView(store: AppAuthenticationBiometricPasswordDomain.Dummies.store)
    }
}
