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

@testable import AVS
import Foundation
import Nimble
import XCTest

final class AVSMessageTests: XCTestCase {
    func testMinimalExample() throws {
        // given
        let version = 1
        let supplyOption = AVSMessage.SupplyOptionsType.onPremise
        let transactionID = UUID(uuidString: "A37E7651-427C-4899-9508-5660677F103C")!
        let taskID = ""
        let accessCode = ""

        // then
        expect(
            try AVSMessage(
                version: version,
                supplyOptionsType: supplyOption,
                transactionID: transactionID,
                taskID: taskID,
                accessCode: accessCode
            )
        ).toNot(throwError())
    }

    func testMinimalExampleJsonEncodable() throws {
        // given
        let version = 1
        let supplyOption = AVSMessage.SupplyOptionsType.onPremise
        let transactionID = UUID(uuidString: "A37E7651-427C-4899-9508-5660677F103C")!
        let taskID = ""
        let accessCode = ""
        let avsMessage = try AVSMessage(
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
        expect(sut.utf8string).to(contain(#""transactionID" : "A37E7651-427C-4899-9508-5660677F103C""#))
        expect(sut.utf8string).to(contain(#""supplyOptionsType" : "onPremise""#))
    }

    func testIsValidName() throws {
        // given
        let name = "Dr. Dr. med. Carsten van Storchhausen"
        let longName = "Dr. Dr. med. Carsten van Storchhausen und von Dazumal"
        let validExample = AVSMessage.Fixtures.completeExample

        // then
        expect(AVSMessage.Validator.isValid(name: name)) == true
        expect(AVSMessage.Validator.isValid(name: longName)) == false
        expect(
            AVSMessage.Validator.isValidAVSMessageInput(
                version: validExample.version,
                supplyOptionsType: validExample.supplyOptionsType,
                name: longName,
                address: validExample.address,
                hint: validExample.hint,
                text: validExample.text,
                phone: validExample.phone,
                mail: validExample.mail
            )
        ) == false
        expect(
            try AVSMessage(
                version: validExample.version,
                supplyOptionsType: validExample.supplyOptionsType,
                name: longName,
                transactionID: validExample.transactionID,
                taskID: validExample.taskID,
                accessCode: validExample.accessCode
            )
        ).to(throwError(AVSError.invalidAVSMessageInput))
    }

    func testIfDeliveryOrShipmentThenNonEmptyPhoneOrNonEmptyMail() throws {
        // given
        let validExample = AVSMessage.Fixtures.completeExample

        // then
        expect(
            try AVSMessage(
                version: validExample.version,
                supplyOptionsType: .delivery,
                name: validExample.name,
                phone: "",
                mail: "",
                transactionID: validExample.transactionID,
                taskID: validExample.taskID,
                accessCode: validExample.accessCode
            )
        ).to(throwError(AVSError.invalidAVSMessageInput))
        expect(
            try AVSMessage(
                version: validExample.version,
                supplyOptionsType: .delivery,
                name: validExample.name,
                phone: "0123467890",
                mail: "",
                transactionID: validExample.transactionID,
                taskID: validExample.taskID,
                accessCode: validExample.accessCode
            )
        ).toNot(throwError())
        expect(
            try AVSMessage(
                version: validExample.version,
                supplyOptionsType: .shipment,
                name: validExample.name,
                phone: "",
                mail: "",
                transactionID: validExample.transactionID,
                taskID: validExample.taskID,
                accessCode: validExample.accessCode
            )
        ).to(throwError(AVSError.invalidAVSMessageInput))
    }
}
