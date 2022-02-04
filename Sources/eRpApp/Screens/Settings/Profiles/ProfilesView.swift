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

import CasePaths
import ComposableArchitecture
import SwiftUI

struct ProfilesView: View {
    let store: ProfilesDomain.Store

    @ObservedObject
    private var viewStore: ViewStore<ProfilesDomain.State, ProfilesDomain.Action>

    init(store: ProfilesDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            ForEach(viewStore.profiles) { profile in
                Button(action: {
                    viewStore.send(.editProfile(profile))
                }, label: {
                    ProfileCell(profile: profile,
                                isSelected: profile.id == viewStore.selectedProfileId,
                                showAsNavigationLink: true)
                })
                    .accessibility(identifier: A11y.settings.profiles.stgBtnProfile)
            }
            #if ENABLE_DEBUG_VIEW
            Button(action: {
                viewStore.send(.addNewProfile)
            }, label: {
                HStack(spacing: 16) {
                    Image(systemName: SFSymbolName.plus)
                    Text(L10n.stgBtnAddProfile)
                }
                .font(.body.weight(.semibold))
                .accentColor(Colors.primary)
                .padding(.vertical, 8)
            })
                .accessibility(identifier: A11y.settings.profiles.stgBtnNewProfile)
            #endif
        }
    }
}

struct ProfilesView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section(
                    header: SectionHeaderView(
                        text: L10n.stgTxtHeaderProfiles,
                        a11y: A11y.settings.profiles.stgTxtHeaderProfiles
                    ).padding(.bottom, 8)
                ) {
                    ProfilesView(store: ProfilesDomain.Dummies.store)
                }
                .textCase(.none)
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}
