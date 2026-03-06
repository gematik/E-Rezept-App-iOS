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
import FeatureHelpers
import SwiftUI

extension AppAuthenticationBiometricPasswordDomain.State {
    var showUsePasswordMessage: Bool {
        authenticationResult != .success(true) && authenticationResult != nil
    }
}

struct AppAuthenticationBiometricPasswordView: View {
    @Bindable var store: StoreOf<AppAuthenticationBiometricPasswordDomain>

    var body: some View {
        if !store.showPassword {
            VStack(alignment: .center) {
                switch store.biometryType {
                case .faceID:
                    Button {
                        store.send(.startAuthenticationChallenge)
                    } label: {
                        Label(L10n.authBtnBapFaceid, systemImage: SFSymbolName.faceId)
                    }
                    .buttonStyle(.primaryHugging)
                    .accessibilityIdentifier(A11y.auth.authBtnBapFaceid)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)

                case .touchID:
                    Button {
                        store.send(.startAuthenticationChallenge)
                    } label: {
                        Label(L10n.authBtnBapTouchid, systemImage: SFSymbolName.touchId)
                    }
                    .buttonStyle(.primaryHugging)
                    .accessibilityIdentifier(A11y.auth.authBtnBapTouchid)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Button {
                    store.send(.switchToPassword(true), animation: .default)
                } label: {
                    Text(L10n.authBtnBapChange)
                }
                .buttonStyle(.smallNavigation(back: false))
                .accessibility(identifier: A11y.auth.authBtnBapChange)
                .frame(maxWidth: .infinity, alignment: .center)
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

struct PasswordView: View {
    @Bindable var store: StoreOf<AppAuthenticationBiometricPasswordDomain>

    var body: some View {
        VStack(alignment: .leading) {
            SecureFieldWithReveal(titleKey: L10n.authTxtPasswordPlaceholder,
                                  accessibilityLabelKey: L10n.authTxtPasswordLabel,
                                  text: $store.password.sending(\.setPassword),
                                  textContentType: .password,
                                  borderColor: store.showUnsuccessfulAttemptMessage ? Colors.red700 : nil) {
                store.send(.loginButtonTapped, animation: .default)
            }
            .padding(.horizontal)
            .disabled(store.passwordDelayIsActive)
            .accessibility(identifier: A11y.auth.authEdtPasswordInput)

            if store.showUnsuccessfulAttemptMessage {
                UnsuccessfulAttemptMessageView(store: store)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }

            Button {
                store.send(.loginButtonTapped, animation: .default)
            } label: {
                Text(L10n.authBtnPasswordContinue)
            }
            .disabled(!store.isPasswordLoginButtonEnabled)
            .buttonStyle(
                .primary(
                    isEnabled: store.isPasswordLoginButtonEnabled,
                    width: .wideHugging
                )
            )
            .accessibilityIdentifier(A11y.auth.authBtnPasswordContinue)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)

            Button {
                store.send(.switchToPassword(false), animation: .default)
            } label: {
                Text(L10n.authBtnBapBack)
            }
            .buttonStyle(.smallNavigation(back: true))
            .accessibility(identifier: A11y.auth.authBtnBapChange)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
        }
        .task {
            await store.send(.task).finish()
        }
    }

    private struct UnsuccessfulAttemptMessageView: View {
        @Bindable var store: StoreOf<AppAuthenticationBiometricPasswordDomain>
        var body: some View {
            Text(store.unsuccessfulAttemptMessage)
                .foregroundColor(Colors.red700)
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
