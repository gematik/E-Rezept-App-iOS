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
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class OnboardingDomainTests: XCTestCase {
    let mockUserDataStore = MockUserDataStore()
    let mockAppSecurityManager = MockAppSecurityManager()
    let testScheduler = DispatchQueue.test
    static let now = Date()
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
            dependencies.date = DateGenerator.constant(Self.now)
            dependencies.tracker = PlaceholderTracker()
        }
    }

    func testSavingAuthenticationWithCorrectPassword() async {
        let selectedOption: AppSecurityOption = .password
        mockAppSecurityManager.savePasswordReturnValue = true
        let state = RegisterPasswordDomain.State(
            passwordA: "ABC",
            passwordB: "ABC",
            passwordStrength: .excellent
        )
        var path = StackState<OnboardingDomain.Path.State>()
        path.append(.registerPassword(state))

        let store = testStore(
            with: OnboardingDomain.State(path: path)
        )

        await store.send(.path(.element(id: 0, action: .registerPassword(.delegate(.nextPage)))))
        await store.receive(.showAnalytics) { state in
            state.path[id: 1] = .analytics
        }
        expect(self.mockAppSecurityManager.savePasswordCallsCount) == 1
        expect(self.mockAppSecurityManager.savePasswordReturnValue).to(beTrue())
        expect(self.mockUserDataStore.setAppSecurityOptionReceivedAppSecurityOption) == selectedOption
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
    }

    func testSavingAuthenticationWithBiometry() async {
        let state = RegisterAuthenticationDomain.State(availableSecurityOptions: [])
        var path = StackState<OnboardingDomain.Path.State>()
        path.append(.registerAuth(state))

        let store = testStore(
            with: OnboardingDomain.State(path: path)
        )

        await store.send(.path(.element(id: 0, action: .registerAuth(.delegate(.nextPage)))))
        await store.receive(.showAnalytics) { state in
            state.path[id: 1] = .analytics
        }
        expect(self.mockUserDataStore.setAppSecurityOptionCallsCount) == 1
    }

    func testDismissOnboarding() async {
        let store = testStore(
            with: OnboardingDomain.State()
        )

        await store.send(.allowTracking)

        await store.receive(.dismissOnboarding)
        expect(self.mockUserDataStore.setHideOnboardingCallsCount) == 1
        expect(self.mockUserDataStore.setHideOnboardingReceivedHideOnboarding) == true

        expect(self.mockUserDataStore.setOnboardingVersionCalled).to(beTrue())
        expect(self.mockUserDataStore.setOnboardingVersionReceivedInvocations)
            .to(equal([AppVersion.current.productVersion]))
    }
}
