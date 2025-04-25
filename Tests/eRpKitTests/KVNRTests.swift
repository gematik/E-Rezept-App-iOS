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

@testable import eRpKit
import Nimble
import XCTest

final class KVNRTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testValidatorSucceeds() {
        XCTAssertTrue(KVNR(value: "A123456780").isValid)
        XCTAssertTrue(KVNR(value: "a123456780").isValid)
        XCTAssertTrue(KVNR(value: "Q123456784").isValid)
        XCTAssertTrue(KVNR(value: "Z123456783").isValid)
        XCTAssertTrue(KVNR(value: "z123456783").isValid)
    }

    func testValidatorFails() {
        let kvnrs: [KVNR] = [
            "Q123456781",
            "Q123456782",
            "Q123456783",
            "Q123456785",
            "Q123456786",
            "Q123456787",
            "Q123456788",
            "Q123456789",
            "Q123456780",
        ].map(KVNR.init)

        for kvnr in kvnrs {
            XCTAssertFalse(kvnr.isValid)
        }
    }

    func testInvalidInput() {
        XCTAssertFalse(KVNR(value: "Q12345678").isValid)
        XCTAssertFalse(KVNR(value: "Q1234567893").isValid)
        XCTAssertFalse(KVNR(value: "").isValid)
    }

    func testInvalidCharacterInput() {
        XCTAssertFalse(KVNR(value: "0123456780").isValid)
        XCTAssertFalse(KVNR(value: "0123456781").isValid)
        XCTAssertFalse(KVNR(value: "0123456782").isValid)
        XCTAssertFalse(KVNR(value: "0123456783").isValid)
        XCTAssertFalse(KVNR(value: "0123456784").isValid)
        XCTAssertFalse(KVNR(value: "0123456785").isValid)
        XCTAssertFalse(KVNR(value: "0123456786").isValid)
        XCTAssertFalse(KVNR(value: "0123456787").isValid)
        XCTAssertFalse(KVNR(value: "0123456788").isValid)
        XCTAssertFalse(KVNR(value: "0123456789").isValid)
        XCTAssertFalse(KVNR(value: "â123456780").isValid)
        XCTAssertFalse(KVNR(value: "â123456781").isValid)
        XCTAssertFalse(KVNR(value: "â123456782").isValid)
        XCTAssertFalse(KVNR(value: "â123456783").isValid)
        XCTAssertFalse(KVNR(value: "â123456784").isValid)
        XCTAssertFalse(KVNR(value: "â123456785").isValid)
        XCTAssertFalse(KVNR(value: "â123456786").isValid)
        XCTAssertFalse(KVNR(value: "â123456787").isValid)
        XCTAssertFalse(KVNR(value: "â123456788").isValid)
        XCTAssertFalse(KVNR(value: "â123456789").isValid)
        XCTAssertFalse(KVNR(value: "ä123456780").isValid)
        XCTAssertFalse(KVNR(value: "ä123456781").isValid)
        XCTAssertFalse(KVNR(value: "ä123456782").isValid)
        XCTAssertFalse(KVNR(value: "ä123456783").isValid)
        XCTAssertFalse(KVNR(value: "ä123456784").isValid)
        XCTAssertFalse(KVNR(value: "ä123456785").isValid)
        XCTAssertFalse(KVNR(value: "ä123456786").isValid)
        XCTAssertFalse(KVNR(value: "ä123456787").isValid)
        XCTAssertFalse(KVNR(value: "ä123456788").isValid)
        XCTAssertFalse(KVNR(value: "ä123456789").isValid)
        XCTAssertFalse(KVNR(value: "Ö123456780").isValid)
        XCTAssertFalse(KVNR(value: "§123456780").isValid)
    }
}
