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

import AVS
@testable import eRpFeatures
import eRpKit
import Foundation
import Nimble
import XCTest

final class AVSMessageFromOrderTests: XCTestCase {
    func testMinimalExample() throws {
        // given
        let order = OrderRequest(
            version: "1",
            redeemType: .onPremise,
            flowType: "160",
            taskID: "taskID",
            accessCode: "accessCode"
        )

        // then
        expect(
            try AVSMessage(order)
        ).toNot(throwError())
    }

    func testMinimalExampleJsonEncodable() throws {
        // given
        let version = 1
        let supplyOption = AVSMessage.SupplyOptionsType.onPremise
        let transactionID = UUID(uuidString: "A37E7651-427C-4899-9508-5660677F103C")!
        let taskID = ""
        let accessCode = ""
        let avsMessage = AVSMessage(
            version: version,
            supplyOptionsType: supplyOption,
            transactionID: transactionID,
            taskID: taskID,
            accessCode: accessCode
        )

        let jsonDecoder = JSONEncoder()
        jsonDecoder.outputFormatting = [.prettyPrinted]

        // when
        let sut = try jsonDecoder.encode(avsMessage)

        // then
        expect(String(data: sut, encoding: .utf8))
            .to(contain(#""transactionID" : "A37E7651-427C-4899-9508-5660677F103C""#))
        expect(String(data: sut, encoding: .utf8)).to(contain(#""supplyOptionsType" : "onPremise""#))
    }

    func testIsValidName() throws {
        let sut = AVSMessage.Validator()
        // given
        let name = "Dr. Dr. med. Carsten van Storchhausen"
        let longName = "Dr. Dr. med. Carsten van Storchhausen und von Dazumal"
        let validExample = AVSMessage.Fixtures.completeExample

        // then
        expect(sut.isValid(name: name)) == .valid
        expect(sut.isValid(name: longName)) ==
            .invalid(L10n.rivAvsInvalidName(String(AVSMessage.Validator.maxNameLength)).text)
        expect(
            sut.isValidAVSMessageInput(
                version: validExample.version,
                supplyOptionsType: validExample.supplyOptionsType,
                name: longName,
                address: Address(street: "Bundesallee", zip: "312", city: "Berlin"),
                hint: validExample.hint,
                text: validExample.text,
                phone: validExample.phone,
                mail: validExample.mail
            )
        ) == .invalid(L10n.rivAvsInvalidName(String(AVSMessage.Validator.maxNameLength)).text)

        let order = OrderRequest(
            version: String(validExample.version),
            redeemType: validExample.supplyOptionsType.asRedeemOption,
            name: longName,
            flowType: "160",
            transactionID: validExample.transactionID,
            taskID: validExample.taskID,
            accessCode: validExample.accessCode
        )
        expect(
            try AVSMessage(order)
        ).to(throwError(AVSError.invalidAVSMessageInput))
    }

    func testIfDeliveryOrShipmentThenNonEmptyPhoneOrNonEmptyMail() throws {
        // given
        let validExample = AVSMessage.Fixtures.completeExample
        let order1 = OrderRequest(
            version: String(validExample.version),
            redeemType: .delivery,
            name: validExample.name,
            flowType: "160",
            phone: "",
            mail: "",
            transactionID: validExample.transactionID,
            taskID: validExample.taskID,
            accessCode: validExample.accessCode
        )

        // then
        expect(try AVSMessage(order1)).to(throwError(AVSError.invalidAVSMessageInput))

        let order2 = OrderRequest(
            version: String(validExample.version),
            redeemType: .delivery,
            name: validExample.name,
            flowType: "160",
            phone: "0123467890",
            mail: "",
            transactionID: validExample.transactionID,
            taskID: validExample.taskID,
            accessCode: validExample.accessCode
        )
        expect(try AVSMessage(order2)).toNot(throwError())

        let order3 = OrderRequest(
            version: String(validExample.version),
            redeemType: .shipment,
            name: validExample.name,
            flowType: "160",
            phone: "",
            mail: "",
            transactionID: validExample.transactionID,
            taskID: validExample.taskID,
            accessCode: validExample.accessCode
        )
        expect(try AVSMessage(order3)).to(throwError(AVSError.invalidAVSMessageInput))
    }
}

extension AVSMessage {
    enum Fixtures {
        static let completeExample: AVSMessage = .init(
            version: 2,
            supplyOptionsType: .delivery,
            name: "Dr. Maximilian von Muster",
            address: ["Bundesallee", "312", "12345", "Berlin"],
            hint: "Bitte im Morsecode klingeln: -.-.",
            text: "123456",
            phone: "004916094858168",
            mail: "max@musterfrau.de",
            transactionID: UUID(uuidString: "ee63e415-9a99-4051-ab07-257632faf985")!,
            taskID: "160.123.456.789.123.58",
            accessCode: "777bea0e13cc9c42ceec14aec3ddee2263325dc2c6c699db115f58fe423607ea"
        )
    }
}
