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

struct OnboardingRegisterAuthenticationView: View, KeyboardReadable {
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
        let biometrySuccessful: Bool

        init(state: RegisterAuthenticationDomain.State) {
            hasPasswordOption = state.availableSecurityOptions.contains(AppSecurityOption.password)
            hasFaceIdOption = state.availableSecurityOptions.contains(AppSecurityOption.biometry(.faceID))
            hasTouchIdOption = state.availableSecurityOptions.contains(AppSecurityOption.biometry(.touchID))
            showNoSelectionMessage = state.showNoSelectionMessage
            selectedOption = state.selectedSecurityOption
            biometryErrorMessage = state.securityOptionsError?.errorDescription
            biometrySuccessful = state.biometrySuccessful
        }
    }

    var selectedOption: Binding<Int> {
        viewStore.binding(
            get: { state in
                state.selectedOption?.id ?? -1
            },
            send: { localState in
                let option = AppSecurityOption(fromId: localState)
                return RegisterAuthenticationDomain.Action.select(option)
            }
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                TitleView()
                    .padding(.top)

                Picker(selection: selectedOption, label: Text("")) {
                    if viewStore.hasFaceIdOption {
                        Text(L10n.stgTxtSecurityOptionFaceidTitle).tag(AppSecurityOption.biometry(.faceID).id)
                    }
                    if viewStore.hasTouchIdOption {
                        Text(L10n.stgTxtSecurityOptionTouchidTitle).tag(AppSecurityOption.biometry(.touchID).id)
                    }
                    if viewStore.hasPasswordOption {
                        Text(L10n.stgTxtSecurityOptionPasswordTitle).tag(AppSecurityOption.password.id)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 25)

                if viewStore.showNoSelectionMessage {
                    Text(L10n.onbAuthTxtNoSelection)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Colors.red600)
                        .font(.body)
                        .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtNoSelection)
                        .padding(.top)
                }

                switch viewStore.selectedOption {
                case .password:
                    PasswordView(store: store)
                case .biometry(.faceID):
                    FaceIDView(isSelected: viewStore.biometrySuccessful, message: viewStore.biometryErrorMessage) {
                        viewStore.send(
                            .startBiometry,
                            animation: Animation.default
                        )
                    }
                case .biometry(.touchID):
                    TouchIDView(isSelected: viewStore.biometrySuccessful, message: viewStore.biometryErrorMessage) {
                        viewStore.send(
                            .startBiometry,
                            animation: Animation.default
                        )
                    }
                default:
                    EmptyView()
                }

                Spacer(minLength: 110)
            }
            .padding(.horizontal)
        }
        .alert(
            self.store.scope(state: \.alertState),
            dismiss: .alertDismissButtonTapped
        )
        .onAppear {
            viewStore.send(.loadAvailableSecurityOptions)
        }
    }
}

extension OnboardingRegisterAuthenticationView {
    struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(decorative: Asset.Onboarding.developer)
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
                Text(L10n.authTxtBiometricsFaceIdTitle)
                    .font(.body.weight(.semibold))
                    .padding(.bottom, 8)

                OnboardingRegisterAuthenticationView.BiometryButton(text: L10n.authBtnBiometricsFaceid,
                                                                    image: Image(
                                                                        systemName: isSelected ? SFSymbolName
                                                                            .checkmark : SFSymbolName.faceId
                                                                    ),
                                                                    backgroundColor: isSelected ? Colors
                                                                        .alertPositiv : Colors.primary,
                                                                    action: action)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnFaceid)

                Text(L10n.authTxtBiometricsDisclaimer)
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)

                if let message = message {
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
            .padding(.top, 42)
        }
    }

    struct TouchIDView: View {
        let isSelected: Bool
        let message: String?
        let action: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.authTxtBiometricsTouchIdTitle)
                    .font(.body.weight(.semibold))
                    .padding(.bottom, 8)

                OnboardingRegisterAuthenticationView.BiometryButton(text: L10n.authBtnBiometricsTouchid,
                                                                    image: Image(
                                                                        systemName: isSelected ? SFSymbolName
                                                                            .checkmark : SFSymbolName.touchId
                                                                    ),
                                                                    backgroundColor: isSelected ? Colors
                                                                        .alertPositiv : Colors.primary,
                                                                    action: action)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnTouchid)
                    .padding(.top, 50)
                    .padding(.horizontal)

                HStack(spacing: 0) {
                    Text(L10n.authTxtBiometricsDisclaimer)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                if let message = message {
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
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.authTxtBiometricsPasswordTitle)
                    .font(.body.weight(.semibold))

                // This TextField is mandatory to support password autofill from iCloud Keychain, applying  `.hidden()`
                // lets iOS no longer detect it.
                TextField("", text: .constant("E-Rezept App – \(UIDevice.current.name)"))
                    .textContentType(.username)
                    .frame(width: 1, height: 1, alignment: .leading)
                    .opacity(0.01)
                    .accessibility(hidden: true)

                SecureField(L10n.cpwInpPasswordAPlaceholder, text: passwordA) {
                    viewStore.send(.enterButtonTapped)
                }
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

                PasswordStrengthView(strength: viewStore.passwordStrength,
                                     barBackgroundColor: Color(.secondarySystemBackground))
                    .padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 11) {
                    SecureField(L10n.cpwInpPasswordBPlaceholder,
                                text: passwordB) {
                        viewStore.send(.enterButtonTapped)
                    }
                    .padding()
                    .font(Font.body)
                    .foregroundColor(Colors.systemLabel)
                    .background(Colors.systemGray6)
                    .cornerRadius(16)
                    .textContentType(.newPassword)
                    .accessibilityLabel(L10n.cpwTxtPasswordBAccessibility)
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthInpPasswordB)

                    if let message = viewStore.passwordErrorMessage {
                        Text(message)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Colors.red600)
                            .font(.footnote)
                            .accessibility(identifier: A11y.onboarding.authentication.onbAuthTxtPasswordsDontMatch)
                    }
                }
            }
            .padding(.top, 42)
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
