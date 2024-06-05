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

struct ReadCardHelpPositionView: View {
    @Perception.Bindable var store: Store<ReadCardHelpDomain.State, ReadCardHelpDomain.Action>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtRcTipTwo)
                            .foregroundColor(Colors.systemGray)
                            .padding()
                            .overlay(
                                Rectangle()
                                    .foregroundColor(Colors.systemGray5)
                                    .opacity(0.4)
                                    .cornerRadius(8)
                            )
                            .padding(.top)

                        Text(L10n.cdwTxtRcPositionHeader)
                            .font(.system(size: 30))
                            .bold()
                            .padding(.top)

                        Text(L10n.cdwTxtRcPositionContent)
                            .padding(.top)
                    }

                    Image(asset: Asset.CardReader.cardReadPosition2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    store.send(.updatePageIndex(.first))
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
                    store.send(.updatePageIndex(.third))
                }
                .accessibility(label: Text(L10n.cdwBtnRcNextTip))
                .accessibility(identifier: A11y.cardWall.readCard.cdwBtnRcHelpNextTip)
            )
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReadCardHelpPositionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<ReadCardHelpPositionView> {
            ReadCardHelpPositionView(
                store: ReadCardHelpDomain.Dummies.store
            )
        }
        .previewDevice("iPhone 11")
    }
}
