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
import eRpStyleKit
import SwiftUI

struct HealthCardSectionView: View {
    @Perception.Bindable var store: StoreOf<SettingsDomain>

    var body: some View {
        WithPerceptionTracking {
            SectionContainer(
                header: {
                    Text(L10n.stgTxtCardSectionHeader)
                },
                content: {
                    NavigationLink(
                        item: $store.scope(
                            state: \.destination?.egk,
                            action: \.destination.egk
                        ),
                        onTap: { store.send(.tappedEgk) },
                        destination: { store in OrderHealthCardListView(store: store) },
                        label: {
                            Label(L10n.stgTxtCardOrderNewCard, systemImage: SFSymbolName.cardIcon)
                        }
                    )
                    .accessibility(identifier: A11y.settings.card.stgTxtCardOrderNewCard)
                    .buttonStyle(.navigation)

                    // Destination: "Forgot PIN"
                    NavigationLink(
                        item: $store.scope(state: \.destination?.healthCardPasswordForgotPin,
                                           action: \.destination.healthCardPasswordForgotPin),
                        onTap: { store.send(.tappedForgotPin) },
                        destination: { store in HealthCardPasswordIntroductionView(store: store) },
                        label: {
                            Label(L10n.stgTxtCardForgotPin,
                                  systemImage: SFSymbolName.questionmarkCircle)
                        }
                    ).accessibility(identifier: A11y.settings.card.stgTxtCardForgotPin)
                        .buttonStyle(.navigation)

                    // Destination: "Set a custom PIN"
                    NavigationLink(
                        item: $store.scope(state: \.destination?.healthCardPasswordSetCustomPin,
                                           action: \.destination
                                               .healthCardPasswordSetCustomPin),
                        onTap: { store.send(.tappedCustomPin) },
                        destination: { store in HealthCardPasswordIntroductionView(store: store) },
                        label: {
                            Label(L10n.stgTxtCardCustomPin,
                                  systemImage: SFSymbolName.cardIconAnd123)
                        }
                    ).accessibility(identifier: A11y.settings.card.stgTxtCardCustomPin)
                        .buttonStyle(.navigation)

                    // Destination: "Unlock health card"
                    NavigationLink(
                        item: $store.scope(state: \.destination?.healthCardPasswordUnlockCard,
                                           action: \.destination.healthCardPasswordUnlockCard),
                        onTap: { store.send(.tappedUnlockCard) },
                        destination: { store in HealthCardPasswordIntroductionView(store: store) },
                        label: {
                            Label(L10n.stgTxtCardUnlockCard,
                                  systemImage: SFSymbolName.lockRotation)
                        }
                    ).accessibility(identifier: A11y.settings.card.stgTxtCardUnlockCard)
                        .buttonStyle(.navigation)
                }
            )
        }
    }
}

struct HealthCardSectionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardSectionView(store: SettingsDomain.Dummies.store)
    }
}
