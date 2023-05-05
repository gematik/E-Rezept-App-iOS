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

struct EditProfileNameView: View {
    let store: EditProfileNameDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, EditProfileNameDomain.Action>

    init(store: EditProfileNameDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        var profileName: String

        init(state: EditProfileNameDomain.State) {
            profileName = state.profileName
        }
    }

    var body: some View {
        EnterProfileNameSubView(
            displayName: viewStore.binding(
                get: \.profileName,
                send: EditProfileNameDomain.Action.set(profileName:)
            ),
            didTapButtonAction: ({ viewStore.send(.saveButtonTapped) })
        )
    }
}

struct EditProfileNameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditProfileNameView(store: EditProfileNameDomain.Dummies.store)
                .previewDevice("iPhone 11")

            EditProfileNameView(store: EditProfileNameDomain.Dummies.store)
                .previewDevice("iPhone 13 Pro")

            EditProfileNameView(store: EditProfileNameDomain.Dummies.store)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
