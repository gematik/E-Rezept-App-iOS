//
//  Copyright (c) 2021 gematik GmbH
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

/// Root screen for the CardWall. Glues screen display order for the given state with the actual views.
/// See `CardWallRoute`.
struct CardWallView: View {
    let store: CardWallDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, CardWallDomain.Action>

    init(store: CardWallDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let introAlreadyDisplayed: Bool
        let isNFCCapable: Bool
        let isCanAvailable: Bool

        init(state: CardWallDomain.State) {
            introAlreadyDisplayed = state.introAlreadyDisplayed
            isNFCCapable = state.isCapable
            isCanAvailable = state.canAvailable
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewStore.introAlreadyDisplayed {
                    afterIntroductionView()
                } else {
                    CardWallIntroductionView(
                        store: store.scope(
                            state: \.introduction,
                            action: CardWallDomain.Action.introduction(action:)
                        )
                    ) {
                        afterIntroductionView()
                    }
                }
            }
        }
    }

    @ViewBuilder
    func afterIntroductionView() -> some View {
        if !viewStore.isNFCCapable {
            CapabilitiesView(store: store)
        } else {
            if viewStore.isCanAvailable {
                pinView()
            } else {
                canView()
            }
        }
    }

    @ViewBuilder
    func canView() -> some View {
        IfLetStore(
            store.scope(
                state: \.can,
                action: CardWallDomain.Action.canAction(action:)
            )
        ) { canStore in
            CardWallCANView(store: canStore) {
                pinView()
            }
        }
    }

    @ViewBuilder
    func pinView() -> some View {
        CardWallPINView(
            store: store.scope(
                state: \.pin,
                action: CardWallDomain.Action.pinAction(action:)
            )
        ) { _ in
            loginOptionView()
        }
    }

    @ViewBuilder
    func loginOptionView() -> some View {
        CardWallLoginOptionView(
            store: store.scope(
                state: \.loginOption,
                action: CardWallDomain.Action.loginOption(action:)
            )
        ) {
            readCardView()
        }
    }

    @ViewBuilder
    func readCardView() -> some View {
        IfLetStore(
            store.scope(
                state: \.readCard,
                action: CardWallDomain.Action.readCard(action:)
            )
        ) { store in
            CardWallReadCardView(store: store)
        }
    }
}

struct CardWall_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardWallView(
                store: CardWallDomain.Dummies.storeFor(
                    CardWallDomain.State(
                        introAlreadyDisplayed: false,
                        isNFCReady: true,
                        isMinimalOS14: true,
                        can: CardWallCANDomain.Dummies.state,
                        pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                        loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
                    )
                )
            )
            CardWallView(
                store: CardWallDomain.Dummies.storeFor(
                    CardWallDomain.State(
                        introAlreadyDisplayed: true,
                        isNFCReady: false,
                        isMinimalOS14: true,
                        can: CardWallCANDomain.Dummies.state,
                        pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                        loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
                    )
                )
            )
            CardWallView(
                store: CardWallDomain.Dummies.storeFor(
                    CardWallDomain.State(
                        introAlreadyDisplayed: true,
                        isNFCReady: true,
                        isMinimalOS14: true,
                        can: CardWallCANDomain.Dummies.state,
                        pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                        loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
                    )
                )
            )
            CardWallView(
                store: CardWallDomain.Dummies.storeFor(
                    CardWallDomain.State(
                        introAlreadyDisplayed: true,
                        isNFCReady: true,
                        isMinimalOS14: true,
                        can: nil,
                        pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
                        loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
                    )
                )
            )
        }
    }
}
