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
import IDP
import SwiftUI

// [REQ:BSI-eRp-ePA:O.Auth_4#8] Confirmation Dialog with brief explanation
struct CardWallExtAuthConfirmationView: View {
    @Perception.Bindable var store: StoreOf<CardWallExtAuthConfirmationDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView(.vertical) {
                    PhoneWithAppIconView(selectedKKName: store.selectedKK.name)

                    if let error = store.error {
                        VStack(alignment: .leading, spacing: 8) {
                            Group {
                                Text(error.localizedDescriptionWithErrorList)
                                    .font(.headline)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(L10n.cdwTxtExtauthConfirmErrorDescription)
                                    .font(.subheadline)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)

                            Button(action: {
                                store.send(.openContactSheet)
                            }, label: {
                                Text(L10n.cdwBtnExtauthConfirmContact)
                            })
                                .accessibility(identifier: A11y.cardWall.extAuthConfirmation
                                    .cdwBtnExtauthConfirmContact)
                                .confirmationDialog(
                                    $store.scope(state: \.contactActionSheet, action: \.contactSheet)
                                )
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.cdwTxtExtauthConfirmHeadline)
                                .font(.headline)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(L10n.cdwTxtExtauthConfirmDescription)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .combine)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if store.loading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }
                }
                .padding(0)

                GreyDivider()

                // [REQ:BSI-eRp-ePA:O.Auth_4#8] User confirms the insurance company
                PrimaryTextButton(text: L10n.cdwBtnExtauthConfirmSend,
                                  a11y: A11y.cardWall.extAuthConfirmation.cdwBtnExtauthConfirmSend,
                                  isEnabled: !store.loading) {
                    store.send(.confirmKK)
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    store.send(.delegate(.close))
                }
                .accessibility(identifier: A11y.cardWall.extAuthConfirmation.cdwBtnExtauthConfirmCancel)
                .accessibility(label: Text(L10n.cdwBtnExtauthConfirmCancel))
            )
            .navigationTitle(L10n.cdwTxtExtauthConfirmTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private struct PhoneWithAppIconView: View {
        let selectedKKName: String
        var body: some View {
            HStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 4) {
                            Image(asset: Asset.CardWall.appIconPlaceholder)
                                .resizable()
                                .frame(width: 56, height: 56)
                                .background(Color.green)
                                .cornerRadius(12)

                            Text(selectedKKName)
                                .font(.caption)
                                .foregroundColor(Color(.white))
                                .lineLimit(2)
                        }
                        .frame(width: 56, alignment: .center)

                        VStack(spacing: 4) {
                            Image(asset: Asset.CardWall.previewAppIcon)

                            Text(L10n.cdwTxtExtauthConfirmOwnAppname)
                                .font(.caption)
                                .foregroundColor(Color(.white))
                                .lineLimit(1)
                        }
                        .frame(width: 56, alignment: .center)

                        Spacer()
                    }
                    .frame(width: 232, alignment: .leading) // avaliable space for icons
                    .padding(.bottom, 86)
                    .padding(.top, 20)
                }
                .background(Image(asset: Asset.CardWall.homescreenBg)
                    .ignoresSafeArea(.all, edges: .top),
                    alignment: .bottom)
            }
            .accessibility(hidden: true)
        }
    }
}

struct CardWallExtAuthConfirmationView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                CardWallExtAuthConfirmationView(
                    store: CardWallExtAuthConfirmationDomain.Dummies.store(
                        for: .init(
                            selectedKK: KKAppDirectory.Entry(name: "abc", identifier: "abc"),
                            loading: true,
                            error: CardWallExtAuthConfirmationDomain.Error.universalLinkFailed
                        )
                    )
                )
            }
        }
    }
}
