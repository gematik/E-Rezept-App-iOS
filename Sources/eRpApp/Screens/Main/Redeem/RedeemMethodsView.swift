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
import SwiftUIIntrospect

struct RedeemMethodsView: View {
    @Perception.Bindable var store: StoreOf<RedeemMethodsDomain>

    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        WithPerceptionTracking {
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
                        action: { store.send(.matrixCodeTapped) },
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
                        action: { store.send(.delegate(.redeemOverview(store.prescriptions))) },
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
        }
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemMethodsView(store: RedeemMethodsDomain.Dummies.store)
            .previewDevice("iPhone 11")
    }
}
