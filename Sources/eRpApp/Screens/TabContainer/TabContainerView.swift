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
        let unreadOrderMessageCount: Int

        init(state: AppDomain.State) {
            selectedTab = state.selectedTab
            unreadOrderMessageCount = state.unreadOrderMessageCount
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
                                       action: AppDomain.Action.main(action:)),
                    profileSelectionToolbarItemStore: store.scope(state: \.profileSelection,
                                                                  action: AppDomain.Action.profile(action:))
                )
                .tabItem {
                    Label(L10n.tabTxtMain, image: Asset.TabIcon.appLogoTabItem.name)
                }
                .tag(AppDomain.Tab.main)

                NavigationView {
                    PharmacySearchView(
                        store: store.scope(
                            state: \.pharmacySearch,
                            action: AppDomain.Action.pharmacySearch(action:)
                        ),
                        profileSelectionToolbarItemStore: store.scope(state: \.profileSelection,
                                                                      action: AppDomain.Action.profile(action:)),
                        isRedeemRecipe: false
                    )
                }
                .tabItem {
                    Label(L10n.tabTxtPharmacySearch, image: Asset.TabIcon.mapPinAndEllipse.name)
                }
                .tag(AppDomain.Tab.pharmacySearch)

                OrdersView(
                    store: store.scope(state: \.orders,
                                       action: AppDomain.Action.orders(action:)),
                    profileSelectionToolbarItemStore: store.scope(state: \.profileSelection,
                                                                  action: AppDomain.Action.profile(action:))
                )
                .tabItem {
                    Label(L10n.tabTxtOrders, image: Asset.TabIcon.bag.name)
                }
                .backport.badge(viewStore.unreadOrderMessageCount)
                .tag(AppDomain.Tab.orders)

                #if ENABLE_DEBUG_VIEW
                SettingsView(
                    store: store.scope(
                        state: \.settingsState,
                        action: AppDomain.Action.settings(action:)
                    ),
                    debugStore: store.scope(
                        state: \.debug,
                        action: AppDomain.Action.debug(action:)
                    )
                )
                .tabItem {
                    Label(L10n.tabTxtSettings, image: Asset.TabIcon.gearshape.name)
                }
                .tag(AppDomain.Tab.settings)
                #else
                SettingsView(
                    store: store.scope(
                        state: \.settingsState,
                        action: AppDomain.Action.settings(action:)
                    )
                )
                .tabItem {
                    Label(L10n.tabTxtSettings, image: Asset.TabIcon.gearshape.name)
                }
                .tag(AppDomain.Tab.settings)
                #endif
            }
            .onAppear {
                viewStore.send(.registerDemoModeListener)
                viewStore.send(.registerNewOrderMessageListener)
                viewStore.send(.profile(action: .registerProfileListener))
            }
            // Fix tabbar background becomming 100% transparent for dynamic views, in our case using quick filters
            // within pharmacy search
            // Source: https://www.hackingwithswift.com/forums/ios/tab-bar-transparent/10549
            .onAppear {
                if #available(iOS 15.0, *) {
                    // correct the transparency bug for Tab bars
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithOpaqueBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
            }
            .onDisappear {
                viewStore.send(.profile(action: .unregisterProfileListener))
            }
            .accentColor(Colors.primary600)
            .zIndex(0)

            if #unavailable(iOS 15.0), viewStore.unreadOrderMessageCount > 0 {
                MessagesBadgeView(badgeCount: viewStore.unreadOrderMessageCount)
            }
        }
    }

    struct MessagesBadgeView: View {
        private let tabNumber: CGFloat = 3
        private let tabCount: CGFloat = 4
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
                    .offset(x: (tabNumber * geometry.size.width / tabCount) - 40, y: geometry.size.height - 33)
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