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

struct OnboardingContainer: View, KeyboardReadable {
    let store: Store<OnboardingDomain.State, OnboardingDomain.Action>

    @ObservedObject
    var viewStore: ViewStore<ViewState, OnboardingDomain.Action>
    @State var isKeyboardVisible = false

    init(store: Store<OnboardingDomain.State, OnboardingDomain.Action>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let composition: OnboardingDomain.Composition
        let isShowingNextButton: Bool
        let hasValidAuthenticationSelection: Bool

        init(state: OnboardingDomain.State) {
            composition = state.composition
            isShowingNextButton = state.isShowingNextButton
            hasValidAuthenticationSelection = state.registerAuthenticationState.hasValidSelection
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
                if viewStore.composition.pages.contains(.altRegisterAuthentication) {
                    // [REQ:gemSpec_BSI_FdV:A_20834] view to register authentication in onboarding process
                    OnboardingAltRegisterAuthenticationView(
                        store: store.scope(state: { $0.registerAuthenticationState },
                                           action: { .registerAuthentication(action: $0) })
                    )
                    .tag(0)

                } else {
                    OnboardingStartView()
                        .tag(0)

                    OnboardingLegalInfoView {
                        viewStore.send(.nextPage, animation: .default)
                    }
                    .tag(1)
                    .contentShape(Rectangle())
                    .gesture(DragGesture())

                    // [REQ:gemSpec_BSI_FdV:A_20834] view to register authentication in onboarding process
                    OnboardingRegisterAuthenticationView(
                        store: store.scope(state: { $0.registerAuthenticationState },
                                           action: { .registerAuthentication(action: $0) })
                    )
                    .contentShape(Rectangle())
                    .gesture(viewStore.hasValidAuthenticationSelection ? nil : DragGesture())
                    .tag(2)

                    OnboardingAnalyticsView {
                        viewStore.send(.showTrackingAlert)
                    }
                    .tag(3)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Colors.systemBackground)
            .alert(store.scope(state: \.alertState), dismiss: .dismissAlert)

            ZStack {
                if viewStore.isShowingNextButton {
                    OnboardingNextButton(isEnabled: true) {
                        // Due to a bug in iOS < 14.5 the keyboard animation somehow breaks
                        // the page animation. For that we close the keyboard on first touch and
                        // animate to the next page only if there is no keyboard on screen
                        if isKeyboardVisible {
                            UIApplication.shared.dismissKeyboard()
                        } else {
                            viewStore.send(
                                .nextPage,
                                animation: Animation.default
                            )
                        }
                    }
                }
            }
            .onReceive(keyboardPublisher) { isKeyboardVisible in
                self.isKeyboardVisible = isKeyboardVisible
            }
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingContainer(store: .init(
                initialState: OnboardingDomain.Dummies.state,
                reducer: OnboardingDomain()
            ))
            OnboardingContainer(store: .init(
                initialState: OnboardingDomain.Dummies.state,
                reducer: OnboardingDomain()
            ))
                .preferredColorScheme(.dark)
        }
    }
}
