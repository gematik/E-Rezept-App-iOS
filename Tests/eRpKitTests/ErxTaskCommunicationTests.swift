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
