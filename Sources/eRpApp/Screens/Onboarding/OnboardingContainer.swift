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
    let store: Store<OnboardingDomain.State, OnboardingDomain.Action>

    @ObservedObject var viewStore: ViewStore<ViewState, OnboardingDomain.Action>
    @State var isKeyboardVisible = false

    init(store: Store<OnboardingDomain.State, OnboardingDomain.Action>) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let composition: OnboardingDomain.Composition
        let isShowingNextButton: Bool
        let hasValidAuthenticationSelection: Bool
        let legalConfirmed: Bool
        let showTermsOfPrivacy: Bool
        let showTermsOfUse: Bool

        init(state: OnboardingDomain.State) {
            composition = state.composition
            isShowingNextButton = state.isShowingNextButton
            hasValidAuthenticationSelection = state.registerAuthenticationState.hasValidSelection
            legalConfirmed = state.legalConfirmed
            showTermsOfPrivacy = state.showTermsOfPrivacy
            showTermsOfUse = state.showTermsOfUse
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(
                selection: viewStore.binding(
                    get: { $0.composition.currentPageIndex },
                    send: OnboardingDomain.Action.setPage(index:)
                )
            ) {
                ForEach(viewStore.composition.pages, id: \.self) { page in
                    switch page {
                    case .start:
                        OnboardingStartView()
                            .tag(0)
                    case .legalInfo:
                        OnboardingLegalInfoView(isAllAccepted: viewStore.binding(get: \.legalConfirmed,
                                                                                 send: OnboardingDomain.Action
                                                                                     .setConfirmLegal),
                                                showTermsOfUse: { viewStore.send(.setShowUse(true)) },
                                                showTermsOfPrivacy: { viewStore.send(.setShowPrivacy(true)) },
                                                action: { viewStore.send(.nextPage, animation: .default) })
                            .tag(1)
                    case .registerAuthentication:
                        OnboardingRegisterAuthenticationView(
                            store: store.scope(state: { $0.registerAuthenticationState },
                                               action: { .registerAuthentication(action: $0) })
                        )
                        .tag(2)
                    case .analytics:
                        OnboardingAnalyticsView {
                            // [REQ:BSI-eRp-ePA:O.Purp_3#4] Callback triggers tracking alert
                            viewStore.send(.showTracking)
                        }
                        .tag(3)
                    }
                }
            }
            // [REQ:BSI-eRp-ePA:O.Arch_9#2] DataPrivacy display within Onboarding
            .sheet(isPresented: viewStore.binding(get: \.showTermsOfPrivacy,
                                                  send: OnboardingDomain.Action.setShowPrivacy)) {
                NavigationView {
                    DataPrivacyView()
                        .toolbar {
                            CloseButton { viewStore.send(.setShowPrivacy(false)) }
                                .embedToolbarContent()
                                .accessibilityIdentifier(A11y.settings.dataPrivacy.stgBtnDataPrivacyClose)
                        }
                }
                .accentColor(Colors.primary600)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            // [REQ:BSI-eRp-ePA:O.Purp_3#1] Terms of Use display is part of the onboarding
            .sheet(isPresented: viewStore.binding(get: \.showTermsOfUse,
                                                  send: OnboardingDomain.Action.setShowUse)) {
                NavigationView {
                    TermsOfUseView()
                        .toolbar {
                            CloseButton { viewStore.send(.setShowUse(false)) }
                                .embedToolbarContent()
                                .accessibilityIdentifier(A11y.settings.termsOfUse.stgBtnTermsOfUseClose)
                        }
                }
                .accentColor(Colors.primary600)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Colors.systemBackground)
            .alert(store: store.scope(state: \.$alertState, action: OnboardingDomain.Action.alert))

            ZStack {
                if viewStore.isShowingNextButton {
                    OnboardingNextButton(isEnabled: true) {
                        viewStore.send(
                            .nextPage,
                            animation: .default
                        )
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
