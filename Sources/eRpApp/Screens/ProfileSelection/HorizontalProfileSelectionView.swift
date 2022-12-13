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

import ComposableArchitecture
import SwiftUI

struct HorizontalProfileSelectionView: View {
    let store: HorizontalProfileSelectionDomain.Store
    let width = UIScreen.main.bounds.size.width * UIScreen.main.scale / UIScreen.main.nativeScale

    @ObservedObject
    var viewStore: ViewStore<HorizontalProfileSelectionDomain.State, HorizontalProfileSelectionDomain.Action>

    init(store: HorizontalProfileSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewStore.profiles) { profile in
                    Button(
                        action: {
                            viewStore.send(.selectProfile(profile), animation: .default)
                        },
                        label: {
                            HorizontalProfileSelectionView.ProfileCell(
                                profile: profile,
                                isSelected: viewStore.selectedProfileId == profile.id
                            )
                        }
                    )
                    .background(viewStore.selectedProfileId == profile.id ? Colors.systemGray6 : Colors
                        .systemBackgroundTertiary)
                    .border(viewStore.selectedProfileId == profile.id ? Colors.separator : Colors.systemGray6,
                            cornerRadius: 8)
                    .frame(maxWidth: width * 0.4, alignment: .leading)
                    .accessibilityRemoveTraits(.isStaticText)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAddTraits(profile.id == viewStore.selectedProfileId ? .isSelected : .isButton)
                    .accessibility(identifier: A11y.profileSelection.proBtnSelectionProfileEntry)
                }
                .accessibility(identifier: A11y.profileSelection.proBtnSelectionProfileRow)

                Button(action: {
                    viewStore.send(.showAddProfileView)
                }, label: {
                    Image(systemName: SFSymbolName.personCirclePlus)
                })
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Colors.backgroundNeutral)
                    .border(Colors.systemGray6, cornerRadius: 8)
                    .accessibility(identifier: A11y.profileSelection.proBtnSelectionAddProfile)
            }
            .padding(.vertical)
            .onAppear {
                viewStore.send(.registerListener)
            }
            .onDisappear {
                viewStore.send(.unregisterListener)
            }
        }
        .background(Colors.systemBackground)
    }
}

extension HorizontalProfileSelectionView {
    struct ProfileCell: View {
        let profile: UserProfile
        let isSelected: Bool

        init(profile: UserProfile, isSelected: Bool) {
            self.profile = profile
            self.isSelected = isSelected
        }

        var body: some View {
            HStack(alignment: .center) {
                Text(profile.name)
                    .foregroundColor(isSelected ? Colors.systemLabel : Colors.textSecondary)
                    .font(.body)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}
