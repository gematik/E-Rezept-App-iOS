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
import eRpKit
@testable import IDP
import Nimble
import XCTest

final class MainDomainTests: XCTestCase {
    typealias TestStore = ComposableArchitecture.TestStore<
        MainDomain.State,
        MainDomain.Action,
        MainDomain.State,
        MainDomain.Action,
        Void
    >

    let testScheduler = DispatchQueue.immediate
    var mockUserDataStore: MockUserDataStore!
    var mockUserSessionContainer: MockUsersSessionContainer!
    var mockRouter: MockRouting!
    var mockUserSession: MockUserSession!
    var mockDeviceSecurityManager: MockDeviceSecurityManager!
    var mockPrescriptionRepository: MockPrescriptionRepository!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        mockUserSessionContainer = MockUsersSessionContainer()
        mockRouter = MockRouting()
        mockUserSession = MockUserSession()
        mockDeviceSecurityManager = MockDeviceSecurityManager()
        mockPrescriptionRepository = MockPrescriptionRepository()
    }

    func testStore() -> TestStore {
        testStore(for: MainDomain.Dummies.state)
    }

    func testStore(for state: MainDomain.State) -> TestStore {
        TestStore(initialState: state, reducer: MainDomain()) { dependencies in
            dependencies.userSession = mockUserSession
            dependencies.changeableUserSessionContainer = mockUserSessionContainer
            dependencies.erxTaskRepository = DummySessionContainer().erxTaskRepository
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.fhirDateFormatter = FHIRDateFormatter.testValue
            dependencies.userDataStore = mockUserDataStore
            dependencies.deviceSecurityManager = mockDeviceSecurityManager
            dependencies.router = mockRouter
            dependencies.prescriptionRepository = mockPrescriptionRepository
            dependencies.serviceLocator = ServiceLocator()
        }
    }

    func testDemoModeChange() {
        // given
        let sut = testStore()

        // when
        mockUserSessionContainer.underlyingIsDemoMode = Just(true).eraseToAnyPublisher()
        sut.send(.subscribeToDemoModeChange)
        sut.receive(.response(.demoModeChangeReceived(true))) { sut in
            // then
            sut.isDemoMode = true
        }

        // when
        mockUserSessionContainer.underlyingIsDemoMode = Just(false).eraseToAnyPublisher()
        sut.send(.response(.demoModeChangeReceived(false))) { sut in
            // then
            sut.isDemoMode = false
        }

        sut.send(.unsubscribeFromDemoModeChange)
    }

    func testTurnOffDemoMode() {
        // given
        let sut = testStore()

        sut.send(.turnOffDemoMode)
        expect(self.mockRouter.routeToCalled).to(beTrue())
    }

    func testShowScanner() {
        // given
        let sut = testStore()

        sut.send(.showScannerView) {
            $0.destination = .scanner(ScannerDomain.State())
        }
    }

    func testLoadingADeviceSecurityWarning() {
        let sut = testStore()

        let expectedWarning = DeviceSecurityWarningType.jailbreakDetected
        mockDeviceSecurityManager.underlyingShowSystemSecurityWarning = Just(expectedWarning).eraseToAnyPublisher()

        let deviceSecurityState = DeviceSecurityDomain.State(warningType: expectedWarning)
        sut.send(.loadDeviceSecurityView)
        sut.receive(.response(.loadDeviceSecurityViewReceived(deviceSecurityState))) {
            $0.destination = .deviceSecurity(deviceSecurityState)
        }
    }

    func testLoadingNoneDeviceSecurityWarning() {
        let sut = testStore()

        mockDeviceSecurityManager.underlyingShowSystemSecurityWarning = Just(DeviceSecurityWarningType.none)
            .eraseToAnyPublisher()

        sut.send(.loadDeviceSecurityView)
        sut.receive(.response(.loadDeviceSecurityViewReceived(nil)))
    }

    func testWhenLoadingProfileWithError() {
        // given
        let sut = testStore()
        let error = UserProfileServiceError.localStoreError(.notImplemented)

        // when
        sut.send(.horizontalProfileSelection(action: .response(.loadReceived(.failure(error))))) { sut in
            // then
            sut.destination = .alert(.init(for: error, primaryButton: .cancel(
                TextState("Okay"),
                action: .send(.setNavigation(tag: nil))
            )))
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
            state.destination = .welcomeDrawer
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
            destination: .deviceSecurity(DeviceSecurityDomain.State(warningType: .devicePinMissing)),
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        // when
        mockUserDataStore.underlyingHideWelcomeDrawer = false

        sut.send(.showWelcomeDrawer)
        // then
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beFalse())
    }

    func testShowingLoginNecessaryAlertAfterIDPErrorServerResponse() {
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        let expectedError = LoginHandlerError.idpError(.serverError(IDPError.ServerResponse(
            error: "2000",
            errorText: "access_denied",
            timestamp: Int(Date().timeIntervalSince1970),
            uuid: "error-id-as-uuid",
            code: "2000"
        )))
        mockPrescriptionRepository
            .forcedLoadRemoteForReturnValue = Fail(error: PrescriptionRepositoryError.loginHandler(expectedError))
            .eraseToAnyPublisher()

        sut.send(.refreshPrescription)
        sut.receive(.prescriptionList(action: .refresh)) {
            $0.prescriptionListState.loadingState = .loading(nil)
        }
        sut.receive(.prescriptionList(action: .response(.errorReceived(expectedError)))) {
            $0.prescriptionListState.loadingState = .idle
            $0.destination = .alert(MainDomain.AlertStates.loginNecessaryAlert(for: expectedError))
        }
    }

    func testInvalidateAccessTokenGetsCalledWhenShowingCardWall() {
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))

        expect(self.mockUserSession.mockIDPSession.invalidateAccessToken_Called).to(beFalse())
        sut.send(.setNavigation(tag: .cardWall)) {
            $0.destination = .cardWall(.init(isNFCReady: true, profileId: self.mockUserSession.profileId))
        }
        expect(self.mockUserSession.mockIDPSession.invalidateAccessToken_Called).to(beTrue())
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
                    state.destination = .redeem(RedeemMethodsDomain.State(erxTasks: [expectedPrescription.erxTask]))
            }
    }
}
