//
//  Copyright (c) 2023 gematik GmbH
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
    let store: SettingsDomain.Store

    @ObservedObject var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let destinationTag: SettingsDomain.Destinations.State.Tag?

        init(state: SettingsDomain.State) {
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        SectionContainer(header: {
            Label(title: { Text(L10n.stgTxtHeaderLegalInfo) }, icon: {})
                .accessibilityIdentifier(A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo)
        }, content: {
            NavigationLinkStore(
                store.scope(state: \.$destination, action: SettingsDomain.Action.destination),
                state: /SettingsDomain.Destinations.State.legalNotice,
                action: SettingsDomain.Destinations.Action.legalNotice,
                onTap: { viewStore.send(.setNavigation(tag: .legalNotice)) },
                destination: { _ in LegalNoticeView() },
                label: { Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info) }
            )
            .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
            .buttonStyle(.navigation)

            // [REQ:BSI-eRp-ePA:O.Arch_9#3] DataPrivacy display within Settings
            NavigationLinkStore(
                store.scope(state: \.$destination, action: SettingsDomain.Action.destination),
                state: /SettingsDomain.Destinations.State.dataProtection,
                action: SettingsDomain.Destinations.Action.dataProtection,
                onTap: { viewStore.send(.setNavigation(tag: .dataProtection)) },
                destination: { _ in DataPrivacyView() },
                label: { Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield) }
            )
            .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
            .buttonStyle(.navigation)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: SettingsDomain.Action.destination),
                state: /SettingsDomain.Destinations.State.openSourceLicence,
                action: SettingsDomain.Destinations.Action.openSourceLicence,
                onTap: { viewStore.send(.setNavigation(tag: .openSourceLicence)) },
                destination: { _ in FOSSView() },
                label: { Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare) }
            )
            .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
            .buttonStyle(.navigation)

            NavigationLinkStore(
                store.scope(state: \.$destination, action: SettingsDomain.Action.destination),
                state: /SettingsDomain.Destinations.State.termsOfUse,
                action: SettingsDomain.Destinations.Action.termsOfUse,
                onTap: { viewStore.send(.setNavigation(tag: .termsOfUse)) },
                destination: { _ in TermsOfUseView() },
                label: { Label(L10n.stgDpoTxtTermsOfUse, systemImage: SFSymbolName.docPlaintext) }
            )
            .accessibility(identifier: A18n.settings.termsOfUse.stgTouTxtTermsOfUse)
            .buttonStyle(.navigation)
        })
    }
}

struct SettingsLegalInfosView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLegalInfoView(store: SettingsDomain.Dummies.store)
    }
}
