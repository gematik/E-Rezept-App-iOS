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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FHIRClient
import XCTest

final class PrescriptionListDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = ComposableArchitecture.TestStore<
        PrescriptionListDomain.State,
        PrescriptionListDomain.Action,
        PrescriptionListDomain.State,
        PrescriptionListDomain.Action,
        PrescriptionListDomain.Environment
    >

    var mockPrescriptionRepository: MockPrescriptionRepository!
    var userSession: MockUserSession!
    var userDataStore: MockUserDataStore {
        userSession.mockUserDataStore
    }

    override func setUp() {
        super.setUp()

        mockPrescriptionRepository = MockPrescriptionRepository()
        userSession = MockUserSession()
    }

    private func testStore(for prescriptionRepository: PrescriptionRepository) -> TestStore {
        .init(
            initialState: PrescriptionListDomain.State(),
            reducer: PrescriptionListDomain.domainReducer,
            environment: PrescriptionListDomain.Environment(
                router: MockRouting(),
                userSession: userSession,
                userProfileService: DummyUserProfileService(),
                serviceLocator: ServiceLocator(),
                accessibilityAnnouncementReceiver: { _ in },
                prescriptionRepository: prescriptionRepository,
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                fhirDateFormatter: FHIRDateFormatter.shared
            )
        )
    }

    func testLoadingPrescriptionsLocalTwoTimes() {
        // given
        let input: [Prescription] = []
        mockPrescriptionRepository.loadLocalReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)

        // when
        store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        testScheduler.advance()
        store.receive(.loadLocalPrescriptionsReceived(expected)) { state in
            // then
            state.loadingState = expected
            state.prescriptions = input
        }
        // when
        store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading(input)
        }
        // when
        testScheduler.advance()
        store.receive(.loadLocalPrescriptionsReceived(expected)) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenAuthenticated() {
        // given
        let input = Prescription.Fixtures.prescriptions

        let returnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository.silentLoadRemoteForReturnValue = returnValue
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expected)) { state in
            // then
            state.loadingState = expected
            state.prescriptions = input
        }
        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expected)) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenNotAuthenticated() {
        // given
        mockPrescriptionRepository.silentLoadRemoteForReturnValue = Just(.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value([])

        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expected)) { state in
            // then
            state.loadingState = expected
        }
        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expected)) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenNotAuthenticated() {
        // given
        let input = Prescription.Fixtures.prescriptions
        mockPrescriptionRepository.loadLocalReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository
            .silentLoadRemoteForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self).eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expectedValueForLoad: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        let expectedValueForFetch: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value([])
        // when
        store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadLocalPrescriptionsReceived(expectedValueForLoad)) { state in
            // then
            state.loadingState = expectedValueForLoad
            state.prescriptions = input
        }
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expectedValueForFetch)) { state in
            // then
            state.loadingState = expectedValueForFetch
        }
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenAuthenticated() {
        // given
        let input = Prescription.Fixtures.prescriptions

        mockPrescriptionRepository.loadLocalReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository
            .silentLoadRemoteForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult
                .prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expectedValueForLoad: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        let expectedValueForFetch = expectedValueForLoad
        // when
        store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        testScheduler.advance()
        store.receive(.loadLocalPrescriptionsReceived(expectedValueForLoad)) { state in
            // then
            state.loadingState = expectedValueForLoad
            state.prescriptions = input
        }
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expectedValueForFetch))
    }

    let loadingErrorTasks: PrescriptionRepositoryError = .erxRepository(.local(.notImplemented))
    let loadingErrorAuditEvents: PrescriptionRepositoryError = .erxRepository(.local(.notImplemented))

    func testLoadingFromDiskWithError() {
        mockPrescriptionRepository.loadLocalReturnValue = Fail(
            outputType: [Prescription].self,
            failure: loadingErrorTasks
        )
        .eraseToAnyPublisher()

        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .error(loadingErrorTasks)
        // when
        store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
            XCTAssert($0.loadingState.isError == false)
        }
        // when
        testScheduler.advance()
        store.receive(.loadLocalPrescriptionsReceived(expected)) { state in
            // then
            state.loadingState = expected
            XCTAssert(state.loadingState.isError == true)
        }
    }

    func testLoadingFromCloudWithError() {
        let store = testStore(for: mockPrescriptionRepository)
        mockPrescriptionRepository.silentLoadRemoteForReturnValue = Fail(error: loadingErrorTasks).eraseToAnyPublisher()
        let expectedTasks: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle

        store.send(.loadRemotePrescriptionsAndSave) {
            $0.loadingState = .loading(nil)
            XCTAssert($0.loadingState.isError == false)
        }
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expectedTasks)) { state in
            // then
            state.loadingState = expectedTasks
            XCTAssert(state.loadingState.isError == false)
        }
    }

    func testRefreshShouldShowCardWallWhenNotAuthenticated() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
        mockPrescriptionRepository.forcedLoadRemoteForReturnValue = Just(.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected = CardWallIntroductionDomain.State(
            isNFCReady: true,
            profileId: userSession.profileId
        )
        store.send(.refresh) {
            $0.loadingState = .loading(nil)
        }
        testScheduler.advance()
        store.receive(.showCardWallReceived(expected))
    }

    func testRefreshShouldShowCardWallServerResponseIs403Forbidden() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
        mockPrescriptionRepository.forcedLoadRemoteForReturnValue = Fail(
            outputType: PrescriptionRepositoryLoadRemoteResult.self,
            failure: PrescriptionRepositoryError.erxRepository(.remote(
                .fhirClientError(FHIRClient.Error.httpError(.httpError(.init(URLError.Code(rawValue: 403)))))
            ))
        ).eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected = CardWallIntroductionDomain.State(
            isNFCReady: true,
            profileId: userSession.profileId
        )
        store.send(.refresh) {
            $0.loadingState = .loading(nil)
        }
        testScheduler.advance()
        store.receive(.showCardWallReceived(expected))
    }

    func testRefreshShouldShowCardWallServerResponseIs401Unauthorized() {
        userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()

        mockPrescriptionRepository.forcedLoadRemoteForReturnValue = Fail(
            outputType: PrescriptionRepositoryLoadRemoteResult.self,
            failure: PrescriptionRepositoryError.erxRepository(.remote(
                .fhirClientError(FHIRClient.Error.httpError(.httpError(.init(URLError.Code(rawValue: 401)))))
            ))
        ).eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected = CardWallIntroductionDomain.State(
            isNFCReady: true,
            profileId: userSession.profileId
        )
        store.send(.refresh) {
            $0.loadingState = .loading(nil)
        }
        testScheduler.advance()
        store.receive(.showCardWallReceived(expected))
    }

    func testRefreshShouldLoadFromCloudWhenAuthenticated() {
        let input = Prescription.Fixtures.prescriptions

        mockPrescriptionRepository
            .forcedLoadRemoteForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> = .value(input)

        store.send(.refresh) {
            $0.loadingState = .loading(nil)
        }
        testScheduler.advance()
        store.receive(.loadRemotePrescriptionsAndSaveReceived(expected)) { state in
            state.loadingState = expected
            state.prescriptions = input
        }
    }

    func testNavigateIntoLowDetailPrescriptionDetails() {
        // given
        let prescription = Prescription.Fixtures.prescriptions

        let store = testStore(for: mockPrescriptionRepository)

        // when
        store.send(.prescriptionDetailViewTapped(selectedPrescription: prescription.first!))

        // nothing happens, as this is currently supposed to be handled in the parent domain
    }
}
