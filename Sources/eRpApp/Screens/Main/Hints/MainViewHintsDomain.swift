//
//  Copyright (c) 2021 gematik GmbH
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

enum MainViewHintsDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Token: Equatable {
        case loadHintsAndDemoMode
    }

    struct Environment {
        var router: Routing
        var userSession: UserSession
        var schedulers: Schedulers
        var hintEventsStore: EventsStore
        var hintProvider: MainViewHintsProvider
    }

    struct State: Equatable {
        var hint: Hint<MainViewHintsDomain.Action>?
    }

    indirect enum Action: Equatable {
        /// Subscribes to receive new hints
        case subscribeToHintChanges
        /// Called whenever a new hint is received or nil if no hint should be shown
        case hintChangeReceived(Hint<Action>?)
        /// Implemented by the defined hint
        case routeTo(Endpoint)
        /// Implemented by the current hint
        case hideHint
        /// Removes the subscription on viewDisappear calls
        case removeSubscription
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case .subscribeToHintChanges:
            return environment.subscribeToHints()
                .cancellable(id: Token.loadHintsAndDemoMode, cancelInFlight: true)
        case let .hintChangeReceived(hint):
            state.hint = hint
            return .none
        case let .routeTo(endpoint):
            environment.router.routeTo(endpoint)
            return .none
        case .hideHint:
            guard let hint = state.hint else { return .none }
            environment.hintEventsStore.hintState.hiddenHintIDs.insert(hint.id)
            return .none
        case .removeSubscription:
            return .cancel(id: Token.loadHintsAndDemoMode)
        }
    }
}

extension MainViewHintsDomain.Environment {
    func subscribeToHints() -> Effect<MainViewHintsDomain.Action, Never> {
        hintEventsStore.hintStatePublisher
            .map { hintState in
				let isDemoMode = userSession.isDemoMode
                let hint = hintProvider.currentHint(for: hintState, isDemoMode: isDemoMode)
                return .hintChangeReceived(hint)
            }
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }
}

extension MainViewHintsDomain {
    enum Dummies {
        static func hintBottomAligned(
            with style: Hint<MainViewHintsDomain.Action>.Style,
            buttonStyle: Hint<MainViewHintsDomain.Action>.ButtonStyle = .quaternary
        ) -> Hint<MainViewHintsDomain.Action> {
            Hint(id: "dummyHintsDomainHintID",
                 title: "Hint Title for this Hint can also be a little longer",
                 message: "A  message which gives you a hint.",
                 actionText: "Take action now",
                 action: .routeTo(.settings),
                 imageName: Asset.Illustrations.redWoman23.name,
                 closeAction: .hideHint,
                 style: style,
                 buttonStyle: buttonStyle,
                 imageStyle: .bottomAligned)
        }

        static func hintTopAligned(
            with style: Hint<MainViewHintsDomain.Action>.Style,
            buttonStyle: Hint<MainViewHintsDomain.Action>.ButtonStyle = .quaternary
        ) -> Hint<MainViewHintsDomain.Action> {
            Hint(id: "dummyHintsDomainHintID",
                 title: "Hint Title for this Hint can also be a little longer",
                 message: "A very very long message which gives you a hint about what you should do with this hint.",
                 actionText: "Take action now",
                 action: .routeTo(.settings),
                 imageName: Asset.Illustrations.egkBlau.name,
                 closeAction: .hideHint,
                 style: style,
                 buttonStyle: buttonStyle,
                 imageStyle: .topAligned)
        }

        static let demoSessionContainer = DemoSessionContainer()
        static func state(with style: Hint<MainViewHintsDomain.Action>.Style) -> State {
            State(hint: hintBottomAligned(with: style))
        }

        static func emptyState() -> State {
            State(hint: nil)
        }

        static let environment = Environment(
            router: DummyRouter(),
            userSession: demoSessionContainer,
            schedulers: Schedulers(),
            hintEventsStore: DemoHintsStateStore(),
            hintProvider: MainViewHintsProvider()
        )
        static func store(with hintStyle: Hint<MainViewHintsDomain.Action>.Style) -> Store {
            Store(initialState: state(with: hintStyle), reducer: reducer, environment: environment)
        }
    }
}
