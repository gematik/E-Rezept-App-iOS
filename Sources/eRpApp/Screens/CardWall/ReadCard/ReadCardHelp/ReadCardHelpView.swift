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

struct ReadCardHelpView: View {
    @Perception.Bindable var store: StoreOf<ReadCardHelpDomain>

    init(store: StoreOf<ReadCardHelpDomain>) {
        self.store = store
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Colors.primary500)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Colors.systemLabelQuarternary)
    }

    var body: some View {
        WithPerceptionTracking {
            TabView(selection: $store.destination.sending(\.updatePageIndex)) {
                ReadCardHelpCardView(store: store)
                    .tag(ReadCardHelpDomain.Destination.State.first)

                ReadCardHelpPositionView(store: store)
                    .tag(ReadCardHelpDomain.Destination.State.second)

                ReadCardHelpVideoView(store: store)
                    .tag(ReadCardHelpDomain.Destination.State.third)

                ReadCardHelpListView(store: store)
                    .tag(ReadCardHelpDomain.Destination.State.fourth)
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
                store: StoreOf<ReadCardHelpDomain>(
                    initialState: .init()
                ) {
                    EmptyReducer()
                }
            )
        }
        .previewDevice("iPhone SE")
    }
}
