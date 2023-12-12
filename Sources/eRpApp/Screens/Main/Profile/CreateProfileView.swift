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

struct CreateProfileView: View {
    let store: CreateProfileDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, CreateProfileDomain.Action>

    init(store: CreateProfileDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isValidName: Bool
        var profileName: String

        init(state: CreateProfileDomain.State) {
            isValidName = state.isValidName
            profileName = state.profileName
        }
    }

    var body: some View {
        EnterProfileNameSubView(
            displayName: viewStore.binding(
                get: \.profileName,
                send: CreateProfileDomain.Action.set(profileName:)
            ),
            didTapButtonAction: { viewStore.send(.createAndSaveProfile(name: viewStore.profileName)) },
            validating: { name in
                !name.trimmed().isEmpty
            }
        )
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateProfileView(store: CreateProfileDomain.Dummies.store)
                .previewDevice("iPhone 11")

            CreateProfileView(store: CreateProfileDomain.Dummies.store)
                .previewDevice("iPhone 13 Pro")

            CreateProfileView(store: CreateProfileDomain.Dummies.store)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
