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
        XCTAssertTrue(("A123456780" as KVNR).isValid)
        XCTAssertTrue(("a123456780" as KVNR).isValid)
        XCTAssertTrue(("Q123456784" as KVNR).isValid)
        XCTAssertTrue(("Z123456783" as KVNR).isValid)
        XCTAssertTrue(("z123456783" as KVNR).isValid)
    }

    func testValidatorFails() {
        let kvnrBase: KVNR = "Q12345678"

        let kvnrs: [KVNR] = [
            kvnrBase + "1",
            kvnrBase + "2",
            kvnrBase + "3",
            kvnrBase + "5",
            kvnrBase + "6",
            kvnrBase + "7",
            kvnrBase + "8",
            kvnrBase + "9",
            kvnrBase + "0",
        ]

        for kvnr in kvnrs {
            XCTAssertFalse(kvnr.isValid)
        }
    }

    func testInvalidInput() {
        XCTAssertFalse(("Q12345678" as KVNR).isValid)
        XCTAssertFalse(("Q1234567893" as KVNR).isValid)
        XCTAssertFalse(("" as KVNR).isValid)
    }

    func testInvalidCharacterInput() {
        XCTAssertFalse(("0123456780" as KVNR).isValid)
        XCTAssertFalse(("0123456781" as KVNR).isValid)
        XCTAssertFalse(("0123456782" as KVNR).isValid)
        XCTAssertFalse(("0123456783" as KVNR).isValid)
        XCTAssertFalse(("0123456784" as KVNR).isValid)
        XCTAssertFalse(("0123456785" as KVNR).isValid)
        XCTAssertFalse(("0123456786" as KVNR).isValid)
        XCTAssertFalse(("0123456787" as KVNR).isValid)
        XCTAssertFalse(("0123456788" as KVNR).isValid)
        XCTAssertFalse(("0123456789" as KVNR).isValid)
        XCTAssertFalse(("â123456780" as KVNR).isValid)
        XCTAssertFalse(("â123456781" as KVNR).isValid)
        XCTAssertFalse(("â123456782" as KVNR).isValid)
        XCTAssertFalse(("â123456783" as KVNR).isValid)
        XCTAssertFalse(("â123456784" as KVNR).isValid)
        XCTAssertFalse(("â123456785" as KVNR).isValid)
        XCTAssertFalse(("â123456786" as KVNR).isValid)
        XCTAssertFalse(("â123456787" as KVNR).isValid)
        XCTAssertFalse(("â123456788" as KVNR).isValid)
        XCTAssertFalse(("â123456789" as KVNR).isValid)
        XCTAssertFalse(("ä123456780" as KVNR).isValid)
        XCTAssertFalse(("ä123456781" as KVNR).isValid)
        XCTAssertFalse(("ä123456782" as KVNR).isValid)
        XCTAssertFalse(("ä123456783" as KVNR).isValid)
        XCTAssertFalse(("ä123456784" as KVNR).isValid)
        XCTAssertFalse(("ä123456785" as KVNR).isValid)
        XCTAssertFalse(("ä123456786" as KVNR).isValid)
        XCTAssertFalse(("ä123456787" as KVNR).isValid)
        XCTAssertFalse(("ä123456788" as KVNR).isValid)
        XCTAssertFalse(("ä123456789" as KVNR).isValid)
        XCTAssertFalse(("Ö123456780" as KVNR).isValid)
        XCTAssertFalse(("§123456780" as KVNR).isValid)
    }
}
