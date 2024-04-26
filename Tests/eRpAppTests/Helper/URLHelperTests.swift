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

@testable import eRpFeatures
import Nimble
import SwiftUI
import XCTest

final class URLHelperTests: XCTestCase {
    func testValidPhoneNumberURL() {
        let phoneNumber1 = " 123-3 21 "
        expect(URL(phoneNumber: phoneNumber1)).to(equal(URL(string: "tel:123321")))
    }

    func testInvalidPhoneNumberURL() {
        let phoneNumber1 = "keine Nummer"
        expect(URL(phoneNumber: phoneNumber1)).to(beNil())
    }
}
