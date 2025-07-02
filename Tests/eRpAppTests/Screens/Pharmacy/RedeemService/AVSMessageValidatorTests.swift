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

import AVS
@testable import eRpFeatures
import eRpKit
import Foundation
import Nimble
import XCTest

final class AVSMessageValidatorTests: XCTestCase {
    func testValidatorFailsWhenShipmentAndPhoneIsNil() {
        let sut = AVSMessage.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: .shipment,
            phone: nil,
            mail: nil
        )

        expect(result) == .invalid(L10n.rivAvsInvalidMissingContact.text)
    }

    func testValidatorFailsWhenDeliveryAndPhoneIsNil() {
        let sut = AVSMessage.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: .delivery,
            phone: nil,
            mail: nil
        )

        expect(result) == .invalid(L10n.rivAvsInvalidMissingContact.text)
    }

    func testValidatorSucceedsWhenDeliveryAndPhoneIsInvalid() {
        let sut = AVSMessage.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: .delivery,
            phone: "123",
            mail: nil
        )

        expect(result) == .valid
    }

    func testValidatorSucceedsWhenOnPremiseAndPhoneIsNil() {
        let sut = AVSMessage.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            supplyOptionsType: .onPremise,
            phone: nil,
            mail: nil
        )

        expect(result) == .valid
    }

    func testPhoneValidatorFailsWhenNumberIsInvalid() {
        let sut = AVSMessage.Validator()

        expect(sut.isValid(phone: "1")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "12")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "123")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "1234")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "12345")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "123456")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "1C234567")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "ABCDEFGH")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "++1234567")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: "123.456.7")) == .invalid(L10n.rivAvsInvalidPhone.text)
        expect(sut.isValid(phone: " 0049  030  345  566  890 ")) == .invalid(L10n.rivAvsInvalidPhone.text)
    }

    func testPhoneValidatorSucceedsWhenNumberIsValid() {
        let sut = AVSMessage.Validator()

        expect(sut.isValid(phone: "1234567")) == .valid
        expect(sut.isValid(phone: "+1234567")) == .valid
        expect(sut.isValid(phone: "123.4567")) == .valid
        expect(sut.isValid(phone: "-1234567")) == .valid
        expect(sut.isValid(phone: "0001234567")) == .valid
        expect(sut.isValid(phone: "030 345 567 890")) == .valid
        expect(sut.isValid(phone: "030-345-567-890")) == .valid
        expect(sut.isValid(phone: "0049-030 345 567 890")) == .valid
        expect(sut.isValid(phone: " 0049  030 345 566 890 ")) == .valid
    }

    func testNameValidatorSucceeds() {
        let sut = AVSMessage.Validator()
        expect(sut.isValid(name: nil)) == .valid
        expect(sut.isValid(name: "")) == .valid
        expect(sut.isValid(name: "1234567")) == .valid
        expect(sut.isValid(name: "Mr. Super Dooper Sonderzeichen §!\"%&()=),.")) == .valid
        expect(sut.isValid(name: "Mr. Super Dooper too long name to be a real")) == .valid
    }

    func testNameValidatorFails() {
        let sut = AVSMessage.Validator()
        expect(sut.isValid(
            name: "Mr. and Mrs. Super Dooper way tooooooo long name to be a true with more than 50 characters"
        )) == .invalid(L10n.rivAvsInvalidName(String(AVSMessage.Validator.maxNameLength)).text)
    }

    func testMailValidatorFails() {
        let sut = AVSMessage.Validator()

        expect(sut.isValid(mail: "1")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "@")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik.")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "gematik.de")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "@gematik.de")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik..de")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "mail@subdomain@gematik.de")) == .invalid(L10n.rivAvsInvalidMail.text)
        expect(sut.isValid(mail: "mail@@gematik.de")) == .invalid(L10n.rivAvsInvalidMail.text)
    }

    func testMailValidatorSucceeds() {
        let sut = AVSMessage.Validator()

        expect(sut.isValid(mail: "mail@gematik.de")) == .valid
        expect(sut.isValid(mail: "1@def.g")) == .valid
        expect(sut.isValid(mail: "abc@def.g.j")) == .valid
        expect(sut.isValid(mail: "mail@subdomain.gematik.de")) == .valid
        expect(sut.isValid(mail: "1-2-3.4a@a.c")) == .valid
        expect(sut.isValid(mail: "mail_with_longer.Name.AndDots@gematik.denkbar")) == .valid
    }

    func testAddressValidatorSucceeds() {
        let sut = AVSMessage.Validator()

        expect(sut.isValid(address: nil)) == .valid
        expect(sut.isValid(address: Address(street: nil, zip: nil, city: nil))) == .valid
        expect(sut.isValid(address: Address(street: "", zip: "", city: ""))) == .valid
        expect(sut.isValid(address: Address(street: "Unter den Linden 17", zip: "", city: nil))) == .valid
        expect(sut.isValid(address: Address(street: "Street 16", zip: nil, city: "Berlin"))) == .valid
        expect(sut.isValid(address: Address(street: "Street", zip: "PLZ", city: "Stadt"))) == .valid
        expect(sut.isValid(address: Address(street: nil, zip: "PLZ", city: "Stadt"))) == .valid
    }

    func testAddressValidatorFails() {
        let sut = AVSMessage.Validator()

        expect(
            sut.isValid(address:
                Address(street: "Street", zip: "this should not be more than 50 characters, never ever", city: nil))
        ) == .invalid(L10n.rivAvsInvalidZip(String(AVSMessage.Validator.maxAddressFieldLength)).text)
        expect(
            sut.isValid(address:
                Address(street: "this should not be more than 50 characters, never ever", zip: "", city: ""))
        ) == .invalid(L10n.rivAvsInvalidStreet(String(AVSMessage.Validator.maxAddressFieldLength)).text)
        expect(
            sut.isValid(address:
                Address(street: "", zip: "", city: "this should not be more than 50 characters, never ever"))
        ) == .invalid(L10n.rivAvsInvalidCity(String(AVSMessage.Validator.maxAddressFieldLength)).text)
    }
}
