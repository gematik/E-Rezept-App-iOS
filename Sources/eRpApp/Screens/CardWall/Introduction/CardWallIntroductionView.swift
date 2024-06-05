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

import CasePaths
import Combine
import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CardWallIntroductionView: View {
    @Perception.Bindable var store: StoreOf<CardWallIntroductionDomain>

    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                VStack {
                    VStack(alignment: .center, spacing: 0) {
                        Image(asset: Asset.CardWall.scanningCard)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())

                        Text(L10n.cdwTxtIntroHeaderTop)
                            .font(Font.largeTitle.weight(.bold))
                            .foregroundColor(Color(.label))
                            .padding(.bottom, 8)

                        Text(L10n.cdwTxtIntroSubheader)
                            .font(.headline)
                            .foregroundColor(Colors.systemLabelSecondary)

                        VStack(spacing: 0) {
                            if store.isNFCReady {
                                Text(L10n.cdwBtnIntroRecommendation)
                                    .foregroundColor(Colors.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .font(.body.bold())
                            }

                            Button(action: {
                                store.send(.advance)
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(L10n.cdwBtnIntroNfc)
                                            .font(Font.body.weight(.medium))
                                            .foregroundColor(!store.isNFCReady ? Colors.disabled : Colors.systemLabel)

                                        Text(!store.isNFCReady ? L10n.cdwBtnSubintroNonfc : L10n.cdwBtnSubintroNfc)
                                            .font(.subheadline)
                                            .foregroundColor(Colors.systemLabelSecondary)
                                    }
                                    .multilineTextAlignment(.leading)

                                    Spacer(minLength: 8)
                                    Image(systemName: SFSymbolName.rightDisclosureIndicator)
                                        .font(Font.headline.weight(.semibold))
                                        .foregroundColor(store.isNFCReady ? Colors.primary : Colors.systemLabelTertiary)
                                        .padding(8)
                                }
                                .padding()
                            })
                                .buttonStyle(DefaultButtonStyle())
                                .background(Colors.systemBackgroundTertiary)
                                .border(store.isNFCReady ? Colors.primary : Colors.separator,
                                        width: store.isNFCReady ? 2.0 : 0.5,
                                        cornerRadius: 16)
                                .padding(.bottom)
                                .disabled(!store.isNFCReady)

                            NavigationLink(
                                item: $store.scope(state: \.destination?.can, action: \.destination.can)
                            ) { store in
                                CardWallCANView(store: store)
                            } label: {
                                EmptyView()
                            }
                            .hidden()
                            .accessibility(hidden: true)

                            // [REQ:BSI-eRp-ePA:O.Auth_4#2] Button the user may use to start login via gID
                            Button(action: {
                                store.send(.extAuthTapped)
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(L10n.cdwBtnIntroExtauth)
                                            .font(Font.body.weight(.medium))
                                            .foregroundColor(Colors.systemLabel)
                                            .multilineTextAlignment(.leading)
                                            .accessibilityIdentifier(A11y.cardWall.intro.cdwBtnIntroLater)

                                        Text(L10n.cdwBtnIntroExtauthDescription)
                                            .font(.subheadline)
                                            .foregroundColor(Colors.systemLabelSecondary)
                                    }
                                    .multilineTextAlignment(.leading)

                                    Spacer(minLength: 8)
                                    Image(systemName: SFSymbolName.rightDisclosureIndicator)
                                        .font(Font.headline.weight(.semibold))
                                        .foregroundColor(Color(.tertiaryLabel))
                                        .padding(8)
                                }
                                .padding()
                            })
                                .buttonStyle(DefaultButtonStyle())
                                .background(Colors.systemBackgroundTertiary)
                                .border(Colors.separator, width: 0.5, cornerRadius: 16)

                            NavigationLink(
                                item: $store.scope(state: \.destination?.extAuth, action: \.destination.extAuth)
                            ) { store in
                                CardWallExtAuthSelectionView(store: store)
                            } label: {
                                EmptyView()
                            }
                            .hidden()
                            .accessibility(hidden: true)
                        }
                        .padding()
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtIntroFootnote)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .padding([.leading, .trailing])

                        Button(action: {
                            store.send(.egkButtonTapped)
                        }, label: {
                            Text(L10n.cdwBtnIntroFootnote)
                        })

                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                            .foregroundColor(Colors.primary)
                            .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroMore)
                            .fullScreenCover(
                                item: $store.scope(state: \.destination?.egk, action: \.destination.egk),
                                onDismiss: {
                                    store.send(.resetNavigation)
                                },
                                content: { store in
                                    NavigationView {
                                        OrderHealthCardListView(store: store)
                                    }
                                    .accentColor(Colors.primary700)
                                    .navigationViewStyle(StackNavigationViewStyle())
                                }
                            )
                    }
                }
                .navigationBarItems(
                    trailing: NavigationBarCloseItem {
                        store.send(.delegate(.close))
                    }
                    .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
                    .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
                )
            }
            .accentColor(Colors.primary700)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallIntroductionView(
                store: CardWallIntroductionDomain.Dummies.store
            )
        }
    }
}
