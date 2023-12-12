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

@testable import eRpKit
import Nimble
import XCTest

// swiftlint:disable line_length
final class ErxTaskCommunicationTests: XCTestCase {
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
}

// swiftlint:enable line_length
