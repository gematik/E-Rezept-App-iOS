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

struct SettingsLegalInfoView: View {
    @Perception.Bindable var store: StoreOf<SettingsDomain>

    var body: some View {
        WithPerceptionTracking {
            SectionContainer(header: {
                Label(title: { Text(L10n.stgTxtHeaderLegalInfo) }, icon: {})
                    .accessibilityIdentifier(A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo)
            }, content: {
                NavigationLink(
                    item: $store.scope(state: \.destination?.legalNotice, action: \.destination.legalNotice),
                    onTap: { store.send(.tappedLegalNotice) },
                    destination: { _ in LegalNoticeView() },
                    label: { Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info)
                    }
                ).accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
                    .buttonStyle(.navigation)

                // [REQ:BSI-eRp-ePA:O.Arch_9#3] DataPrivacy display within Settings
                NavigationLink(
                    item: $store.scope(state: \.destination?.dataProtection, action: \.destination.dataProtection),
                    onTap: { store.send(.tappedDataProtection) },
                    destination: { _ in DataPrivacyView() },
                    label: { Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield)
                    }
                ).accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
                    .buttonStyle(.navigation)
                NavigationLink(
                    item: $store
                        .scope(state: \.destination?.openSourceLicence, action: \.destination.openSourceLicence),
                    onTap: { store.send(.tappedFOSS) },
                    destination: { _ in FOSSView() },
                    label: { Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare)
                    }
                ).accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
                    .buttonStyle(.navigation)

                NavigationLink(
                    item: $store.scope(state: \.destination?.termsOfUse, action: \.destination.termsOfUse),
                    onTap: { store.send(.tappedTermsOfUse) },
                    destination: { _ in TermsOfUseView() },
                    label: { Label(L10n.stgDpoTxtTermsOfUse, systemImage: SFSymbolName.docPlaintext)
                    }
                ).accessibility(identifier: A18n.settings.termsOfUse.stgTouTxtTermsOfUse)
                    .buttonStyle(.navigation)
            })
        }
    }
}

struct SettingsLegalInfosView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLegalInfoView(store: SettingsDomain.Dummies.store)
    }
}
