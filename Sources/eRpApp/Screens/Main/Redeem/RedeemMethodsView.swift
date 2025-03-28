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
import SwiftUIIntrospect

struct RedeemMethodsView: View {
    @Perception.Bindable var store: StoreOf<RedeemMethodsDomain>

    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        if sizeCategory <= ContentSizeCategory.extraExtraExtraLarge {
                            Spacer()
                            Image(asset: Asset.Redeem.pharmacistBlue)
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
                            action: { store.send(.showMatrixCodeTapped) },
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
                            action: { store.send(.showPharmacySearchTapped) },
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
                }
                .navigationBarItems(
                    trailing: NavigationBarCloseItem { store.send(.closeButtonTapped) }
                        .accessibility(identifier: A18n.redeem.overview.rdmBtnCloseButton)
                )
                .navigationBarTitleDisplayMode(.inline)
                .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18)) { navigationController in
                    let navigationBar = navigationController.navigationBar
                    navigationBar.barTintColor = UIColor(Colors.systemBackground)
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                    navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                    navigationBar.standardAppearance = navigationBarAppearance
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.matrixCode, action: \.destination.matrixCode)
                ) { store in
                    MatrixCodeView(store: store)
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.pharmacySearch, action: \.destination.pharmacySearch)
                ) { store in
                    PharmacySearchView(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tint(Colors.primary700)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
