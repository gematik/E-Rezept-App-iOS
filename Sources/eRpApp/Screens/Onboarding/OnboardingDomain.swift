//
//  Copyright (c) 2022 gematik GmbH
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

        var newProfileState = OnboardingNewProfileDomain.State(name: "")

        var isShowingNextButton: Bool {
            currentPage != .legalInfo && currentPage != .altRegisterAuthentication
        }

        var isNextButtonEnabled: Bool {
            if case .registerAuthentication = currentPage {
                return registerAuthenticationState.hasValidSelection
            } else if case .newProfile = currentPage {
                return newProfileState.hasValidName
            }
            return true
        }

        var isDragEnabled: Bool {
            if currentPage == .registerAuthentication && registerAuthenticationState.hasValidSelection {
                return true
            } else if currentPage == .altRegisterAuthentication ||
                currentPage == .registerAuthentication {
                return false
            } else if currentPage == .newProfile {
                return newProfileState.hasValidName
            } else {
                return true
            }
        }
    }

    enum Page {
        case start
        case welcome
        case features
        case newProfile
        case registerAuthentication
        case altRegisterAuthentication
        case legalInfo

        static var all: [Page] = [.start, .welcome, .features, .newProfile, .registerAuthentication, .legalInfo]
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

        init(currentPageIndex: Int = 0,
             pages: [Page] = [],
             hideOnboardingLegacy: Bool = false,
             onboardingVersion: String? = nil) {
            self.currentPageIndex = currentPageIndex
            self.pages = pages
            self.hideOnboardingLegacy = hideOnboardingLegacy
            self.onboardingVersion = onboardingVersion
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

    enum Action: Equatable {
        case saveAuthenticationAndProfile
        case saveProfile
        case saveProfileReceived(Result<UUID, LocalStoreError>)
        case dismissOnboarding
        case setPage(index: Int)
        case registerAuthentication(action: RegisterAuthenticationDomain.Action)
        case newProfile(action: OnboardingNewProfileDomain.Action)
        case nextPage
    }

    struct Environment {
        let appVersion: AppVersion
        let localUserStore: UserDataStore
        let profileStore: ProfileDataStore
        let schedulers: Schedulers
        let appSecurityManager: AppSecurityManager
        let authenticationChallengeProvider: AuthenticationChallengeProvider
        let userSession: UserSession
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .nextPage:
            state.composition.next()
            return .none
        case let .setPage(index):
            state.composition.setPage(index: index)
            return .none
        case .saveAuthenticationAndProfile:
            guard state.registerAuthenticationState.hasValidSelection,
                  let selectedOption = state.registerAuthenticationState.selectedSecurityOption else {
                state.composition.setPage(.registerAuthentication)
                state.registerAuthenticationState.showNoSelectionMessage = true
                return .none
            }

            if case .password = selectedOption {
                guard state.registerAuthenticationState.passwordStrength.passesMinimumThreshold,
                      let success = try? environment.appSecurityManager
                      .save(password: state.registerAuthenticationState.passwordA),
                      success == true else {
                    state.composition.setPage(.registerAuthentication)
                    state.registerAuthenticationState.showNoSelectionMessage = true
                    return .none
                }
                environment.localUserStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .saveProfile)
            } else {
                environment.localUserStore.set(appSecurityOption: selectedOption.id)
                return Effect(value: .saveProfile)
            }
        case .saveProfile:
            let name = state.newProfileState.name.trimmed()
            guard name.lengthOfBytes(using: .utf8) > 0 else {
                state.newProfileState.alertState = OnboardingNewProfileDomain.AlertStates.emptyName
                state.composition.setPage(.newProfile)
                return .none
            }
            // On app install no profile is available, use the generated profileId for the initial profile.
            let profile = Profile(name: name, identifier: environment.userSession.profileId)
            return environment.profileStore.save(profiles: [profile])
                .catchToEffect()
                .map { result in
                    switch result {
                    case let .success(profileId):
                        return Action.saveProfileReceived(.success(profile.id))
                    case let .failure(error):
                        return Action.saveProfileReceived(.failure(error))
                    }
                }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()

        case let .saveProfileReceived(.success(profileId)):
            environment.localUserStore.set(selectedProfileId: profileId)
            return Effect(value: .dismissOnboarding)
        case let .saveProfileReceived(.failure(error)):
            state.newProfileState.alertState = OnboardingNewProfileDomain.AlertStates.for(error)
            state.composition.setPage(.newProfile)
            return .none
        case .dismissOnboarding:
            environment.localUserStore.set(hideOnboarding: true)
            environment.localUserStore.set(onboardingVersion: environment.appVersion.productVersion)
            return RegisterAuthenticationDomain.cleanup()
        case .registerAuthentication(action: .saveSelectionSuccess):
            return Effect(value: .dismissOnboarding)
        case .registerAuthentication:
            return .none
        case .newProfile:
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
                authenticationChallengeProvider: $0.authenticationChallengeProvider,
                passwordStrengthTester: DefaultPasswordStrengthTester()
            )
        }

    private static let newProfilePullbackReducer: Reducer =
        OnboardingNewProfileDomain.reducer.pullback(
            state: \.newProfileState,
            action: /OnboardingDomain.Action.newProfile(action:)
        ) { _ in
            OnboardingNewProfileDomain.Environment()
        }

    static let reducer = Reducer.combine(
        appSecurityPullbackReducer,
        newProfilePullbackReducer,
        domainReducer
    )
}

extension OnboardingDomain {
    enum Dummies {
        static let state = State(composition: OnboardingDomain.Composition.allPages)
        static let environment = Environment(
            appVersion: AppVersion.current,
            localUserStore: DummyUserSessionContainer().userSession.localUserStore,
            profileStore: DemoProfileDataStore(),
            schedulers: Schedulers(),
            appSecurityManager: DummyAppSecurityManager(),
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider(),
            userSession: DemoSessionContainer()
        )
    }
}
