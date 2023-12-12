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

struct HorizontalProfileSelectionView: View {
    let store: HorizontalProfileSelectionDomain.Store
    let width = UIScreen.main.bounds.size.width * UIScreen.main.scale / UIScreen.main.nativeScale

    @ObservedObject var viewStore: ViewStoreOf<HorizontalProfileSelectionDomain>

    init(store: HorizontalProfileSelectionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewStore.profiles) { userProfile in
                    Button(
                        action: {
                            viewStore.send(.selectProfile(userProfile), animation: .default)
                        },
                        label: {
                            HorizontalProfileSelectionChipView(
                                userProfile: userProfile,
                                isSelected: viewStore.selectedProfileId == userProfile.id
                            )
                        }
                    )
                    .highPriorityGesture(LongPressGesture(minimumDuration: 1).onEnded { _ in
                        viewStore.send(.profileButtonLongPressed(userProfile))
                    })
                    .if(userProfile == viewStore.profiles.first) {
                        $0.tooltip(tooltip: MainViewTooltip.rename)
                    }
                    .frame(maxWidth: width * 0.4, alignment: .leading)
                }
                .accessibility(identifier: A11y.profileSelection.proBtnSelectionProfileRow)

                Button(action: {
                    viewStore.send(.showAddProfileView)
                }, label: {
                    Image(systemName: SFSymbolName.personCirclePlus)
                })
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Colors.backgroundNeutral)
                    .border(Colors.systemGray6, cornerRadius: 8)
                    .accessibility(identifier: A11y.profileSelection.proBtnSelectionAddProfile)
                    .tooltip(tooltip: MainViewTooltip.addProfile)

                Spacer()
            }
            .padding(.vertical)
            .padding(.horizontal)
            .task {
                await viewStore.send(.registerListener).finish()
            }
        }
        .highPriorityGesture(DragGesture())
        .background(Colors.systemBackground)
    }
}

struct HorizontalProfileSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalProfileSelectionView(store: HorizontalProfileSelectionDomain.Dummies.store)
    }
}
