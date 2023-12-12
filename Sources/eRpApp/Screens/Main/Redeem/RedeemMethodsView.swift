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

struct RedeemMethodsView: View {
    let store: RedeemMethodsDomain.Store

    init(store: RedeemMethodsDomain.Store) {
        self.store = store
    }

    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    if sizeCategory <= ContentSizeCategory.extraExtraExtraLarge {
                        Spacer()
                        Image(Asset.Redeem.pharmacistBlue)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 240, height: 240)
                    }

                    VStack(spacing: 8) {
                        Text(L10n.rdmTxtTitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(Font.title.bold())
                            .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacyTitle)

                        Text(L10n.rdmTxtSubtitle)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .multilineTextAlignment(.center)
                            .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacySubtitle)
                    }
                    .padding(.horizontal)

                    if sizeCategory <= ContentSizeCategory.extraExtraExtraLarge {
                        Spacer()
                    }

                    Button(
                        action: { store.send(.setNavigation(tag: .matrixCode)) },
                        label: {
                            Tile(
                                title: L10n.rdmBtnRedeemPharmacyTitle,
                                description: L10n.rdmBtnRedeemPharmacyDescription,
                                discloseIcon: SFSymbolName.rightDisclosureIndicator
                            )
                            .padding([.leading, .trailing], 16)
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibility(identifier: A18n.redeem.overview.rdmBtnPharmacyTile)

                    Button(
                        action: { store.send(.setNavigation(tag: .pharmacySearch)) },
                        label: {
                            Tile(
                                title: L10n.rdmBtnRedeemSearchPharmacyTitle,
                                description: L10n.rdmBtnRedeemSearchPharmacyDescription,
                                discloseIcon: SFSymbolName.rightDisclosureIndicator
                            )
                            .padding([.leading, .trailing], 16)
                        }
                    )
                    .buttonStyle(.plain)
                    .accessibility(identifier: A18n.redeem.overview.rdmBtnDeliveryTile)

                    Spacer()
                }

                RedeemMethodsViewNavigation(store: store)
            }
            .navigationBarItems(
                trailing: NavigationBarCloseItem { store.send(.closeButtonTapped) }
                    .accessibility(identifier: A18n.redeem.overview.rdmBtnCloseButton)
            )
            .navigationBarTitleDisplayMode(.inline)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct RedeemMethodsViewNavigation: View {
        let store: RedeemMethodsDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, RedeemMethodsDomain.Action>

        init(store: RedeemMethodsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let destinationTag: RedeemMethodsDomain.Destinations.State.Tag?

            init(state: RedeemMethodsDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        var body: some View {
            NavigationLinkStore(
                store.scope(state: \.$destination, action: RedeemMethodsDomain.Action.destination),
                state: /RedeemMethodsDomain.Destinations.State.matrixCode,
                action: RedeemMethodsDomain.Destinations.Action.redeemMatrixCodeAction(action:),
                onTap: { viewStore.send(.setNavigation(tag: .matrixCode)) },
                destination: MatrixCodeView.init(store:),
                label: {}
            )
            .hidden()
            .accessibility(hidden: true)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: RedeemMethodsDomain.Action.destination),
                state: /RedeemMethodsDomain.Destinations.State.pharmacySearch,
                action: RedeemMethodsDomain.Destinations.Action.pharmacySearchAction(action:),
                onTap: { viewStore.send(.setNavigation(tag: .pharmacySearch)) },
                destination: PharmacySearchView.init(store:),
                label: {}
            )
            .hidden()
            .accessibility(hidden: true)
        }
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
