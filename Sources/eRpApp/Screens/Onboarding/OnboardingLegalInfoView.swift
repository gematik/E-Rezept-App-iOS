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

import SwiftUI

struct OnboardingLegalInfoView: View {
    var action: () -> Void
    @ScaledMetric var iconSize: CGFloat = 24
    @State private var isUseAccepted = false
    @State private var showTermsOfUse = false
    @State private var isPrivacyAccepted = false
    @State private var showTermsOfPrivacy = false
    private var isDoneButtonDisabled: Bool {
        !(isPrivacyAccepted && isUseAccepted)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(L10n.onbLegTxtTitle)
                    .foregroundColor(Colors.primary900)
                    .font(Font.title3.weight(.bold))
                    .accessibility(identifier: A18n.onboarding.legalInfo.onbTxtLegalInfoTitle)
                    .padding([.leading, .trailing, .top], 24)
                Text(L10n.onbLegTxtSubtitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(24)

                VStack(alignment: .leading) {
                    OnboardingTermsOfUseView(
                        action: action,
                        iconSize: iconSize,
                        isUseAccepted: $isUseAccepted,
                        showTermsOfUse: $showTermsOfUse
                    )

                    OnboardingPrivacyView(
                        action: action,
                        iconSize: iconSize,
                        isPrivacyAccepted: $isPrivacyAccepted,
                        showTermsOfPrivacy: $showTermsOfPrivacy
                    )
                }

                HStack {
                    Spacer()

                    Button(action: action) {
                        Text(L10n.onbLegBtnTitle)
                            .padding(15)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: iconSize)
                    }
                    .disabled(isDoneButtonDisabled)
                    .accessibility(identifier: A18n.onboarding.legalInfo.onbBtnAccept)
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(isDoneButtonDisabled ? Colors.systemGray : Colors.systemColorWhite)
                    .background(isDoneButtonDisabled ? Colors.systemGray5 : Colors.primary600)
                    .cornerRadius(16)
                    .padding()

                    Spacer()
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                UIApplication.shared.dismissKeyboard()
            }
        }
    }
}

extension OnboardingLegalInfoView {
    struct OnboardingTermsOfUseView: View {
        var action: () -> Void
        @ScaledMetric var iconSize: CGFloat
        @Binding var isUseAccepted: Bool
        @Binding var showTermsOfUse: Bool

        var body: some View {
            HStack {
                Button(
                    action: { showTermsOfUse.toggle() },
                    label: {
                        Group {
                            Text(L10n.onbTxtTermsOfUsePrefix)
                                .foregroundColor(Colors.systemLabel)
                                + Text(L10n.onbTxtTermsOfUseLink)
                                .foregroundColor(Colors.primary600)
                                + Text(L10n.onbTxtTermsOfUseSuffix)
                                .foregroundColor(Colors.systemLabel)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfUse)
                    }
                )
                .sheet(isPresented: $showTermsOfUse) {
                    NavigationView {
                        TermsOfUseView()
                            .toolbar {
                                CloseButton { showTermsOfUse = false }
                            }
                    }
                    .accentColor(Colors.primary700)
                    .navigationViewStyle(StackNavigationViewStyle())
                }

                Spacer()

                Button(
                    action: {
                        isUseAccepted.toggle()
                    },
                    label: {
                        OnboardingLegalInfoCheckmarkView(isAccepted: $isUseAccepted)
                    }
                ).accessibility(identifier: A18n.onboarding.legalInfo.onbBtnAcceptTermsOfUse)
                    .accessibility(hint: Text(L10n.onbLegBtnTermsOfUseHint))
            }
            .padding([.leading, .trailing, .bottom], 24)
        }
    }

    struct OnboardingPrivacyView: View {
        var action: () -> Void
        @ScaledMetric var iconSize: CGFloat
        @Binding var isPrivacyAccepted: Bool
        @Binding var showTermsOfPrivacy: Bool

        var body: some View {
            HStack {
                Button(
                    action: { showTermsOfPrivacy.toggle() },
                    label: {
                        Group {
                            Text(L10n.onbTxtTermsOfPrivacyPrefix)
                                .foregroundColor(Colors.systemLabel)
                                + Text(L10n.onbTxtTermsOfPrivacyLink)
                                .foregroundColor(Colors.primary600)
                                + Text(L10n.onbTxtTermsOfPrivacySuffix)
                                .foregroundColor(Colors.systemLabel)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .accessibilityIdentifier(A18n.onboarding.legalInfo.onbTxtTermsOfPrivacy)
                    }
                )
                .sheet(isPresented: $showTermsOfPrivacy) {
                    NavigationView {
                        DataPrivacyView()
                            .toolbar {
                                CloseButton { showTermsOfPrivacy = false }
                            }
                    }
                    .accentColor(Colors.primary700)
                    .navigationViewStyle(StackNavigationViewStyle())
                }

                Spacer()

                Button(
                    action: {
                        isPrivacyAccepted.toggle()
                    },
                    label: {
                        OnboardingLegalInfoCheckmarkView(isAccepted: $isPrivacyAccepted)
                    }
                ).accessibility(identifier: A18n.onboarding.legalInfo.onbBtnAcceptPrivacy)
                    .accessibility(hint: Text(L10n.onbLegBtnPrivacyHint))
            }
            .padding([.leading, .trailing, .bottom], 24)
        }
    }
}

struct OnboardingLegalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingLegalInfoView {}
            OnboardingLegalInfoView {}
                .preferredColorScheme(.dark)
            OnboardingLegalInfoView {}
                .previewDevice("iPod touch (7th generation)")
        }
    }
}
