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
import DataKit
import eRpKit
import Foundation
import IDP

// domain and screens will be subject to refactoring for new style, long body is ok for now
// swiftlint:disable:next type_body_length
struct SettingsDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        .concatenate(
            cleanupSubDomains(),
            EffectTask<T>.cancel(ids: Token.allCases),
            ProfilesDomain.cleanup()
        )
    }

    static func cleanupSubDomains<T>() -> EffectTask<T> {
        .concatenate(
            HealthCardPasswordDomain.cleanup(),
            DebugDomain.cleanup(),
            EditProfileDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case trackingStatus
        case demoModeStatus
    }

    struct State: Equatable {
        var isDemoMode: Bool
        var profiles = ProfilesDomain.State(profiles: [], selectedProfileId: nil)
        var appVersion = AppVersion.current
        var trackerOptIn = false

        var destination: Destinations.State?
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case debug(DebugDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<SettingsDomain.Action>)
            // sourcery: AnalyticsScreen = healthCardPassword_forgotPin
            case healthCardPasswordForgotPin(HealthCardPasswordDomain.State)
            // sourcery: AnalyticsScreen = healthCardPassword_setCustomPin
            case healthCardPasswordSetCustomPin(HealthCardPasswordDomain.State)
            // sourcery: AnalyticsScreen = healthCardPassword_unlockCard
            case healthCardPasswordUnlockCard(HealthCardPasswordDomain.State)
            case appSecurity(AppSecurityDomain.State)
            // sourcery: AnalyticsScreen = settings_productImprovements_complyTracking
            case complyTracking
            // sourcery: AnalyticsScreen = settings_legalNotice
            case legalNotice
            // sourcery: AnalyticsScreen = settings_dataProtection
            case dataProtection
            // sourcery: AnalyticsScreen = settings_openSourceLicence
            case openSourceLicence
            // sourcery: AnalyticsScreen = settings_termsOfUse
            case termsOfUse
            // sourcery: AnalyticsScreen = contactInsuranceCompany
            case egk(OrderHealthCardDomain.State)

            // sourcery: AnalyticsScreen = profile
            case editProfile(EditProfileDomain.State)
            // sourcery: AnalyticsScreen = settings_newProfile
            case newProfile(NewProfileDomain.State)
        }

        enum Action: Equatable {
            case debugAction(DebugDomain.Action)
            case healthCardPasswordForgotPinAction(HealthCardPasswordDomain.Action)
            case healthCardPasswordSetCustomPinAction(HealthCardPasswordDomain.Action)
            case healthCardPasswordUnlockCardAction(HealthCardPasswordDomain.Action)
            case appSecurityStateAction(AppSecurityDomain.Action)
            case egkAction(OrderHealthCardDomain.Action)
            case editProfileAction(EditProfileDomain.Action)
            case newProfileAction(NewProfileDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            #if ENABLE_DEBUG_VIEW
            Scope(state: /State.debug, action: /Action.debugAction) {
                DebugDomain()
            }
            #endif
            Scope(state: /State.appSecurity, action: /Action.appSecurityStateAction) {
                AppSecurityDomain()
            }

            Scope(state: /State.egk, action: /Action.egkAction) {
                OrderHealthCardDomain()
            }

            Scope(state: /State.healthCardPasswordForgotPin, action: /Action.healthCardPasswordForgotPinAction) {
                HealthCardPasswordDomain()
            }
            Scope(
                state: /State.healthCardPasswordSetCustomPin,
                action: /Action.healthCardPasswordSetCustomPinAction
            ) {
                HealthCardPasswordDomain()
            }
            Scope(state: /State.healthCardPasswordUnlockCard, action: /Action.healthCardPasswordUnlockCardAction) {
                HealthCardPasswordDomain()
            }
            Scope(
                state: /State.editProfile,
                action: /Action.editProfileAction
            ) {
                EditProfileDomain()
            }

            Scope(
                state: /State.newProfile,
                action: /Action.newProfileAction
            ) {
                NewProfileDomain()
            }
        }
    }

    enum Action: Equatable {
        case close
        case initSettings
        case trackerStatusReceived(Bool)
        case demoModeStatusReceived(Bool)
        case toggleTrackingTapped(Bool)
        case confirmedOptInTracking
        case toggleDemoModeSwitch
        case profiles(action: ProfilesDomain.Action)
        case popToRootView
        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)
    }

    @Dependency(\.changeableUserSessionContainer) var changeableUserSessionContainer: UsersSessionContainer
    @Dependency(\.tracker) var tracker: Tracker

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.profiles, action: /SettingsDomain.Action.profiles(action:)) {
            ProfilesDomain()
        }

        Reduce(core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .initSettings:
            return .merge(
                tracker.optInPublisher
                    .map(Action.trackerStatusReceived)
                    .eraseToEffect()
                    .cancellable(id: Token.trackingStatus, cancelInFlight: true),
                changeableUserSessionContainer.isDemoMode
                    .map(Action.demoModeStatusReceived)
                    .eraseToEffect()
                    .cancellable(id: Token.demoModeStatus, cancelInFlight: true)
            )
        case let .demoModeStatusReceived(isDemo):
            state.isDemoMode = isDemo
            return .none
        case let .trackerStatusReceived(value):
            state.trackerOptIn = value
            return .none
        case .close:
            return .none
        // Demo-Mode
        case .toggleDemoModeSwitch:
            state.destination = .alert(.info(state.isDemoMode ? Self.demoModeOffAlertState : Self.demoModeOnAlertState))
            if state.isDemoMode {
                changeableUserSessionContainer.switchToStandardMode()
            } else {
                changeableUserSessionContainer.switchToDemoMode()
            }
            return .none

        // Tracking
        // [REQ:gemSpec_eRp_FdV:A_19088, A_19089, A_19092, A_19097] OptIn for usage tracking
        // [REQ:BSI-eRp-ePA:O.Purp_5#2] Actual disabling of analytics
        // [REQ:gemSpec_eRp_FdV:A_19982#2] Opt out of analytics
        case let .toggleTrackingTapped(optIn):
            if optIn {
                // [REQ:gemSpec_eRp_FdV:A_19091#3] Show comply route to display analytics usage within settings
                state.destination = .complyTracking
            } else {
                // [REQ:gemSpec_eRp_FdV:A_20185,A_20187] OptOut for user
                state.trackerOptIn = false
                tracker.optIn = false
            }
            return .none
        // [REQ:gemSpec_eRp_FdV:A_19090,A_19091#4] User confirms the opt in within settings
        // [REQ:BSI-eRp-ePA:O.Purp_5#4] User confirms the opt in within settings
        case .confirmedOptInTracking:
            state.trackerOptIn = true
            tracker.optIn = true
            state.destination = nil
            return .none
        case .destination(.healthCardPasswordUnlockCardAction(.delegate(.navigateToSettings))),
             .destination(.healthCardPasswordForgotPinAction(.delegate(.navigateToSettings))),
             .destination(.healthCardPasswordSetCustomPinAction(.delegate(.navigateToSettings))):
            state.destination = nil
            return HealthCardPasswordReadCardDomain.cleanup()
        case .destination(.healthCardPasswordUnlockCardAction),
             .destination(.healthCardPasswordForgotPinAction),
             .destination(.healthCardPasswordSetCustomPinAction):
            return .none
        case .setNavigation(tag: .healthCardPasswordForgotPin):
            state.destination = .healthCardPasswordForgotPin(.init(mode: .forgotPin))
            return .none
        case .setNavigation(tag: .healthCardPasswordSetCustomPin):
            state.destination = .healthCardPasswordSetCustomPin(.init(mode: .setCustomPin))
            return .none
        case .setNavigation(tag: .healthCardPasswordUnlockCard):
            state.destination = .healthCardPasswordUnlockCard(.init(mode: .unlockCard))
            return .none
        case let .setNavigation(tag: tag):
            switch tag {
            case .debug:
                state.destination = .debug(DebugDomain.State(trackingOptIn: tracker.optIn))
            case .egk:
                state.destination = .egk(.init())
            case .legalNotice:
                state.destination = .legalNotice
            case .dataProtection:
                state.destination = .dataProtection
            case .openSourceLicence:
                state.destination = .openSourceLicence
            case .termsOfUse:
                state.destination = .termsOfUse
            case .appSecurity:
                state.destination = .appSecurity(.init(availableSecurityOptions: []))
            case .none:
                state.destination = nil
                return Self.cleanupSubDomains()
            default: break
            }
            return .none
        case .destination(.egkAction(.delegate(.close))):
            state.destination = nil
            return Self.cleanup()
        case let .profiles(action: .delegate(delegateAction)):
            switch delegateAction {
            case let .showEditProfile(editProfileState):
                state.destination = .editProfile(editProfileState)
            case .showNewProfile:
                state.destination = .newProfile(.init(name: "", acronym: "", color: .blue))
            case let .alert(alert):
                state.destination = .alert(
                    alert.pullback { action in
                        Action.profiles(action: action)
                    }
                )
            }
            return .none
        case let .destination(.editProfileAction(.delegate(action))):
            switch action {
            case .logout:
                return .init(value: .profiles(action: .registerListener))
            case .close:
                state.destination = nil
                return .none
            }
        case let .destination(.newProfileAction(.delegate(action))):
            switch action {
            case .close:
                state.destination = nil
                return .none
            }
        case .popToRootView:
            state.destination = nil
            return .none
        case .destination(.debugAction),
             .destination(.editProfileAction),
             .destination(.newProfileAction),
             .destination(.egkAction),
             .destination(.appSecurityStateAction),
             .profiles:
            return .none
        }
    }

    static var demoModeOnAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoMode),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOn),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }()

    static var demoModeOffAlertState: AlertState<Action> = {
        AlertState<Action>(
            title: TextState(L10n.stgTxtAlertTitleDemoModeOff),
            message: TextState(L10n.stgTxtAlertMessageDemoModeOff),
            dismissButton: .default(TextState(L10n.alertBtnOk), action: .send(.setNavigation(tag: nil)))
        )
    }()
}

extension SettingsDomain {
    enum Dummies {
        static let state = State(
            isDemoMode: false,
            profiles: ProfilesDomain.Dummies.state,
            appVersion: AppVersion(productVersion: "1.0",
                                   buildNumber: "LOCAL BUILD",
                                   buildHash: "LOCAL BUILD")
        )

        static let store = storeFor(state)

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: SettingsDomain()
            )
        }
    }
}
