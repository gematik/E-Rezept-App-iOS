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
            sut.destination = .alert(.info(SettingsDomain.demoModeOnAlertState))
        }
        expect(self.mockUserSessionContainer.switchToDemoModeCalled).to(beTrue())
    }

    func testDemoModeToggleShouldSetStandardModeWhenDemoModeIsTrue() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: true
            )
        )
        // when
        store.send(.toggleDemoModeSwitch) { sut in
            // then
            sut.destination = .alert(.info(SettingsDomain.demoModeOffAlertState))
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
                isDemoMode: false
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
                isDemoMode: false
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
                isDemoMode: false
            )
        )

        mockTracker.optIn = true

        store.send(.toggleTrackingTapped(false))

        expect(self.mockTracker.optIn).to(beFalse())
    }

    func testAppTrackingOptInCancelAlert() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false
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
}
