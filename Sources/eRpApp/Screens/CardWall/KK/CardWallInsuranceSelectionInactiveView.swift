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

import SwiftUI

struct CardWallInsuranceSelectionInactiveView: View {
    var closeAction: () -> Void

    @State var presentOderEGK = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.cdwTxtFtfbHeadline)
                    .font(.title3.bold())
                    .padding(.bottom, 8)

                Text(L10n.cdwTxtFtfbDescription1)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                Text(L10n.cdwTxtFtfbDescription2)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                Button {
                    presentOderEGK = true
                } label: {
                    HStack {
                        Spacer()
                        Text(L10n.cdwBtnFtfbOrderEgk)
                            .font(.subheadline)
                            .foregroundColor(Colors.primary)
                    }
                }
                .accessibility(identifier: A11y.cardWall.fasttrackFallback.cdwBtnFtfbOrderegk)
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
            .accessibility(identifier: A11y.cardWall.fasttrackFallback.cdwBtnFtfbCancel)
        )
        .navigationTitle(L10n.cdwTxtFtfbTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CardWallInsuranceSelectionInactiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallInsuranceSelectionInactiveView {}
        }
    }
}
