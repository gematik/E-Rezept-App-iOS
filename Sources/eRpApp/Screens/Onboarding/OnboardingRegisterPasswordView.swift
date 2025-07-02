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

struct OnboardingRegisterPasswordView: View, KeyboardReadable {
    @Perception.Bindable var store: StoreOf<RegisterPasswordDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    OnboardingProgressView(currentPage: .second)
                        .padding(.top)

                    TitleView()
                        .padding(.top)

                    PasswordView(store: store)
                }

                Spacer()

                PasswordButtonView(store: store)
            }
            .padding(.horizontal)
        }
    }
}

extension OnboardingRegisterPasswordView {
    struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.onbAuthTxtPasswordTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtSectionTitle)
                    .padding(.top, 22)

                Text(L10n.onbAuthTxtPasswordSubtitle)
                    .font(Font.subheadline)
                    .foregroundStyle(Colors.systemLabelSecondary)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtSectionSubtitle)
                    .padding(.top, 8)
            }
        }
    }

    struct PasswordView: View {
        @Perception.Bindable var store: StoreOf<RegisterPasswordDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 6) {
                    // This TextField is mandatory to support password autofill from iCloud Keychain, applying
                    // `.hidden()` lets iOS no longer detect it.
                    TextField("", text: .constant("E-Rezept App – \(UIDevice.current.name)"))
                        .textContentType(.username)
                        .frame(width: 1, height: 1, alignment: .leading)
                        .opacity(0.01)
                        .accessibility(hidden: true)

                    SecureField(L10n.cpwInpPasswordAPlaceholder, text: $store.passwordA)
                        .onSubmit { store.send(.enterButtonTapped) }
                        .padding()
                        .font(Font.body)
                        .foregroundColor(Colors.systemLabel)
                        .background(Colors.systemGray6)
                        .cornerRadius(8)
                        .textContentType(.newPassword)
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthInpPasswordA)

                    Text(L10n.cpwTxtPasswordRecommendation)
                        .font(.footnote)
                        .foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 10)
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtPasswordRecommendation)

                    // [REQ:BSI-eRp-ePA:O.Pass_2#2] Password strength view within onboarding.
                    PasswordStrengthView(
                        strength: store.passwordStrength,
                        barBackgroundColor: Color(.secondarySystemBackground)
                    )
                    .padding(.bottom, 16)
                    .animation(.easeInOut, value: store.passwordA)

                    VStack(alignment: .leading, spacing: 11) {
                        SecureField(L10n.cpwInpPasswordBPlaceholder, text: $store.passwordB)
                            .onSubmit { store.send(.enterButtonTapped) }
                            .padding()
                            .font(Font.body)
                            .foregroundColor(Colors.systemLabel)
                            .background(Colors.systemGray6)
                            .cornerRadius(8)
                            .textContentType(.newPassword)
                            .accessibilityLabel(L10n.cpwTxtPasswordBAccessibility)
                            .accessibility(identifier: A11y.onboarding.authentication.onbAuthInpPasswordB)

                        if let message = store.passwordErrorMessage {
                            Text(message)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Colors.red600)
                                .font(.footnote)
                                .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtPasswordsDontMatch)
                        }
                    }
                }
                .padding(.top, 40)
            }
        }
    }

    struct PasswordButtonView: View {
        @Perception.Bindable var store: StoreOf<RegisterPasswordDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    Button(action: {
                        store.send(.delegate(.nextPage))
                    }, label: {
                        Text(L10n.onbAuthBtnPasswordSave)
                            .padding(.horizontal, 64)
                            .padding(.vertical)
                    })
                        .disabled(!store.hasValidPasswordEntries)
                        .accessibility(identifier: A18n.onboarding.authentication.onbAuthBtnPassword)
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(Colors.systemColorWhite)
                        .background(!store.hasValidPasswordEntries ? Colors.primary.opacity(0.5) : Colors.primary)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        store.send(.delegate(.prevPage))
                    }, label: {
                        Text(L10n.onbAuthBtnPasswordBack)
                    })
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnBack)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Colors.primary)
                        .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    OnboardingRegisterPasswordView(store: RegisterPasswordDomain.Dummies.store)
}
