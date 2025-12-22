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

import BfArM
import CodedError
import Combine
import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import eRpResources
import ErxTaskRepository
import FeatureHelpers
import IDP
import Nimble
import Pharmacy
import Sharing
import Synchronization
import XCTest

@MainActor
final class DiGaDetailDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    let uiDateFormatter = UIDateFormatter(fhirDateFormatter: FHIRDateFormatter.shared)
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
            dependencies.schedulers = schedulers
            dependencies.fhirDateFormatter = FHIRDateFormatter.shared
            dependencies.uiDateFormatter = uiDateFormatter
            dependencies.hapticFeedbackGenerator.success = {}
            dependencies.redeemService = mockRedeemService
            dependencies.date.now = mockNow
            dependencies.redeemOrderService
                .redeemViaErxTaskRepositoryDiGa = { @Sendable [mockRedeemService] orders, _ in
                    try await mockRedeemService.redeemDiGa(orders, profileId: UUID()).async()
                }
            dependencies.prescriptionRepository = mockPrescriptionRepository
            prepareDependencies(&dependencies)
        }
    }

    func testDiGaUpdate() async {
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in }
        } operation: {
            let store = testStore(.init(
                diGaTask: .init(prescription: Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest)),
                diGaInfo: .init(diGaState: .request, isRead: false),
                profile: UserProfile.Dummies.profileA
            ))

            let prescription = Prescription(erxTask: erxTask)

            let task = await store.send(.task) { state in
                state.isLoading = true
            }
            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.response(.updateDiGaInfoReceived(.success(expectedDiGaInfo))))

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await task.cancel()
        }
    }

    func testDiGaUpdateFailed() async {
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let error = ErxRepositoryError.local(.notImplemented)
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in throw error }
        } operation: {
            let store = testStore(.init(
                diGaTask: .init(prescription: Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest)),
                diGaInfo: .init(diGaState: .request, isRead: false),
                profile: UserProfile.Dummies.profileA
            ))

            let prescription = Prescription(erxTask: erxTask)

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.response(.updateDiGaInfoReceived(.failure(error)))) { state in
                state.destination = .alert(DiGaDetailDomain.AlertStates.alertFor(error))
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await task.cancel()
        }
    }

    func testfetchInsuranceFail() async {
        let error = PharmacyRepositoryError.remote(.notFound)
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in throw error }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
        } operation: {
            let store = testStore()
            let prescription = Prescription(erxTask: erxTask)

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.failure(error)))) { state in
                state.isLoading = false
                state.destination = .alert(.init(for: error))
            }

            await task.cancel()
        }
    }

    func testTelematikIdAndRedeemHappy() async {
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let erxTask = ErxTask.Fixtures.erxTaskDeviceRequest
        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in }
        } operation: {
            let store = testStore()
            let prescription = Prescription(erxTask: erxTask)

            let returnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions([prescription]))
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
            mockPrescriptionRepository.silentLoadRemoteForForReturnValue = returnValue

            var expectedOrderResponses = IdentifiedArrayOf<OrderDiGaResponse>()
            mockRedeemService.redeemDiGaProfileIdClosure = { orders, _ in
                let orderResponses = orders.map { order in
                    OrderDiGaResponse(requested: order, result: .success(true))
                }
                expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
                return Just(expectedOrderResponses)
                    .setFailureType(to: RedeemServiceError.self)
                    .eraseToAnyPublisher()
            }

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await store.send(.mainButtonTapped)

            await store.receive(.response(.redeemReceived(.success(expectedOrderResponses))))

            let expectedDiGaInfo = DiGaInfo(diGaState: .insurance, isRead: true, refreshDate: nil, taskId: nil)

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
                    .diGaTask =
                    .init(prescription: Prescription(erxTask: updatedTask))
                state.diGaInfo = updatedDiGaInfo
                state.refreshTime = self.mockNow
                state.$appDefaults.withLock { $0.diga.hasRedeemdADiga = true }
            }
            await task.cancel()
        }
    }

    func testSelectInsuranceAndRedeemHappy() async {
        let erxTask = ErxTask.Fixtures.erxTaskDeviceRequest

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in nil }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in }
        } operation: {
            let store = testStore()
            let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
            let prescription = Prescription(erxTask: erxTask)

            let returnValue = Just(PrescriptionRepositoryLoadRemoteResult.prescriptions([prescription]))
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
            mockPrescriptionRepository.silentLoadRemoteForForReturnValue = returnValue

            var expectedOrderResponses = IdentifiedArrayOf<OrderDiGaResponse>()
            mockRedeemService.redeemDiGaProfileIdClosure = { orders, _ in
                let orderResponses = orders.map { order in
                    OrderDiGaResponse(requested: order, result: .success(true))
                }
                expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
                return Just(expectedOrderResponses)
                    .setFailureType(to: RedeemServiceError.self)
                    .eraseToAnyPublisher()
            }

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(nil)))) { state in
                state.isLoading = false
                state.destination = .alert(DiGaDetailDomain.AlertStates.telematikIdEmpty())
            }

            await store.send(.setNavigation(tag: .insuranceList)) { state in
                state.destination = .insuranceList(.init())
            }

            await store.send(.destination(.presented(.insuranceList(.selectInsurance(insurance))))) { state in
                state.selectedInsurance = insurance
                state.destination = nil
            }

            await store.send(.mainButtonTapped)

            await store.receive(.response(.redeemReceived(.success(expectedOrderResponses))))

            let expectedDiGaInfo = DiGaInfo(diGaState: .insurance, isRead: true, refreshDate: nil, taskId: nil)

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
                    .diGaTask =
                    .init(prescription: Prescription(erxTask: updatedTask))
                state.diGaInfo = updatedDiGaInfo
                state.refreshTime = self.mockNow
                state.$appDefaults.withLock { $0.diga.hasRedeemdADiga = true }
            }
            await task.cancel()
        }
    }

    func testDiGaRedeemPartially() async {
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))
        let error = RedeemServiceError.eRxRepository(.remote(.notImplemented))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in }
        } operation: {
            let store = testStore()
            let prescription = Prescription(erxTask: erxTask)

            var expectedOrderResponses = IdentifiedArrayOf<OrderDiGaResponse>()
            mockRedeemService.redeemDiGaProfileIdClosure = { orders, _ in
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

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await store.send(.mainButtonTapped)

            await store.receive(.response(.redeemReceived(.success(expectedOrderResponses)))) { state in
                state.destination = .alert(DiGaDetailDomain.AlertStates
                    .failingRequest(count: expectedOrderResponses.failedCount))
            }

            await task.cancel()
        }
    }

    func testRedeemFail() async {
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in nil }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
            $0.erxTaskRepository.updateLocalDiGaInfo = { _ in }
        } operation: {
            let store = testStore()
            let error = RedeemServiceError.eRxRepository(.remote(.notImplemented))

            let prescription = Prescription(erxTask: erxTask)
            mockRedeemService.redeemDiGaProfileIdReturnValue = Fail(error: error).eraseToAnyPublisher()
            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(nil))))

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await store.send(.mainButtonTapped)

            await store.receive(.response(.redeemReceived(.failure(error)))) { state in
                state.destination = .alert(.init(for: error))
            }

            await task.cancel()
        }
    }

    func testBfArMHappyPath() async {
        let bfarmDiGaDetails: BfArMDiGaDetails = .init(contractMedicalServicesRequired: true,
                                                       additionalDevices: ["OPTIONAL"],
                                                       manufacturerCost: "500",
                                                       languageNames: ["Deutsch"],
                                                       supportedPlatforms: ["iOS"])
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in bfarmDiGaDetails }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
        } operation: {
            let store = testStore()
            let prescription = Prescription(erxTask: erxTask)

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.success(bfarmDiGaDetails)))) { state in
                state.bfarmDiGaDetails = bfarmDiGaDetails
            }

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await task.cancel()
        }
    }

    func testBfArMFailure() async {
        let error = BfArMError.network(error: .networkError("timeout"))
        let insurance = Insurance(id: UUID(), name: "TestInsurance", telematikId: "123123")
        let expectedDiGaInfo = DiGaInfo(diGaState: .request, isRead: true, refreshDate: nil, taskId: nil)
        let erxTask = ErxTask(identifier: "132",
                              status: .ready,
                              flowType: .pharmacyOnly,
                              deviceRequest: .init(diGaInfo: expectedDiGaInfo))

        await withDependencies {
            $0.bfArMSession = .init(fetchBfArMInfo: { _ in throw error }, fetchCachedImage: { _ in nil })
            $0.pharmacyRepository.fetchInsurance = { _ in insurance }
            $0.erxTaskRepository.loadLocalTask = { _, _ in
                Just(erxTask).setFailureType(to: ErxRepositoryError.self).eraseToAnyPublisher()
            }
        } operation: {
            let store = testStore()
            let prescription = Prescription(erxTask: erxTask)

            let task = await store.send(.task) { state in
                state.isLoading = true
            }

            await store.receive(.fetchBfArMDiGaDetails)

            await store.receive(.loadInsurance)

            await store.receive(.receivedTaskUpdate(.success(erxTask))) { state in
                state.diGaInfo = DiGaInfo(diGaState: .request, isRead: true)
                state.diGaTask = .init(prescription: prescription)
                state.refreshTime = self.mockNow
            }

            await store.receive(.response(.receivedBfArMDiGaDetails(.failure(error)))) { state in
                state.destination = .alert(.init(for: error))
            }

            await store.receive(.response(.receivedTelematikId(.success(insurance)))) { state in
                state.selectedInsurance = insurance
                state.isLoading = false
            }

            await task.cancel()
        }
    }

    @available(iOS 18.0, *)
    func testOpenUrlBfarm() async {
        let openedURL = Mutex<URL?>(nil)
        let prescription = Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest)
        let url = "https://www.das-e-rezept-fuer-deutschland.de"
        let sut = testStore(.init(diGaTask: .init(prescription: prescription),
                                  diGaInfo: .init(diGaState: .request))) { dependencies in
            dependencies.openURLHandler.canOpenURL = { _ in true }
            dependencies.openURLHandler.open = { url in
                openedURL.withLock { $0 = url }
            }
        }
        expect(openedURL.withLock { $0 }).to(beNil())

        await sut.send(.openLink(urlString: url))

        expect(openedURL.withLock { $0 }).to(equal(URL(string: url)!))
    }

    func testCopyRedeemCode() async {
        var receivedPasteboardValue: String?

        var calledCount = 0

        let sut = testStore(withDependencies: { dependencies in
            dependencies.pasteboardService = .init { value in
                receivedPasteboardValue = value
            }
            dependencies.hapticFeedbackGenerator.success = {
                calledCount += 1
            }
        })

        @Dependency(\.hapticFeedbackGenerator) var feedbackGenerator

        let redeemCode = "123123"

        await sut.send(.copyCode(redeemCode)) { state in
            state.successCopied = true
        }
        expect(receivedPasteboardValue).to(equal(redeemCode))
        expect(calledCount).to(equal(1))
        await sut.receive(.copyCompleted) { state in
            state.successCopied = false
        }
    }

    func testDiGaCancelDeleteWithAlert() async {
        let store = testStore()
        await withDependencies {
            $0.erxTaskRepository.deleteTask = { _, _ in
                throw ErxRepositoryError.remote(.notImplemented)
            }
        } operation: {
            await store.send(.delete) { sut in
                sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
            }
            await store.send(.destination(.dismiss)) { sut in
                sut.destination = nil
            }
        }
    }

    func testDiGaDeleteWithAlertSuccess() async {
        let store = testStore()
        store.dependencies.erxTaskRepository.deleteTask = { _, _ in }
        await store.send(.delete) { sut in
            sut.destination = .alert(DiGaDetailDomain.AlertStates.confirmDeleteAlertState)
        }
        await store.send(.destination(.presented(.alert(.confirmedDelete)))) { sut in
            sut.destination = nil
        }
        await store.receive(.response(.taskDeletedReceived(Result.success(true))))

        await store.receive(.delegate(.closeFromDelete))
    }

    func testDiGaDeleteWhenNotLoggedIn() async {
        let store = testStore()
        let expectedError = ErxRepositoryError
            .remote(.fhirClient(.http(.init(httpClientError: .authentication(IDPError.tokenUnavailable),
                                            operationOutcome: nil))))
        store.dependencies.erxTaskRepository.deleteTask = { _, _ in
            throw expectedError
        }

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

        await store.send(.delegate(.closeFromDelete))
    }

    func testDiGaDeleteWithOtherErrorMessage() async {
        let store = testStore()
        let expectedError = ErxRepositoryError.local(.notImplemented)
        store.dependencies.erxTaskRepository.deleteTask = { _, _ in
            throw expectedError
        }

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
            $0.erxTaskRepository.deleteTask = { _, _ in }
        } operation: {
            let prescription = Prescription(
                erxTask: ErxTask.Fixtures.erxTaskInProgressAndValid,
                date: TestDate.defaultReferenceDate
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
        }
    }
}

extension DiGaDetailDomainTests {
    enum Fixuture {
        static let defaultState = DiGaDetailDomain.State(
            diGaTask: .init(prescription: Prescription(erxTask: ErxTask.Fixtures.erxTaskDeviceRequest)),
            diGaInfo: .init(diGaState: .request, isRead: true),
            profile: UserProfile.Dummies.profileA
        )
    }
}
