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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

@Reducer
struct OnboardingDomain {
    @ObservableState
    struct State: Equatable {
        var showTermsOfUse = false
        var showTermsOfPrivacy = false
        var legalConfirmed = false
        var version: Version = .none

        var path = StackState<Path.State>()
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case legalInfo
        case registerAuth(RegisterAuthenticationDomain)
        case registerPassword(RegisterPasswordDomain)
        case analytics
        case analyticsDetail
    }

    enum Action: Equatable {
        case dismissOnboarding
        case setShowPrivacy(Bool)
        case setShowUse(Bool)
        case showLegalInfo
        case showAnalytics
        case showAnalyticsDetail
        case showRegisterAuth
        case showRegisterPassword

        case allowTracking
        case denyTracking

        case path(StackActionOf<Path>)
    }

    enum Version: String, Equatable {
        // Add new versions to refresh onboarding
        case none

        init?(rawVersion: String?) {
            switch rawVersion {
            case .none:
                self = .none
            case let .some(version):
                if let knownVersion = Self(rawValue: version) {
                    self = knownVersion
                } else { return nil }
            }
        }
    }

    @Dependency(\.currentAppVersion) var appVersion: AppVersion
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager
    @Dependency(\.userDataStore) var localUserStore: UserDataStore
    @Dependency(\.tracker) var tracker: Tracker
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        Reduce(core)
            .forEach(\.path, action: \.path)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .setShowPrivacy(bool):
            state.showTermsOfPrivacy = bool
            return .none
        case let .setShowUse(bool):
            state.showTermsOfUse = bool
            return .none
        case .showLegalInfo:
            state.path.append(.legalInfo)
            return .none
        case .showRegisterAuth:
            state.path.append(
                .registerAuth(RegisterAuthenticationDomain.State(
                    availableSecurityOptions: []
                ))
            )
            return .none
        case .showRegisterPassword:
            state.path.append(
                .registerPassword(RegisterPasswordDomain.State())
            )
            return .none
        case .dismissOnboarding:
            localUserStore.set(hideOnboarding: true)
            localUserStore.set(onboardingVersion: appVersion.productVersion)
            localUserStore.set(onboardingDate: date())
            return .none
        case .showAnalyticsDetail:
            state.path.append(.analyticsDetail)
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19088,A_19091-01#1,A_19092-01#2] Show comply route to display analytics usage within
        // onboarding
        // [REQ:BSI-eRp-ePA:O.Purp_3#5] Show comply route to display analytics usage within onboarding
        // [REQ:gemSpec_eRp_FdV:A_19089-01#2] Show comply route to display analytics usage within onboarding
        case .showAnalytics:
            state.path.append(.analytics)
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090-01,A_19091-01#2] User confirms the opt in within settings
        // [REQ:BSI-eRp-ePA:O.Purp_3#6] Accept usage analytics
        case .allowTracking:
            tracker.optIn = true
            return Effect.send(.dismissOnboarding)
        // [REQ:gemSpec_eRp_FdV:A_19092-01#3] User may choose to not accept analytics, onboarding will still continue
        // [REQ:BSI-eRp-ePA:O.Purp_3#7] Deny usage analytics
        case .denyTracking:
            tracker.optIn = false
            return Effect.send(.dismissOnboarding)
        case let .path(.element(id: id, action: .registerAuth(.delegate(delegate)))):
            switch delegate {
            case .showRegisterPassword:
                state.path.append(
                    .registerPassword(RegisterPasswordDomain.State())
                )
            case .nextPage:
                guard let registerAuthState = state.path[id: id, case: \.registerAuth]
                else { return .none }
                localUserStore.set(appSecurityOption: registerAuthState.selectedSecurityOption)
                return .send(.showAnalytics)
            }
            return .none
        case let .path(.element(id: id, action: .registerPassword(.delegate(delegate)))):
            switch delegate {
            case .prevPage:
                state.path.pop(from: id)
            case .nextPage:
                guard let registerPasswordState = state.path[id: id, case: \.registerPassword],
                      let success = try? appSecurityManager
                      .save(password: registerPasswordState.passwordA),
                      success == true
                else { return .none }
                localUserStore.set(appSecurityOption: .password)
                return .send(.showAnalytics)
            }
            return .none
        case .path:
            return .none
        }
    }
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State()

        static let store = Store(
            initialState: state
        ) {
            OnboardingDomain()
        }
    }
}
