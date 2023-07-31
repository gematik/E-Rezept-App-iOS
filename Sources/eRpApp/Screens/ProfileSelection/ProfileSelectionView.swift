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

struct ProfileSelectionView: View {
    let store: ProfileSelectionDomain.Store

    @ObservedObject var viewStore: ViewStore<ProfileSelectionDomain.State, ProfileSelectionDomain.Action>

    init(store: ProfileSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationView {
            List {
                Section(
                    footer: Button(action: {
                        viewStore.send(.editProfiles)
                    }, label: {
                        HStack {
                            Image(systemName: SFSymbolName.pencil)

                            Text(L10n.proBtnSelectionEdit)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Asset.Colors.primary600.color)
                    })
                        .accessibility(identifier: A11y.profileSelection.proBtnSelectionEdit)
                        .padding(.vertical, 16)
                ) {
                    ForEach(viewStore.profiles) { profile in
                        Button(action: {
                            viewStore.send(.selectProfile(profile), animation: .default)
                        }, label: {
                            ProfileSelectionView.ProfileCell(
                                profile: profile,
                                isSelected: profile.id == viewStore.selectedProfileId
                            )
                        })
                            .accessibilityRemoveTraits(.isStaticText)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAddTraits(profile.id == viewStore.selectedProfileId ? .isSelected : .isButton)
                            .accessibility(identifier: A11y.profileSelection.proTxtSelectionProfileListEntry)
                    }
                    .accessibility(identifier: A11y.profileSelection.proTxtSelectionProfileList)
                }
                .textCase(.none)
            }
            .introspectTableView { tableView in
                tableView.tableHeaderView = nil
                tableView.backgroundColor = UIColor.tertiarySystemBackground
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(L10n.proTxtSelectionTitle, displayMode: .inline)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
        }
        .onAppear {
            viewStore.send(.registerListener)
        }
    }
}

extension ProfileSelectionView {
    struct ProfileCell: View {
        let profile: ProfileCellModel

        let isSelected: Bool
        let showAsNavigationLink: Bool

        init(profile: ProfileCellModel, isSelected: Bool, showAsNavigationLink: Bool = false) {
            self.profile = profile
            self.isSelected = isSelected
            self.showAsNavigationLink = showAsNavigationLink
        }

        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                Circle()
                    .strokeBorder(profile.color.border, lineWidth: isSelected ? 2 : 0)
                    .frame(width: 32, height: 32, alignment: .center)
                    .background(Circle().fill(profile.color.background))
                    .overlay(
                        Text(profile.acronym)
                            .font(.system(size: 13).weight(.bold))
                            .foregroundColor(Color(.secondaryLabel))
                    )

                VStack(alignment: .leading, spacing: 0) {
                    Text(profile.name)
                        .foregroundColor(Color(.label))
                        .font(.body)

                    if let date = profile.lastSuccessfulSync {
                        RelativeTimerView(date: date)
                            .foregroundColor(Color(.secondaryLabel))
                            .font(.caption)
                    } else {
                        Text(L10n.ctlTxtProfileCellNotConnected)
                            .foregroundColor(Color(.secondaryLabel))
                            .font(.caption)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)

                if showAsNavigationLink {
                    Image(systemName: SFSymbolName.chevronForward)
                        .foregroundColor(Color(.tertiaryLabel))
                        .font(.body.weight(.semibold))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct ProfileSelectionView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("abc")
        }
        .sheet(isPresented: .constant(true)) {
            ProfileSelectionView(store: ProfileSelectionDomain.Dummies.store)
        }
    }
}
