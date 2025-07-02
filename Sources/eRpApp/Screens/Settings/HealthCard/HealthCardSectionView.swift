//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
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
                    Button {
                        store.send(.tappedEgk)
                    } label: {
                        Label(L10n.stgTxtCardOrderNewCard, systemImage: SFSymbolName.cardIcon)
                    }
                    .accessibility(identifier: A11y.settings.card.stgTxtCardOrderNewCard)
                    .buttonStyle(.navigation)

                    // Destination: "Forgot PIN"
                    Button {
                        store.send(.tappedForgotPin)
                    } label: {
                        Label(L10n.stgTxtCardForgotPin,
                              systemImage: SFSymbolName.questionmarkCircle)
                    }
                    .accessibility(identifier: A11y.settings.card.stgTxtCardForgotPin)
                    .buttonStyle(.navigation)

                    // Destination: "Set a custom PIN"
                    Button {
                        store.send(.tappedCustomPin)
                    } label: {
                        Label(L10n.stgTxtCardCustomPin,
                              systemImage: SFSymbolName.cardIconAnd123)
                    }
                    .accessibility(identifier: A11y.settings.card.stgTxtCardCustomPin)
                    .buttonStyle(.navigation)

                    // Destination: "Unlock health card"
                    Button {
                        store.send(.tappedUnlockCard)
                    } label: {
                        Label(L10n.stgTxtCardUnlockCard,
                              systemImage: SFSymbolName.lockRotation)
                    }
                    .accessibility(identifier: A11y.settings.card.stgTxtCardUnlockCard)
                    .buttonStyle(.navigation)
                }
            )
            .destinations(store: $store)
        }
    }
}

extension View {
    func destinations(store: Perception.Bindable<StoreOf<SettingsDomain>>) -> some View {
        navigationDestination(
            item: store.scope(state: \.destination?.egk, action: \.destination.egk)
        ) { store in
            OrderHealthCardListView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.healthCardPasswordForgotPin,
                              action: \.destination.healthCardPasswordForgotPin)
        ) { store in
            HealthCardPasswordIntroductionView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.healthCardPasswordSetCustomPin,
                              action: \.destination.healthCardPasswordSetCustomPin)
        ) { store in
            HealthCardPasswordIntroductionView(store: store)
        }
        .navigationDestination(
            item: store.scope(state: \.destination?.healthCardPasswordUnlockCard,
                              action: \.destination.healthCardPasswordUnlockCard)
        ) { store in
            HealthCardPasswordIntroductionView(store: store)
        }
    }
}

struct HealthCardSectionView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardSectionView(store: SettingsDomain.Dummies.store)
    }
}
