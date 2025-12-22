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
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import FeatureCardWall
import FeatureHelpers
import FHIRClient
import XCTest

@MainActor
final class PrescriptionListDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<PrescriptionListDomain>

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

    private func testStore(for _: PrescriptionRepository) -> TestStore {
        TestStore(initialState: PrescriptionListDomain.State()) {
            PrescriptionListDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.serviceLocator = ServiceLocator()
            dependencies.userSession = userSession
            dependencies.prescriptionRepository = mockPrescriptionRepository
        }
    }

    func testLoadingPrescriptionsLocalTwoTimes() async {
        // given
        let input: [Prescription] = []
        mockPrescriptionRepository.loadLocalForReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)

        // when
        await store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadLocalPrescriptionsReceived(expected))) { state in
            // then
            state.loadingState = expected
            state.prescriptions = input
        }
        // when
        await store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading(input)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadLocalPrescriptionsReceived(expected))) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenAuthenticated() async {
        // given
        let input = Prescription.Fixtures.prescriptions

        let returnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository.silentLoadRemoteForForReturnValue = returnValue
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expected))) { state in
            // then
            state.loadingState = expected
            state.prescriptions = input
        }
        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expected))) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromCloudTwoTimesWhenNotAuthenticated() async {
        // given
        mockPrescriptionRepository.silentLoadRemoteForForReturnValue = Just(.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value([])

        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expected))) { state in
            // then
            state.loadingState = expected
        }
        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expected))) { state in
            // then
            state.loadingState = expected
        }
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenNotAuthenticated() async {
        // given
        let input = Prescription.Fixtures.prescriptions
        mockPrescriptionRepository.loadLocalForReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository
            .silentLoadRemoteForForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult.notAuthenticated)
            .setFailureType(to: PrescriptionRepositoryError.self).eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expectedValueForLoad: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        let expectedValueForFetch: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value([])
        // when
        await store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadLocalPrescriptionsReceived(expectedValueForLoad))) { state in
            // then
            state.loadingState = expectedValueForLoad
            state.prescriptions = input
        }
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expectedValueForFetch))) { state in
            // then
            state.loadingState = expectedValueForFetch
        }
    }

    func testLoadingPrescriptionsFromDiskAndCloudWhenAuthenticated() async {
        // given
        let input = Prescription.Fixtures.prescriptions

        mockPrescriptionRepository.loadLocalForReturnValue = Just(input)
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository
            .silentLoadRemoteForForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult
                .prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expectedValueForLoad: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .value(input)
        let expectedValueForFetch = expectedValueForLoad
        // when
        await store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
        }
        // when
        await store.send(.loadRemotePrescriptionsAndSave) {
            // then
            $0.loadingState = .loading(nil)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadLocalPrescriptionsReceived(expectedValueForLoad))) { state in
            // then
            state.loadingState = expectedValueForLoad
            state.prescriptions = input
        }
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expectedValueForFetch)))
    }

    let loadingErrorTasks: PrescriptionRepositoryError = .erxRepository(.local(.notImplemented))
    let loadingErrorAuditEvents: PrescriptionRepositoryError = .erxRepository(.local(.notImplemented))

    func testLoadingFromDiskWithError() async {
        mockPrescriptionRepository.loadLocalForReturnValue = Fail(
            outputType: [Prescription].self,
            failure: loadingErrorTasks
        )
        .eraseToAnyPublisher()

        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .error(loadingErrorTasks)
        // when
        await store.send(.loadLocalPrescriptions) {
            // then
            $0.loadingState = .loading([])
            XCTAssert($0.loadingState.isError == false)
        }
        // when
        await testScheduler.advance()
        await store.receive(.response(.loadLocalPrescriptionsReceived(expected))) { state in
            // then
            state.loadingState = expected
            XCTAssert(state.loadingState.isError == true)
        }
    }

    func testLoadingFromCloudWithError() async {
        let store = testStore(for: mockPrescriptionRepository)
        mockPrescriptionRepository.silentLoadRemoteForForReturnValue = Fail(error: loadingErrorTasks)
            .eraseToAnyPublisher()
        let expectedTasks: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle

        await store.send(.loadRemotePrescriptionsAndSave) {
            $0.loadingState = .loading(nil)
            XCTAssert($0.loadingState.isError == false)
        }
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expectedTasks))) { state in
            // then
            state.loadingState = expectedTasks
            XCTAssert(state.loadingState.isError == false)
        }
    }

    func testRefreshShouldShowCardWallWhenNotAuthenticated() async {
        await withDependencies {
            $0.drawerEvaluation.showDrawerEvaluationOnRefresh = { .none }
        } operation: {
            userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
            mockPrescriptionRepository.forcedLoadRemoteForForReturnValue = Just(.notAuthenticated)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
            let store = testStore(for: mockPrescriptionRepository)

            let expected = CardWallIntroductionDomain.State(
                isNFCReady: true,
                profileId: userSession.profileId
            )
            await store.send(.refresh) {
                $0.loadingState = .loading(nil)
            }
            await testScheduler.advance()
            await store.receive(.response(.showCardWallReceived(expected))) {
                $0.loadingState = .idle
            }
        }
    }

    func testRefreshShouldShowCardWallServerResponseIs403Forbidden() async {
        await withDependencies {
            $0.drawerEvaluation.showDrawerEvaluationOnRefresh = { .none }
        } operation: {
            userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()
            mockPrescriptionRepository.forcedLoadRemoteForForReturnValue = Fail(
                outputType: PrescriptionRepositoryLoadRemoteResult.self,
                failure: PrescriptionRepositoryError.erxRepository(.remote(
                    .fhirClient(FHIRClient.Error
                        .http(.init(httpClientError: .httpError(.init(URLError.Code(rawValue: 403))),
                                    operationOutcome: nil)))
                ))
            ).eraseToAnyPublisher()
            let store = testStore(for: mockPrescriptionRepository)

            let expected = CardWallIntroductionDomain.State(
                isNFCReady: true,
                profileId: userSession.profileId
            )
            await store.send(.refresh) {
                $0.loadingState = .loading(nil)
            }
            await testScheduler.advance()
            await store.receive(.response(.showCardWallReceived(expected))) {
                $0.loadingState = .idle
            }
        }
    }

    func testRefreshShouldShowCardWallServerResponseIs401Unauthorized() async {
        await withDependencies {
            $0.drawerEvaluation.showDrawerEvaluationOnRefresh = { .none }
        } operation: {
            userDataStore.hideCardWallIntro = Just(false).eraseToAnyPublisher()

            mockPrescriptionRepository.forcedLoadRemoteForForReturnValue = Fail(
                outputType: PrescriptionRepositoryLoadRemoteResult.self,
                failure: PrescriptionRepositoryError.erxRepository(.remote(
                    .fhirClient(FHIRClient.Error
                        .http(.init(httpClientError: .httpError(.init(URLError.Code(rawValue: 401))),
                                    operationOutcome: nil)))
                ))
            ).eraseToAnyPublisher()
            let store = testStore(for: mockPrescriptionRepository)

            let expected = CardWallIntroductionDomain.State(
                isNFCReady: true,
                profileId: userSession.profileId
            )

            await store.send(.refresh) {
                $0.loadingState = .loading(nil)
            }
            await testScheduler.advance()
            await store.receive(.response(.showCardWallReceived(expected))) {
                $0.loadingState = .idle
            }
        }
    }

    func testRefreshShouldLoadFromCloudWhenAuthenticated() async {
        let input = Prescription.Fixtures.prescriptions

        mockPrescriptionRepository
            .forcedLoadRemoteForForReturnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions(input))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        let store = testStore(for: mockPrescriptionRepository)

        let expected: LoadingState<[Prescription], PrescriptionRepositoryError> = .value(input)

        await store.send(.refresh) {
            $0.loadingState = .loading(nil)
        }
        await testScheduler.advance()
        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(expected))) { state in
            state.loadingState = expected
            state.prescriptions = input
        }
    }

    func testNavigateIntoLowDetailPrescriptionDetails() async {
        // given
        let prescription = Prescription.Fixtures.prescriptions

        let store = testStore(for: mockPrescriptionRepository)

        // when
        await store.send(.prescriptionDetailViewTapped(selectedPrescription: prescription.first!))

        // nothing happens, as this is currently supposed to be handled in the parent domain
    }
}
