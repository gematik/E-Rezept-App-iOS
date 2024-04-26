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
    let store: CardWallIntroductionDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, CardWallIntroductionDomain.Action>

    init(store: CardWallIntroductionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let routeTag: CardWallIntroductionDomain.Destinations.State.Tag?
        let isNFCReady: Bool

        init(state: CardWallIntroductionDomain.State) {
            routeTag = state.destination?.tag
            isNFCReady = state.isNFCReady
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center, spacing: 0) {
                    Image(Asset.CardWall.scanningCard)
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
                        if viewStore.isNFCReady {
                            Text(L10n.cdwBtnIntroRecommendation)
                                .foregroundColor(Colors.primary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .font(.body.bold())
                        }

                        Button(action: {
                            viewStore.send(.advance)
                        }, label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L10n.cdwBtnIntroNfc)
                                        .font(Font.body.weight(.medium))
                                        .foregroundColor(!viewStore.isNFCReady ? Colors.disabled : Colors.systemLabel)

                                    Text(!viewStore.isNFCReady ? L10n.cdwBtnSubintroNonfc : L10n.cdwBtnSubintroNfc)
                                        .font(.subheadline)
                                        .foregroundColor(Colors.systemLabelSecondary)
                                }
                                .multilineTextAlignment(.leading)

                                Spacer(minLength: 8)
                                Image(systemName: SFSymbolName.rightDisclosureIndicator)
                                    .font(Font.headline.weight(.semibold))
                                    .foregroundColor(viewStore.isNFCReady ? Colors.primary : Colors.systemLabelTertiary)
                                    .padding(8)
                            }
                            .padding()
                        })
                            .buttonStyle(DefaultButtonStyle())
                            .background(Colors.systemBackgroundTertiary)
                            .border(viewStore.isNFCReady ? Colors.primary : Colors.separator,
                                    width: viewStore.isNFCReady ? 2.0 : 0.5,
                                    cornerRadius: 16)
                            .padding(.bottom)
                            .disabled(!viewStore.isNFCReady)

                        NavigationLinkStore(
                            store.scope(state: \.$destination, action: CardWallIntroductionDomain.Action.destination),
                            state: /CardWallIntroductionDomain.Destinations.State.extauth,
                            action: CardWallIntroductionDomain.Destinations.Action.extauth(action:),
                            onTap: { viewStore.send(.setNavigation(tag: .extauth)) },
                            destination: CardWallExtAuthSelectionView.init(store:),
                            label: {}
                        )
                        .hidden()
                        .accessibility(hidden: true)

                        Button(action: {
                            viewStore.send(.setNavigation(tag: .extauth))
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

                        NavigationLinkStore(
                            store.scope(state: \.$destination, action: CardWallIntroductionDomain.Action.destination),
                            state: /CardWallIntroductionDomain.Destinations.State.can,
                            action: CardWallIntroductionDomain.Destinations.Action.canAction(action:),
                            onTap: { viewStore.send(.setNavigation(tag: .can)) },
                            destination: CardWallCANView.init(store:),
                            label: {}
                        )
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
                        viewStore.send(.setNavigation(tag: .egk))
                    }, label: {
                        Text(L10n.cdwBtnIntroFootnote)
                    })

                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                        .foregroundColor(Colors.primary)
                        .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroMore)
                        .fullScreenCover(isPresented: Binding<Bool>(
                            get: { viewStore.state.routeTag == .egk },
                            set: { show in
                                if !show {
                                    viewStore.send(.setNavigation(tag: nil))
                                }
                            }
                        ),
                        onDismiss: {},
                        content: {
                            NavigationView {
                                IfLetStore(
                                    store.scope(
                                        state: \.$destination,
                                        action: CardWallIntroductionDomain.Action.destination
                                    ),
                                    state: /CardWallIntroductionDomain.Destinations.State.egk,
                                    action: CardWallIntroductionDomain.Destinations.Action.egkAction(action:),
                                    then: OrderHealthCardListView.init(store:)
                                )
                            }
                            .accentColor(Colors.primary700)
                            .navigationViewStyle(StackNavigationViewStyle())
                        })
                }
            }
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.intro.cdwBtnIntroCancel)
                .accessibility(label: Text(L10n.cdwBtnIntroCancelLabel))
            )
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
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
