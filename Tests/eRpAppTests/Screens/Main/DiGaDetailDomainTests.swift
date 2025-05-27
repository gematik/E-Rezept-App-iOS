//
//  Copyright (c) 2025 gematik GmbH
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
@testable import eRpFeatures
import eRpKit
import IDP
import Nimble
import Pharmacy
import Sharing
import XCTest

@MainActor
final class DiGaDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let mockErxTaskRepository = MockErxTaskRepository()
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)
    let mockResourceHandler = MockResourceHandler()
    let mockFeedbackReceiver = MockFeedbackReceiver()
    let mockPharmacyRepository = MockPharmacyRepository()
    let mockRedeemService = MockRedeemService()
    var mockPrescriptionRepository = MockPrescriptionRepository()
    let mockNow = Date()

    typealias TestStore = TestStoreOf<DiGaDetailDomain>

    func testStore(
        _ state: DiGaDetailDomain.State? = nil,
        withDependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore {
        let schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
        let userSessionContainer = MockUsersSessionContainer()
        userSessionContainer.userSession = MockUserSession()

        return TestStore(initialState: state ?? Self.Fixuture.defaultState) {
            DiGaDetailDomain()
        } withDependencies: { dependencies in
            dependencies.changeableUserSessionContainer = userSessionContainer
            dependencies.erxTaskRepository = mockErxTaskRepository
            dependencies.schedulers = schedulers
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.uiDateFormatter = uiDateFormatter
            dependencies.resourceHandler = mockResourceHandler
            dependencies.feedbackReceiver = mockFeedbackReceiver
            dependencies.pharmacyRepository = mockPharmacyRepository
            dependencies.redeemService = mockRedeemService
            dependencies.date.now = mockNow
            dependencies.redeemOrderService.redeemViaErxTaskRepositoryDiGa = { @Sendable [mockRedeemService] orders in
                try await mockRedeemService.redeemDiGa(orders).async()
            }
            dependencies.prescriptionRepository = mockPrescriptionRepository
            prepareDependencies(&dependencies)
        }
    }

    func testDiGaUpdate() async {
        let store = testStore()
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))
        let prescription = Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue)
        mockErxTaskRepository.loadLocalPublisher = Just(erxTask)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        mockErxTaskRepository.updateLocalDiGaInfoReturnValue = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        let task = await store.send(.task)

        await store.receive(.response(.updateDiGaInfoReceived(.success(DiGaInfo(diGaState: .request, isRead: true)))))

        await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
            state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
            state.diGaTask = .init(prescription: prescription)
            state.refreshTime = self.mockNow
        }

        await task.cancel()
    }

    func testDiGaUpdateFailed() async {
        let store = testStore()
        let error = ErxRepositoryError.local(.notImplemented)
        mockErxTaskRepository.updateLocalDiGaInfoReturnValue = Fail(error: error).eraseToAnyPublisher()

        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))
        let prescription = Prescription(erxTask: erxTask, dateFormatter: UIDateFormatter.testValue)
        mockErxTaskRepository.loadLocalPublisher = Just(erxTask)
            .setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        let task = await store.send(.task)

        await store.receive(.response(.updateDiGaInfoReceived(.failure(error)))) { state in
            state.destination = .alert(DiGaDetailDomain.AlertStates.alertFor(error))
        }

        await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
            state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
            state.diGaTask = .init(prescription: prescription)
            state.refreshTime = self.mockNow
        }

        await task.cancel()
    }

    func testFetchTelematikIdFail() async {
        let store = testStore()
        let error = PharmacyRepositoryError.remote(.notFound)
        mockPharmacyRepository.fetchTelematikIdIkNumberReturnValue = Fail(error: error).eraseToAnyPublisher()

        await store.send(.mainButtonTapped)

        await store.receive(.response(.receivedTelematikId(.failure(error)))) { state in
            state.destination = .alert(.init(for: error))
        }
    }

    func testTelematikIdAndRedeemHappy() async {
        let store = testStore()
        let telematikId = "123321"

        mockPharmacyRepository.fetchTelematikIdIkNumberReturnValue = Just(telematikId)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()

        mockErxTaskRepository.updateLocalDiGaInfoReturnValue = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        let prescription = Prescription(
            erxTask: ErxTask.Fixtures.erxTaskDeviceRequest,
            dateFormatter: UIDateFormatter.previewValue
        )

        let returnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions([prescription]))
            .setFailureType(to: PrescriptionRepositoryError.self)
            .eraseToAnyPublisher()
        mockPrescriptionRepository.silentLoadRemoteForReturnValue = returnValue

        var expectedOrderResponses = IdentifiedArrayOf<OrderDiGaResponse>()
        mockRedeemService.redeemDiGaClosure = { orders in
            let orderResponses = orders.map { order in
                OrderDiGaResponse(requested: order, result: .success(true))
            }
            expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
            return Just(expectedOrderResponses)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        }

        await store.send(.mainButtonTapped)

        await store.receive(.response(.receivedTelematikId(.success(telematikId))))

        await store.receive(.response(.redeemReceived(.success(expectedOrderResponses))))

        let expectedDiGaInfo = DiGaInfo(diGaState: .insurance, isRead: false, refreshDate: nil, taskId: nil)

        await store.receive(.response(.updateDiGaInfoReceived(.success(expectedDiGaInfo))))
        await store.receive(.refreshTask(silent: true))

        await store.receive(.response(.loadRemotePrescriptionsAndSaveReceived(.value([prescription]))))

        // Fake update that supposted to come through the publisher
        let updatedDiGaInfo = DiGaInfo(diGaState: .completed, isRead: false, refreshDate: nil, taskId: nil)
        let updatedTask = ErxTask.lens.deviceRequest
            .set(.init(status: .completed, appName: "Beste App", diGaInfo: updatedDiGaInfo))(ErxTask.Fixtures
                .erxTaskDeviceRequest)
        await store.send(.receivedTaskUpdate(.success(updatedTask))) { state in
            state
                .diGaTask = .init(prescription: Prescription(erxTask: updatedTask, dateFormatter: self.uiDateFormatter))
            state.diGaInfo = updatedDiGaInfo
            state.refreshTime = self.mockNow
            state.$appDefaults.withLock { $0.diga.hasRedeemdADiga = true }
        }
    }

    func testDiGaRedeemPartially() async {
        let store = testStore()
        let telematikId = "123321"
        let error = RedeemServiceError.eRxRepository(.remote(.notImplemented))
        mockPharmacyRepository.fetchTelematikIdIkNumberReturnValue = Just(telematikId)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        var expectedOrderResponses = IdentifiedArrayOf<OrderDiGaResponse>()
        mockRedeemService.redeemDiGaClosure = { orders in
            var orderResponses = orders.map { order in
                OrderDiGaResponse(requested: order, result: .success(true))
            }
            // let one of the response be failing
            orderResponses[0] = OrderDiGaResponse(requested: orderResponses[0].requested,
                                                  result: .failure(error))
            expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
            return Just(expectedOrderResponses)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        }

        await store.send(.mainButtonTapped)

        await store.receive(.response(.receivedTelematikId(.success(telematikId))))

        await store.receive(.response(.redeemReceived(.success(expectedOrderResponses)))) { state in
            state.destination = .alert(DiGaDetailDomain.AlertStates
                .failingRequest(count: expectedOrderResponses.failedCount))
        }
    }

    func testRedeemFail() async {
        let store = testStore()
        let telematikId = "123321"
        let error = RedeemServiceError.eRxRepository(.remote(.notImplemented))
        mockPharmacyRepository.fetchTelematikIdIkNumberReturnValue = Just(telematikId)
            .setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        mockRedeemService.redeemDiGaReturnValue = Fail(error: error).eraseToAnyPublisher()

        await store.send(.mainButtonTapped)

        await store.receive(.response(.receivedTelematikId(.success(telematikId))))

        await store.receive(.response(.redeemReceived(.failure(error)))) { state in
            state.destination = .alert(.init(for: error))
        }
    }

    func testOpenUrlBfarm() async {
        let prescription = Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest,
                                        dateFormatter: UIDateFormatter.previewValue)
        let bfarmMock = DiGaDetailDomain.Dummies.placeholderValues
        let sut = testStore(.init(diGaTask: .init(prescription: prescription),
                                  diGaInfo: .init(diGaState: .request),
                                  bfarmDiGaDetails: bfarmMock))
        mockResourceHandler.canOpenURLReturnValue = true

        expect(self.mockResourceHandler.canOpenURLCalled).to(beFalse())
        await sut.send(.openLink(urlString: bfarmMock.supportUrl))
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
        expect(self.mockResourceHandler.canOpenURLCalled).to(beTrue())
    }

    func testCopyRedeemCode() async {
        var receivedPasteboardValue: String?
        let sut = testStore(withDependencies: { dependencies in
            dependencies.pasteboardService = .init { value in
                receivedPasteboardValue = value
            }
        })
        let redeemCode = "123123"

        await sut.send(.copyCode(redeemCode)) { state in
            state.successCopied = true
        }
        expect(receivedPasteboardValue).to(equal(redeemCode))
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCalled).to(beTrue())
        expect(self.mockFeedbackReceiver.hapticFeedbackSuccessCallsCount) == 1
        await sut.receive(.copyCompleted) { state in
            state.successCopied = false
        }
    }

    func testDiGaCancelDeleteWithAlert() async {
        let store = testStore()
        await store.send(.delete) { sut in
            sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
        }
        await store.send(.destination(.dismiss)) { sut in
            sut.destination = nil
        }
        expect(self.mockErxTaskRepository.deleteCallsCount) == 0
        expect(self.mockErxTaskRepository.deleteCalled).to(beFalse())
    }

    func testDiGaDeleteWithAlertSuccess() async {
        let store = testStore()

        mockErxTaskRepository.deletePublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()
        await store.send(.delete) { sut in
            sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(Result.success(true))))

        expect(self.mockErxTaskRepository.deleteCallsCount) == 1
        expect(self.mockErxTaskRepository.deleteCalled).to(beTrue())
        await store.receive(.delegate(.closeFromDelete))
    }

    func testDiGaDeleteWhenNotLoggedIn() async {
        let store = testStore()
        let expectedError = ErxRepositoryError
            .remote(.fhirClient(.http(.init(httpClientError: .authentication(IDPError.tokenUnavailable),
                                            operationOutcome: nil))))

        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()
        await store.send(.delete) { sut in
            sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(Result.failure(expectedError)))) { state in
            state.destination = .alert(DiGaDetailDomain.AlertStates.missingTokenAlertState())
        }
        await store.send(.destination(.dismiss)) { state in
            state.destination = nil
        }
        expect(self.mockErxTaskRepository.deleteCallsCount) == 1
        expect(self.mockErxTaskRepository.deleteCalled).to(beTrue())
        await store.send(.delegate(.closeFromDelete))
    }

    func testDiGaDeleteWithOtherErrorMessage() async {
        let store = testStore()
        let expectedError = ErxRepositoryError.local(.notImplemented)
        mockErxTaskRepository.deletePublisher = Fail(error: expectedError).eraseToAnyPublisher()

        // when
        await store.send(.delete) { sut in
            // then
            sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            // then
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(
            Result.failure(ErxRepositoryError.local(.notImplemented))
        ))) { state in
            // then
            state.destination = .alert(
                DiGaDetailDomain.AlertStates.deleteFailedAlertState(
                    error: ErxRepositoryError.local(.notImplemented),
                    localizedError: ErxRepositoryError.local(.notImplemented).localizedDescriptionWithErrorList
                )
            )
        }
        await store.send(.setNavigation(tag: nil)) { state in
            state.destination = nil
        }
        await store.send(.delegate(.closeFromDelete))
    }

    func testDiGaDeletingDiGaInProgress() async {
        await withDependencies {
            $0.date = DateGenerator { TestDate.defaultReferenceDate }
        } operation: {
            let prescription = Prescription(
                erxTask: ErxTask.Fixtures.erxTaskInProgressAndValid,
                date: TestDate.defaultReferenceDate,
                dateFormatter: UIDateFormatter.testValue
            )
            let sut =
                testStore(.init(diGaTask: .init(prescription: prescription), diGaInfo: .init(diGaState: .request)))

            await sut.send(.delete) {
                $0.destination = .alert(ErpAlertState(
                    title: L10n.digaDtlBtnDeleteDisabledNote,
                    actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    }
                ))
            }
            expect(self.mockErxTaskRepository.deleteCallsCount) == 0
            expect(self.mockErxTaskRepository.deleteCalled).to(beFalse())
        }
    }
}

extension DiGaDetailDomainTests {
    enum Fixuture {
        static let defaultState = DiGaDetailDomain.State(
            diGaTask: .init(prescription: Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest,
                                                       dateFormatter: UIDateFormatter.previewValue)),
            diGaInfo: .init(diGaState: .request),
            profile: UserProfile.Dummies.profileA
        )
    }
}
