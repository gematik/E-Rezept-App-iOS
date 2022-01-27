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

import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import XCTest

final class GroupedPrescriptionListViewTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        GroupedPrescriptionListDomain.State,
        GroupedPrescriptionListDomain.State,
        GroupedPrescriptionListDomain.Action,
        GroupedPrescriptionListDomain.Action,
        GroupedPrescriptionListDomain.Environment
    >

    var userSession: MockUserSession!
    var userDataStore: MockUserDataStore {
        userSession.mockUserDataStore
    }

    override func setUp() {
        super.setUp()

        userSession = MockUserSession()
    }

    private func testStore(for groupedPrescriptionStore: GroupedPrescriptionRepository,
                           isAuthenticated: Bool = true) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())

        let loginHandler = LoginHandlerMock()
        loginHandler.isAuthenticatedOrAuthenticateReturnValue =
            Just(LoginResult.success(isAuthenticated))
                .eraseToAnyPublisher()

        userSession.isLoggedIn = isAuthenticated

        return TestStore(
            initialState: GroupedPrescriptionListDomain.State(),
            reducer: GroupedPrescriptionListDomain.domainReducer,
            environment: GroupedPrescriptionListDomain.Environment(
                router: MockRouting(),
                userSession: userSession,
                serviceLocator: ServiceLocator(),
                accessibilityAnnouncementReceiver: { _ in },
                groupedPrescriptionStore: groupedPrescriptionStore,
                schedulers: schedulers,
                fhirDateFormatter: FHIRDateFormatter.shared,
                loginHandler: loginHandler,
                signatureProvider: DummySecureEnclaveSignatureProvider()
            )
        )
    }

    private func testStore(groups: [GroupedPrescription],
                           auditEvents _: [ErxAuditEvent],
                           isAuthenticated: Bool = true) -> TestStore {
        testStore(for: MockGroupedPrescriptionRepository(groups: groups),
                  isAuthenticated: isAuthenticated)
    }

    func testLoadingPrescriptionsFromDiskTwoTimes() {
        // given
        let input: [GroupedPrescription] = []
        let store = testStore(groups: input,
                              auditEvents: [])

        let expected: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value(input)

        store.assert(
            // when
            .send(.loadLocalGroupedPrescriptions) {
                // then
                $0.loadingState = .loading([])
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadLocalGroupedPrescriptionsReceived(expected)) { state in
                // then
                state.loadingState = expected
                state.groupedPrescriptions = input
            },
            // when
            .send(.loadLocalGroupedPrescriptions) {
                // then
                $0.loadingState = .loading(input)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadLocalGroupedPrescriptionsReceived(expected)) { state in
                // then
                state.loadingState = expected
            }
        )
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenAuthenticated() {
        // given
        let input = [GroupedPrescription.Dummies.twoPrescriptions]
        let store = testStore(groups: input,
                              auditEvents: [])

        let expected: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value(input)
        store.assert(
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expected)) { state in
                // then
                state.loadingState = expected
                state.groupedPrescriptions = input
            },
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expected)) { state in
                // then
                state.loadingState = expected
            }
        )
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenNotAuthenticated() {
        // given
        let input = [GroupedPrescription.Dummies.twoPrescriptions]
        let store = testStore(groups: input,
                              auditEvents: [],
                              isAuthenticated: false)

        let expected: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value([])
        store.assert(
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expected)) { state in
                // then
                state.loadingState = expected
            },
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expected)) { state in
                // then
                state.loadingState = expected
            }
        )
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenNotAuthenticated() {
        // given
        let input = [GroupedPrescription.Dummies.twoPrescriptions]
        let store = testStore(groups: input,
                              auditEvents: [],
                              isAuthenticated: false)

        let expectedValueForLoad: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value(input)
        let expectedValueForFetch: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value([])
        store.assert(
            // when
            .send(.loadLocalGroupedPrescriptions) {
                // then
                $0.loadingState = .loading([])
            },
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadLocalGroupedPrescriptionsReceived(expectedValueForLoad)) { state in
                // then
                state.loadingState = expectedValueForLoad
                state.groupedPrescriptions = input
            },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expectedValueForFetch)) { state in
                // then
                state.loadingState = expectedValueForFetch
            }
        )
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenAuthenticated() {
        // given
        let input = [GroupedPrescription.Dummies.twoPrescriptions]
        let store = testStore(groups: input,
                              auditEvents: [],
                              isAuthenticated: true)

        let expectedValueForLoad: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value(input)
        let expectedValueForFetch = expectedValueForLoad
        store.assert(
            // when
            .send(.loadLocalGroupedPrescriptions) {
                // then
                $0.loadingState = .loading([])
            },
            // when
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                // then
                $0.loadingState = .loading(nil)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadLocalGroupedPrescriptionsReceived(expectedValueForLoad)) { state in
                // then
                state.loadingState = expectedValueForLoad
                state.groupedPrescriptions = input
            },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expectedValueForFetch)) { state in
                // then
                state.loadingState = expectedValueForFetch
            }
        )
    }

    let loadingErrorTasks: ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType> =
        .local(.notImplemented)
    let loadingErrorAuditEvents: ErxRepositoryError<ErxTaskCoreDataStore.ErrorType, ErxTaskFHIRDataStore.ErrorType> =
        .local(.notImplemented)

    func testLoadingFromDiskWithError() {
        let groupedPrescriptionStore = MockGroupedPrescriptionRepository(
            loadFromDisk: Fail(error: loadingErrorTasks).eraseToAnyPublisher(),
            loadedFromCloudAndSaved: Fail(error: loadingErrorTasks).eraseToAnyPublisher()
        )
        let store = testStore(for: groupedPrescriptionStore)

        let expected: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .error(loadingErrorTasks)
        store.assert(
            // when
            .send(.loadLocalGroupedPrescriptions) {
                // then
                $0.loadingState = .loading([])
                XCTAssert($0.loadingState.isError == false)
            },
            // when
            .do { self.testScheduler.advance() },
            .receive(.loadLocalGroupedPrescriptionsReceived(expected)) { state in
                // then
                state.loadingState = expected
                XCTAssert(state.loadingState.isError == true)
            }
        )
    }

    func testLoadingFromCloudWithError() {
        let groupedPrescriptionStore = MockGroupedPrescriptionRepository(
            loadFromDisk: Fail(error: loadingErrorTasks).eraseToAnyPublisher(),
            loadedFromCloudAndSaved: Fail(error: loadingErrorTasks).eraseToAnyPublisher()
        )
        let store = testStore(for: groupedPrescriptionStore)
        let expectedTasks: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .idle

        store.assert(
            .send(.loadRemoteGroupedPrescriptionsAndSave) {
                $0.loadingState = .loading(nil)
                XCTAssert($0.loadingState.isError == false)
            },
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expectedTasks)) { state in
                // then
                state.loadingState = expectedTasks
                XCTAssert(state.loadingState.isError == false)
            }
        )
    }

    func testRefreshShouldShowCardWallWhenNotAuthenticated() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
        let store = testStore(groups: [],
                              auditEvents: [],
                              isAuthenticated: false)

        let expected = CardWallDomain.State(
            introAlreadyDisplayed: false,
            isNFCReady: true,
            isMinimalOS14: true,
            pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
            loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
        )
        store.assert(
            .send(.refresh) {
                $0.loadingState = .loading(nil)
            },
            .do { self.testScheduler.advance() },
            .receive(.showCardWallReceived(expected)) { state in
                state.cardWallState = expected
            }
        )
    }

    func testRefreshShouldShowCardWallServerResponseIs403Forbidden() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
        let repository = MockGroupedPrescriptionRepository(groups: [])
        repository.loadRemoteAndSavePublisher = Fail(
            error: ErxTaskRepositoryError.remote(
                .fhirClientError(.httpError(.httpError(.init(URLError.Code(rawValue: 403)))))
            )
        ).eraseToAnyPublisher()
        let store = testStore(for: repository,
                              isAuthenticated: true)

        let expected = CardWallDomain.State(
            introAlreadyDisplayed: false,
            isNFCReady: true,
            isMinimalOS14: true,
            pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
            loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
        )
        store.assert(
            .send(.refresh) {
                $0.loadingState = .loading(nil)
            },
            .do { self.testScheduler.advance() },
            .receive(.showCardWallReceived(expected)) { state in
                state.cardWallState = expected
            }
        )
    }

    func testRefreshShouldShowCardWallServerResponseIs401Unauthorized() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()

        let repository = MockGroupedPrescriptionRepository(groups: [])
        repository.loadRemoteAndSavePublisher = Fail(
            error: ErxTaskRepositoryError.remote(
                .fhirClientError(.httpError(.httpError(.init(URLError.Code(rawValue: 401)))))
            )
        ).eraseToAnyPublisher()
        let store = testStore(for: repository,
                              isAuthenticated: true)

        let expected = CardWallDomain.State(
            introAlreadyDisplayed: false,
            isNFCReady: true,
            isMinimalOS14: true,
            pin: CardWallPINDomain.State(isDemoModus: false, pin: ""),
            loginOption: CardWallLoginOptionDomain.State(isDemoModus: false)
        )
        store.assert(
            .send(.refresh) {
                $0.loadingState = .loading(nil)
            },
            .do { self.testScheduler.advance() },
            .receive(.showCardWallReceived(expected)) { state in
                state.cardWallState = expected
            }
        )
    }

    func testRefreshShouldLoadFromCloudWhenAuthenticated() {
        let input = [GroupedPrescription.Dummies.twoPrescriptions]
        let store = testStore(groups: input,
                              auditEvents: [],
                              isAuthenticated: true)

        let expected: LoadingState<[GroupedPrescription], AnyErxTaskRepository.ErrorType> =
            .value(input)

        store.assert(
            .send(.refresh) {
                $0.loadingState = .loading(nil)
            },
            .do { self.testScheduler.advance() },
            .receive(.loadRemoteGroupedPrescriptionsAndSaveReceived(expected)) { state in
                state.loadingState = expected
                state.groupedPrescriptions = input
            }
        )
    }

    func testNavigateIntoLowDetailPrescriptionDetails() {
        // given
        let prescription = PrescriptionDetailDomain.Dummies.state.prescription
        let groupedPrescription = GroupedPrescription(
            id: "1",
            title: "Scanned Prescription",
            authoredOn: "2020-02-03",
            prescriptions: [prescription],
            displayType: GroupedPrescription.DisplayType.lowDetail
        )
        let store = testStore(groups: [groupedPrescription],
                              auditEvents: [],
                              isAuthenticated: true)

        let expectedState = PrescriptionDetailDomain.State(
            prescription: prescription,
            isArchived: false
        )

        store.assert(
            // when
            .send(
                .prescriptionDetailViewTapped(selectedPrescription: prescription)
            ) {
                // then
                $0.selectedPrescriptionDetailState = expectedState
            }
        )
    }
}
