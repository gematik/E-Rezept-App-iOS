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

enum OnboardingDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var onboardingVisible: Bool

        var page = Page.start

        enum Page: Int {
            case start
            case welcome
            case features
            case legalInfo

            mutating func next() {
                self = Page(rawValue: rawValue + 1) ?? .welcome
            }
        }

        var isShowingNextButton: Bool {
            page != .legalInfo
        }
    }

    enum Action: Equatable {
        case dismissOnboarding
        case setPage(page: OnboardingDomain.State.Page)
        case nextPage
    }

    struct Environment {
        var userSession: UserSession
        var schedulers: Schedulers
    }

    static let reducer = Reducer { state, action, environment in
        switch action {
        case .nextPage:
            state.page.next()
            return .none
        case let .setPage(value):
            state.page = value
            return .none
        case .dismissOnboarding:
            state.onboardingVisible = false
            environment.userSession.localUserStore.set(hideOnboarding: true)
            return .none
        }
    }
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State(onboardingVisible: true)
        static let environment = Environment(
            userSession: AppContainer.shared.userSessionSubject,
            schedulers: Schedulers()
        )
    }
}
