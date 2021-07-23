//
//  Copyright (c) 2021 gematik GmbH
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

struct CapabilitiesView: View {
    let store: CardWallDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                ScrollView(.vertical, showsIndicators: true) {
                    MinimumRequirementsView().padding()
                }

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnNfuDone,
                                  a11y: A11y.cardWall.notForYou.cdwBtnNfuDone) {
                    viewStore.send(.close)
                }
                .accessibility(label: Text(L10n.cdwBtnPinDoneLabel))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitle(L10n.cdwTxtNfuTitle, displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.notForYou.cdwBtnNfuCancel)
                .accessibility(label: Text(L10n.cdwBtnNfuCancelLabel))
            )
        }
    }
}

extension CapabilitiesView {
    // MARK: - screen related views

    private struct MinimumRequirementsView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Image(Asset.CardWall.ohNo)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwImgNfu)

                Text(L10n.cdwTxtNfuSubtitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(.title3)
                    .bold()
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwTxtNfuSubtitle)

                Text(L10n.cdwTxtNfuDescription)
                    .font(.body)
                    .foregroundColor(Colors.systemLabel)
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwTxtNfuDescription)

                Text(L10n.cdwTxtNfuFootnote)
                    .font(.footnote)
                    .foregroundColor(Colors.systemLabelSecondary.opacity(0.6))
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwTxtNfuFootnote)

                // TODO: implement this when there is a destination for the button //swiftlint:disable:this todo
//                HStack {
//                    Spacer()
//                    Text(L10n.cdwBtnNfuMore)
//                        .font(.footnote)
//                        .foregroundColor(Colors.primary600)
//                        .accessibility(identifier: A11y.cardWall.notForYou.cdwBtnNfuMore)
//                }
            }
        }
    }
}

struct NotForYouView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CapabilitiesView(
                store: CardWallDomain.Dummies.store
            )
        }.generateVariations()
    }
}
