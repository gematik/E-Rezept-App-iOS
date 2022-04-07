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
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class OnboardingDomainTests: XCTestCase {
    let mockUserDataStore = MockUserDataStore()
    let mockAppSecurityManager = MockAppSecurityManager()
    let mockProfileDataStore = MockProfileDataStore()
    typealias TestStore = ComposableArchitecture.TestStore<
        OnboardingDomain.State,
        OnboardingDomain.State,
        OnboardingDomain.Action,
        OnboardingDomain.Action,
        OnboardingDomain.Environment
    >

    func testStore(with state: OnboardingDomain.State = OnboardingDomain.Dummies.state) -> TestStore {
        TestStore(
            initialState: state,
            reducer: OnboardingDomain.reducer,
            environment: OnboardingDomain.Environment(
                appVersion: AppVersion.current,
                localUserStore: mockUserDataStore,
                profileStore: mockProfileDataStore,
                schedulers: Schedulers.immediate,
                appSecurityManager: mockAppSecurityManager,
                authenticationChallengeProvider: MockAuthenticationChallengeProvider(result: .success(true)),
                userSession: MockUserSession()
            )
        )
    }

    func testSavingAuthenticationWithoutSelection() {
        let composition = OnboardingDomain.Composition.allPages
        let store = testStore(
            with: OnboardingDomain.State(composition: composition)
        )

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }
    }

    func testSavingAuthenticationWithWrongPassword() {
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .password,
            passwordA: "ABC",
            passwordB: "different"
        )
        let store = testStore(
            with: OnboardingDomain.State(composition: OnboardingDomain.Composition.allPages,
                                         registerAuthenticationState: authenticationState)
        )

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }

    func testSavingAuthenticationWithUnsafePassword() {
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .password,
            passwordA: "ABC",
            passwordB: "ABC",
            passwordStrength: .veryWeak
        )

        let store = testStore(
            with: OnboardingDomain.State(composition: OnboardingDomain.Composition.allPages,
                                         registerAuthenticationState: authenticationState)
        )

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }
        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }

    func testSavingAuthenticationAndProfileWithCorrectPasswordAndName() {
        let selectedOption: AppSecurityOption = .password
        mockAppSecurityManager.savePasswordReturnValue = true
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .password,
            passwordA: "ABC",
            passwordB: "ABC",
            passwordStrength: .excellent
        )
        let store = testStore(
            with: OnboardingDomain.State(composition: OnboardingDomain.Composition.allPages,
                                         registerAuthenticationState: authenticationState,
                                         newProfileState: OnboardingNewProfileDomain.State(name: "Test Profile"))
        )
        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(index: 0)
            state.registerAuthenticationState.selectedSecurityOption = .password
            state.registerAuthenticationState.passwordA = "ABC"
            state.registerAuthenticationState.passwordB = "ABC"
            state.registerAuthenticationState.showNoSelectionMessage = false
        }
        expect(self.mockAppSecurityManager.savePasswordCallsCount) == 1
        expect(self.mockAppSecurityManager.savePasswordReturnValue).to(beTrue())
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption.id
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
        store.receive(.saveProfile)
        let savedProfile = mockProfileDataStore.saveProfilesReceivedProfiles!.first!
        store.receive(.saveProfileReceived(.success(savedProfile.id)))
        store.receive(.dismissOnboarding)
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingReceivedHideOnboarding) == true
        expect(self.mockUserDataStore.setSelectedProfileIdCallsCount) == 1
        expect(self.mockUserDataStore.setSelectedProfileIdReceived) == savedProfile.id
        expect(self.mockProfileDataStore.saveProfilesCallsCount) == 1

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beTrue())
        expect(self.mockUserDataStore.setOnboardingVersionReceivedInvocations)
            .to(equal([AppVersion.current.productVersion]))
    }

    func testSavingAuthenticationAndProfileWithBiometryAndCorrectName() {
        let selectedOption: AppSecurityOption = .biometry(.faceID)
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .biometry(.faceID)
        )
        let store = testStore(
            with: OnboardingDomain.State(
                composition: OnboardingDomain.Composition.allPages,
                registerAuthenticationState: authenticationState,
                newProfileState: OnboardingNewProfileDomain.State(name: "Test Profile")
            )
        )

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(index: 0)
            state.registerAuthenticationState.selectedSecurityOption = selectedOption
        }
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption.id
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
        store.receive(.saveProfile)
        let savedProfile = mockProfileDataStore.saveProfilesReceivedProfiles!.first!
        store.receive(.saveProfileReceived(.success(savedProfile.id)))
        store.receive(.dismissOnboarding)
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingReceivedHideOnboarding) == true
        expect(self.mockUserDataStore.setSelectedProfileIdCallsCount) == 1
        expect(self.mockUserDataStore.setSelectedProfileIdReceived) == savedProfile.id
        expect(self.mockProfileDataStore.saveProfilesCallsCount) == 1

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beTrue())
        expect(self.mockUserDataStore.setOnboardingVersionReceivedInvocations)
            .to(equal([AppVersion.current.productVersion]))
    }

    func testSavingAuthenticationAndProfileWithBiometryAndIncorrectName() {
        let selectedOption: AppSecurityOption = .biometry(.faceID)
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .biometry(.faceID)
        )
        let store = testStore(
            with: OnboardingDomain.State(
                composition: OnboardingDomain.Composition.allPages,
                registerAuthenticationState: authenticationState,
                newProfileState: OnboardingNewProfileDomain.State(name: "") // empty name is producing the error
            )
        )

        mockProfileDataStore.saveProfilesReturnValue = Just(true)
            .setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(index: 0)
            state.registerAuthenticationState.selectedSecurityOption = selectedOption
        }
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption.id
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
        store.receive(.saveProfile) { state in
            state.composition.setPage(OnboardingDomain.Page.newProfile)
            state.newProfileState.alertState = OnboardingNewProfileDomain.AlertStates.emptyName
        }

        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 0
        expect(self.mockUserDataStore.setSelectedProfileIdCallsCount) == 0
        expect(self.mockProfileDataStore.saveProfilesCallsCount) == 0
        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }

    func testSavingAuthenticationAndProfileWithBiometryAndFailingSaveProfile() {
        let selectedOption: AppSecurityOption = .biometry(.faceID)
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .biometry(.faceID)
        )
        let store = testStore(
            with: OnboardingDomain.State(
                composition: OnboardingDomain.Composition.allPages,
                registerAuthenticationState: authenticationState,
                newProfileState: OnboardingNewProfileDomain.State(name: "Test Profile")
            )
        )
        let expectedError = LocalStoreError.notImplemented
        mockProfileDataStore.saveProfilesReturnValue = Fail(error: expectedError)
            .eraseToAnyPublisher()

        store.send(.saveAuthenticationAndProfile) { state in
            state.composition.setPage(index: 0)
            state.registerAuthenticationState.selectedSecurityOption = selectedOption
        }
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption.id
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
        store.receive(.saveProfile)
        store.receive(.saveProfileReceived(.failure(expectedError))) { state in
            state.composition.setPage(OnboardingDomain.Page.newProfile)
            state.newProfileState.alertState = OnboardingNewProfileDomain.AlertStates.for(expectedError)
        }

        expect(self.mockProfileDataStore.saveProfilesCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 0
        expect(self.mockUserDataStore.setSelectedProfileIdCallsCount) == 0
        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }
}
