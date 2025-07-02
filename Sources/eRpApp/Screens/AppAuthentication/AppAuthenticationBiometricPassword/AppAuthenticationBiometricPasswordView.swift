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
                    switch store.biometryType {
                    case .faceID:
                        PrimaryTextButton(
                            text: L10n.authBtnBapFaceid,
                            a11y: A11y.auth.authBtnBapFaceid,
                            image: Image(systemName: SFSymbolName.faceId),
                            useFullWidth: false
                        ) {
                            store.send(.startAuthenticationChallenge)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)

                    case .touchID:
                        PrimaryTextButton(
                            text: L10n.authBtnBapTouchid,
                            a11y: A11y.auth.authBtnBapTouchid,
                            image: Image(systemName: SFSymbolName.touchId),
                            useFullWidth: false
                        ) {
                            store.send(.startAuthenticationChallenge)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
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
            VStack(alignment: .leading) {
                SecureFieldWithReveal(titleKey: L10n.authTxtPasswordPlaceholder,
                                      accessibilityLabelKey: L10n.authTxtPasswordLabel,
                                      text: $store.password.sending(\.setPassword),
                                      textContentType: .password) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()
                .font(Font.body)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            store.showUnsuccessfulAttemptMessage ? Colors.red600 : Color(.systemGray3),
                            lineWidth: 1
                        )
                )
                .padding(.horizontal)
                .accessibility(identifier: A11y.auth.authEdtPasswordInput)

                if store.showUnsuccessfulAttemptMessage {
                    UnsuccessfulAttemptMessageView()
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                PrimaryTextButton(
                    text: L10n.authBtnPasswordContinue,
                    a11y: A11y.auth.authBtnPasswordContinue,
                    isEnabled: !store.password.isEmpty,
                    useFullWidth: false
                ) {
                    store.send(.loginButtonTapped, animation: .default)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)

                Button(action: {
                    store.send(.switchToPassword(false), animation: .default)
                }, label: {
                    Text(L10n.authBtnBapBack)
                }).foregroundColor(Colors.primary700)
                    .font(.body.weight(.regular))
                    .accessibility(identifier: A11y.auth.authBtnBapChange)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
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
