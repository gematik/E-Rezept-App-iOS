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
import SwiftUI

struct OnboardingLegalInfoView: View {
    @Binding<Bool> var isAllAccepted: Bool
    var action: () -> Void

    @State private var showTermsOfUse = false
    @State private var showTermsOfPrivacy = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    TitleView()
                        .padding(.bottom)

                    VStack {
                        OnboardingTermsOfUseView(
                            showTermsOfUse: $showTermsOfUse
                        )

                        OnboardingPrivacyView(
                            showTermsOfPrivacy: $showTermsOfPrivacy
                        )
                    }
                    .padding(.vertical, 32)

                    Button(action: {
                        withAnimation {
                            isAllAccepted.toggle()
                        }

                    }, label: {
                        HStack {
                            // [REQ:BSI-eRp-ePA:O.Purp_3#3] User acceptance
                            OnboardingLegalInfoCheckmarkView(isAccepted: $isAllAccepted)
                                .padding(.leading, 8)

                            Text(L10n.onbLegBtnAccept)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Colors.systemLabel)
                                .padding(.trailing)
                                .padding(.vertical)
                        }
                    })
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Colors.systemGray6.cornerRadius(16))
                        .accessibility(identifier: A18n.onboarding.legalInfo.onbBtnAcceptTermsOfUseAndPrivacy)
                }
            }
            Spacer()

            Button(action: action) {
                Text(L10n.onbLegBtnTitle)
                    .padding(.horizontal, 64)
                    .padding(.vertical)
            }
            .disabled(!isAllAccepted)
            .accessibility(identifier: A18n.onboarding.legalInfo.onbBtnConfirm)
            .font(Font.body.weight(.semibold))
            .foregroundColor(!isAllAccepted ? Colors.systemGray : Colors.systemColorWhite)
            .background(!isAllAccepted ? Colors.systemGray5 : Colors.primary600)
            .cornerRadius(16)
        }
        .padding()
        .onAppear {
            withAnimation {
                UIApplication.shared.dismissKeyboard()
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
                    .padding(.top, 22)
            }
        }
    }

    // [REQ:BSI-eRp-ePA:O.Purp_3#1] Terms of Use display is part of the onboarding
    struct OnboardingTermsOfUseView: View {
        @Binding var showTermsOfUse: Bool

        var body: some View {
            HStack {
                Button(
                    action: { showTermsOfUse.toggle() },
                    label: {
                        Text(L10n.onbTxtTermsOfUseLink)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfUse)
                            .padding()
                            .foregroundColor(Colors.primary600)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .background(Colors.systemGray6.cornerRadius(16))
                .sheet(isPresented: $showTermsOfUse) {
                    NavigationView {
                        TermsOfUseView()
                            .toolbar {
                                CloseButton { showTermsOfUse = false }
                                    .embedToolbarContent()
                                    .accessibilityIdentifier(A11y.settings.termsOfUse.stgBtnTermsOfUseClose)
                            }
                    }
                    .accentColor(Colors.primary600)
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
            .padding(.bottom, 16)
        }
    }

    // [REQ:BSI-eRp-ePA:O.Purp_1#1] Display as part of the onboarding
    struct OnboardingPrivacyView: View {
        @Binding var showTermsOfPrivacy: Bool

        var body: some View {
            HStack {
                Button(
                    action: { showTermsOfPrivacy.toggle() },
                    label: {
                        Text(L10n.onbTxtTermsOfPrivacyLink)
                            .font(Font.body.weight(.semibold))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfPrivacy)
                            .padding()
                            .foregroundColor(Colors.primary600)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .background(Colors.systemGray6.cornerRadius(16))
                // [REQ:BSI-eRp-ePA:O.Arch_9#2] DataPrivacy display within Onboarding
                .sheet(isPresented: $showTermsOfPrivacy) {
                    NavigationView {
                        DataPrivacyView()
                            .toolbar {
                                CloseButton { showTermsOfPrivacy = false }
                                    .embedToolbarContent()
                                    .accessibilityIdentifier(A11y.settings.dataPrivacy.stgBtnDataPrivacyClose)
                            }
                    }
                    .accentColor(Colors.primary600)
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }
    }
}

struct OnboardingLegalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingLegalInfoView(isAllAccepted: .constant(false)) {}
            OnboardingLegalInfoView(isAllAccepted: .constant(false)) {}
                .preferredColorScheme(.dark)
            OnboardingLegalInfoView(isAllAccepted: .constant(false)) {}
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
