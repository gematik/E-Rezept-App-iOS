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
    var mockErxTaskRepository: MockErxTaskRepository!
    var mockUserSession: MockUserSession!
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
        mockErxTaskRepository = MockErxTaskRepository()
        mockShipmentInfoDataStore = MockShipmentInfoDataStore()
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
                erxTaskRepository: mockErxTaskRepository,
                shipmentInfoStore: mockShipmentInfoDataStore
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
            hoursOfOperation: []
        )
    }

    func testRedeemingWhenNotLoggedIn() {
        let inputTasks = ErxTask.Dummies.erxTasks
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

        sut.send(.registerSelectedShipmentInfoListener)
        sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        sut.send(.redeem) {
            $0.loadingState = .loading(nil)
        }
        sut.receive(.redeemReceived(.value(false))) {
            $0.loadingState = .value(false)
            $0.alertState = PharmacyRedeemDomain.loginAlertState
        }
    }

    func testRedeemHappyPath() {
        let inputTasks = ErxTask.Dummies.erxTasks
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
        mockUserSession.isLoggedIn = true
        mockErxTaskRepository.redeemPublisher = Just(true).setFailureType(to: ErxRepositoryError.self)
            .eraseToAnyPublisher()

        sut.send(.registerSelectedShipmentInfoListener)
        sut.receive(.selectedShipmentInfoReceived(.success(expectedShipmentInfo))) {
            $0.selectedShipmentInfo = expectedShipmentInfo
        }

        sut.send(.redeem) {
            $0.loadingState = .loading(nil)
        }
        sut.receive(.redeemReceived(.value(true))) {
            $0.loadingState = .value(true)
            $0.successViewState = RedeemSuccessDomain.State(redeemOption: .onPremise)
        }
    }

    func testLoadingProfile() {
        let inputTasks = ErxTask.Dummies.erxTasks
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
        let inputTasks = ErxTask.Dummies.erxTasks
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
            $0.loadingState = .loading(nil)
            $0.alertState = PharmacyRedeemDomain.missingPhoneState
        }
    }

    func testGeneratingShipmentInfoFromErxTask() {
        let erxTask = ErxTask.Dummies.erxTasks.first!
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
