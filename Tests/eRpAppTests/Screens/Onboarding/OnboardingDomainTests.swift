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
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class OnboardingDomainTests: XCTestCase {
    let mockUserDataStore = MockUserDataStore()
    let mockAppSecurityManager = MockAppSecurityManager()
    let testScheduler = DispatchQueue.test
    typealias TestStore = TestStoreOf<OnboardingDomain>

    func testStore(with state: OnboardingDomain.State = OnboardingDomain.Dummies.state) -> TestStore {
        let mockAuthenticationChallengeProvider = MockAuthenticationChallengeProvider()
        mockAuthenticationChallengeProvider.startAuthenticationChallengeReturnValue = Just(.success(true))
            .eraseToAnyPublisher()
        return TestStore(initialState: state) {
            OnboardingDomain()
        } withDependencies: { dependencies in
            dependencies.currentAppVersion = AppVersion.current
            dependencies.appSecurityManager = mockAppSecurityManager
            dependencies.userDataStore = mockUserDataStore
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        }
    }

    func testSavingAuthenticationWithoutSelection() async {
        let composition = OnboardingDomain.Composition.allPages
        let store = testStore(
            with: OnboardingDomain.State(composition: composition)
        )

        await store.send(.saveAuthentication) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }
    }

    func testSavingAuthenticationWithWrongPassword() async {
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

        await store.send(.saveAuthentication) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }

    func testSavingAuthenticationWithUnsafePassword() async {
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

        await store.send(.saveAuthentication) { state in
            state.composition.setPage(OnboardingDomain.Page.registerAuthentication)
            state.registerAuthenticationState.showNoSelectionMessage = true
        }
        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beFalse())
    }

    func testSavingAuthenticationWithCorrectPassword() async {
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
                                         registerAuthenticationState: authenticationState)
        )

        await store.send(.saveAuthentication)
        expect(self.mockAppSecurityManager.savePasswordCallsCount) == 1
        expect(self.mockAppSecurityManager.savePasswordReturnValue).to(beTrue())
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1

        await store.receive(.dismissOnboarding)
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingReceivedHideOnboarding) == true

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beTrue())
        expect(self.mockUserDataStore.setOnboardingVersionReceivedInvocations)
            .to(equal([AppVersion.current.productVersion]))
    }

    func testSavingAuthenticationWithBiometry() async {
        let selectedOption: AppSecurityOption = .biometry(.faceID)
        let authenticationState = RegisterAuthenticationDomain.State(
            availableSecurityOptions: [],
            selectedSecurityOption: .biometry(.faceID),
            biometrySuccessful: true
        )
        let store = testStore(
            with: OnboardingDomain.State(
                composition: OnboardingDomain.Composition.allPages,
                registerAuthenticationState: authenticationState
            )
        )

        await store.send(.saveAuthentication)
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1

        await store.receive(.dismissOnboarding)
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingReceivedHideOnboarding) == true

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beTrue())
        expect(self.mockUserDataStore.setOnboardingVersionReceivedInvocations)
            .to(equal([AppVersion.current.productVersion]))
    }

    func testAddNextViewAfterLegalConfirm() async {
        let store = testStore(
            with: OnboardingDomain.State(
                legalConfirmed: false,
                composition: OnboardingDomain.Composition(currentPageIndex: 1, pages: [.start, .legalInfo])
            )
        )

        await store.send(.setConfirmLegal(true)) { store in
            store.legalConfirmed = true
            store.composition.pages = [.start, .legalInfo, .registerAuthentication, .analytics]
        }

        await store.send(.nextPage) { store in
            store.composition.currentPageIndex = 2
        }
    }

    func testResetViewAfterLegalUnchecked() async {
        let store = testStore(
            with: OnboardingDomain.State(
                legalConfirmed: true,
                composition: OnboardingDomain.Composition(
                    currentPageIndex: 1,
                    pages: [.start, .legalInfo, .registerAuthentication]
                )
            )
        )

        await store.send(.setConfirmLegal(false)) { store in
            store.legalConfirmed = false
            store.composition.pages = [.start, .legalInfo]
        }
    }
}
