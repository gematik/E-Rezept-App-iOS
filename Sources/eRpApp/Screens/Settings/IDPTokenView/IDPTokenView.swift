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

import IDP
import SwiftUI

// [REQ:gemSpec_BSI_FdV:O.Tokn_9] actual view that presents the token
struct IDPTokenView: View {
    let token: IDPToken?

    var body: some View {
        List {
            if let accessToken = token?.accessToken {
                TokenCell(
                    title: L10n.stgTknTxtAccessToken,
                    token: accessToken
                )
                .accessibility(identifier: A11y.settings.tokens.stgTknTxtAccessToken)
            }
            if let ssoToken = token?.ssoToken {
                TokenCell(
                    title: L10n.stgTknTxtSsoToken,
                    token: ssoToken
                )
                .accessibility(identifier: A11y.settings.tokens.stgTknTxtSsoToken)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(L10n.stgTknTxtTitleTokens)
    }

    struct TokenCell: View {
        let title: LocalizedStringKey
        let token: String

        var body: some View {
            Button(
                action: {
                    UIPasteboard.general.string = token
                },
                label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .foregroundColor(Colors.systemLabel)
                            Text(token)
                                .lineLimit(2)
                                .foregroundColor(Colors.systemLabelSecondary)
                        }
                        Spacer()
                        Image(systemName: SFSymbolName.copy)
                            .foregroundColor(Colors.systemLabelTertiary)
                    }
                }
            )
            .accessibility(label: Text(L10n.stgTknTxtCopyToClipboard))
        }
    }
}

struct TokensView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            IDPTokenView(
                token: IDPToken(
                    accessToken: "12122121212",
                    expires: Date(),
                    idToken: "123456",
                    ssoToken: "sso_token",
                    tokenType: "ended"
                )
            )
        }
    }
}
