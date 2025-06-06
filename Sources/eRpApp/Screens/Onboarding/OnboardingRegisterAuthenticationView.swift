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

// [REQ:BSI-eRp-ePA:O.Resi_1#2] View containing onboarding authentication
struct OnboardingRegisterAuthenticationView: View, KeyboardReadable {
    @Perception.Bindable var store: StoreOf<RegisterAuthenticationDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    TitleView()
                        .padding(.top)

                    Picker(
                        selection: $store.selectedSecurityOption.intValue,
                        label: Text("")
                    ) {
                        if store.hasFaceIdOption {
                            Text(L10n.stgTxtSecurityOptionFaceidTitle).tag(AppSecurityOption.biometry(.faceID).id)
                        }
                        if store.hasTouchIdOption {
                            Text(L10n.stgTxtSecurityOptionTouchidTitle).tag(AppSecurityOption.biometry(.touchID).id)
                        }
                        if store.hasPasswordOption {
                            Text(L10n.stgTxtSecurityOptionPasswordTitle).tag(AppSecurityOption.password.id)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 25)

                    if store.showNoSelectionMessage {
                        Text(L10n.onbAuthTxtNoSelection)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Colors.red600)
                            .font(.body)
                            .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtNoSelection)
                            .padding(.top)
                    }

                    if store.selectedSecurityOption == .password {
                        PasswordView(store: store)
                    }
                }
                switch store.selectedSecurityOption {
                case .password:
                    PasswordViewButton(store: store)
                case .biometry(.faceID):
                    FaceIDView(
                        isSelected: store.biometrySuccessful,
                        message: store.securityOptionsError?.errorDescription
                    ) {
                        store.send(
                            .startBiometry,
                            animation: Animation.default
                        )
                    }
                case .biometry(.touchID):
                    TouchIDView(
                        isSelected: store.biometrySuccessful,
                        message: store.securityOptionsError?.errorDescription
                    ) {
                        store.send(
                            .startBiometry,
                            animation: Animation.default
                        )
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
            .alert($store.scope(state: \.alertState, action: \.alert))
            .onAppear {
                store.send(.loadAvailableSecurityOptions)
            }
        }
    }
}

extension OnboardingRegisterAuthenticationView {
    struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(decorative: Asset.Onboarding.developerCircle)
                        .accessibilityHidden(true)

                    Spacer()
                }
                .padding(.top, 10)

                Text(L10n.onbAuthTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.authentication.onbAuthTxtSectionTitle)
                    .padding(.top, 22)
            }
        }
    }

    struct DividerView: View {
        var body: some View {
            HStack {
                VStack {
                    Divider().padding(.leading)
                }
                Text(L10n.onbAuthTxtDivider)
                    .font(Font.callout.weight(.semibold))
                    .foregroundColor(Colors.systemLabelSecondary)
                VStack {
                    Divider().padding(.trailing)
                }
            }
        }
    }

    struct FaceIDView: View {
        let isSelected: Bool
        let message: String?
        let action: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                OnboardingRegisterAuthenticationView.BiometryButton(
                    text: L10n.authBtnBiometricsFaceid,
                    image: Image(systemName: isSelected ? SFSymbolName.checkmark : SFSymbolName.faceId),
                    backgroundColor: isSelected ? Colors.alertPositiv : Colors.primary,
                    action: action
                )
                .padding()
                .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnFaceid)
            }
            .padding(.top, 42)
        }
    }

    struct TouchIDView: View {
        let isSelected: Bool
        let message: String?
        let action: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                OnboardingRegisterAuthenticationView.BiometryButton(
                    text: L10n.authBtnBiometricsTouchid,
                    image: Image(systemName: isSelected ? SFSymbolName.checkmark : SFSymbolName.touchId),
                    backgroundColor: isSelected ? Colors.alertPositiv : Colors.primary,
                    action: action
                )
                .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnTouchid)
                .padding()
                .padding(.top, 50)
                .padding(.horizontal)
            }
            .padding(.top, 42)
        }
    }

    /// sourcery: StringAssetInitialized
    struct BiometryButton: View {
        var text: LocalizedStringKey
        var image: Image
        let backgroundColor: Color
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Spacer()
                    image
                        .foregroundColor(.white)
                        .font(Font.body.weight(.semibold))
                    Text(text, bundle: .module)
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.systemColorWhite)
                        .padding([.top, .bottom, .trailing])
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(16)
        }
    }

    struct PasswordView: View {
        @Perception.Bindable var store: StoreOf<RegisterAuthenticationDomain>

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
                        .cornerRadius(16)
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
                            .cornerRadius(16)
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

    struct PasswordViewButton: View {
        @Perception.Bindable var store: StoreOf<RegisterAuthenticationDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack {
                    Button(action: { store.send(.nextPage) }, label: {
                        Text(L10n.onbAuthBtnPasswordSave)
                            .padding(.horizontal, 64)
                            .padding(.vertical)
                    })
                        .disabled(!store.hasValidSelection)
                        .accessibility(identifier: A18n.onboarding.authentication.onbAuthBtnPassword)
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(!store.hasValidSelection ? Colors.systemGray : Colors.systemColorWhite)
                        .background(!store.hasValidSelection ? Colors.systemGray5 : Colors.primary700)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}

struct OnboardingRegisterAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies
                .store(with: RegisterAuthenticationDomain.State(availableSecurityOptions: [.password])))
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
                .preferredColorScheme(.dark)
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies
                .store(with: RegisterAuthenticationDomain.State(availableSecurityOptions: [.password])))
                            .preferredColorScheme(.dark)
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
                .previewDevice("iPod touch (7th generation)")
            OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies
                .store(with: RegisterAuthenticationDomain.State(availableSecurityOptions: [.password])))
                            .previewDevice("iPod touch (7th generation)")
        }
    }
}
