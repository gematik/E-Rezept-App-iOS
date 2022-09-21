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
import eRpStyleKit
import SwiftUI

struct ResetRetryCounterIntroductionView: View {
    let store: ResetRetryCounterDomain.Store
    @ObservedObject var viewStore: ViewStore<ResetRetryCounterDomain.State, ResetRetryCounterDomain.Action>

    init(store: ResetRetryCounterDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        if viewStore.withNewPin {
                            Text(L10n.stgTxtCardResetIntroCustomPin)
                                .font(.title.bold())
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroCustomPin)
                        } else {
                            Text(L10n.stgTxtCardResetIntroUnlockCard)
                                .font(.title.bold())
                                .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroUnlockCard)
                        }
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.stgTxtCardResetIntroSubheadline)
                                .font(Font.body.weight(.semibold))

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

                            Label(
                                title: { Text(L10n.stgTxtCardResetIntroNeedYourCardsPuk) },
                                icon: {
                                    Image(systemName: SFSymbolName.checkmarkCircleFill)
                                        .foregroundColor(Colors.secondary500)
                                        .font(.title3)
                                }
                            )
                            .accessibility(identifier: A11y.settings.card.stgTxtCardResetIntroNeedYourCardsPuk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)

                            VStack(spacing: 8) {
                                Text(L10n.stgTxtCardResetIntroHint)
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

            NavigationLink(
                isActive: .init(
                    get: {
                        viewStore.state.route != ResetRetryCounterDomain.Route.introduction
                    },
                    set: { active in
                        if active {
                            viewStore.send(.advance)
                        } else {
                            viewStore.send(.setNavigation(tag: .introduction))
                        }
                    }
                ),
                destination: {
                    ResetRetryCounterCanView(store: store)
                },
                label: {
                    Text(L10n.stgBtnCardResetAdvance)
                }
            )
            .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
            .accessibility(identifier: A11y.settings.card.stgBtnCardResetAdvance)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResetRetryCounterIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResetRetryCounterIntroductionView(
                store: ResetRetryCounterDomain.Dummies.store
            )
        }
    }
}
