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
import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

class PharmacyRedeemDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockShipmentInfoDataStore: MockShipmentInfoDataStore!
    var mockUserSession: MockUserSession!
    var mockRedeemService: MockRedeemService!

    typealias TestStore = ComposableArchitecture.TestStore<
        PharmacyRedeemDomain.State,
        PharmacyRedeemDomain.State,
        PharmacyRedeemDomain.Action,
        PharmacyRedeemDomain.Action,
        PharmacyRedeemDomain.Environment
    >
    var store: TestStore!

    override func setUp() {
        super.setUp()
        mockUserSession = MockUserSession()
        mockShipmentInfoDataStore = MockShipmentInfoDataStore()
        mockRedeemService = MockRedeemService()
    }

    override func tearDownWithError() throws {
        store = nil

        try super.tearDownWithError()
    }

    func testStore(for state: PharmacyRedeemDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: PharmacyRedeemDomain.reducer,
            environment: PharmacyRedeemDomain.Environment(
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                userSession: mockUserSession,
                shipmentInfoStore: mockShipmentInfoDataStore,
                redeemService: mockRedeemService
            )
        )
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
            avsEndpoints: PharmacyLocation.AVSEndpoints(onPremiseUrl: URL(string: "http://onpremise.de")),
            avsCertificates: []
        )
    }

    func testRedeemingWhenNotLoggedIn() {
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
        mockShipmentInfoDataStore.selectedShipmentInfoReturnValue = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = false
        mockRedeemService.redeemReturnValue = Fail(error: RedeemServiceError.noTokenAvailable)
            .eraseToAnyPublisher()

        sut.send(.registerSelectedShipmentInfoListener)
        sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        sut.send(.redeem)
        sut.receive(.redeemReceived(.failure(RedeemServiceError.noTokenAvailable))) {
            $0.orderResponses = []
            $0.alertState = PharmacyRedeemDomain.AlertStates.alert(for: .noTokenAvailable)
        }
    }

    func testRedeemHappyPath() {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let initialState = PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        )
        let sut = testStore(for: initialState)

        let expectedShipmentInfo = ShipmentInfo(
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

        mockShipmentInfoDataStore.selectedShipmentInfoReturnValue = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = true

        var expectedOrderResponses = IdentifiedArrayOf<OrderResponse>()
        mockRedeemService.redeemOrdersClosure = { orders in
            let orderResponses = orders.map { order in
                OrderResponse(requested: order, result: .success(true))
            }
            expectedOrderResponses = IdentifiedArrayOf(uniqueElements: orderResponses)
            return Just(expectedOrderResponses)
                .setFailureType(to: RedeemServiceError.self)
                .eraseToAnyPublisher()
        }

        sut.send(.registerSelectedShipmentInfoListener)
        sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        sut.send(.redeem) { state in
            let orders = state.orders
            for task in inputTasks {
                let order = orders.first { $0.taskID == task.id }
                expect(order?.name) == expectedShipmentInfo.name
                expect(order?.address) == expectedShipmentInfo.address
                expect(order?.hint) == expectedShipmentInfo.deliveryInfo
                expect(order?.phone) == expectedShipmentInfo.phone
                expect(order?.mail) == expectedShipmentInfo.mail
                expect(order?.text).to(beNil())
                expect(order?.redeemType) == initialState.redeemOption
                expect(order?.accessCode) == task.accessCode
                expect(order?.telematikId) == self.pharmacy.telematikID
                expect(order?.endpoint) == self.pharmacy.avsEndpoints?.url(for: initialState.redeemOption)
            }
        }
        sut.receive(.redeemReceived(.success(expectedOrderResponses))) {
            $0.orderResponses = expectedOrderResponses
            $0.successViewState = RedeemSuccessDomain.State(redeemOption: .onPremise)

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
                expect(response?.requested.endpoint) == self.pharmacy.avsEndpoints?.url(for: initialState.redeemOption)
            }
        }
    }

    func testLoadingProfile() {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(for: PharmacyRedeemDomain.State(
            redeemOption: .onPremise,
            erxTasks: inputTasks,
            pharmacy: pharmacy,
            selectedErxTasks: Set(inputTasks)
        ))

        let expectedProfile = Profile(name: "Anna Vetter", color: Profile.Color.yellow)
        mockUserSession.profileReturnValue = Just(expectedProfile).setFailureType(to: LocalStoreError.self)
            .eraseToAnyPublisher()

        sut.send(.registerSelectedProfileListener)

        sut.receive(.selectedProfileReceived(.success(expectedProfile))) {
            $0.profile = expectedProfile
        }
    }

    func testRedeemWithMissingPhone() {
        let inputTasks = ErxTask.Fixtures.erxTasks
        let sut = testStore(for: PharmacyRedeemDomain.State(
            redeemOption: .shipment,
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
        mockShipmentInfoDataStore.selectedShipmentInfoReturnValue = Just(expectedShipmentInfo)
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()
        mockUserSession.isLoggedIn = false

        sut.send(.registerSelectedShipmentInfoListener)
        sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        sut.send(.redeem) {
            $0.alertState = PharmacyRedeemDomain.AlertStates.missingPhoneState
        }
    }

    func testGeneratingShipmentInfoFromErxTask() {
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
}

extension Order {
    static var fixture: Order = {
        Order(redeemType: .shipment, taskID: "task_id_0", accessCode: "access_code_0", telematikId: "k123456789")
    }()
}
