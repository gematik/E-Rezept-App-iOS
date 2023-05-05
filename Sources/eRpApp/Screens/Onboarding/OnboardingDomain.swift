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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

struct OnboardingDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var composition: Composition
        var alertState: AlertState<Action>?
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
            } else {
                return true
            }
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
        case features
        case registerAuthentication
        case altRegisterAuthentication
        case legalInfo

        static var all: [Page] = [.start, .features, .registerAuthentication, .legalInfo]
    }

    struct Composition: Equatable {
        var currentPageIndex: Int
        let pages: [Page]

        init(hideOnboardingLegacy: Bool, onboardingVersion: String?) {
            currentPageIndex = 0
            pages = Composition.calculatePages(
                hideOnboarding: hideOnboardingLegacy,
                onboardingVersion: onboardingVersion
            )
        }

        init(
            currentPageIndex: Int = 0,
            pages: [Page] = []
        ) {
            self.currentPageIndex = currentPageIndex
            self.pages = pages
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
            setPage(index: currentPageIndex + 1)
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

    enum Action: Equatable {
        case saveAuthentication
        case dismissOnboarding
        case setPage(index: Int)
        case registerAuthentication(action: RegisterAuthenticationDomain.Action)
        case nextPage
        case dismissAlert
    }

    @Dependency(\.currentAppVersion) var appVersion: AppVersion
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.userDataStore) var localUserStore: UserDataStore

    var environment: Environment {
        .init(appVersion: appVersion, appSecurityManager: appSecurityManager, localUserStore: localUserStore)
    }

    struct Environment {
        let appVersion: AppVersion
        let appSecurityManager: AppSecurityManager
        let localUserStore: UserDataStore
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.registerAuthenticationState, action: /OnboardingDomain.Action.registerAuthentication(action:)) {
            RegisterAuthenticationDomain()
        }

        Reduce(core)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
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
                guard state.registerAuthenticationState.passwordStrength.passesMinimumThreshold,
                      let success = try? appSecurityManager
                      .save(password: state.registerAuthenticationState.passwordA),
                      success == true else {
                    state.composition.setPage(.registerAuthentication)
                    state.registerAuthenticationState.showNoSelectionMessage = true
                    return .none
                }
                localUserStore.set(appSecurityOption: selectedOption)
                return Effect(value: .dismissOnboarding)
            } else {
                localUserStore.set(appSecurityOption: selectedOption)
                return Effect(value: .dismissOnboarding)
            }
        case .dismissOnboarding:
            localUserStore.set(hideOnboarding: true)
            localUserStore.set(onboardingVersion: appVersion.productVersion)
            return RegisterAuthenticationDomain.cleanup()
        case .registerAuthentication(action: .saveSelectionSuccess):
            return Effect(value: .dismissOnboarding)
        case .registerAuthentication(action: .continueBiometry):
            return Effect(value: .nextPage)
        case .registerAuthentication:
            return .none
        case .dismissAlert:
            state.alertState = nil
            return .none
        }
    }
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State(composition: OnboardingDomain.Composition.allPages)
    }
}
