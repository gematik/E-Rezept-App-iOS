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

@testable import eRpKit
import Nimble
import XCTest

// swiftlint:disable line_length
final class ErxTaskCommunicationTests: XCTestCase {
    // MARK: - V1 Payload Tests

    func testParsingShipmentPayloadWithUrl() throws {
        let inputJson =
            "{\"version\": \"1\",\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurde!\",\"url\": \"www.das-e-rezept-fuer-deutschland.de\"}"
        let expected = ErxTask.Communication.Payload(
            supplyOptionsType: .shipment,
            infoText: "Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurde!",
            pickUpCodeHR: nil,
            pickUpCodeDMC: nil,
            url: "www.das-e-rezept-fuer-deutschland.de",
            version: 1
        )
        let payload = try ErxTask.Communication.Payload.from(string: inputJson)
        expect(payload) == expected
    }

    func testParsingShipmentPayloadWithUrlWithVersionInt() throws {
        let inputJson =
            "{\"version\": 1,\"supplyOptionsType\": \"shipment\",\"info_text\": \"Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurde!\",\"url\": \"www.das-e-rezept-fuer-deutschland.de\"}"
        let expected = ErxTask.Communication.Payload(
            supplyOptionsType: .shipment,
            infoText: "Wir möchten Sie informieren, dass Ihre bestellten Medikamente versandt wurde!",
            pickUpCodeHR: nil,
            pickUpCodeDMC: nil,
            url: "www.das-e-rezept-fuer-deutschland.de",
            version: 1
        )
        let payload = try ErxTask.Communication.Payload.from(string: inputJson)
        expect(payload) == expected
    }

    func testParsingOnPremisePayloadWithUrl() throws {
        let inputJson =
            "{\"version\": \"1\",\"supplyOptionsType\": \"onPremise\",\"info_text\": \"bitte abholen\",\"pickUpCodeHR\": \"12341234\",\"pickUpCodeDMC\": \"465465465f6s4g6df54gs65dfg\",\"url\": \"\"}"
        let expected = ErxTask.Communication.Payload(
            supplyOptionsType: .onPremise,
            infoText: "bitte abholen",
            pickUpCodeHR: "12341234",
            pickUpCodeDMC: "465465465f6s4g6df54gs65dfg",
            url: "",
            version: 1
        )
        let payload = try ErxTask.Communication.Payload.from(string: inputJson)
        expect(payload) == expected
    }

    func testParsingOnPremisePayloadWithUrlWithVersionInt() throws {
        let inputJson =
            "{\"version\": 1,\"supplyOptionsType\": \"onPremise\",\"info_text\": \"bitte abholen\",\"pickUpCodeHR\": \"12341234\",\"pickUpCodeDMC\": \"465465465f6s4g6df54gs65dfg\",\"url\": \"\"}"
        let expected = ErxTask.Communication.Payload(
            supplyOptionsType: .onPremise,
            infoText: "bitte abholen",
            pickUpCodeHR: "12341234",
            pickUpCodeDMC: "465465465f6s4g6df54gs65dfg",
            url: "",
            version: 1
        )
        let payload = try ErxTask.Communication.Payload.from(string: inputJson)
        expect(payload) == expected
    }

    // MARK: - PayloadVersion Detection

    func testPayloadVersionDetectionV1() {
        let v1Json = "{\"version\": 1, \"supplyOptionsType\": \"shipment\", \"info_text\": \"test\"}"
        let communication = ErxTask.Communication(
            identifier: "test-id",
            profile: .reply,
            taskId: "task-1",
            userId: "X110461389",
            telematikId: "3-09.2.S.10.743",
            timestamp: "2025-01-01T00:00:00Z",
            payloadJSON: v1Json
        )
        expect(communication.payload?.payloadVersion) == .v1_0
        expect(communication.payload?.supplyOptionsType) == .shipment
        expect(communication.payload?.infoText) == "test"
    }

    func testPayloadVersionDetectionV3() {
        let v3Json = """
        {"version":3,"communicationType":"text","transactionID":"ABCD-1234","text":"Vielen Dank!"}
        """
        let communication = ErxTask.Communication(
            identifier: "test-id",
            profile: .reply,
            taskId: "task-1",
            userId: "X110461389",
            telematikId: "3-09.2.S.10.743",
            timestamp: "2025-01-01T00:00:00Z",
            payloadJSON: v3Json
        )
        expect(communication.payload?.payloadVersion) == .v3_0
        expect(communication.payload?.communicationType) == .text
        expect(communication.payload?.infoText) == "Vielen Dank!"
        expect(communication.payload?.transactionID) == "ABCD-1234"
    }

    // MARK: - V3 Reply Payload Decoding

    func testDecodingV3TextReply() throws {
        let json = """
        {"version":3,"communicationType":"text","transactionID":"TX-001","text":"Vielen Dank für Ihre Bestellung!"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.version) == 3
        expect(payload?.communicationType) == .text
        expect(payload?.transactionID) == "TX-001"
        expect(payload?.infoText) == "Vielen Dank für Ihre Bestellung!"
    }

    func testDecodingV3LinkReply() throws {
        let json = """
        {"version":3,"communicationType":"link","transactionID":"TX-002","text":"Hier finden Sie Ihren Warenkorb.","url":"https://example.com/cart"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .link
        expect(payload?.url) == "https://example.com/cart"
        expect(payload?.infoText) == "Hier finden Sie Ihren Warenkorb."
    }

    func testDecodingV3ReservationStatusReply() throws {
        let json = """
        {"version":3,"communicationType":"reservationStatus","transactionID":"TX-003","readyForCollection":"immediately"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .reservationStatus
        expect(payload?.readyForCollection) == .immediately
    }

    func testDecodingV3PickupCodeHRReply() throws {
        let json = """
        {"version":3,"communicationType":"pickupCodeHR","transactionID":"TX-004","pickupCodeHR":"0815","text":"Bitte abholen"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .pickupCodeHR
        expect(payload?.pickUpCodeHR) == "0815"
        expect(payload?.infoText) == "Bitte abholen"
    }

    func testDecodingV3PickupCodeDMCReply() throws {
        let json = """
        {"version":3,"communicationType":"pickupCodeDMC","transactionID":"TX-005","pickupCodeDMC":"MACHINE_READABLE_CONTENT"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .pickupCodeDMC
        expect(payload?.pickUpCodeDMC) == "MACHINE_READABLE_CONTENT"
        expect(payload?.isPickupCodeEmptyOrNil) == false
    }

    func testDecodingV3DeliveryStatusReply() throws {
        let json = """
        {"version":3,"communicationType":"deliveryStatus","transactionID":"TX-006","deliveryStatus":"inTransport","inTransportPosition":{"long":13.387,"lat":52.522},"inTransportETA":{"from":1735736400,"to":1735741800}}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .deliveryStatus
        expect(payload?.deliveryStatus) == .inTransport
        expect(payload?.inTransportPosition?.lat).to(beCloseTo(52.522, within: 0.001))
        expect(payload?.inTransportETA?.from) == 1_735_736_400
    }

    func testDecodingV3PaymentInfoReply() throws {
        let json = """
        {"version":3,"communicationType":"paymentInfo","transactionID":"TX-007","totalAmount":12530,"paymentMethods":[{"method":"cash"},{"method":"paypal","url":"https://paypal.me/pharmacy"}]}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.communicationType) == .paymentInfo
        expect(payload?.totalAmount) == 12530
        expect(payload?.paymentMethods.count) == 2
        expect(payload?.paymentMethods.first?.method) == .cash
        expect(payload?.paymentMethods.last?.method) == .paypal
        expect(payload?.paymentMethods.last?.url) == "https://paypal.me/pharmacy"
    }

    func testDecodingV3WithStringVersion() throws {
        let json = """
        {"version":"3","communicationType":"text","transactionID":"TX-008","text":"String version"}
        """
        let payload = try ErxTask.Communication.Payload.from(string: json)
        expect(payload?.version) == 3
        expect(payload?.payloadVersion) == .v3_0
    }

    // MARK: - V3 Reply Payload Encoding

    func testEncodingV3TextReplyRoundTrip() throws {
        let payload = ErxTask.Communication.Payload(
            communicationType: .text,
            transactionID: "TX-ENC-001",
            infoText: "Danke!"
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let decoded = try JSONDecoder().decode(ErxTask.Communication.Payload.self, from: data)
        expect(decoded.communicationType) == .text
        expect(decoded.infoText) == "Danke!"
        expect(decoded.transactionID) == "TX-ENC-001"
        expect(decoded.version) == 3
    }

    func testEncodingV3PickupCodeHRReplyRoundTrip() throws {
        let payload = ErxTask.Communication.Payload(
            communicationType: .pickupCodeHR,
            transactionID: "TX-ENC-002",
            infoText: "Bereit",
            pickUpCodeHR: "1234"
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        // V3 encoding uses lowercase "pickupCodeHR"
        expect(jsonString).to(contain("\"pickupCodeHR\":\"1234\""))
        expect(jsonString).to(contain("\"version\":3"))
    }

    // MARK: - V3 DispReq Payload (Outgoing)

    func testV3DispReqDeliveryOrderPayload() throws {
        let payload = ErxTaskOrder.Payload(
            communicationType: .order,
            supplyOptionsType: .delivery,
            firstname: "Max",
            lastname: "Mustermann",
            addressLine: "Musterstraße 1",
            postcode: "12345",
            city: "Berlin",
            country: "DE",
            phone: "+49555555555",
            hint: "Klingeln",
            transactionID: "TX-ORDER-001"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        expect(jsonString).to(contain("\"version\":3"))
        expect(jsonString).to(contain("\"communicationType\":\"order\""))
        expect(jsonString).to(contain("\"firstname\":\"Max\""))
        expect(jsonString).to(contain("\"lastname\":\"Mustermann\""))
        expect(jsonString).to(contain("\"supplyOptionsType\":\"delivery\""))
        expect(jsonString).to(contain("\"postcode\":\"12345\""))
    }

    func testV3DispReqReservationPayload() throws {
        let payload = ErxTaskOrder.Payload(
            communicationType: .order,
            supplyOptionsType: .onPremise,
            phone: "+49555555555",
            hint: "Ab 14 Uhr",
            transactionID: "TX-ORDER-002"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        expect(jsonString).to(contain("\"supplyOptionsType\":\"onPremise\""))
        expect(jsonString).to(contain("\"communicationType\":\"order\""))
        expect(jsonString).toNot(contain("\"firstname\""))
    }

    func testV3DispReqMessagePayload() throws {
        let payload = ErxTaskOrder.Payload(
            communicationType: .text,
            phone: "+49555555555",
            text: "Gibt es noch Traubenzucker?",
            transactionID: "TX-MSG-001"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        expect(jsonString).to(contain("\"communicationType\":\"text\""))
        expect(jsonString).to(contain("\"text\":\"Gibt es noch Traubenzucker?\""))
        expect(jsonString).to(contain("\"transactionID\":\"TX-MSG-001\""))
    }

    func testV3DispReqPayloadRoundTrip() throws {
        let original = ErxTaskOrder.Payload(
            communicationType: .order,
            supplyOptionsType: .shipment,
            firstname: "Erika",
            lastname: "Musterfrau",
            addressLine: "Hauptstraße 10",
            postcode: "80331",
            city: "München",
            country: "DE",
            phone: "+4989123456",
            email: "erika@example.de",
            transactionID: "TX-RT-001"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ErxTaskOrder.Payload.self, from: data)
        expect(decoded) == original
    }

    func testV1DispReqPayloadBackwardCompatibility() throws {
        let payload = ErxTaskOrder.Payload(
            version: 1,
            supplyOptionsType: .shipment,
            name: "Graf Dracula",
            address: ["Schloss Bran", "Rumänien"],
            hint: "Nur bei Tageslicht liefern!",
            phone: "666 999 666"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(payload)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        expect(jsonString).to(contain("\"name\":\"Graf Dracula\""))
        expect(jsonString).to(contain("\"version\":1"))
        // V1 should NOT contain v3 fields
        expect(jsonString).toNot(contain("\"communicationType\""))
        expect(jsonString).toNot(contain("\"firstname\""))
    }
}

// swiftlint:enable line_length
