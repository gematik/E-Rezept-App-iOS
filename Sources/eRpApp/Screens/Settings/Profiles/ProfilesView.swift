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
import eRpStyleKit
import SwiftUI

struct ProfilesView: View {
    let store: ProfilesDomain.Store

    @ObservedObject
    private var viewStore: ViewStore<ViewState, ProfilesDomain.Action>

    init(store: ProfilesDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let profiles: [UserProfile]
        let selectedProfileId: UUID?
        init(state: ProfilesDomain.State) {
            profiles = state.profiles
            selectedProfileId = state.selectedProfileId
        }
    }

    var body: some View {
        SectionContainer(header: {
            Label(title: {
                Text(L10n.stgTxtHeaderProfiles)
            }, icon: {})
                .accessibility(identifier: A11y.settings.profiles.stgTxtHeaderProfiles)
        }, content: {
            ForEach(viewStore.profiles) { profile in
                Button(action: {
                    viewStore.send(.editProfile(profile))
                }, label: {
                    SingleProfileView(profile: profile, selectedProfileId: viewStore.selectedProfileId)
                })
                    .buttonStyle(.navigation)
                    .accessibility(identifier: A11y.settings.profiles.stgBtnProfile)
            }

            #if ENABLE_DEBUG_VIEW
            Button(action: {
                viewStore.send(.addNewProfile)
            }, label: {
                Label(L10n.stgBtnAddProfile, systemImage: SFSymbolName.plus)
            })
                .buttonStyle(.simple(showSeparator: false))
                .accessibility(identifier: A11y.settings.profiles.stgBtnNewProfile)
            #else
            EmptyView()
            #endif
        })
            .onAppear {
                viewStore.send(.registerListener)
            }
            .onDisappear {
                viewStore.send(.unregisterListener)
            }
    }

    private struct SingleProfileView: View {
        let profile: UserProfile
        let selectedProfileId: UUID?

        var body: some View {
            Label(title: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                    Group {
                        if let date = profile.lastSuccessfulSync {
                            RelativeTimerView(date: date)

                        } else {
                            Text(L10n.ctlTxtProfileCellNotConnected)
                        }
                    }
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.subheadline)
                }
            }, icon: {
                InitialsImage(backgroundColor: profile.color.background,
                              text: profile.emoji ?? profile.acronym,
                              size: .large)
            })
        }
    }
}

struct ProfilesView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfilesView(store: ProfilesDomain.Dummies.store)
        }.background(Color(.secondarySystemBackground).ignoresSafeArea())
    }
}
