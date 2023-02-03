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

    @ObservedObject
    var viewStore: ViewStore<ViewState, SettingsDomain.Action>

    init(store: SettingsDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    struct ViewState: Equatable {
        let routeTag: SettingsDomain.Route.Tag?

        init(state: SettingsDomain.State) {
            routeTag = state.route?.tag
        }
    }

    var body: some View {
        SectionContainer(header: {
            Label(title: { Text(L10n.stgTxtHeaderLegalInfo) }, icon: {})
                .accessibilityIdentifier(A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo)
        }, content: {
            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: (\SettingsDomain.State.route)
                            .appending(path: /SettingsDomain.Route.legalNotice)
                            .extract(from:)
                    )
                ) { _ in
                    LegalNoticeView()
                },
                tag: SettingsDomain.Route.Tag.legalNotice,
                selection: viewStore.binding(
                    get: \.routeTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info)
            }
            .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: (\SettingsDomain.State.route)
                            .appending(path: /SettingsDomain.Route.dataProtection)
                            .extract(from:)
                    )
                ) { _ in
                    DataPrivacyView()
                },
                tag: SettingsDomain.Route.Tag.dataProtection,
                selection: viewStore.binding(
                    get: \.routeTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield)
            }
            .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: (\SettingsDomain.State.route)
                            .appending(path: /SettingsDomain.Route.openSourceLicence)
                            .extract(from:)
                    )
                ) { _ in
                    FOSSView()
                },
                tag: SettingsDomain.Route.Tag.openSourceLicence,
                selection: viewStore.binding(
                    get: \.routeTag,
                    send: SettingsDomain.Action.setNavigation
                )
            ) {
                Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare)
            }
            .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: (\SettingsDomain.State.route)
                            .appending(path: /SettingsDomain.Route.termsOfUse)
                            .extract(from:)
                    )
                ) { _ in
                    TermsOfUseView()
                },
                tag: SettingsDomain.Route.Tag.termsOfUse,
                selection: viewStore.binding(
                    get: \.routeTag,
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
