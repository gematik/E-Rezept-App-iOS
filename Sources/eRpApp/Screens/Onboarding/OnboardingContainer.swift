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
    @State private var offsetValue: CGSize = .zero
    @State private var isShowingNextButton = false

    init(store: Store<OnboardingDomain.State, OnboardingDomain.Action>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Colors.primary500)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Colors.systemLabelQuarternary)
        UIScrollView.appearance().bounces = false
    }

    var body: some View {
        WithViewStore(store) { viewStore in

            ZStack(alignment: .bottomTrailing) {
                if viewStore.onboardingVisible {
                    TabView(
                        selection: viewStore.binding(
                            get: { $0.page },
                            send: OnboardingDomain.Action.setPage(page:)
                        )
                    ) {
                        OnboardingStartView { withAnimation { viewStore.send(.nextPage) } }
                            .tag(OnboardingDomain.State.Page.start)
                        OnboardingWelcomeView { withAnimation { viewStore.send(.nextPage) } }
                            .tag(OnboardingDomain.State.Page.welcome)
                        OnboardingFeaturesView { withAnimation { viewStore.send(.nextPage) } }
                            .tag(OnboardingDomain.State.Page.features)
                        OnboardingLegalInfoView { withAnimation { viewStore.send(.dismissOnboarding) } }
                            .tag(OnboardingDomain.State.Page.legalInfo)
                    }
                    .background(Colors.systemBackground)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

                    ZStack {
                        if viewStore.state.isShowingNextButton {
                            OnboardingNextButton {
                                withAnimation { viewStore.send(.nextPage) }
                            }
                        }
                    }
                    .animation(.easeInOut)
                }
            }
        }
    }
}
