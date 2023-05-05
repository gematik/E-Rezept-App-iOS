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
@testable import eRpApp
import Nimble
import XCTest

final class SettingsDomainTests: XCTestCase {
    var mockTracker = MockTracker()
    let mockUserSessionContainer = MockUsersSessionContainer()
    let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
    typealias TestStore = ComposableArchitecture.TestStore<
        SettingsDomain.State,
        SettingsDomain.Action,
        SettingsDomain.State,
        SettingsDomain.Action,
        Void
    >

    func testStore() -> TestStore {
        testStore(for: SettingsDomain.Dummies.state)
    }

    func testStore(for state: SettingsDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: SettingsDomain()
        ) { dependencies in
            dependencies.changeableUserSessionContainer = mockUserSessionContainer
            dependencies.tracker = mockTracker
            dependencies.router = MockRouting()
        }
    }

    func testDemoModeToggleShouldSetDemoModeWhenDemoModeIsFalse() {
        let store = testStore()

        mockUserSessionContainer.underlyingIsDemoMode = Just(false).eraseToAnyPublisher()
        store.send(.demoModeStatusReceived(false))
        // when
        store.send(.toggleDemoModeSwitch) { sut in
            // then
            sut.destination = .alert(SettingsDomain.demoModeOnAlertState)
        }
        expect(self.mockUserSessionContainer.switchToDemoModeCalled).to(beTrue())
    }

    func testDemoModeToggleShouldSetStandardModeWhenDemoModeIsTrue() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: true,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )
        // when
        store.send(.toggleDemoModeSwitch) { sut in
            // then
            sut.destination = .alert(SettingsDomain.demoModeOffAlertState)
        }
        expect(self.mockUserSessionContainer.switchToStandardModeCalled).to(beTrue())
    }

    func testToggleHealthCardView() {
        let store = testStore()

        // when
        store.send(.setNavigation(tag: .egk)) { sut in
            // then
            sut.destination = .egk(.init())
        }

        // when
        store.send(.setNavigation(tag: .egk))

        // when
        store.send(.setNavigation(tag: nil)) { sut in
            // then
            sut.destination = nil
        }
    }

    func testAppTrackingOptInStartsComplyDialog() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )

        // when
        store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking
        }
    }

    func testAppTrackingOptInConfirmAlert() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )

        mockTracker.optIn = false

        // when
        store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking
        }
        store.send(.confirmedOptInTracking) { sut in
            sut.trackerOptIn = true
            sut.destination = nil
        }

        expect(self.mockTracker.optIn).to(beTrue())
    }

    func testAppTrackingOptInDisableAfterConfirm() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )

        mockTracker.optIn = true

        store.send(.toggleTrackingTapped(false))

        expect(self.mockTracker.optIn).to(beFalse())
    }

    func testAppTrackingOptInCancelAlert() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )
        mockTracker.optIn = false

        // when
        store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking
        }
        store.send(.setNavigation(tag: nil)) { sut in
            sut.trackerOptIn = false
            sut.destination = nil
        }

        expect(self.mockTracker.optIn).to(beFalse())
    }

    func testSelectingAppSecurityOption_From_Biometry_To_Password() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(
                    availableSecurityOptions: [.biometry(.faceID), .password],
                    selectedSecurityOption: .biometry(.faceID)
                )
            )
        )
        mockUserSessionContainer.underlyingUserSession = MockUserSession()

        store.send(.appSecurity(action: .select(.password))) {
            $0.destination = .setAppPassword(
                CreatePasswordDomain.State(
                    mode: CreatePasswordDomain.State.Mode.create,
                    password: "",
                    passwordA: "",
                    passwordB: "",
                    passwordStrength: PasswordStrength.none,
                    showPasswordErrorMessage: false,
                    showOriginalPasswordWrong: false
                )
            )
        }
        store.send(.destination(.setAppPasswordAction(.delegate(.closeAfterPasswordSaved)))) {
            $0.destination = nil
        }
    }

    func testSelectingAppSecurityOption_From_Password_To_New_Password() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(
                    availableSecurityOptions: [.biometry(.faceID), .password],
                    selectedSecurityOption: .password
                )
            )
        )
        mockUserSessionContainer.underlyingUserSession = MockUserSession()

        store.send(.appSecurity(action: .select(.password))) {
            $0.destination = .setAppPassword(
                CreatePasswordDomain.State(
                    mode: CreatePasswordDomain.State.Mode.update,
                    password: "",
                    passwordA: "",
                    passwordB: "",
                    passwordStrength: PasswordStrength.none,
                    showPasswordErrorMessage: false,
                    showOriginalPasswordWrong: false
                )
            )
        }
        store.send(.destination(.setAppPasswordAction(.delegate(.closeAfterPasswordSaved)))) {
            $0.destination = nil
        }
    }

    func testSelectingAppSecurityOption_From_Password_To_Biometry() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(
                    availableSecurityOptions: [.biometry(.touchID), .password],
                    selectedSecurityOption: .password
                )
            )
        )
        mockUserSessionContainer.underlyingUserSession = MockUserSession()

        store.dependencies.userDataStore = MockUserDataStore()

        store.send(.appSecurity(action: .select(.biometry(.touchID)))) {
            $0.appSecurityState.selectedSecurityOption = .biometry(.touchID)
        }
    }
}
