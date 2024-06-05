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

// TODO: do we actually need this //swiftlint:disable:this todo
struct IDPCardWallView: View {
    @Perception.Bindable var store: StoreOf<IDPCardWallDomain>

    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                VStack(alignment: .leading) {
                    if let store = store.scope(state: \.subdomain, action: \.subdomain) {
                        switch store.case {
                        case let .can(store):
                            CardWallCANView(store: store)
                        case let .pin(store):
                            CardWallPINView(store: store)
                        case let .readCard(store):
                            CardWallReadCardView(store: store)
                        }
                    }
                }
            }
            .task {
                await store.send(.task).finish()
            }
            .background(Color(.systemBackground))
            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
            .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
        }
    }
}

struct IDPCardWallView_Preview: PreviewProvider {
    static var previews: some View {
        IDPCardWallView(store: IDPCardWallDomain.Dummies.store)
    }
}
