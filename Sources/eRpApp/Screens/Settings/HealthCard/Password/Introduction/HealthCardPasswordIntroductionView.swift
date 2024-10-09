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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordIntroductionView: View {
    @Perception.Bindable var store: StoreOf<HealthCardPasswordIntroductionDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 8) {
                            // headline
                            store.mode.headLineText
                                .font(.title.bold())
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroHeadline)

                            VStack(alignment: .leading, spacing: 16) {
                                // subheadline
                                Text(L10n.stgTxtCardResetIntroSubheadline)
                                    .font(Font.body.weight(.semibold))

                                // 1st checkmark
                                Label(
                                    title: { Text(L10n.stgTxtCardResetIntroNeedYourCard) },
                                    icon: {
                                        Image(systemName: SFSymbolName.checkmarkCircleFill)
                                            .foregroundColor(Colors.secondary500)
                                            .font(.title3)
                                    }
                                )
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroNeedYourCard)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)

                                // 2nd checkmark
                                Label(
                                    title: { store.mode.checkmarkText },
                                    icon: {
                                        Image(systemName: SFSymbolName.checkmarkCircleFill)
                                            .foregroundColor(Colors.secondary500)
                                            .font(.title3)
                                    }
                                )
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroNeedYourCardsPin)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)

                                // Hint
                                VStack(spacing: 8) {
                                    store.mode.hintText
                                        .foregroundColor(Color(.secondaryLabel))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .font(.subheadline)
                            }
                            .padding(.top, 32)
                        }.padding()
                    }
                }

                Spacer(minLength: 0)

                GreyDivider()

                Button {
                    store.send(.advance)
                } label: {
                    Text(L10n.stgBtnCardResetAdvance)
                }
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
                .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.can, action: \.destination.can)
            ) { store in
                HealthCardPasswordCanView(store: store)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HealthCardPasswordIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthCardPasswordIntroductionView(
                store: HealthCardPasswordIntroductionDomain.Dummies.store
            )
        }
    }
}
