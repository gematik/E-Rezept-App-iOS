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
@testable import eRpApp
import eRpKit
import Nimble
import XCTest

class PharmacyContactDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.immediate
    var mockShipmentInfoDataStore: MockShipmentInfoDataStore!
    typealias TestStore = ComposableArchitecture.TestStore<
        PharmacyContactDomain.State,
        PharmacyContactDomain.State,
        PharmacyContactDomain.Action,
        PharmacyContactDomain.Action,
        PharmacyContactDomain.Environment
    >
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
    }

    override func tearDownWithError() throws {
        store = nil

        try super.tearDownWithError()
    }

    func testStore(for state: PharmacyContactDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: PharmacyContactDomain.reducer,
            environment: PharmacyContactDomain.Environment(
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                shipmentInfoStore: mockShipmentInfoDataStore
            )
        )
    }

    func test_saveContactInformation() {
        // given
        let sut = testStore(for: PharmacyContactDomain.State(shipmentInfo: shipmentInfo))
        mockShipmentInfoDataStore.saveShipmentInfoReturnValue = Just([shipmentInfo])
            .setFailureType(to: LocalStoreError.self).eraseToAnyPublisher()

        // when
        sut.send(.save)

        // then
        expect(self.mockShipmentInfoDataStore.saveShipmentInfoCallsCount).to(equal(1))
        sut.receive(.shipmentInfoSaved(.success(shipmentInfo)))
        expect(self.mockShipmentInfoDataStore.setSelectedShipmentInfoIdCallsCount).to(equal(1))
        sut.receive(.close)
    }

    func test_saveContactInformationWithError() {
        // given
        let expectedError = LocalStoreError.write(error: DemoError.demo)
        let sut = testStore(for: PharmacyContactDomain.State(shipmentInfo: shipmentInfo))
        mockShipmentInfoDataStore.saveShipmentInfoReturnValue =
            Fail(error: expectedError)
                .eraseToAnyPublisher()

        // when
        sut.send(.save)

        // then
        expect(self.mockShipmentInfoDataStore.saveShipmentInfoCallsCount).to(equal(1))
        sut.receive(.shipmentInfoSaved(.failure(expectedError))) {
            $0.alertState = AlertState(
                title: TextState("Error"),
                message: TextState("The operation couldn’t be completed. (eRpApp.DemoError error 0.)"),
                dismissButton: AlertState.Button.default(
                    TextState("OK"),
                    action: AlertState.ButtonAction.send(PharmacyContactDomain.Action.alertDismissButtonTapped)
                )
            )
        }
        expect(self.mockShipmentInfoDataStore.setSelectedShipmentInfoIdCallsCount).to(equal(0))
    }
}
