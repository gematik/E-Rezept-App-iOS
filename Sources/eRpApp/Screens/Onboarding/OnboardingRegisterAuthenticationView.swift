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

// [REQ:BSI-eRp-ePA:O.Resi_1#2] View containing onboarding authentication
struct OnboardingRegisterAuthenticationView: View, KeyboardReadable {
    @Perception.Bindable var store: StoreOf<RegisterAuthenticationDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    OnboardingProgressView(currentPage: .second)
                        .padding(.top)

                    TitleView()
                        .padding(.top)

                    if store.hasFaceIdOption {
                        FaceIDView {
                            store.send(.startBiometry(.biometry(.faceID)))
                        }
                    }
                    if store.hasTouchIdOption {
                        TouchIDView {
                            store.send(.startBiometry(.biometry(.touchID)))
                        }
                    }
                    if store.hasPasswordOption {
                        PasswordView {
                            store.send(.delegate(.showRegisterPassword))
                        }
                    }
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
                Text(L10n.onbAuthTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.authentication.onbAuthTxtSectionTitle)
                    .padding(.top, 22)

                Text(L10n.onbAuthTxtSubtitle)
                    .font(Font.subheadline)
                    .foregroundStyle(Colors.systemLabelSecondary)
                    .padding(.top, 8)
            }
        }
    }

    struct FaceIDView: View {
        let action: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Text(L10n.onbAuthTxtBiometryRecommended)
                    .foregroundColor(Colors.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.body.bold())

                Button(action: {
                    action()
                }, label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.onbAuthBtnFaceIdTitle)
                                .font(Font.body.weight(.medium))
                                .foregroundColor(Colors.systemLabel)

                            Text(L10n.onbAuthBtnFaceIdSubtitle)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        .multilineTextAlignment(.leading)

                        Spacer(minLength: 32)
                    }
                    .padding()
                })
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnFaceId)
                    .buttonStyle(DefaultButtonStyle())
                    .background(Colors.systemBackgroundTertiary)
                    .border(Colors.primary, width: 2.0, cornerRadius: 16)
            }
            .padding(.top, 24)
        }
    }

    struct TouchIDView: View {
        let action: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Text(L10n.onbAuthTxtBiometryRecommended)
                    .foregroundColor(Colors.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.body.bold())

                Button(action: {
                    action()
                }, label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.onbAuthBtnTouchIdTitle)
                                .font(Font.body.weight(.medium))
                                .foregroundColor(Colors.systemLabel)

                            Text(L10n.onbAuthBtnTouchIdSubtitle)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        .multilineTextAlignment(.leading)

                        Spacer(minLength: 32)
                    }
                    .padding()
                })
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnTouchId)
                    .buttonStyle(DefaultButtonStyle())
                    .background(Colors.systemBackgroundTertiary)
                    .border(Colors.primary, width: 2.0, cornerRadius: 16)
            }
            .padding(.top, 24)
        }
    }

    struct PasswordView: View {
        let action: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Button(action: {
                    action()
                }, label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.onbAuthBtnPasswordTitle)
                                .font(Font.body.weight(.medium))
                                .foregroundColor(Colors.systemLabel)

                            Text(L10n.onbAuthBtnPasswordSubtitle)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        .multilineTextAlignment(.leading)

                        Spacer(minLength: 8)

                        Image(systemName: SFSymbolName.rightDisclosureIndicator)
                            .font(Font.headline.weight(.semibold))
                            .foregroundColor(Colors.systemLabelTertiary)
                            .padding(8)
                    }
                    .padding()
                })
                    .accessibility(identifier: A11y.onboarding.authentication.onbAuthBtnPassword)
                    .buttonStyle(DefaultButtonStyle())
                    .background(Colors.systemBackgroundTertiary)
                    .border(Colors.primary, width: 1.0, cornerRadius: 16)
                    .padding(.bottom)
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    Group {
        OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies.store)
        OnboardingRegisterAuthenticationView(store: RegisterAuthenticationDomain.Dummies
            .store(with: RegisterAuthenticationDomain.State(availableSecurityOptions: [.password])))
    }
}
