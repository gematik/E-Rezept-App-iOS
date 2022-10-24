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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

/// Root screen for the HealthCardPassword views
struct HealthCardPasswordView: View {
    let store: HealthCardPasswordDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, HealthCardPasswordDomain.Action>

    init(store: HealthCardPasswordDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: HealthCardPasswordDomain.Route.Tag

        init(state: HealthCardPasswordDomain.State) {
            routeTag = state.route.tag
        }
    }

    var body: some View {
        HealthCardPasswordIntroductionView(store: store)
            .fullScreenCover(
                isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .readCard },
                    set: { _ in } // is handled by store
                )
            ) {
                IfLetStore(store.scope(
                    state: (\HealthCardPasswordDomain.State.route)
                        .appending(path: /HealthCardPasswordDomain.Route.readCard)
                        .extract(from:),
                    action: HealthCardPasswordDomain.Action.readCard(action:)

                ),
                then: HealthCardPasswordReadCardView.init(store:))
            }
    }
}

struct HealthCardPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardPasswordView(
            store: HealthCardPasswordDomain.Dummies.store
        )
    }
}
