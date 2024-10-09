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
import Nimble
import XCTest

@MainActor
final class SettingsDomainTests: XCTestCase {
    var mockTracker = MockTracker()
    let mockUserSessionContainer = MockUsersSessionContainer()
    let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
    let mockResourceHandler = MockResourceHandler()
    typealias TestStore = TestStoreOf<SettingsDomain>

    func testStore() -> TestStore {
        testStore(for: SettingsDomain.Dummies.state)
    }

    func testStore(for state: SettingsDomain.State) -> TestStore {
        TestStore(initialState: state) {
            SettingsDomain()
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = mockUserSessionContainer
            dependencies.tracker = mockTracker
            dependencies.router = MockRouting()
            dependencies.resourceHandler = mockResourceHandler
        }
    }

    func testDemoModeToggleShouldSetDemoModeWhenDemoModeIsFalse() async {
        let store = testStore()

        mockUserSessionContainer.underlyingIsDemoMode = Just(false).eraseToAnyPublisher()
        await store.send(.response(.demoModeStatusReceived(false)))
        // when
        await store.send(.toggleDemoModeSwitch(true)) { sut in
            // then
            sut.destination = .alert(.info(SettingsDomain.demoModeOnAlertState))
        }
        expect(self.mockUserSessionContainer.switchToDemoModeCalled).to(beTrue())
    }

    func testDemoModeToggleShouldSetStandardModeWhenDemoModeIsTrue() async {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: true
            )
        )
        // when
        await store.send(.toggleDemoModeSwitch(false)) { sut in
            // then
            sut.destination = .alert(.info(SettingsDomain.demoModeOffAlertState))
        }
        expect(self.mockUserSessionContainer.switchToStandardModeCalled).to(beTrue())
    }

    func testLanguageSettings() async {
        let store = testStore()

        await store.send(.languageSettingsTapped) { sut in
            sut.destination = .alert(.info(SettingsDomain.languageSettingsAlertState))
        }

        expect(self.mockResourceHandler.openCalled).to(beFalse())

        await store.send(.destination(.presented(.alert(.openSettings))))

        expect(self.mockResourceHandler.openCalled).to(beTrue())
    }

    func testToggleHealthCardView() async {
        let store = testStore()

        // when
        await store.send(.tappedEgk) { sut in
            // then
            sut.destination = .egk(.init())
        }

        // when
        await store.send(.tappedEgk)

        // when
        await store.send(.resetNavigation) { sut in
            // then
            sut.destination = nil
        }
    }

    func testAppTrackingOptInStartsComplyDialog() async {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false
            )
        )

        // when
        await store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking(.init())
        }
    }

    func testAppTrackingOptInConfirmAlert() async {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false
            )
        )

        mockTracker.optIn = false

        // when
        await store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking(.init())
        }
        await store.send(.confirmedOptInTracking) { sut in
            sut.trackerOptIn = true
            sut.destination = nil
        }

        expect(self.mockTracker.optIn).to(beTrue())
    }

    func testAppTrackingOptInDisableAfterConfirm() async {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false
            )
        )

        mockTracker.optIn = true

        await store.send(.toggleTrackingTapped(false))

        expect(self.mockTracker.optIn).to(beFalse())
    }

    func testAppTrackingOptInCancelAlert() async {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false
            )
        )
        mockTracker.optIn = false

        // when
        await store.send(.toggleTrackingTapped(true)) { sut in
            // then
            sut.trackerOptIn = false
            sut.destination = .complyTracking(.init())
        }
        await store.send(.resetNavigation) { sut in
            sut.trackerOptIn = false
            sut.destination = nil
        }

        expect(self.mockTracker.optIn).to(beFalse())
    }
}
