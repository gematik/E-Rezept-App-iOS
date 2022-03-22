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

import ComposableArchitecture
import SwiftUI

struct RedeemView: View {
    let store: RedeemDomain.Store

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
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

                    NavigateToRedeemView(store: store)
                    if viewStore.state.prescriptionsAreAllFullDetail {
                        NavigateToPharmacySearchView(store: store)
                        // This is a workaround due to a SwiftUI bug where never 2 NavigationLink
                        // should be on the same view. See:
                        // https://forums.swift.org/t/14-5-beta3-navigationlink-unexpected-pop/45279
                        NavigationLink(destination: EmptyView()) {
                            EmptyView()
                        }.accessibility(hidden: true)
                    }
                    Spacer()
                }
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
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private struct NavigateToRedeemView: View {
        let store: RedeemDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    // swiftlint:disable trailing_closure
                    destination: IfLetStore(
                        self.store.scope(
                            state: { $0.redeemMatrixCodeState },
                            action: RedeemDomain.Action.redeemMatrixCodeAction(action:)
                        ),
                        then: { scopedStore in
                            RedeemMatrixCodeView(store: scopedStore)
                        }
                    ),
                    isActive: viewStore.binding(
                        get: { $0.redeemMatrixCodeState != nil },
                        send: { active -> RedeemDomain.Action in
                            if active {
                                return RedeemDomain.Action.openRedeemMatrixCodeView
                            } else {
                                return RedeemDomain.Action.dismissRedeemMatrixCodeView
                            }
                        }
                    )
                ) { Tile(iconSystemName: SFSymbolName.qrCode,
                         title: L10n.rdmBtnRedeemPharmacyTitle,
                         description: L10n.rdmBtnRedeemPharmacyDescription,
                         discloseIcon: SFSymbolName.rightDisclosureIndicator)
                        .padding([.leading, .trailing], 16)
                }
                .accessibility(identifier: A18n.redeem.overview.rdmBtnPharmacyTile)
            }
        }
    }

    private struct NavigateToPharmacySearchView: View {
        let store: RedeemDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                NavigationLink(
                    // swiftlint:disable trailing_closure
                    destination: IfLetStore(
                        self.store.scope(
                            state: { $0.pharmacySearchState },
                            action: RedeemDomain.Action.pharmacySearchAction(action:)
                        ),
                        then: { scopedStore in
                            PharmacySearchView(store: scopedStore)
                        }
                    ),
                    isActive: viewStore.binding(
                        get: {
                            $0.pharmacySearchState != nil
                        },
                        send: { active -> RedeemDomain.Action in
                            if active {
                                return RedeemDomain.Action.openPharmacySearchView
                            } else {
                                return RedeemDomain.Action.dismissPharmacySearchView
                            }
                        }
                    )
                ) { Tile(iconSystemName: SFSymbolName.bag,
                         title: L10n.rdmBtnRedeemSearchPharmacyTitle,
                         description: L10n.rdmBtnRedeemSearchPharmacyDescription,
                         discloseIcon: SFSymbolName.rightDisclosureIndicator)
                        .padding([.leading, .trailing], 16)
                }
                .accessibility(identifier: A18n.redeem.overview.rdmBtnPharmacyTile)
            }
        }
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemView(store: RedeemDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
