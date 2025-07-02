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

import eRpStyleKit
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
        NavigationStack {
            CardWallExtAuthFallbackView {}
        }
    }
}
