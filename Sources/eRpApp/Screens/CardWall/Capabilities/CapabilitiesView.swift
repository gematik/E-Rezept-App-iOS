//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct CapabilitiesView: View {
    let store: StoreOf<CardWallIntroductionDomain>
    @ObservedObject var viewStore: ViewStoreOf<CardWallIntroductionDomain>

    init(store: StoreOf<CardWallIntroductionDomain>) {
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
        NavigationStack {
            CapabilitiesView(
                store: CardWallIntroductionDomain.Dummies.store
            )
        }
    }
}
