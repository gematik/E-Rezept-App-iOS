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

@Reducer
struct ReadCardHelpDomain {
    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .first
    }

    @Reducer(state: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp1
        case first
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp2
        case second
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp3
        case third
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp4
        case fourth
    }

    enum Action: Equatable {
        case delegate(Delegate)
        case updatePageIndex(Destination.State)
    }

    enum Delegate: Equatable {
        case close
        case navigateToIntro
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .updatePageIndex(pageIndex):
                state.destination = pageIndex
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

extension ReadCardHelpDomain {
    enum Dummies {
        static let store = Store(
            initialState: State()
        ) {
            ReadCardHelpDomain()
        }
    }
}
