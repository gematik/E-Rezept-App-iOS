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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class OrderDetailViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testOderDetailViewWithOneCommunicationDispRequest() {
        let sut = OrderDetailView(
            store: OrderDetailDomain.Store(
                initialState: .init(order: OrderCommunications(
                    orderId: "test",
                    communications: [OrdersDomain.Dummies.communicationDispRequest]
                )),
                reducer: EmptyReducer()
            )
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithExpectedCommunications() {
        let sut = OrderDetailView(
            store: OrderDetailDomain.Store(
                initialState: .init(order: OrderCommunications(
                    orderId: "test",
                    communications: [OrdersDomain.Dummies.communicationOnPremise,
                                     OrdersDomain.Dummies.communicationShipment,
                                     OrdersDomain.Dummies.communicationDelivery]
                )),
                reducer: EmptyReducer()
            )
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithUnexpectedCommunications() {
        let sut = OrderDetailView(store:
            OrderDetailDomain.Store(
                initialState: .init(order: OrderCommunications(
                    orderId: "test",
                    communications: [OrdersDomain.Dummies.communicationOnPremiseWithUrl,
                                     OrdersDomain.Dummies.communicationWithoutPayload]
                )),
                reducer: EmptyReducer()
            ))
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
