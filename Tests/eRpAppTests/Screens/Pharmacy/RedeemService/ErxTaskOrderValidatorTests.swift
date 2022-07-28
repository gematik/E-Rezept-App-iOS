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

@testable import eRpApp
import eRpKit
import Foundation
import Nimble
import XCTest

final class ErxTaskOrderValidatorTests: XCTestCase {
    func testValidatorFailsWhenShipmentAndPhoneIsNil() {
        let sut = ErxTaskOrder.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: .shipment,
            phone: nil,
            mail: nil
        )

        expect(result) == .invalid(L10n.rivTiInvalidMissingContact.text)
    }

    func testValidatorSucceedsWhenDeliveryAndPhoneIsValid() {
        let sut = ErxTaskOrder.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: .delivery,
            phone: "1234567",
            mail: nil
        )

        expect(result) == .valid
    }

    func testValidatorFailsWhenDeliveryAndPhoneIsNil() {
        let sut = ErxTaskOrder.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: .delivery,
            phone: nil,
            mail: nil
        )

        expect(result) == .invalid(L10n.rivTiInvalidMissingContact.text)
    }

    func testValidatorSucceedsWhenDeliveryAndPhoneIsInvalid() {
        let sut = ErxTaskOrder.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: .delivery,
            phone: "123",
            mail: nil
        )

        expect(result) == .valid
    }

    func testValidatorSucceedsWhenOnPremiseAndPhoneIsNil() {
        let sut = ErxTaskOrder.Validator()

        let result = sut.ifDeliveryOrShipmentThenIsNonEmptyPhoneOrNonEmptyMail(
            optionType: .onPremise,
            phone: nil,
            mail: nil
        )

        expect(result) == .valid
    }

    func testValidatorFailsWhenNumberIsInvalid() {
        let sut = ErxTaskOrder.Validator()

        expect(sut.isValid(phone: "1")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "12")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "123")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "1234")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "12345")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "123456")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "1C234567")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "ABCDEFGH")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "++1234567")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: "123.456.7")) == .invalid(L10n.rivTiInvalidPhone.text)
        expect(sut.isValid(phone: " 0049  030  345  566  890 ")) == .invalid(L10n.rivTiInvalidPhone.text)
    }

    func testPhoneValidatorSucceedsWhenNumberIsValid() {
        let sut = ErxTaskOrder.Validator()

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
        let sut = ErxTaskOrder.Validator()
        expect(sut.isValid(name: nil)) == .valid
        expect(sut.isValid(name: "")) == .valid
        expect(sut.isValid(name: "1234567")) == .valid
        expect(sut.isValid(name: "Mr. Super Dooper Sonderzeichen §!\"%&()=),.")) == .valid
        expect(sut.isValid(name: "Mr. Super Dooper too long name to be a real")) == .valid
    }

    func testNameValidatorFails() {
        let sut = ErxTaskOrder.Validator()
        expect(sut.isValid(
            name: "Mr. and Mrs. Super Dooper way tooooooo long name to be a true with more than 50 characters"
        )) == .invalid(L10n.rivTiInvalidName(String(ErxTaskOrder.Validator.maxNameLength)).text)
    }

    func testHintValidatorWithFails() {
        let sut = ErxTaskOrder.Validator()
        expect(sut.isValid(
            hint: "The hint cannot be longer than 90 characters. That is different from using the AVS service."
        )) == .invalid(L10n.rivTiInvalidHint(String(ErxTaskOrder.Validator.maxHintLength)).text)
    }

    func testHintValidatorWithSuccess() {
        let sut = ErxTaskOrder.Validator()
        expect(sut.isValid(hint: nil)) == .valid
        expect(sut.isValid(hint: "")) == .valid
        expect(sut.isValid(
            hint: "This is only a short hint within the range allowed!"
        )) == .valid
    }

    func testMailValidatorFails() {
        let sut = ErxTaskOrder.Validator()

        expect(sut.isValid(mail: "1")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "@")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik.")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "gematik.de")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "@gematik.de")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "mail@gematik..de")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "mail@subdomain@gematik.de")) == .invalid(L10n.rivTiInvalidMail.text)
        expect(sut.isValid(mail: "mail@@gematik.de")) == .invalid(L10n.rivTiInvalidMail.text)
    }

    func testMailValidatorSucceeds() {
        let sut = ErxTaskOrder.Validator()

        expect(sut.isValid(mail: "mail@gematik.de")) == .valid
        expect(sut.isValid(mail: "1@def.g")) == .valid
        expect(sut.isValid(mail: "abc@def.g.j")) == .valid
        expect(sut.isValid(mail: "mail@subdomain.gematik.de")) == .valid
        expect(sut.isValid(mail: "1-2-3.4a@a.c")) == .valid
        expect(sut.isValid(mail: "mail_with_longer.Name.AndDots@gematik.denkbar")) == .valid
    }

    func testAddressValidatorSucceeds() {
        let sut = ErxTaskOrder.Validator()

        expect(sut.isValid(address: nil)) == .valid
        expect(sut.isValid(address: Address(street: nil, zip: nil, city: nil))) == .valid
        expect(sut.isValid(address: Address(street: "", zip: "", city: ""))) == .valid
        expect(sut.isValid(address: Address(street: "Unter den Linden 17", zip: "", city: nil))) == .valid
        expect(sut.isValid(address: Address(street: "Street 16", zip: nil, city: "Berlin"))) == .valid
        expect(sut.isValid(address: Address(street: "Street", zip: "PLZ", city: "Stadt"))) == .valid
        expect(sut.isValid(address: Address(street: nil, zip: "PLZ", city: "Stadt"))) == .valid
    }

    func testAddressValidatorFails() {
        let sut = ErxTaskOrder.Validator()

        expect(
            sut.isValid(address:
                Address(street: "Street", zip: "this should not be more than 50 characters, never ever", city: nil))
        ) == .invalid(L10n.rivTiInvalidZip(String(ErxTaskOrder.Validator.maxAddressFieldLength)).text)
        expect(
            sut.isValid(address:
                Address(street: "this should not be more than 50 characters, never ever", zip: "", city: ""))
        ) == .invalid(L10n.rivTiInvalidStreet(String(ErxTaskOrder.Validator.maxAddressFieldLength)).text)
        expect(
            sut.isValid(address:
                Address(street: "", zip: "", city: "this should not be more than 50 characters, never ever"))
        ) == .invalid(L10n.rivTiInvalidCity(String(ErxTaskOrder.Validator.maxAddressFieldLength)).text)
    }
}
