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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class OrderDetailViewSnapshotTests: ERPSnapshotTestCase {
    let communicationDispRequest = ErxTask.Communication(
        identifier: "1",
        profile: .dispReq,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
    )

    let communicationOnPremise = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\"}" // swiftlint:disable:this line_length
    )

    let communicationShipment = ErxTask.Communication(
        identifier: "2",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-28T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Checkout your shimpment in the shopping cart.\",\"url\": \"https://das-e-rezept-fuer-deutschland.de\"}",
        // swiftlint:disable:previous line_length
        isRead: true
    )

    let communicationDelivery = ErxTask.Communication(
        identifier: "3",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-29T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"delivery\",\"info_text\": \"Your prescription is on the way. Make sure you are at home. We will not come back and bring you more drugs! Just kidding ;)\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
    )

    let communicationOnPremiseWithUrl = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-29T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs.\", \"pickUpCodeHR\":\"4711\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
    )

    let communicationWithoutPayload = ErxTask.Communication(
        identifier: "4",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        orderId: "orderId",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "",
        isRead: true
    )

    let communicationWithEmptyInfoText = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"\", \"pickUpCodeHR\":\"4711\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
    )

    let communicationWithInfoTextPhoneNumber = ErxTask.Communication(
        identifier: "1",
        profile: .reply,
        taskId: "taskID",
        userId: "userID",
        telematikId: "telematikID",
        timestamp: "2021-05-26T10:59:37.098245933+00:00",
        payloadJSON: "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"You can come by and pick up your drugs or call us at: +49 30 89 00 43 33.\", \"pickUpCodeHR\":\"4711\", \"url\": \"https://das-e-rezept-fuer-deutschland.de\"}" // swiftlint:disable:this line_length
    )

    func testOderDetailViewWithOneCommunicationDispRequest() {
        let order = Order(
            orderId: "test",
            communications: [communicationDispRequest],
            chargeItems: []
        )
        let sut = OrderDetailView(
            store: StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithExpectedCommunicationsAndChargeItem() {
        let order = Order(
            orderId: "test",
            communications: [communicationOnPremise,
                             communicationShipment,
                             communicationDelivery],
            chargeItems: [ErxChargeItem.Fixtures.chargeItem]
        )
        let sut = OrderDetailView(
            store: StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithUnexpectedCommunications() {
        let order = Order(
            orderId: "test",
            communications: [communicationOnPremiseWithUrl,
                             communicationWithoutPayload],
            chargeItems: []
        )
        let sut = OrderDetailView(store:
            StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithEmptyTextButPickupCode() {
        let order = Order(
            orderId: "test",
            communications: [communicationWithEmptyInfoText],
            chargeItems: []
        )
        let sut = OrderDetailView(store:
            StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            })
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithInfoTextPhoneNumber() {
        let order = Order(
            orderId: "test",
            communications: [communicationWithInfoTextPhoneNumber],
            chargeItems: []
        )
        let sut = OrderDetailView(
            store: StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOderDetailViewWithSingleChips() {
        var order = Order(orderId: "test",
                          communications: [communicationDispRequest],
                          chargeItems: [],
                          timelineEntries: [.dispReq(ErxTask.Communication.Unique(from: communicationDispRequest),
                                                     pharmacy: nil,
                                                     chipTexts: ["Traubenzucker 100g"])])

        let sut = OrderDetailView(
            store: StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    // TODO: Add Test with multiple rows of chips but view is broken for Snapshots // swiftlint:disable:this todo
    func testOderDetailViewWithMultipleChips() {
        let order = Order(orderId: "test",
                          communications: [communicationDispRequest],
                          chargeItems: [],
                          timelineEntries: [.dispReq(ErxTask.Communication.Unique(from: communicationDispRequest),
                                                     pharmacy: nil,
                                                     chipTexts: ["Traubenzucker 100g", "Vita-Tee"])])
        let sut = OrderDetailView(
            store: StoreOf<OrderDetailDomain>(
                initialState: .init(
                    communicationMessage: CommunicationMessage.order(order),
                    erxTasks: IdentifiedArray(arrayLiteral: ErxTask.Fixtures.erxTask1)
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
