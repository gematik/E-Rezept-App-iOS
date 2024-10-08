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
import eRpStyleKit
import SwiftUI

struct OnboardingContainer: View, KeyboardReadable {
    @Perception.Bindable var store: StoreOf<OnboardingDomain>
    @State var isKeyboardVisible = false

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottomTrailing) {
                TabView(
                    selection: $store.composition.currentPageIndex.sending(\.setPage)
                ) {
                    ForEach(store.composition.pages, id: \.self) { page in
                        switch page {
                        case .start:
                            OnboardingStartView()
                                .tag(0)
                        case .legalInfo:
                            OnboardingLegalInfoView(isAllAccepted: $store.legalConfirmed.sending(\.setConfirmLegal),
                                                    showTermsOfUse: { store.send(.setShowUse(true)) },
                                                    showTermsOfPrivacy: { store.send(.setShowPrivacy(true)) },
                                                    action: { store.send(.nextPage, animation: .default) })
                                .tag(1)
                        case .registerAuthentication:
                            OnboardingRegisterAuthenticationView(
                                store: store.scope(state: \.registerAuthenticationState,
                                                   action: \.registerAuthentication)
                            )
                            .tag(2)
                        case .analytics:
                            OnboardingAnalyticsView {
                                // [REQ:BSI-eRp-ePA:O.Purp_3#4] Callback triggers tracking alert
                                store.send(.showTracking)
                            }
                            .tag(3)
                        }
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
                    .accentColor(Colors.primary600)
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
                    .accentColor(Colors.primary600)
                    .navigationViewStyle(StackNavigationViewStyle())
                }
                .tabViewStyle(
                    PageTabViewStyle(indexDisplayMode: .never)
                )
                .indexViewStyle(
                    PageIndexViewStyle(backgroundDisplayMode: .never)
                )
                .background(Colors
                    .systemBackground)
                .alert($store.scope(state: \.alertState, action: \.alert))

                ZStack {
                    if store.isShowingNextButton {
                        OnboardingNextButton(isEnabled: true) {
                            store.send(
                                .nextPage,
                                animation: .default
                            )
                        }
                    }
                }
            }
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingContainer(
                store: .init(
                    initialState: OnboardingDomain.Dummies.state
                ) {
                    OnboardingDomain()
                }
            )

            OnboardingContainer(
                store: .init(
                    initialState: OnboardingDomain.Dummies.state
                ) {
                    OnboardingDomain()
                }
            )
            .preferredColorScheme(.dark)
        }
    }
}
