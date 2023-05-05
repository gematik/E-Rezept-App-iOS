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

struct ReadCardHelpView: View {
    let store: Store<CardWallReadCardHelpDomain.State, CardWallReadCardDomain.Action>

    init(store: Store<CardWallReadCardHelpDomain.State, CardWallReadCardDomain.Action>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Colors.primary500)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Colors.systemLabelQuarternary)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(
                get: { $0 },
                send: {
                    CardWallReadCardDomain.Action.updatePageIndex(page: $0)
                }
            )) {
                ReadCardHelpCardView(store: store.stateless)
                    .tag(CardWallReadCardHelpDomain.State.first)

                ReadCardHelpVideoView(store: store.stateless)
                    .tag(CardWallReadCardHelpDomain.State.second)

                ReadCardHelpListView(store: store.stateless)
                    .tag(CardWallReadCardHelpDomain.State.third)
            }
            .background(Colors.systemBackground)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

struct ReadCardHelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<ReadCardHelpView> {
            ReadCardHelpView(
                store: Store<CardWallReadCardHelpDomain.State, CardWallReadCardDomain.Action>(
                    initialState: .first,
                    reducer: EmptyReducer()
                )
            )
        }
        .previewDevice("iPhone SE")
    }
}
