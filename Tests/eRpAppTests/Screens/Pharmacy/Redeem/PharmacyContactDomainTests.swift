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
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

@MainActor
class PharmacyContactDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockShipmentInfoDataStore: MockShipmentInfoDataStore!
    var mockInputValidator: MockRedeemInputValidator!

    typealias TestStore = TestStoreOf<PharmacyContactDomain>
    var store: TestStore!

    let shipmentInfo = ShipmentInfo(
        identifier: UUID(),
        name: "Ludger Königsstein",
        street: "Musterstr. 1",
        zip: "10623",
        city: "Berlin"
    )

    override func setUp() {
        super.setUp()

        mockShipmentInfoDataStore = MockShipmentInfoDataStore()
        mockInputValidator = MockRedeemInputValidator()
    }

    override func tearDownWithError() throws {
        store = nil

        try super.tearDownWithError()
    }

    func testStore(for state: PharmacyContactDomain.State) -> TestStore {
        TestStore(initialState: state) {
            PharmacyContactDomain()
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.shipmentInfoDataStore = mockShipmentInfoDataStore
            dependencies.redeemInputValidator = mockInputValidator
        }
    }

    func test_saveContactInformation() async {
        // given
        let sut = testStore(for: PharmacyContactDomain.State(
            shipmentInfo: shipmentInfo,
            service: .erxTaskRepository
        ))
        mockInputValidator.returnValue = .valid
        mockShipmentInfoDataStore.saveShipmentInfosReturnValue = Just([shipmentInfo])
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        // when
        await sut.send(.save)

        // then
        expect(self.mockShipmentInfoDataStore.saveShipmentInfosCallsCount).to(equal(1))
        await sut.receive(.response(.shipmentInfoSaved(.success(shipmentInfo))))
        expect(self.mockShipmentInfoDataStore.setSelectedShipmentInfoIdCallsCount).to(equal(1))
        await sut.receive(.delegate(.close))
    }

    func test_saveContactInformationWithError() async {
        // given
        let expectedError = LocalStoreError.write(error: DemoError.demo)
        let sut = testStore(
            for: PharmacyContactDomain.State(
                shipmentInfo: shipmentInfo,
                service: .erxTaskRepository
            )
        )
        mockInputValidator.returnValue = .valid
        mockShipmentInfoDataStore.saveShipmentInfosReturnValue =
            Fail(error: expectedError)
                .eraseToAnyPublisher()

        // when
        await sut.send(.save)

        // then
        expect(self.mockShipmentInfoDataStore.saveShipmentInfosCallsCount).to(equal(1))
        await sut.receive(.response(.shipmentInfoSaved(.failure(expectedError)))) {
            $0.alertState = AlertState(
                title: { TextState("Fehler") },
                actions: {
                    ButtonState(role: .cancel, action: .send(.none)) {
                        TextState("Okay")
                    }
                },
                message: { TextState(LocalStoreError.write(error: DemoError.demo).localizedDescriptionWithErrorList) }
            )
        }
        expect(self.mockShipmentInfoDataStore.setSelectedShipmentInfoIdCallsCount).to(equal(0))
    }

    func testChangingInputIntoSomethingInvalid() async {
        let shipmentInfo = shipmentInfo
        let sut = testStore(
            for: PharmacyContactDomain.State(
                shipmentInfo: shipmentInfo,
                service: .erxTaskRepository
            )
        )

        mockInputValidator.returnValue = .invalid("that is invalid")
        await sut.send(.setDeliveryInfo("hey")) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "that is invalid")
        }
        await sut.send(.alert(.dismiss)) {
            $0.alertState = nil
        }
        await sut.send(.setName("Some Name")) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "that is invalid")
        }
        await sut.send(.alert(.dismiss)) {
            $0.alertState = nil
        }
        await sut.send(.setStreet("Street")) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "that is invalid")
        }
        await sut.send(.alert(.dismiss)) {
            $0.alertState = nil
        }
        await sut.send(.setZip("123")) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "that is invalid")
        }
        await sut.send(.alert(.dismiss)) {
            $0.alertState = nil
        }
        await sut.send(.setCity("Köln")) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "that is invalid")
        }
        await sut.send(.alert(.dismiss)) {
            $0.alertState = nil
        }
        await sut.send(.setPhone("1")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: shipmentInfo.name,
                             street: shipmentInfo.street,
                             addressDetail: shipmentInfo.addressDetail,
                             zip: shipmentInfo.zip,
                             city: shipmentInfo.city,
                             phone: "1",
                             mail: shipmentInfo.mail,
                             deliveryInfo: shipmentInfo.deliveryInfo)
            )
        }
        await sut.send(.setMail("mail")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: shipmentInfo.name,
                             street: shipmentInfo.street,
                             addressDetail: shipmentInfo.addressDetail,
                             zip: shipmentInfo.zip,
                             city: shipmentInfo.city,
                             phone: "1",
                             mail: "mail",
                             deliveryInfo: shipmentInfo.deliveryInfo)
            )
        }
        mockInputValidator.returnValue = .invalid("Invalid Phone")
        await sut.send(.save) { state in
            state.alertState = PharmacyContactDomain.invalidInputAlert(with: "Invalid Phone")
        }
    }

    func testChangingInputIntoSomethingValid() async {
        let shipmentInfo = shipmentInfo
        let sut = testStore(
            for: PharmacyContactDomain.State(
                shipmentInfo: shipmentInfo,
                service: .erxTaskRepository
            )
        )

        mockInputValidator.returnValue = .valid
        await sut.send(.setDeliveryInfo("hey")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: shipmentInfo.name,
                             street: shipmentInfo.street,
                             zip: shipmentInfo.zip,
                             city: shipmentInfo.city,
                             deliveryInfo: "hey")
            )
        }
        await sut.send(.setName("Some Name")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: "Some Name",
                             street: shipmentInfo.street,
                             zip: shipmentInfo.zip,
                             city: shipmentInfo.city,
                             deliveryInfo: "hey")
            )
        }

        await sut.send(.setStreet("Street")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: "Some Name",
                             street: "Street",
                             zip: shipmentInfo.zip,
                             city: shipmentInfo.city,
                             deliveryInfo: "hey")
            )
        }

        await sut.send(.setZip("123")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: "Some Name",
                             street: "Street",
                             zip: "123",
                             city: shipmentInfo.city,
                             deliveryInfo: "hey")
            )
        }
        await sut.send(.setCity("Köln")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: "Some Name",
                             street: "Street",
                             zip: "123",
                             city: "Köln",
                             deliveryInfo: "hey")
            )
        }

        await sut.send(.setPhone("1771234")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(
                ShipmentInfo(identifier: shipmentInfo.id,
                             name: "Some Name",
                             street: "Street",
                             zip: "123",
                             city: "Köln",
                             phone: "1771234",
                             deliveryInfo: "hey")
            )
        }
        let finalShipmentInfo = ShipmentInfo(identifier: shipmentInfo.id,
                                             name: "Some Name",
                                             street: "Street",
                                             zip: "123",
                                             city: "Köln",
                                             phone: "1771234",
                                             mail: "mail",
                                             deliveryInfo: "hey")
        await sut.send(.setMail("mail")) { state in
            state.contactInfo = PharmacyContactDomain.State.ContactInfo(finalShipmentInfo)
        }

        mockShipmentInfoDataStore.saveShipmentInfosReturnValue = Just([finalShipmentInfo])
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        await sut.send(.save)

        expect(self.mockShipmentInfoDataStore.saveShipmentInfosCallsCount).to(equal(1))
        await sut.receive(.response(.shipmentInfoSaved(.success(finalShipmentInfo))))
        expect(self.mockShipmentInfoDataStore.setSelectedShipmentInfoIdCallsCount).to(equal(1))
        await sut.receive(.delegate(.close))
    }
}
