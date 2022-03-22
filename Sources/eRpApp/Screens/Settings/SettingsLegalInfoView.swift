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
        let showLegalNoticeView: Bool
        let showDataProtectionView: Bool
        let showFOSSView: Bool
        let showTermsOfUseView: Bool

        init(state: SettingsDomain.State) {
            showLegalNoticeView = state.showLegalNoticeView
            showDataProtectionView = state.showDataProtectionView
            showFOSSView = state.showFOSSView
            showTermsOfUseView = state.showTermsOfUseView
        }
    }

    var body: some View {
        SectionContainer(header: {
            Label(title: { Text(L10n.stgTxtHeaderLegalInfo) }, icon: {})
                .accessibilityIdentifier(A18n.settings.legalNotice.stgLnoTxtHeaderLegalInfo)
        }, content: {
            NavigationLink(
                destination: LegalNoticeView(),
                isActive: viewStore.binding(
                    get: { $0.showLegalNoticeView },
                    send: SettingsDomain.Action.toggleLegalNoticeView
                )
            ) {
                Label(L10n.stgLnoTxtLegalNotice, systemImage: SFSymbolName.info)
            }
            .accessibility(identifier: A18n.settings.legalNotice.stgLnoTxtLegalNotice)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: DataPrivacyView(),
                isActive: viewStore.binding(
                    get: { $0.showDataProtectionView },
                    send: SettingsDomain.Action.toggleDataProtectionView
                )
            ) {
                Label(L10n.stgDpoTxtDataPrivacy, systemImage: SFSymbolName.shield)
            }
            .accessibility(identifier: A18n.settings.dataPrivacy.stgDprTxtDataPrivacy)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: FOSSView(),
                isActive: viewStore.binding(
                    get: { $0.showFOSSView },
                    send: SettingsDomain.Action.toggleFOSSView
                )
            ) {
                Label(L10n.stgDpoTxtFoss, systemImage: SFSymbolName.heartTextSquare)
            }
            .accessibility(identifier: A18n.settings.foss.stgDprTxtFoss)
            .buttonStyle(.navigation)

            NavigationLink(
                destination: TermsOfUseView(),
                isActive: viewStore.binding(
                    get: { $0.showTermsOfUseView },
                    send: SettingsDomain.Action.toggleTermsOfUseView
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
