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

struct SettingsExploreView: View {
    @Perception.Bindable var store: StoreOf<SettingsDomain>

    var body: some View {
        SectionContainer(header: {
            Label(title: { Text(L10n.stgExpTxtTitle) }, icon: {})
                .accessibilityIdentifier(A11y.settings.explore.stgConHeaderExplore)
        }, content: {
            WithPerceptionTracking {
                Toggle(isOn: $store.isDemoMode.sending(\.toggleDemoModeSwitch).animation()) {
                    EmptyView()
                    Label(L10n.stgTxtDemoMode, systemImage: SFSymbolName.wandAndStars)
                        .accessibilityIdentifier(A11y.settings.demo.stgTxtDemoMode)
                }
            }

            Button(action: {
                store.send(.tappedOpenOrganspenderegister)
            }, label: {
                Label(L10n.stgConBtnOrganDonor, systemImage: SFSymbolName.heartTextSquare)
            })
                .accessibility(identifier: A11y.settings.explore.stgConBtnOrganDonor)
                .buttonStyle(.navigation)

            Button(action: {
                guard let url = URL(string: "https://www.das-e-rezept-fuer-deutschland.de/ext/community"),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url)
            }, label: {
                Label(L10n.stgConBtnGemmunity, systemImage: SFSymbolName.person2)
            })
                .accessibility(identifier: A11y.settings.explore.stgConBtnGemmunity)
                .buttonStyle(.navigation)

            Button(action: {
                guard let url = URL(string: "https://gesundbund.de"),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url)
            }, label: {
                Label(L10n.stgConBtnGesundBundDe, systemImage: SFSymbolName.info)
            })
                .accessibility(identifier: A11y.settings.explore.stgConBtnGesundbundde)
                .buttonStyle(.navigation)
        })
    }
}
