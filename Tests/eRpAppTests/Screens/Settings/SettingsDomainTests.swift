//
//  Copyright (c) 2021 gematik GmbH
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

import ComposableArchitecture
@testable import eRpApp
import XCTest

final class SettingsDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        SettingsDomain.State,
        SettingsDomain.State,
        SettingsDomain.Action,
        SettingsDomain.Action,
        SettingsDomain.Environment
    >

    func testStore() -> TestStore {
        testStore(for: SettingsDomain.Dummies.state)
    }

    func testStore(for state: SettingsDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: SettingsDomain.reducer,
            environment: SettingsDomain.Environment(
                changeableUserSessionContainer: MockUserSessionContainer(),
                schedulers: Schedulers(uiScheduler: DispatchQueue.test.eraseToAnyScheduler()),
                tracker: DummyTracker(),
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )
    }

    func testDemoModeToggleShouldSetDemoMode() {
        let store = testStore()

        store.assert(
            // when
            .send(.toggleDemoModeSwitch) { sut in
                // then
                sut.isDemoMode = true
                sut.alertState = SettingsDomain.demoModeOnAlertState
            }
        )
    }

    func testDemoModeToggleShouldUnsetDemoMode() {
        let store = testStore(for: SettingsDomain.State(isDemoMode: true))

        store.assert(
            // when
            .send(.toggleDemoModeSwitch) { sut in
                // then
                sut.isDemoMode = false
                sut.alertState = SettingsDomain.demoModeOffAlertState
            }
        )
    }

    func testAppTrackingOptInStartsComplyDialog() {
        let store = testStore(for: SettingsDomain.State(isDemoMode: false))

        store.assert(
            // when
            .send(.toggleTrackingTapped(true)) { sut in
                // then
                sut.trackerOptIn = false
                sut.showTrackerComplyView = true
            }
        )
    }

    func testAppTrackingOptInConfirmAlert() {
        let store = testStore(for: SettingsDomain.State(isDemoMode: false))

        store.assert(
            // when
            .send(.toggleTrackingTapped(true)) { sut in
                // then
                sut.trackerOptIn = false
                sut.showTrackerComplyView = true
            },
            .send(.confirmedOptInTracking) { sut in
                sut.trackerOptIn = true
                sut.trackerOptIn = UserDefaults.standard.kAppTrackingAllowed
                sut.showTrackerComplyView = false
            }
        )
    }

    func testAppTrackingOptInCancelAlert() {
        let store = testStore(for: SettingsDomain.State(isDemoMode: false))

        store.assert(
            // when
            .send(.toggleTrackingTapped(true)) { sut in
                // then
                sut.trackerOptIn = false
                sut.showTrackerComplyView = true
            },
            .send(.confirmedOptInTracking) { sut in
                sut.trackerOptIn = false
                sut.trackerOptIn = UserDefaults.standard.kAppTrackingAllowed
                sut.showTrackerComplyView = false
            }
        )
    }
}
