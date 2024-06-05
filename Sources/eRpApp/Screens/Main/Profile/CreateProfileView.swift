//
//  Copyright (c) 2024 gematik GmbH
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
    @Perception.Bindable var store: StoreOf<CreateProfileDomain>

    var body: some View {
        WithPerceptionTracking {
            EnterProfileNameSubView(
                displayName: $store.profileName.sending(\.setProfileName),
                didTapButtonAction: { store.send(.createAndSaveProfile(name: store.profileName)) },
                validating: { name in
                    !name.trimmed().isEmpty
                }
            )
        }
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
