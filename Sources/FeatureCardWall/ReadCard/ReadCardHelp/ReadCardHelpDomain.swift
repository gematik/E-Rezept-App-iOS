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

/// Domain for handling read card help flow
@Reducer
public struct ReadCardHelpDomain {
    /// Initializes a new ReadCardHelpDomain
    public init() {}

    /// State for the read card help screen
    @ObservableState
    public struct State: Equatable {
        /// Initializes a new state
        public init() {}

        init(destination: ReadCardHelpDomain.Destination.State = .first) {
            self.destination = destination
        }

        public var destination: Destination.State = .first
    }

    /// Help page destinations
    @Reducer(state: .equatable)
    public enum Destination {
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp1
        /// First help page
        case first
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp2
        /// Second help page
        case second
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp3
        /// Third help page
        case third
        // sourcery: AnalyticsScreen = troubleShooting_readCardHelp4
        /// Fourth help page
        case fourth
    }

    /// Actions that can be performed in the help domain
    public enum Action: Equatable {
        case delegate(Delegate)
        case updatePageIndex(Destination.State)
    }

    public enum Delegate: Equatable {
        case close
        case navigateToIntro
    }

    /// The reducer body that handles state transitions and effects
    public var body: some ReducerOf<Self> {
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
