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
    @ObservedObject var viewStore: ViewStore<Void, RedeemMethodsDomain.Action>

    init(store: RedeemMethodsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.stateless)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 16) {
                Text(L10n.rdmTxtTitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.title.bold())
                    .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacyTitle)
                Text(L10n.rdmTxtSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabel)
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibility(identifier: A18n.redeem.overview.rdmTxtPharmacySubtitle)

                Button(action: { viewStore.send(.setNavigation(tag: .matrixCode)) }, label: {
                    Tile(iconSystemName: SFSymbolName.qrCode,
                         title: L10n.rdmBtnRedeemPharmacyTitle,
                         description: L10n.rdmBtnRedeemPharmacyDescription,
                         discloseIcon: SFSymbolName.rightDisclosureIndicator)
                        .padding([.leading, .trailing], 16)
                })
                    .accessibility(identifier: A18n.redeem.overview.rdmBtnPharmacyTile)

                Button(action: { viewStore.send(.setNavigation(tag: .pharmacySearch)) }, label: {
                    Tile(iconSystemName: SFSymbolName.bag,
                         title: L10n.rdmBtnRedeemSearchPharmacyTitle,
                         description: L10n.rdmBtnRedeemSearchPharmacyDescription,
                         discloseIcon: SFSymbolName.rightDisclosureIndicator)
                        .padding([.leading, .trailing], 16)
                })
                    .accessibility(identifier: A18n.redeem.overview.rdmBtnDeliveryTile)
                Spacer()
            }
            .navigations(for: store)
            .navigationBarItems(
                trailing: NavigationBarCloseItem { viewStore.send(.closeButtonTapped) }
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

    struct Navigation: ViewModifier {
        let store: RedeemMethodsDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, RedeemMethodsDomain.Action>

        init(store: RedeemMethodsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let destinationTag: RedeemMethodsDomain.Destinations.State.Tag?

            init(state: RedeemMethodsDomain.State) {
                destinationTag = state.destination?.tag
            }
        }

        func body(content: Content) -> some View {
            Group {
                content

                NavigationLink(
                    destination: dataMatrixDestination,
                    tag: RedeemMethodsDomain.Destinations.State.Tag.matrixCode,
                    selection: viewStore.binding(get: \.destinationTag) { .setNavigation(tag: $0) }
                ) {}
                    .hidden()
                    .accessibility(hidden: true)

                NavigationLink(
                    destination: IfLetStore(
                        store.destinationsScope(
                            state: /RedeemMethodsDomain.Destinations.State.pharmacySearch,
                            action: RedeemMethodsDomain.Destinations.Action.pharmacySearchAction(action:)
                        )
                    ) { scopedStore in
                        PharmacySearchView(store: scopedStore)
                    },
                    tag: RedeemMethodsDomain.Destinations.State.Tag.pharmacySearch,
                    selection: viewStore.binding(get: \.destinationTag) { .setNavigation(tag: $0) }
                ) {}
                    .hidden()
                    .accessibility(hidden: true)
                // This is a workaround due to a SwiftUI bug where never 2 NavigationLink
                // should be on the same view. See:
                // https://forums.swift.org/t/14-5-beta3-navigationlink-unexpected-pop/45279
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }.accessibility(hidden: true)
            }
        }

        private var dataMatrixDestination: some View {
            IfLetStore(
                store.destinationsScope(
                    state: /RedeemMethodsDomain.Destinations.State.matrixCode,
                    action: RedeemMethodsDomain.Destinations.Action.redeemMatrixCodeAction(action:)
                ),
                then: RedeemMatrixCodeView.init(store:)
            )
        }
    }
}

extension View {
    func navigations(for store: RedeemMethodsDomain.Store) -> some View {
        modifier(
            RedeemMethodsView.Navigation(store: store)
        )
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
