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
import Foundation

@Reducer
struct HealthCardPasswordIntroductionDomain {
    @ObservableState
    struct State: Equatable {
        let mode: HealthCardPasswordDomainMode

        @Presents var destination: Destination.State?
    }

    enum Action: Equatable {
        case advance
        case destination(PresentationAction<Destination.Action>)

        case delegate(Delegate)

        enum Delegate {
            case navigateToSettings
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = healthCardPassword_can
        case can(HealthCardPasswordCanDomain)
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
            .ifLet(\.$destination, action: \.destination)
    }

    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .advance:
            state.destination = .can(.init(mode: state.mode))
            return .none
        case let .destination(.presented(.can(.delegate(canDelegateAction)))):
            switch canDelegateAction {
            case .navigateToSettings:
                return Effect.send(.delegate(.navigateToSettings))
            }
        case .destination,
             .delegate:
            return .none
        }
    }
}

extension HealthCardPasswordIntroductionDomain {
    enum Dummies {
        static let state = State(mode: .setCustomPin)

        static let store = Store(initialState: state) {
            HealthCardPasswordIntroductionDomain()
        }
    }
}
