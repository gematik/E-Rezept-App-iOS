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

@MainActor
final class MainDomainTests: XCTestCase {
    typealias TestStore = TestStoreOf<MainDomain>

    let testScheduler = DispatchQueue.immediate
    var mockUserDataStore: MockUserDataStore!
    var mockUserSessionContainer: MockUsersSessionContainer!
    var mockRouter: MockRouting!
    var mockUserSession: MockUserSession!
    var mockDeviceSecurityManager: MockDeviceSecurityManager!
    var mockPrescriptionRepository: MockPrescriptionRepository!
    var mockProfileDataWiper: MockProfileSecureDataWiper!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
        mockUserSessionContainer = MockUsersSessionContainer()
        mockRouter = MockRouting()
        mockUserSession = MockUserSession()
        mockDeviceSecurityManager = MockDeviceSecurityManager()
        mockPrescriptionRepository = MockPrescriptionRepository()
        mockProfileDataWiper = MockProfileSecureDataWiper()
    }

    func testStore() -> TestStore {
        testStore(for: MainDomain.Dummies.state)
    }

    func testStore(for state: MainDomain.State) -> TestStore {
        TestStore(initialState: state) {
            MainDomain()
        } withDependencies: { dependencies in
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
            dependencies.profileSecureDataWiper = mockProfileDataWiper
        }
    }

    func testDemoModeChange() async {
        // given
        let sut = testStore()

        // when
        mockUserSessionContainer.underlyingIsDemoMode = Just(true).eraseToAnyPublisher()
        await sut.send(.subscribeToDemoModeChange)
        await sut.receive(.response(.demoModeChangeReceived(true))) { sut in
            // then
            sut.isDemoMode = true
        }

        // when
        mockUserSessionContainer.underlyingIsDemoMode = Just(false).eraseToAnyPublisher()
        await sut.send(.response(.demoModeChangeReceived(false))) { sut in
            // then
            sut.isDemoMode = false
        }
    }

    func testTurnOffDemoMode() async {
        // given
        let sut = testStore()

        await sut.send(.turnOffDemoMode)
        expect(self.mockRouter.routeToCalled).to(beTrue())
    }

    func testShowScanner() async {
        // given
        let sut = testStore()

        await sut.send(.showScannerView) {
            $0.destination = .scanner(ScannerDomain.State())
        }
    }

    func testLoadingADeviceSecurityWarning() async {
        let sut = testStore()

        let expectedWarning = DeviceSecurityWarningType.jailbreakDetected
        mockDeviceSecurityManager.underlyingShowSystemSecurityWarning = Just(expectedWarning).eraseToAnyPublisher()

        let deviceSecurityState = DeviceSecurityDomain.State(warningType: expectedWarning)
        await sut.send(.loadDeviceSecurityView)
        await sut.receive(.response(.loadDeviceSecurityViewReceived(deviceSecurityState))) {
            $0.destination = .deviceSecurity(deviceSecurityState)
        }
    }

    func testLoadingNoneDeviceSecurityWarning() async {
        let sut = testStore()

        mockDeviceSecurityManager.underlyingShowSystemSecurityWarning = Just(DeviceSecurityWarningType.none)
            .eraseToAnyPublisher()

        await sut.send(.loadDeviceSecurityView)
        await sut.receive(.response(.loadDeviceSecurityViewReceived(nil)))
    }

    func testWhenLoadingProfileWithError() async {
        // given
        let sut = testStore()
        let error = UserProfileServiceError.localStoreError(.notImplemented)

        // when
        await sut.send(.horizontalProfileSelection(action: .response(.loadReceived(.failure(error))))) { sut in
            // then
            sut.destination = .alert(
                .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        TextState("Okay")
                    }
                })
            )
        }
    }

    func testWelcomeDrawerRoute() async {
        // given
        let sut = testStore(for: .init(prescriptionListState: .init(),
                                       horizontalProfileSelectionState: .init()))
        // when
        mockUserDataStore.underlyingHideWelcomeDrawer = false
        await sut.send(.showWelcomeDrawer) { state in
            // then
            state.destination = .welcomeDrawer
        }
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beTrue())

        // when
        await sut.send(.showWelcomeDrawer)
        // then
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beTrue())
    }

    func testWelcomeDrawerNotPresentedWhileRouteSet() async {
        // given
        let sut = testStore(for: .init(
            destination: .deviceSecurity(DeviceSecurityDomain.State(warningType: .devicePinMissing)),
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        // when
        mockUserDataStore.underlyingHideWelcomeDrawer = false

        await sut.send(.showWelcomeDrawer)
        // then
        expect(self.mockUserDataStore.hideWelcomeDrawer).to(beFalse())
    }

    func testShowingLoginNecessaryAlertAfterIDPErrorServerResponse() async {
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        let expectedError = LoginHandlerError.idpError(.serverError(IDPError.ServerResponse(
            error: "2041",
            errorText: "access_denied",
            timestamp: Int(Date().timeIntervalSince1970),
            uuid: "error-id-as-uuid",
            code: "2041"
        )))
        mockPrescriptionRepository
            .forcedLoadRemoteForReturnValue = Fail(error: PrescriptionRepositoryError.loginHandler(expectedError))
            .eraseToAnyPublisher()

        await sut.send(.refreshPrescription)
        await sut.receive(.prescriptionList(action: .refresh)) {
            $0.prescriptionListState.loadingState = .loading(nil)
        }
        await sut.receive(.prescriptionList(action: .response(.errorReceived(expectedError)))) {
            $0.prescriptionListState.loadingState = .idle
            $0.destination = .alert(MainDomain.AlertStates.loginNecessaryAlert(for: expectedError))
        }
    }

    func testShowingDevicePairingInvalidAlert() async {
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
        mockProfileDataWiper.wipeSecureDataOfReturnValue = Just(()).eraseToAnyPublisher()

        await sut.send(.refreshPrescription)
        await sut.receive(.prescriptionList(action: .refresh)) {
            $0.prescriptionListState.loadingState = .loading(nil)
        }
        await sut.receive(.prescriptionList(action: .response(.errorReceived(expectedError)))) {
            $0.prescriptionListState.loadingState = .idle
            $0.destination = .alert(MainDomain.AlertStates.devicePairingInvalid())
        }

        expect(self.mockProfileDataWiper.wipeSecureDataOfCalled).to(beTrue())
    }

    func testInvalidateAccessTokenGetsCalledWhenShowingCardWall() async {
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))

        expect(self.mockUserSession.mockIDPSession.invalidateAccessToken_Called).to(beFalse())
        await sut.send(.setNavigation(tag: .cardWall)) {
            $0.destination = .cardWall(.init(isNFCReady: true, profileId: self.mockUserSession.profileId))
        }
        expect(self.mockUserSession.mockIDPSession.invalidateAccessToken_Called).to(beTrue())
    }

    func testRedeemPrescriptionsOnlyWithReadyStatus() async {
        // given
        let sut = testStore(for: .init(
            prescriptionListState: .init(),
            horizontalProfileSelectionState: .init()
        ))
        let expectedPrescription = Prescription(erxTask: ErxTask.Fixtures.erxTask1,
                                                dateFormatter: UIDateFormatter.testValue)
        let nonReadyPrescriptions = [
            Prescription(erxTask: ErxTask.Fixtures.erxTask9, dateFormatter: UIDateFormatter.testValue),
            Prescription(erxTask: ErxTask.Fixtures.erxTask10, dateFormatter: UIDateFormatter.testValue),
            Prescription(erxTask: ErxTask.Fixtures.erxTask11, dateFormatter: UIDateFormatter.testValue),
        ]
        // when
        await sut
            .send(.prescriptionList(action: .redeemButtonTapped(openPrescriptions: nonReadyPrescriptions +
                    [expectedPrescription]))) { state in
                    state.destination = .redeem(RedeemMethodsDomain.State(erxTasks: [expectedPrescription.erxTask]))
            }
    }
}
