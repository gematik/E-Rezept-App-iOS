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
                Button {
                    store.send(.tappedLegalNotice)
                } label: {
                    Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info)
                }
                .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
                .buttonStyle(.navigation)
                .navigationDestination(
                    item: $store.scope(state: \.destination?.legalNotice, action: \.destination.legalNotice)
                ) { _ in
                    LegalNoticeView()
                }

                // [REQ:BSI-eRp-ePA:O.Arch_9#3,O.Purp_1#4] DataPrivacy display within Settings
                Button {
                    store.send(.tappedDataProtection)
                } label: {
                    Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield)
                }
                .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
                .buttonStyle(.navigation)
                .navigationDestination(
                    item: $store.scope(state: \.destination?.dataProtection, action: \.destination.dataProtection)
                ) { _ in
                    DataPrivacyView()
                }

                Button {
                    store.send(.tappedFOSS)
                } label: {
                    Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare)
                }
                .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
                .buttonStyle(.navigation)
                .navigationDestination(
                    item: $store.scope(state: \.destination?.openSourceLicence, action: \.destination.openSourceLicence)
                ) { _ in
                    FOSSView()
                }

                Button {
                    store.send(.tappedTermsOfUse)
                } label: {
                    Label(L10n.stgDpoTxtTermsOfUse, systemImage: SFSymbolName.docPlaintext)
                }
                .accessibility(identifier: A18n.settings.termsOfUse.stgTouTxtTermsOfUse)
                .buttonStyle(.navigation)
                .navigationDestination(
                    item: $store.scope(state: \.destination?.termsOfUse, action: \.destination.termsOfUse)
                ) { _ in
                    TermsOfUseView()
                }
            })
        }
    }
}

struct SettingsLegalInfosView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLegalInfoView(store: SettingsDomain.Dummies.store)
    }
}
