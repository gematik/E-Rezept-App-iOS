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

import ComposableArchitecture
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

final class MainDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    let mockUserDataStore = MockUserDataStore()

    typealias TestStore = ComposableArchitecture.TestStore<
        MainDomain.State,
        MainDomain.Action,
        MainDomain.State,
        MainDomain.Action,
        MainDomain.Environment
    >

    func testStore() -> TestStore {
        testStore(for: MainDomain.Dummies.state)
    }

    func testStore(for state: MainDomain.State) -> TestStore {
        TestStore(initialState: state,
                  reducer: MainDomain.reducer,
                  environment: MainDomain.Environment(
                      router: DummyRouter(),
                      userSessionContainer: DummyUserSessionContainer(),
                      userSession: DummySessionContainer(),
                      appSecurityManager: DemoAppSecurityPasswordManager(),
                      serviceLocator: ServiceLocator(),
                      accessibilityAnnouncementReceiver: { _ in },
                      erxTaskRepository: DummySessionContainer().erxTaskRepository,
                      schedulers: Schedulers(),
                      fhirDateFormatter: globals.fhirDateFormatter,
                      userProfileService: DummyUserProfileService(),
                      secureDataWiper: DummyProfileSecureDataWiper(),
                      signatureProvider: DummySecureEnclaveSignatureProvider(),
                      userSessionProvider: DummyUserSessionProvider(),
                      userDataStore: mockUserDataStore,
                      tracker: DummyTracker()
                  ))
    }

    func testDemoModeChange() {
        // given
        let sut = testStore()

        // when
        sut.send(.demoModeChangeReceived(true)) { sut in
            // then
            sut.isDemoMode = true
        }

        // when
        sut.send(.demoModeChangeReceived(false)) { sut in
            // then
            sut.isDemoMode = false
        }
    }

    func testWhenLoadingProfileWithError() {
        // given
        let sut = testStore()
        let error = UserProfileServiceError.localStoreError(.notImplemented)

        // when
        sut.send(.horizontalProfileSelection(action: .loadReceived(.failure(error)))) { sut in
            // then
            sut.route = .alert(.init(for: error))
        }
    }

    func testWelcomeDrawerRoute() {
        // given
        let sut = testStore(for: .init(prescriptionListState: .init(),
                                       horizontalProfileSelectionState: .init()))
        // when
        mockUserDataStore.underlyingHideWelcomeDrawer = false
        sut.send(.showWelcomeDrawer) { state in
            // then
            state.route = .welcomeDrawer
        }
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beTrue())

        // when
        sut.send(.showWelcomeDrawer)
        // then
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beTrue())
    }

    func testWelcomeDrawerNotPresentedWhileRouteSet() {
        // given
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init(),
            route: .deviceSecurity(DeviceSecurityDomain.State(warningType: .devicePinMissing))
        ))
        // when
        mockUserDataStore.underlyingHideWelcomeDrawer = false

        sut.send(.showWelcomeDrawer)
        // then
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beFalse())
    }

    func testRedeemPrescriptionsOnlyWithReadyStatus() {
        // given
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        let expectedPrescription = Prescription(erxTask: ErxTask.Fixtures.erxTask1)
        let nonReadyPrescriptions = [
            Prescription(erxTask: ErxTask.Fixtures.erxTask9),
            Prescription(erxTask: ErxTask.Fixtures.erxTask10),
            Prescription(erxTask: ErxTask.Fixtures.erxTask11),
        ]
        // when
        sut
            .send(.prescriptionList(action: .redeemButtonTapped(openPrescriptions: nonReadyPrescriptions +
                    [expectedPrescription]))) { state in
                    state.route = .redeem(RedeemMethodsDomain.State(erxTasks: [expectedPrescription.erxTask]))
            }
    }
}
