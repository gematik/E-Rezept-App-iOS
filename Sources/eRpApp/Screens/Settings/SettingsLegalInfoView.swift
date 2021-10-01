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

struct SettingsLegalInfoView: View {
    let store: SettingsDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(
                destination: LegalNoticeView(),
                isActive: viewStore.binding(
                    get: { $0.showLegalNoticeView },
                    send: SettingsDomain.Action.toggleLegalNoticeView
                )
            ) {
                ListCellView(
                    sfSymbolName: SFSymbolName.info,
                    text: L10n.stgLnoTxtLegalNotice
                )
            }
            .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)

            NavigationLink(
                destination: DataPrivacyView(),
                isActive: viewStore.binding(
                    get: { $0.showDataProtectionView },
                    send: SettingsDomain.Action.toggleDataProtectionView
                )
            ) {
                ListCellView(
                    sfSymbolName: SFSymbolName.shield,
                    text: L10n.stgDpoTxtDataPrivacy
                )
            }
            .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)

            NavigationLink(
                destination: FOSSView(),
                isActive: viewStore.binding(
                    get: { $0.showFOSSView },
                    send: SettingsDomain.Action.toggleFOSSView
                )
            ) {
                ListCellView(
                    sfSymbolName: SFSymbolName.heartTextSquare,
                    text: L10n.stgDpoTxtFoss
                )
            }
            .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)

            NavigationLink(
                destination: TermsOfUseView(),
                isActive: viewStore.binding(
                    get: { $0.showTermsOfUseView },
                    send: SettingsDomain.Action.toggleTermsOfUseView
                )
            ) {
                ListCellView(
                    sfSymbolName: SFSymbolName.docPlaintext,
                    text: L10n.stgDpoTxtTermsOfUse
                )
            }
            .accessibility(identifier: A18n.settings.termsOfUse.stgTouTxtTermsOfUse)
        }
    }
}

struct SettingsLegalInfosView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLegalInfoView(store: SettingsDomain.Dummies.store)
    }
}
