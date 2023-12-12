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

// TODO: do we actually need this //swiftlint:disable:this todo
struct IDPCardWallView: View {
    let store: IDPCardWallDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, IDPCardWallDomain.Action>

    init(store: IDPCardWallDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isCanAvailable: Bool

        init(with state: IDPCardWallDomain.State) {
            isCanAvailable = state.canAvailable
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if viewStore.isCanAvailable {
                    pinView()
                } else {
                    canView()
                }
            }
            .background(Color(.systemBackground))
            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
            .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
        }
    }

    @ViewBuilder func canView() -> some View {
        IfLetStore(canStore) { store in
            CardWallCANView(store: store)
        }
    }

    private var canStore: Store<CardWallCANDomain.State?, CardWallCANDomain.Action> {
        store.scope(
            state: \.can,
            action: IDPCardWallDomain.Action.canAction(action:)
        )
    }

    @ViewBuilder func pinView() -> some View {
        CardWallPINView(store: pinStore)
    }

    private var pinStore: Store<CardWallPINDomain.State, CardWallPINDomain.Action> {
        store.scope(
            state: \.pin,
            action: IDPCardWallDomain.Action.pinAction(action:)
        )
    }

    @ViewBuilder func readCardView() -> some View {
        IfLetStore(readCardStore) { store in
            CardWallReadCardView(store: store)
        }
    }

    private var readCardStore: Store<CardWallReadCardDomain.State?, CardWallReadCardDomain.Action> {
        store.scope(
            state: \.readCard,
            action: IDPCardWallDomain.Action.readCard(action:)
        )
    }
}

struct IDPCardWallView_Preview: PreviewProvider {
    static var previews: some View {
        IDPCardWallView(store: IDPCardWallDomain.Dummies.store)
    }
}
