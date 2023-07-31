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
        viewStore = ViewStore(store.scope(state: ViewState.init))
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
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /SettingsDomain.Destinations.State.legalNotice
                    )
                ) { _ in
                    LegalNoticeView()
                },
                tag: SettingsDomain.Destinations.State.Tag.legalNotice,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info)
            }
            .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /SettingsDomain.Destinations.State.dataProtection
                    )
                ) { _ in
                    DataPrivacyView()
                },
                tag: SettingsDomain.Destinations.State.Tag.dataProtection,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield)
            }
            .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /SettingsDomain.Destinations.State.openSourceLicence
                    )
                ) { _ in
                    FOSSView()
                },
                tag: SettingsDomain.Destinations.State.Tag.openSourceLicence,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare)
            }
            .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(
                        state: /SettingsDomain.Destinations.State.termsOfUse
                    )
                ) { _ in
                    TermsOfUseView()
                },
                tag: SettingsDomain.Destinations.State.Tag.termsOfUse,
                selection: viewStore.binding(
                    get: \.destinationTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgDpoTxtTermsOfUse, systemImage: SFSymbolName.docPlaintext)
            }
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
