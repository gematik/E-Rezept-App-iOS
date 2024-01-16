//
//  Copyright (c) 2024 gematik GmbH
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
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacyRedeemDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockShipmentInfoDataStore: MockShipmentInfoDataStore!
    var mockUserSession: MockUserSession!
    var mockRedeemService: MockRedeemService!
    var mockRedeemValidator: MockRedeemInputValidator!
    var mockPharmacyRepository: MockPharmacyRepository!

    typealias TestStore = TestStoreOf<PharmacyRedeemDomain>
    var store: TestStore!

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockShipmentInfoDataStore = MockShipmentInfoDataStore()
        mockRedeemService = MockRedeemService()
        mockRedeemValidator = MockRedeemInputValidator()
        mockPharmacyRepository = MockPharmacyRepository()
    }

    override func tearDownWithError() throws {
        store = nil

        try super.tearDownWithError()
    }

    func testStore(for state: PharmacyRedeemDomain.State) -> TestStore {
        TestStore(initialState: state) {
            PharmacyRedeemDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.userSession = mockUserSession
            dependencies.shipmentInfoDataStore = mockShipmentInfoDataStore
            dependencies.redeemInputValidator = mockRedeemValidator
            dependencies.redeemService = mockRedeemService
            dependencies.serviceLocator = ServiceLocator()
            dependencies.pharmacyRepository = mockPharmacyRepository
        }
    }

    var pharmacy: PharmacyLocation {
        PharmacyLocation(
            id: "2345",
            status: .active,
            telematikID: "telematikId",
            name: "Klee Apotheke",
            types: [.outpharm],
            position: nil,
            address: nil,
            telecom: nil,
            hoursOfOperation: [],
            avsEndpoints: PharmacyLocation.AVSEndpoints(onPremiseUrl: "http://onpremise.de"),
            avsCertificates: []
        )
    }

    func testRedeemingWhenNotLoggedIn() async {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(for: PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        ))

        let expectedShipmentInfo = ShipmentInfo(
            identifier: UUID(),
            name: "Ludger Königsstein",
            street: "Musterstr. 1",
            zip: "10623",
            city: "Berlin"
        )
        mockRedeemValidator.returnValue = .valid
        mockShipmentInfoDataStore.selectedShipmentInfo = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = false
        mockRedeemService.redeemReturnValue = Fail(error: RedeemServiceError.noTokenAvailable)
            .eraseToAnyPublisher()

        await sut.send(.registerSelectedShipmentInfoListener)
        await sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        await sut.send(.redeem)

        let expectedCardWallState = CardWallIntroductionDomain.State(
            isNFCReady: true,
            profileId: mockUserSession.profileId,
            destination: nil
        )
        await sut.receive(.setNavigation(tag: .cardWall)) {
            $0.destination = PharmacyRedeemDomain.Destinations.State.cardWall(expectedCardWallState)
        }
        expect(self.mockPharmacyRepository.savePharmaciesCallsCount) == 0
    }

    let shipmentInfo = ShipmentInfo(
        identifier: UUID(),
        name: "Ludger Königsstein",
        street: "Musterstr. 1",
        addressDetail: "Postfach 1212",
        zip: "10623",
        city: "Berlin",
        phone: "0177123456",
        mail: "mail@gematik.de",
        deliveryInfo: "Bitte klingeln."
    )

    func testRedeemHappyPath() async {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        )
        let sut = testStore(for: initialState)

        let expectedShipmentInfo = shipmentInfo
        mockRedeemValidator.returnValue = .valid
        mockShipmentInfoDataStore.selectedShipmentInfo = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = true
        mockPharmacyRepository.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        var expectedOrderResponses = IdentifiedArrayOf<OrderResponse>()
        mockRedeemService.redeemClosure = { orders in
            let orderResponses = orders.map { order in
                OrderResponse(requested: order, result: .success(true))
            }
            expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
            return Just(expectedOrderResponses)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        }

        await sut.send(.registerSelectedShipmentInfoListener)
        await sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        await sut.send(.redeem)
        await sut.receive(.redeemReceived(.success(expectedOrderResponses))) {
            $0.orderResponses = expectedOrderResponses
            $0.destination = .redeemSuccess(RedeemSuccessDomain.State(redeemOption: .onPremise))

            for task in inputTasks {
                let response = $0.orderResponses.first { $0.requested.taskID == task.id }
                expect(response?.requested.name) == expectedShipmentInfo.name
                expect(response?.requested.address) == expectedShipmentInfo.address
                expect(response?.requested.hint) == expectedShipmentInfo.deliveryInfo
                expect(response?.requested.phone) == expectedShipmentInfo.phone
                expect(response?.requested.mail) == expectedShipmentInfo.mail
                expect(response?.requested.text).to(beNil())
                expect(response?.requested.redeemType) == initialState.redeemOption
                expect(response?.requested.accessCode) == task.accessCode
                expect(response?.requested.telematikId) == self.pharmacy.telematikID
                expect(response?.requested.endpoint) == self.pharmacy.avsEndpoints?.url(
                    for: initialState.redeemOption,
                    transactionId: "",
                    telematikId: self.pharmacy.telematikID
                )
            }
        }
        expect(self.mockPharmacyRepository.savePharmaciesCallsCount) == 1
    }

    func testRedeemWithPartialSuccess() async {
        // given
        let inputTasks = ErxTask.Fixtures.erxTasks
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        )
        let sut = testStore(for: initialState)

        let expectedShipmentInfo = shipmentInfo
        mockRedeemValidator.returnValue = .valid
        mockShipmentInfoDataStore.selectedShipmentInfo = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = true
        mockPharmacyRepository.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let expectedError = RedeemServiceError.eRxRepository(.remote(.notImplemented))
        var expectedOrderResponses = IdentifiedArrayOf<OrderResponse>()
        mockRedeemService.redeemClosure = { orders in
            var orderResponses = orders.map { order in
                OrderResponse(requested: order, result: .success(true))
            }
            // let one of the response be failing
            orderResponses[0] = OrderResponse(requested: orderResponses[0].requested,
                                              result: .failure(expectedError))
            expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
            return Just(expectedOrderResponses)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        }

        // when redeeming
        await sut.send(.redeem)
        await sut.receive(.redeemReceived(.success(expectedOrderResponses))) {
            $0.orderResponses = expectedOrderResponses
            $0.destination = .alert(
                .info(PharmacyRedeemDomain.AlertStates.failingRequest(count: expectedOrderResponses.failedCount))
            )
        }
        expect(self.mockPharmacyRepository.savePharmaciesCallsCount) == 1
    }

    func testRedeemWithFailure() async {
        // given
        let inputTasks = ErxTask.Fixtures.erxTasks
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        )
        let sut = testStore(for: initialState)

        let expectedShipmentInfo = shipmentInfo
        mockRedeemValidator.returnValue = .valid
        mockShipmentInfoDataStore.selectedShipmentInfo = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = true
        let expectedError = RedeemServiceError.internalError(.missingTelematikId)
        mockRedeemService.redeemReturnValue = Fail(error: expectedError).eraseToAnyPublisher()
        mockPharmacyRepository.savePharmaciesReturnValue = Just(true).setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        // when redeeming
        await sut.send(.redeem)
        await sut.receive(.redeemReceived(.failure(expectedError))) {
            $0.destination = .alert(.init(for: expectedError))
        }
        expect(self.mockPharmacyRepository.savePharmaciesCallsCount) == 1
    }

    func testLoadingProfile() async {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(
            for: PharmacyRedeemDomain.State(
                redeemOption: .onPremise,
                erxTasks: inputTasks,
                pharmacy: pharmacy,
                selectedErxTasks: Set(inputTasks)
            )
        )

        let expectedProfile = Profile(name: "Anna Vetter", color: Profile.Color.yellow)
        mockUserSession.profileReturnValue = Just(expectedProfile).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        await sut.send(.registerSelectedProfileListener)

        await sut.receive(.selectedProfileReceived(.success(expectedProfile))) {
            $0.profile = expectedProfile
        }
    }

    func testRedeemWithInvalidInput() async {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(
            for: PharmacyRedeemDomain.State(
                redeemOption: .shipment,
                erxTasks: inputTasks,
                pharmacy: pharmacy,
                selectedErxTasks: Set(inputTasks)
            )
        )

        let expectedShipmentInfo = ShipmentInfo(
            identifier: UUID(),
            name: "Ludger Königsstein",
            street: "Musterstr. 1",
            zip: "10623",
            city: "Berlin"
        )
        mockShipmentInfoDataStore.selectedShipmentInfo = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = false

        await sut.send(.registerSelectedShipmentInfoListener)
        await sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        mockRedeemValidator.returnValue = .invalid("Invalid Input")

        await sut.send(.redeem) {
            $0
                .destination =
                .alert(.info(PharmacyRedeemDomain.AlertStates.missingContactInfo(with: "Invalid Input")))
        }
    }

    func testGeneratingShipmentInfoFromErxTask() async {
        let erxTask = ErxTask.Fixtures.erxTask1
        let identifier = UUID()

        let sut = erxTask.patient?.shipmentInfo(with: identifier)
        expect(sut?.id) == identifier
        expect(sut?.name) == "Ludger Königsstein"
        expect(sut?.street) == "Musterstr. 1"
        expect(sut?.addressDetail).to(beNil())
        expect(sut?.zip) == "10623"
        expect(sut?.city) == "Berlin"
        expect(sut?.phone).to(beNil())
        expect(sut?.mail).to(beNil())
        expect(sut?.deliveryInfo).to(beNil())
    }

    func testRedeemNoPrescriptionsSelected() async {
        let inputTasks = [ErxTask.Fixtures.erxTask1, ErxTask.Fixtures.erxTask2, ErxTask.Fixtures.erxTask3]
        let sut = testStore(
            for: PharmacyRedeemDomain.State(
                redeemOption: .shipment,
                erxTasks: inputTasks,
                pharmacy: pharmacy,
                selectedErxTasks: Set(inputTasks)
            )
        )
        let selectionPrescriptionState = PharmacyPrescriptionSelectionDomain.State(
            erxTasks: sut.state.erxTasks,
            selectedErxTasks: sut.state.selectedErxTasks
        )

        await sut.send(.setNavigation(tag: .prescriptionSelection)) { sut in
            sut.destination = .prescriptionSelection(selectionPrescriptionState)
        }

        await sut
            .send(.destination(.presented(.prescriptionSelection(action: .saveSelection(Set<ErxTask>()))))) { sut in
                sut.destination = nil
                sut.selectedErxTasks = Set<ErxTask>()
            }

        await sut.send(.redeem)
        expect(self.mockPharmacyRepository.savePharmaciesCalled).to(beFalse())
    }
}

extension OrderRequest {
    static var fixture: OrderRequest = {
        OrderRequest(redeemType: .shipment, taskID: "task_id_0", accessCode: "access_code_0", telematikId: "k123456789")
    }()
}
