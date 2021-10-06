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
import eRpKit
import SwiftUI

enum OnboardingDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var composition: Composition
        var currentPage: Page {
            composition.currentPage
        }

        var registerAuthenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: []
        )

        var isShowingNextButton: Bool {
            currentPage != .legalInfo && currentPage != .altRegisterAuthentication
        }

        var isNextButtonEnabled: Bool {
            if case .registerAuthentication = currentPage {
                return registerAuthenticationState.hasValidSelection
            }
            return true
        }

        var isDragEnabled: Bool {
            if currentPage == .registerAuthentication && registerAuthenticationState.hasValidSelection {
                return true
            } else if currentPage == .altRegisterAuthentication ||
                currentPage == .registerAuthentication {
                return false
            } else {
                return true
            }
        }
    }

    enum Page {
        case start
        case welcome
        case features
        case registerAuthentication
        case altRegisterAuthentication
        case legalInfo

        static var all: [Page] = [.start, .welcome, .features, .registerAuthentication, .legalInfo]
    }

    enum Action: Equatable {
        case saveAuthentication
        case dismissOnboarding
        case setPage(index: Int)
        case registerAuthentication(action: RegisterAuthenticationDomain.Action)
        case nextPage
    }

    struct Composition: Equatable {
        let hideOnboardingLegacy: Bool
        let onboardingVersion: String?
        var currentPageIndex: Int
        let pages: [Page]

        init(hideOnboardingLegacy: Bool, onboardingVersion: String?) {
            self.hideOnboardingLegacy = hideOnboardingLegacy
            self.onboardingVersion = onboardingVersion
            currentPageIndex = 0
            pages = Composition.calculatePages(
                hideOnboarding: hideOnboardingLegacy,
                onboardingVersion: onboardingVersion
            )
        }

        init(currentPageIndex: Int = 0, pages: [Page] = []) {
            self.currentPageIndex = currentPageIndex
            self.pages = pages
            hideOnboardingLegacy = false
            onboardingVersion = nil
        }

        var isEmpty: Bool {
            pages.isEmpty
        }

        var currentPage: Page {
            pages[currentPageIndex]
        }

        mutating func setPage(_ page: Page) {
            if let index = pages.firstIndex(of: page) {
                setPage(index: index)
            }
        }

        mutating func next() {
            if currentPageIndex < pages.count - 1 {
                currentPageIndex += 1
            }
        }

        mutating func setPage(index: Int) {
            if index >= 0, index < pages.count {
                currentPageIndex = index
            }
        }

        static func calculatePages(hideOnboarding: Bool,
                                   onboardingVersion: String?) -> [Page] {
            guard onboardingVersion == nil else {
                return []
            }

            if hideOnboarding {
                return [.altRegisterAuthentication]
            } else {
                return Page.all
            }
        }

        static var empty = Composition()

        static var allPages = Composition(currentPageIndex: 0, pages: Page.all)
    }

    struct Environment {
        let appVersion: AppVersion
        let localUserStore: UserDataStore
        let schedulers: Schedulers
        let appSecurityManager: AppSecurityManager
        let authenticationChallengeProvider: AuthenticationChallengeProvider
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .nextPage:
            state.composition.next()
            return .none
        case let .setPage(index):
            state.composition.setPage(index: index)
            return .none
        case .saveAuthentication:
            guard state.registerAuthenticationState.hasValidSelection,
                  let selectedOption = state.registerAuthenticationState.selectedSecurityOption else {
                state.composition.setPage(.registerAuthentication)
                state.registerAuthenticationState.showNoSelectionMessage = true
                return .none
            }

            if case .password = selectedOption {
                guard let success = try? environment.appSecurityManager
                    .save(password: state.registerAuthenticationState.passwordA),
                    success == true else {
                    state.composition.setPage(.registerAuthentication)
                    state.registerAuthenticationState.showNoSelectionMessage = true
                    return .none
                }
                environment.localUserStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .dismissOnboarding)
            } else {
                environment.localUserStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .dismissOnboarding)
            }
        case .dismissOnboarding:
            environment.localUserStore.set(hideOnboarding: true)
            environment.localUserStore.set(onboardingVersion: environment.appVersion.productVersion)
            return RegisterAuthenticationDomain.cleanup()
        case .registerAuthentication(action: .saveSelectionSuccess):
            return Effect(value: .dismissOnboarding)
        case .registerAuthentication:
            return .none
        }
    }

    private static let appSecurityPullbackReducer: Reducer =
        RegisterAuthenticationDomain.reducer.pullback(
            state: \.registerAuthenticationState,
            action: /OnboardingDomain.Action.registerAuthentication(action:)
        ) {
            RegisterAuthenticationDomain.Environment(
                appSecurityManager: $0.appSecurityManager,
                userDataStore: $0.localUserStore,
                schedulers: $0.schedulers,
                authenticationChallengeProvider: $0.authenticationChallengeProvider
            )
        }

    static let reducer = Reducer.combine(
        appSecurityPullbackReducer,
        domainReducer
    )
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State(composition: OnboardingDomain.Composition.allPages)
        static let environment = Environment(
            appVersion: AppVersion.current,
            localUserStore: DummyUserSessionContainer().userSession.localUserStore,
            schedulers: Schedulers(),
            appSecurityManager: DummyAppSecurityManager(),
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
        )
    }
}
