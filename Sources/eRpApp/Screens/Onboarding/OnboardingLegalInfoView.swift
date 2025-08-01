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
import eRpStyleKit
import SwiftUI

struct OnboardingLegalInfoView: View {
    @Perception.Bindable var store: StoreOf<OnboardingDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        OnboardingProgressView(currentPage: .first)
                            .padding(.bottom)

                        TitleView()
                            .padding(.bottom)

                        VStack {
                            Button(
                                action: { store.send(.setShowPrivacy(true)) },
                                label: {
                                    Text(L10n.onbTxtTermsOfPrivacyLink)
                                        .font(Font.body.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfPrivacy)
                                        .padding()
                                        .foregroundColor(Colors.primary700)
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .buttonStyle(PrimaryBorderButtonStyle())

                            Button(
                                action: { store.send(.setShowUse(true)) },
                                label: {
                                    Text(L10n.onbTxtTermsOfUseLink2)
                                        .font(Font.body.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfUse)
                                        .padding()
                                        .foregroundColor(Colors.primary700)
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .buttonStyle(PrimaryBorderButtonStyle())
                        }
                        .padding(.vertical, 16)
                    }
                }

                Spacer()

                Button(action: {
                    store.send(.showRegisterAuth)
                }, label: {
                    Text(L10n.onbBtnNextHint)
                        .accessibility(identifier: A11y.onboarding.legalInfo.onbBtnNext)
                        .accessibilityLabel(Text(L10n.onbBtnNextHint))
                })
                    .buttonStyle(.primaryHugging)
                    .padding(.top, 8)
            }
            .padding()
            .onAppear {
                withAnimation {
                    UIApplication.shared.dismissKeyboard()
                }
            }
            // [REQ:BSI-eRp-ePA:O.Arch_9#2] DataPrivacy display within Onboarding
            .sheet(isPresented: $store.showTermsOfPrivacy.sending(\.setShowPrivacy)) {
                NavigationStack {
                    DataPrivacyView()
                        .toolbar {
                            CloseButton { store.send(.setShowPrivacy(false)) }
                                .embedToolbarContent()
                                .accessibilityIdentifier(A11y.settings.dataPrivacy.stgBtnDataPrivacyClose)
                        }
                }
                .tint(Colors.primary700)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            // [REQ:BSI-eRp-ePA:O.Purp_3#1] Terms of Use display is part of the onboarding
            .sheet(isPresented: $store.showTermsOfUse.sending(\.setShowUse)) {
                NavigationStack {
                    TermsOfUseView()
                        .toolbar {
                            CloseButton { store.send(.setShowUse(false)) }
                                .embedToolbarContent()
                                .accessibilityIdentifier(A11y.settings
                                    .termsOfUse.stgBtnTermsOfUseClose)
                        }
                }
                .tint(Colors.primary700)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

extension OnboardingLegalInfoView {
    struct TitleView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(decorative: Asset.Onboarding.paragraphCircle)
                        .accessibilityHidden(true)
                    Spacer()
                }
                .padding(.top, 10)

                Text(L10n.onbLegTxtTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(Font.title.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.legalInfo.onbTxtLegalInfoTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityRemoveTraits(.isStaticText)
                    .padding(.top, 22)

                Text(L10n.onbLegTxtSubtitle)
                    .font(Font.subheadline)
                    .foregroundStyle(Colors.systemLabelSecondary)
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    Group {
        OnboardingLegalInfoView(
            store: .init(
                initialState: OnboardingDomain.Dummies.state
            ) {
                OnboardingDomain()
            }
        )
    }
}
