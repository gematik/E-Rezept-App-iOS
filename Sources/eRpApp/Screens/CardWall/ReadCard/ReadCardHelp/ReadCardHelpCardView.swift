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
import eRpStyleKit
import SwiftUI

struct ReadCardHelpCardView: View {
    let store: Store<Void, CardWallReadCardDomain.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtRcTipOne)
                            .foregroundColor(Colors.systemGray)
                            .padding()
                            .overlay(
                                Rectangle()
                                    .foregroundColor(Colors.systemGray5)
                                    .opacity(0.4)
                                    .cornerRadius(8)
                            )
                            .padding(.top)

                        Text(L10n.cdwTxtRcCardHeader)
                            .font(.system(size: 30))
                            .bold()
                            .padding(.top)

                        Text(L10n.cdwTxtRcCard)
                            .padding(.top)
                    }

                    Image(Asset.CardReader.cardReading.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    viewStore.send(.setNavigation(tag: nil))
                }, label: {
                    HStack {
                        Image(systemName: SFSymbolName.back).padding(0)
                            .foregroundColor(Colors.primary700)
                        Text(L10n.cdwBtnRcHelpBack)
                            .font(.body)
                            .foregroundColor(Colors.primary700)
                            .padding(0)
                    }
                }),
                trailing: Button(L10n.cdwBtnRcNextTip) {
                    viewStore.send(.updatePageIndex(page: .second))
                }
                .accessibility(label: Text(L10n.cdwBtnRcNextTip))
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcHelpNextTip)
            )
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReadCardHelpCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<ReadCardHelpCardView> {
            ReadCardHelpCardView(
                store: CardWallReadCardDomain.Dummies.store.stateless
            )
        }
        .previewDevice("iPhone 11")
    }
}
