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

import ComposableArchitecture
@testable import eRpApp
import Nimble
import XCTest

final class SettingsDomainTests: XCTestCase {
    var mockTracker = MockTracker()
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
                tracker: mockTracker,
                signatureProvider: DummySecureEnclaveSignatureProvider(),
                nfcHealthCardPasswordController: DummyNFCHealthCardPasswordController(),
                appSecurityManager: DummyAppSecurityManager(),
                router: MockRouting(),
                userSessionProvider: MockUserSessionProvider(),
                accessibilityAnnouncementReceiver: { _ in }
            )
        )
    }

    func testDemoModeToggleShouldSetDemoMode() {
        let store = testStore()

        // when
        store.send(.toggleDemoModeSwitch) { sut in
            // then
            sut.isDemoMode = true
            sut.alertState = SettingsDomain.demoModeOnAlertState
        }
    }

    func testToggleHealthCardView() {
        let store = testStore()

        // when
        store.send(.toggleOrderHealthCardView(true)) { sut in
            // then
            sut.showOrderHealthCardView = true
        }

        // when
        store.send(.toggleOrderHealthCardView(true))

        // when
        store.send(.toggleOrderHealthCardView(false)) { sut in
            // then
            sut.showOrderHealthCardView = false
        }
    }

    func testDemoModeToggleShouldUnsetDemoMode() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: true,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )

        // when
        store.send(.toggleDemoModeSwitch) { sut in
            // then
            sut.isDemoMode = false
            sut.alertState = SettingsDomain.demoModeOffAlertState
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
            sut.showTrackerComplyView = true
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
            sut.showTrackerComplyView = true
        }
        store.send(.confirmedOptInTracking) { sut in
            sut.trackerOptIn = true
            sut.showTrackerComplyView = false
        }

        expect(self.mockTracker.optInCalled).to(beTrue())
        expect(self.mockTracker.optIn).to(beTrue())
        expect(self.mockTracker.optInPublisherCalled).to(beFalse())
    }

    func testAppTrackingOptInDisableAferConfirm() {
        let store = testStore(
            for: SettingsDomain.State(
                isDemoMode: false,
                appSecurityState: AppSecurityDomain.State(availableSecurityOptions: [.password])
            )
        )

        mockTracker.optIn = true

        store.send(.toggleTrackingTapped(false))

        expect(self.mockTracker.optInCalled).to(beTrue())
        expect(self.mockTracker.optIn).to(beFalse())
        expect(self.mockTracker.optInPublisherCalled).to(beFalse())
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
            sut.showTrackerComplyView = true
        }
        store.send(.dismissTrackerComplyView) { sut in
            sut.trackerOptIn = false
            sut.showTrackerComplyView = false
        }

        expect(self.mockTracker.optInCalled).to(beTrue())
        expect(self.mockTracker.optIn).to(beFalse())
        expect(self.mockTracker.optInPublisherCalled).to(beFalse())
    }
}
