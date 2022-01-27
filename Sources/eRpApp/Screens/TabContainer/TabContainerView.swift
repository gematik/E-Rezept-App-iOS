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

import Combine
import ComposableArchitecture
import eRpLocalStorage
import SwiftUI

struct TabContainerView: View {
    let store: AppDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, AppDomain.Action>

    init(store: AppDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let selectedTab: AppDomain.Tab
        let unreadMessagesCount: Int

        init(state: AppDomain.State) {
            selectedTab = state.selectedTab
            unreadMessagesCount = state.unreadMessagesCount
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            #if ENABLE_DEBUG_VIEW
            DebugEnvironmentView()
                .offset(x: 0, y: -12)
                .zIndex(1000)
            #endif

            TabView(selection: Binding<AppDomain.Tab>(
                get: { viewStore.selectedTab },
                set: { selected in
                    viewStore.send(.selectTab(selected))
                }
            )) {
                MainView(
                    store: store.scope(state: \.main,
                                       action: AppDomain.Action.main(action:))
                )
                .tabItem {
                    Image(Asset.TabIcon.appLogoTabItem)
                        .accessibility(hidden: true)
                    Text(L10n.tabTxtMain)
                }
                .tag(AppDomain.Tab.main)

                MessagesView(
                    store: store.scope(state: \.messages,
                                       action: AppDomain.Action.messages(action:))
                )
                .tabItem {
                    Image(Asset.TabIcon.bubbleLeft)
                        .accessibility(hidden: true)
                    Text(L10n.tabTxtMessages)
                }
                .tag(AppDomain.Tab.messages)
            }
            .onAppear {
                viewStore.send(.registerDemoModeListener)
                viewStore.send(.registerUnreadMessagesListener)
            }
            .accentColor(Colors.primary700)
            .zIndex(0)

            if viewStore.unreadMessagesCount > 0 {
                MessagesBadgeView(badgeCount: viewStore.unreadMessagesCount)
            }
        }
    }

    struct MessagesBadgeView: View {
        let badgeCount: Int
        var body: some View {
            GeometryReader { geometry in
                Text(" \(badgeCount) ")
                    .foregroundColor(Colors.systemColorWhite)
                    .font(Font.system(size: 12))
                    .bold()
                    .padding(2)
                    .background(Colors.red600)
                    .cornerRadius(16)
                    .offset(x: 3 * geometry.size.width / 4, y: geometry.size.height - 33)
            }.ignoresSafeArea(.keyboard) // prevent badge from floating when keyboard appears
        }
    }
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabContainerView(store: AppDomain.Dummies.store)
            TabContainerView(store: AppDomain.Dummies.store)
                .preferredColorScheme(.dark)
        }
    }
}
