//
//  Copyright (c) 2021 gematik GmbH
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

struct OnboardingContainer: View {
    let store: Store<OnboardingDomain.State, OnboardingDomain.Action>

    init(store: Store<OnboardingDomain.State, OnboardingDomain.Action>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Colors.primary500)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Colors.systemLabelQuarternary)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                TabView(
                    selection: viewStore.binding(
                        get: { $0.composition.currentPageIndex },
                        send: OnboardingDomain.Action.setPage(index:)
                    )
                ) {
                    if viewStore.composition.pages.contains(.altRegisterAuthentication) {
                        // [REQ:gemSpec_BSI_FdV:A_20834] view to register authentication in onboarding process
                        OnboardingAltRegisterAuthenticationView(
                            store: store.scope(state: { $0.registerAuthenticationState },
                                               action: { .registerAuthentication(action: $0) })
                        )
                        .gesture(viewStore.isDragEnabled ? nil : DragGesture())
                        .tag(0)
                    } else {
                        OnboardingStartView()
                            .tag(0)
                        OnboardingWelcomeView()
                            .tag(1)
                        OnboardingFeaturesView()
                            .tag(2)
                        // [REQ:gemSpec_BSI_FdV:A_20834] view to register authentication in onboarding process
                        OnboardingRegisterAuthenticationView(
                            store: store.scope(state: { $0.registerAuthenticationState },
                                               action: { .registerAuthentication(action: $0) })
                        )
                        .gesture(viewStore.isDragEnabled ? nil : DragGesture())
                        .tag(3)

                        OnboardingLegalInfoView { withAnimation { viewStore.send(.saveAuthentication) } }
                            .tag(4)
                    }
                }
                .background(Colors.systemBackground)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: viewStore.isDragEnabled ? .always : .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: viewStore.isDragEnabled ? .always : .never))

                ZStack {
                    if viewStore.state.isShowingNextButton {
                        OnboardingNextButton(isEnabled: viewStore.state.isNextButtonEnabled) {
                            withAnimation { viewStore.send(.nextPage) }
                        }
                    }
                }
                .animation(.easeInOut)
            }
        }
    }
}
