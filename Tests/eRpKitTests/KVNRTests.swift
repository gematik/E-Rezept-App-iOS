//
//  Copyright (c) 2021 gematik GmbH
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
        let kvnr: KVNR = "Q123456784"

        XCTAssertTrue(kvnr.isValid)

        let kvnr2: KVNR = "A123456780"

        XCTAssertTrue(kvnr2.isValid)
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
}
