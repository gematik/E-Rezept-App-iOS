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

struct ReadCardHelpDomain: ReducerProtocol {
    enum State: Int {
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
    }

    enum Delegate: Equatable {
        case close
        case navigateToIntro
        case updatePageIndex(State)
    }

    var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
    }
}

extension ReadCardHelpDomain {
    enum Dummies {
        static let state = State.first

        static let store = Store(
            initialState: state
        ) { ReadCardHelpDomain()
        }
    }
}
