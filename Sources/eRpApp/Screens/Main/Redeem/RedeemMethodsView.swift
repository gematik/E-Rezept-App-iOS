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
    @ObservedObject var viewStore: ViewStore<ViewState, RedeemMethodsDomain.Action>
    @AppStorage("enable_avs_login") var enableAvsLogin = false

    init(store: RedeemMethodsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let prescriptionsAreAllFullDetail: Bool

        init(state: RedeemMethodsDomain.State) {
            prescriptionsAreAllFullDetail = state.erxTasks.allSatisfy { $0.source == .server }
        }
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

                if viewStore.prescriptionsAreAllFullDetail || enableAvsLogin {
                    Button(action: { viewStore.send(.setNavigation(tag: .pharmacySearch)) }, label: {
                        Tile(iconSystemName: SFSymbolName.bag,
                             title: L10n.rdmBtnRedeemSearchPharmacyTitle,
                             description: L10n.rdmBtnRedeemSearchPharmacyDescription,
                             discloseIcon: SFSymbolName.rightDisclosureIndicator)
                            .padding([.leading, .trailing], 16)
                    })
                        .accessibility(identifier: A18n.redeem.overview.rdmBtnDeliveryTile)
                }
                Spacer()
            }
            .routes(for: store)
            .navigationBarItems(
                trailing: NavigationBarCloseItem { viewStore.send(.close) }
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

    struct Router: ViewModifier {
        let store: RedeemMethodsDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, RedeemMethodsDomain.Action>
        @AppStorage("enable_avs_login") var enableAvsLogin = false

        init(store: RedeemMethodsDomain.Store) {
            self.store = store
            viewStore = ViewStore(store.scope(state: ViewState.init))
        }

        struct ViewState: Equatable {
            let prescriptionsAreAllFullDetail: Bool
            let routeTag: RedeemMethodsDomain.Route.Tag?

            init(state: RedeemMethodsDomain.State) {
                routeTag = state.route?.tag
                prescriptionsAreAllFullDetail = state.erxTasks.allSatisfy { $0.source == .server }
            }
        }

        func body(content: Content) -> some View {
            Group {
                content

                NavigationLink(
                    // swiftlint:disable trailing_closure
                    destination: dataMatrixDestination,
                    tag: RedeemMethodsDomain.Route.Tag.matrixCode,
                    selection: viewStore.binding(get: \.routeTag, send: { .setNavigation(tag: $0) })
                ) {}
                    .hidden()
                    .accessibility(hidden: true)

                if viewStore.prescriptionsAreAllFullDetail || enableAvsLogin {
                    NavigationLink(
                        destination: pharmacySearchDestination,
                        tag: RedeemMethodsDomain.Route.Tag.pharmacySearch,
                        selection: viewStore.binding(get: \.routeTag, send: { .setNavigation(tag: $0) })
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
        }

        private var dataMatrixDestination: some View {
            IfLetStore(
                self.store.scope(
                    state: (\RedeemMethodsDomain.State.route).appending(path: /RedeemMethodsDomain.Route.matrixCode)
                        .extract(from:),
                    action: RedeemMethodsDomain.Action.redeemMatrixCodeAction(action:)
                ),
                then: RedeemMatrixCodeView.init(store:)
            )
        }

        private var pharmacySearchDestination: some View {
            IfLetStore(
                self.store.scope(
                    state: (\RedeemMethodsDomain.State.route).appending(path: /RedeemMethodsDomain.Route.pharmacySearch)
                        .extract(from:),
                    action: RedeemMethodsDomain.Action.pharmacySearchAction(action:)
                ),
                then: { scopedStore in
                    PharmacySearchView(store: scopedStore)
                }
            )
        }
    }
}

extension View {
    func routes(for store: RedeemMethodsDomain.Store) -> some View {
        modifier(
            RedeemMethodsView.Router(store: store)
        )
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
