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
import SwiftUI

struct CapabilitiesView: View {
    let store: CardWallIntroductionDomain.Store
    @ObservedObject var viewStore: ViewStoreOf<CardWallIntroductionDomain>

    init(store: CardWallIntroductionDomain.Store) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: true) {
                MinimumRequirementsView().padding()
            }
        }
        .navigationBarTitle(L10n.cdwTxtNfuTitle, displayMode: .inline)
        .navigationBarItems(
            trailing: NavigationBarCloseItem {
                viewStore.send(.delegate(.close))
            }
            .accessibility(identifier: A11y.cardWall.notForYou.cdwBtnNfuCancel)
            .accessibility(label: Text(L10n.cdwBtnNfuCancelLabel))
        )
    }
}

extension CapabilitiesView {
    // MARK: - screen related views

    private struct MinimumRequirementsView: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.cdwTxtNfuSubtitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(.title)
                    .bold()
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwTxtNfuSubtitle)

                Text(L10n.cdwTxtNfuDescription)
                    .font(.body)
                    .foregroundColor(Colors.systemLabel)
                    .accessibility(identifier: A11y.cardWall.notForYou.cdwTxtNfuDescription)

                Button(L10n.cdwBtnNfuMore) {
                    guard let url = URL(string: "https://www.das-e-rezept-fuer-deutschland.de/fragen-antworten"),
                          UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibility(identifier: A11y.cardWall.notForYou.cdwBtnNfuMore)
            }
        }
    }
}

struct NotForYouView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CapabilitiesView(
                store: CardWallIntroductionDomain.Dummies.store
            )
        }.generateVariations()
    }
}
