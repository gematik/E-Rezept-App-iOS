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

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct HorizontalProfileSelectionView: View {
    @Bindable var store: StoreOf<HorizontalProfileSelectionDomain>
    let width = UIScreen.main.bounds.size.width * UIScreen.main.scale / UIScreen.main.nativeScale

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(store.profiles) { userProfile in
                    HorizontalProfileSelectionChipView(
                        userProfile: userProfile,
                        isSelected: store.selectedProfileId == userProfile.id
                    )
                    .focusable()
                    .onTapGesture {
                        store.send(.selectProfile(userProfile), animation: .default)
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        store.send(.profileButtonLongPressed(userProfile))
                    }
                    .frame(maxWidth: width * 0.4, alignment: .leading)
                }

                Button(action: {
                    store.send(.showAddProfileView)
                }, label: {
                    Image(systemName: SFSymbolName.personCirclePlus)
                })
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Colors.backgroundNeutral)
                .border(Colors.systemGray6, cornerRadius: 8)
                .accessibilityIdentifier(A11y.profileSelection.proBtnSelectionAddProfile)
                .accessibilityLabel(L10n.mainBtnAddProfile)

                Spacer()
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11y.profileSelection.proBtnSelectionProfileRow)
            .padding()
            .task {
                await store.send(.registerListener).finish()
            }
        }
        .background(Colors.systemBackground)
    }
}

struct HorizontalProfileSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalProfileSelectionView(store: HorizontalProfileSelectionDomain.Dummies.store)
    }
}
