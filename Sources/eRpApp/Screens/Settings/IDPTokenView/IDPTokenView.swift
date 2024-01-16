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

import IDP
import SwiftUI

// [REQ:BSI-eRp-ePA:O.Purp_9#1] Access and SSO Token display
// [REQ:BSI-eRp-ePA:O.Tokn_5#3] Access and SSO Token display
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
                .accessibilityValue(Text(accessToken))
            }
            if let ssoToken = token?.ssoToken {
                TokenCell(
                    title: L10n.stgTknTxtSsoToken,
                    token: ssoToken
                )
                .accessibility(identifier: A11y.settings.tokens.stgTknTxtSsoToken)
                .accessibilityValue(Text(ssoToken))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(L10n.stgTknTxtTitleTokens)
        .navigationBarTitleDisplayMode(.automatic)
    }

    /// sourcery: StringAssetInitialized
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
                    tokenType: "ended",
                    redirect: ""
                )
            )
        }
    }
}
