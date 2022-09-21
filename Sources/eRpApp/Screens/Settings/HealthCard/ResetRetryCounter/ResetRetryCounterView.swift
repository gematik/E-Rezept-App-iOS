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

/// Root screen for the Reset Retry Counter views
struct ResetRetryCounterView: View {
    let store: ResetRetryCounterDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, ResetRetryCounterDomain.Action>

    init(store: ResetRetryCounterDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: ResetRetryCounterDomain.Route.Tag

        init(state: ResetRetryCounterDomain.State) {
            routeTag = state.route.tag
        }
    }

    var body: some View {
        ResetRetryCounterIntroductionView(store: store)
            .fullScreenCover(
                isPresented: Binding<Bool>(
                    get: { viewStore.routeTag == .readCard },
                    set: { _ in } // is handled by store
                )
            ) {
                IfLetStore(store.scope(
                    state: (\ResetRetryCounterDomain.State.route)
                        .appending(path: /ResetRetryCounterDomain.Route.readCard)
                        .extract(from:),
                    action: ResetRetryCounterDomain.Action.readCard(action:)

                ),
                then: ResetRetryCounterReadCardView.init(store:))
            }
    }
}

struct ResetRetryCounterView_Previews: PreviewProvider {
    static var previews: some View {
        ResetRetryCounterView(
            store: ResetRetryCounterDomain.Dummies.store
        )
    }
}
