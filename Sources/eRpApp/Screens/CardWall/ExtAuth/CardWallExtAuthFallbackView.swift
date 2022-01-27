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

import SwiftUI

struct CardWallExtAuthFallbackView: View {
    var closeAction: () -> Void

    @State var presentOderEGK = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.cdwTxtExtauthFallbackHeadline)
                    .font(.title3.bold())
                    .padding(.bottom, 8)

                Text(L10n.cdwTxtExtauthFallbackDescription1)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                Text(L10n.cdwTxtExtauthFallbackDescription2)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                Button {
                    presentOderEGK = true
                } label: {
                    HStack {
                        Spacer()
                        Text(L10n.cdwBtnExtauthFallbackOrderEgk)
                            .font(.subheadline)
                            .foregroundColor(Colors.primary)
                    }
                }
                .accessibility(identifier: A11y.cardWall.extAuthFallback.cdwBtnExtauthFallbackOrderegk)
            }
            .padding()
            .fullScreenCover(isPresented: $presentOderEGK) {
                NavigationView {
                    OrderHealthCardView {
                        presentOderEGK = false
                    }
                }
                .accentColor(Colors.primary700)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                closeAction()
            }
            .accessibility(identifier: A11y.cardWall.extAuthFallback.cdwBtnExtauthFallbackCancel)
        )
        .navigationTitle(L10n.cdwTxtExtauthFallbackTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CardWallExtAuthSelectionInactiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallExtAuthFallbackView {}
        }
    }
}
