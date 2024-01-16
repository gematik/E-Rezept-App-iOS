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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

struct OnboardingDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var legalConfirmed = false
        var composition: Composition
        @PresentationState var alertState: AlertState<Action.Alert>?
        var currentPage: Page {
            composition.currentPage
        }

        var registerAuthenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: []
        )

        var isShowingNextButton: Bool {
            currentPage == .start
        }
    }

    enum Page {
        case start
        case registerAuthentication
        case legalInfo
        case analytics

        static var all: [Page] = [.start, .legalInfo]
    }

    struct Composition: Equatable {
        var currentPageIndex: Int
        var pages: [Page]

        init(onboardingVersion: String?) {
            currentPageIndex = 0
            pages = Composition.calculatePages(
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

        static func calculatePages(onboardingVersion: String?) -> [Page] {
            guard onboardingVersion == nil else {
                return []
            }

            return Page.all
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
        case setConfirmLegal(Bool)
        case showTracking
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case allowTracking
        }
    }

    @Dependency(\.currentAppVersion) var appVersion: AppVersion
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.userDataStore) var localUserStore: UserDataStore
    @Dependency(\.tracker) var tracker: Tracker
    @Dependency(\.schedulers) var schedulers: Schedulers

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
            .ifLet(\.$alertState, action: /OnboardingDomain.Action.alert)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .nextPage:
            state.composition.next()
            return .none
        case let .setPage(index):
            state.composition.setPage(index: index)
            return .none
        case let .setConfirmLegal(bool):
            state.legalConfirmed = bool
            if !state.legalConfirmed, state.composition.pages.contains(.registerAuthentication) {
                state.composition.pages = [.start, .legalInfo]
            } else {
                state.composition.pages = [.start, .legalInfo, .registerAuthentication, .analytics]
            }
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
                return EffectTask.send(.dismissOnboarding)
            } else {
                localUserStore.set(appSecurityOption: selectedOption)
                return EffectTask.send(.dismissOnboarding)
            }
        case .dismissOnboarding:
            localUserStore.set(hideOnboarding: true)
            localUserStore.set(onboardingVersion: appVersion.productVersion)
            return .none
        case .registerAuthentication(action: .continueBiometry),
             .registerAuthentication(action: .nextPage),
             .registerAuthentication(action: .saveSelectionSuccess):
            return EffectTask.send(.nextPage)
        case .registerAuthentication:
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19088,A_19091#1,A_19092] Show comply route to display analytics usage within
        // onboarding
        // [REQ:BSI-eRp-ePA:O.Purp_3#5] Show comply route to display analytics usage within onboarding
        case .showTracking:
            state.alertState = Self.trackingAlertState
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090,A_19091#2] User confirms the opt in within settings
        // [REQ:BSI-eRp-ePA:O.Purp_3#6] Accept usage analytics
        case .alert(.presented(.allowTracking)):
            tracker.optIn = true
            return EffectTask.send(.saveAuthentication)
        // [REQ:gemSpec_eRp_FdV:A_19092] User may choose to not accept analytics
        // [REQ:BSI-eRp-ePA:O.Purp_3#7] Deny usage analytics
        case .alert(.dismiss):
            tracker.optIn = false
            state.alertState = nil
            return EffectTask.send(.saveAuthentication)
        }
    }

    // [REQ:gemSpec_eRp_FdV:A_19184] Alert for the user to choose.
    static let trackingAlertState: AlertState<Action.Alert> = {
        AlertState(
            title: { TextState(L10n.onbAnaAlertTitle) },
            actions: {
                ButtonState(role: .cancel, action: .send(.none)) {
                    TextState(L10n.onbAnaAlertDeny)
                }
                ButtonState(action: .send(.allowTracking, animation: .default)) {
                    TextState(L10n.onbAnaAlertAccept)
                }
            },
            message: { TextState(L10n.onbAnaAlertMessage) }
        )
    }()
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State(composition: OnboardingDomain.Composition.allPages)

        static let store = Store(
            initialState: state
        ) {
            OnboardingDomain()
        }
    }
}
