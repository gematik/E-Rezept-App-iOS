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

struct OnboardingAltRegisterAuthenticationView: View {
    let store: RegisterAuthenticationDomain.Store
    @ObservedObject
    var viewStore: ViewStore<RegisterAuthenticationDomain.State, RegisterAuthenticationDomain.Action>

    init(store: RegisterAuthenticationDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            AltRegistrationView(store: store)

            Spacer()

            GreyDivider()

            PrimaryTextButton(text: L10n.cpwBtnAltAuthSave,
                              a11y: A11y.cardWall.canInput.cdwBtnCanDone,
                              isEnabled: viewStore.state.hasValidSelection) {
                viewStore.send(.saveSelection)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct AltRegistrationView: View, KeyboardReadable {
    let store: RegisterAuthenticationDomain.Store
    @ObservedObject
    var viewStore: ViewStore<ViewState, RegisterAuthenticationDomain.Action>

    init(store: RegisterAuthenticationDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let hasPasswordOption: Bool
        let hasFaceIdOption: Bool
        let hasTouchIdOption: Bool
        let showNoSelectionMessage: Bool
        let selectedOption: AppSecurityOption?
        let biometryErrorMessage: String?

        init(state: RegisterAuthenticationDomain.State) {
            hasPasswordOption = state.availableSecurityOptions.contains(AppSecurityOption.password)
            hasFaceIdOption = state.availableSecurityOptions.contains(AppSecurityOption.biometry(.faceID))
            hasTouchIdOption = state.availableSecurityOptions.contains(AppSecurityOption.biometry(.touchID))
            showNoSelectionMessage = state.showNoSelectionMessage
            selectedOption = state.selectedSecurityOption
            biometryErrorMessage = state.securityOptionsError?.errorDescription
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Image(decorative: Asset.Illustrations.ladyDeveloperBlueCircle)

                TitleView()

                Text(L10n.onbAuthTxtAltDescription)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtAltDescription)

                if viewStore.showNoSelectionMessage {
                    Text(L10n.onbAuthTxtNoSelection)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Colors.red600)
                        .font(.body)
                        .padding(.horizontal)
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtNoSelection)
                }

                if viewStore.hasPasswordOption {
                    PasswordView(store: store)
                        .padding(.bottom, 50)
                }

                DividerView()

                if viewStore.hasFaceIdOption {
                    FaceIDView(isSelected: viewStore.selectedOption == .biometry(.faceID)) {
                        withAnimation {
                            viewStore.send(.select(.biometry(.faceID)))
                        }
                    }

                } else if viewStore.hasTouchIdOption {
                    TouchIDView(isSelected: viewStore.selectedOption == .biometry(.touchID)) {
                        withAnimation {
                            viewStore.send(.select(.biometry(.touchID)))
                        }
                    }
                } else if let message = viewStore.biometryErrorMessage {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Colors.systemGray)
                        .padding(.horizontal)
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtNoBiometrics)
                        .padding(.top, 50)
                        .padding(.horizontal)
                }
            }
        }
        .alert(
            self.store.scope(state: \.alertState),
            dismiss: .alertDismissButtonTapped
        )
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            if isKeyboardVisible {
                withAnimation {
                    viewStore.send(.select(.password))
                }
            }
        }
        .onAppear {
            viewStore.send(.loadAvailableSecurityOptions)
        }
    }

    struct TitleView: View {
        var body: some View {
            Text(L10n.onbAuthTxtTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(Colors.primary900)
                .font(Font.title.weight(.bold))
                .accessibility(identifier: A18n.onboarding.authentication.onbAuthTxtSectionTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 40)
                .padding(.top)
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
        let action: () -> Void

        var body: some View {
            BiometryButton(text: L10n.authBtnBiometricsFaceid,
                           image: Image(systemName: isSelected ? SFSymbolName.checkmark : SFSymbolName.faceId),
                           backgroundColor: isSelected ? Colors.alertPositiv : Colors.primary,
                           action: action)
                .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnFaceid)
                .padding(.top, 50)
                .padding(.horizontal)
        }
    }

    struct TouchIDView: View {
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            BiometryButton(text: L10n.authBtnBiometricsTouchid,
                           image: Image(systemName: isSelected ? SFSymbolName.checkmark : SFSymbolName.touchId),
                           backgroundColor: isSelected ? Colors.alertPositiv : Colors.primary,
                           action: action)
                .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnTouchid)
                .padding(.top, 50)
                .padding(.horizontal)
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
                    image.foregroundColor(.white)
                    Text(text)
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.systemColorWhite)
                        .padding()
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
        let store: RegisterAuthenticationDomain.Store
        @ObservedObject private var viewStore: ViewStore<
            RegisterAuthenticationDomain.State,
            RegisterAuthenticationDomain.Action
        >

        init(store: RegisterAuthenticationDomain.Store) {
            self.store = store
            viewStore = ViewStore(store)
        }

        var passwordA: Binding<String> {
            viewStore.binding(get: \.passwordA, send: RegisterAuthenticationDomain.Action.setPasswordA).animation()
        }

        var passwordB: Binding<String> {
            viewStore.binding(get: \.passwordB, send: RegisterAuthenticationDomain.Action.setPasswordB).animation()
        }

        var body: some View {
            VStack {
                VStack(alignment: .leading, spacing: 11) {
                    Divider()
                    SecureFieldWithReveal(titleKey: L10n.cpwInpPasswordAPlaceholder,
                                          text: passwordA,
                                          textContentType: .newPassword) {
                        viewStore.send(.enterButtonTapped)
                    }
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthInpPasswordA)
                    .padding(.horizontal)
                    Divider()
                }

                if viewStore.selectedSecurityOption == .password {
                    FootnoteView(
                        text: L10n.cpwTxtPasswordRecommendation,
                        a11y: A11y.settings.createPassword.cpwTxtPasswordRecommendation
                    )
                    .padding(.horizontal)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtPasswordRecommendation)

                    PasswordStrengthView(strength: viewStore.passwordStrength)
                        .padding(.bottom, 16)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 11) {
                        Divider()
                        SecureFieldWithReveal(
                            titleKey: L10n.cpwInpPasswordBPlaceholder,
                            accessibilityLabelKey: L10n.cpwTxtPasswordBAccessibility,
                            text: passwordB,
                            textContentType: .newPassword
                        ) {
                            viewStore.send(.enterButtonTapped)
                        }
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthInpPasswordB)
                        .padding(.horizontal)
                        Divider()

                        if let message = viewStore.passwordErrorMessage {
                            Text(message)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Colors.red600)
                                .font(.footnote)
                                .padding(.horizontal)
                                .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtPasswordsDontMatch)
                        }
                    }
                }
            }
        }
    }
}

struct OnboardingRegisterAltAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingAltRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
            OnboardingAltRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
                .preferredColorScheme(.dark)
            OnboardingAltRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
