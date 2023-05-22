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
import eRpStyleKit
import SwiftUI

struct HealthCardSectionView: View {
    let store: SettingsDomain.Store

    @ObservedObject
    var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let destinationTag: SettingsDomain.Destinations.State.Tag?

        init(state: SettingsDomain.State) {
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        SectionContainer(
            header: {
                Text(L10n.stgTxtCardSectionHeader)
            },
            content: {
                // Destination: "Order health card"
                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.egk,
                            action: SettingsDomain.Destinations.Action.egkAction
                        ),
                        then: OrderHealthCardListView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.egk,
                    selection: viewStore.binding(
                        get: \.destinationTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardOrderNewCard, systemImage: SFSymbolName.cardIcon)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardOrderNewCard)
                .buttonStyle(.navigation)

                // Destination: "Forgot PIN"
                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.healthCardPasswordForgotPin,
                            action: SettingsDomain.Destinations.Action.healthCardPasswordForgotPinAction
                        ),
                        then: HealthCardPasswordView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.healthCardPasswordForgotPin,
                    selection: viewStore.binding(
                        get: \.destinationTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardForgotPin, systemImage: SFSymbolName.questionmarkCircle)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardForgotPin)
                .buttonStyle(.navigation)

                // Destination: "Set a custom PIN"
                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.healthCardPasswordSetCustomPin,
                            action: SettingsDomain.Destinations.Action.healthCardPasswordSetCustomPinAction
                        ),
                        then: HealthCardPasswordView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.healthCardPasswordSetCustomPin,
                    selection: viewStore.binding(
                        get: \.destinationTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardCustomPin, systemImage: SFSymbolName.cardIconAnd123)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardCustomPin)
                .buttonStyle(.navigation)

                // Destination: "Unlock health card"
                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /SettingsDomain.Destinations.State.healthCardPasswordUnlockCard,
                            action: SettingsDomain.Destinations.Action.healthCardPasswordUnlockCardAction
                        ),
                        then: HealthCardPasswordView.init(store:)
                    ),
                    tag: SettingsDomain.Destinations.State.Tag.healthCardPasswordUnlockCard,
                    selection: viewStore.binding(
                        get: \.destinationTag,
                        send: SettingsDomain.Action.setNavigation
                    )
                ) {
                    Label(L10n.stgTxtCardUnlockCard, systemImage: SFSymbolName.lockRotation)
                }
                .accessibility(identifier: A11y.settings.card.stgTxtCardUnlockCard)
                .buttonStyle(.navigation)
            }
        )
    }
}

struct HealthCardSectionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardSectionView(store: SettingsDomain.Dummies.store)
    }
}
