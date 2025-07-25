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

import Combine
import ComposableArchitecture
import eRpLocalStorage
import eRpStyleKit
import SwiftUI

struct TabContainerView: View {
    @Perception.Bindable var store: StoreOf<AppDomain>

    @Shared(.appDefaults) var appDefaults

    var settingsBadge: String? {
        if appDefaults.diga.hasRedeemdADiga,
           !appDefaults.diga.hasSeenDigaSurvery {
            return L10n.stgConTextDigaSurveyBadge.text
        }
        return nil
    }

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .top) {
                #if ENABLE_DEBUG_VIEW
                DebugEnvironmentView()
                    .offset(x: 0, y: -12)
                    .zIndex(1000)
                #endif

                TabView(selection: $store.destination.sending(\.setNavigation)) {
                    Group {
                        MainView(store: store.scope(state: \.main, action: \.main))
                            .tabItem {
                                Label(L10n.tabTxtMain, image: Asset.TabIcon.appLogoTabItem.name)
                            }
                            .tag(AppDomain.Destinations.State.main)

                        PharmacyContainerView(
                            store: store.scope(
                                state: \.pharmacy,
                                action: \.pharmacy
                            )
                        )
                        .tabItem {
                            Label(L10n.tabTxtPharmacySearch, image: Asset.TabIcon.mapPinAndEllipse.name)
                        }
                        .tag(AppDomain.Destinations.State.pharmacy)

                        OrdersView(store: store.scope(state: \.orders, action: \.orders))
                            .tabItem {
                                Label(L10n.tabTxtMessages, image: Asset.TabIcon.message.name)
                            }
                            .badge(store.unreadMessageCount)
                            .tag(AppDomain.Destinations.State.orders)

                        SettingsView(
                            store: store.scope(state: \.settings, action: \.settings)
                        )
                        .tabItem {
                            Label(L10n.tabTxtSettings, image: Asset.TabIcon.gearshape.name)
                        }
                        .badge(settingsBadge)
                        .tag(AppDomain.Destinations.State.settings)
                    }
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Colors.tabViewToolBarBackground, for: .tabBar)
                }
                .task {
                    await store.send(.task).finish()
                }
                .tint(Colors.primary700)
                .zIndex(0)
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
