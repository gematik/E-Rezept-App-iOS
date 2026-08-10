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
import Nimble
import Synchronization
import XCTest

@MainActor
final class SettingsDomainTests: XCTestCase {
    var mockTracker = DummyTracker()
    let mockUserSessionContainer = UsersSessionContainerMock()
    let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
    typealias TestStore = TestStoreOf<SettingsDomain>

    func testStore(
        for state: SettingsDomain.State = SettingsDomain.Dummies.state,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        TestStore(initialState: state) {
            SettingsDomain()
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = mockUserSessionContainer
            dependencies.tracker = mockTracker
            dependencies.router = RoutingMock()

            prepareDependencies(&dependencies)
        }
    }

    func testDemoModeToggleShouldSetDemoModeWhenDemoModeIsFalse() async {
        let store = testStore()

        @Shared(.isDemoMode) var isDemoMode
        $isDemoMode.withLock { $0 = false }

        // when
        await store.send(.toggleDemoModeSwitch(true)) { sut in
            // then
            sut.destination = .alert(.info(SettingsDomain.demoModeOnAlertState))
            sut.$isDemoMode.withLock { $0 = true }
        }
    }

    func testDemoModeToggleShouldSetStandardModeWhenDemoModeIsTrue() async {
        @Shared(.isDemoMode) var isDemoMode
        $isDemoMode.withLock { $0 = true }

        let store = testStore(
            for: SettingsDomain.State()
        )
        // when
        await store.send(.toggleDemoModeSwitch(false)) { sut in
            // then
            sut.destination = .alert(.info(SettingsDomain.demoModeOffAlertState))
            sut.$isDemoMode.withLock { $0 = false }
        }
    }

    @available(iOS 18.0, *)
    func testLanguageSettings() async {
        let openedURL = Mutex<URL?>(nil)

        let store = testStore { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in true }
            dependencies.openURLHandler.open = { url in
                openedURL.withLock { $0 = url }
                return true
            }
        }

        await store.send(.languageSettingsTapped) { sut in
            sut.destination = .alert(.info(SettingsDomain.languageSettingsAlertState))
        }

        expect(openedURL.withLock { $0 }).to(beNil())

        await store.send(.destination(.presented(.alert(.openSettings))))

        expect(openedURL.withLock { $0 }).toNot(beNil())
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
            for: SettingsDomain.State()
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
            for: SettingsDomain.State()
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
            for: SettingsDomain.State()
        )

        mockTracker.optIn = true

        await store.send(.toggleTrackingTapped(false))

        expect(self.mockTracker.optIn).to(beFalse())
    }

    func testAppTrackingOptInCancelAlert() async {
        let store = testStore(
            for: SettingsDomain.State()
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
