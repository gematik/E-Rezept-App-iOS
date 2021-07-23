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

@testable import eRpApp
import Nimble
import TestUtils
import XCTest

final class SystemKeychainAccessHelperTests: XCTestCase {
    let service = "SystemKeychainAccessHelperTestsService"
    let account = "SystemKeychainAccessHelperTestsAccount"

    override func setUp() {
        super.setUp()

        let sut = SystemKeychainAccessHelper()
        _ = try! sut.unsetGenericPassword(for: account, ofService: service)
    }

    func testAccessNonAvailableKeychainObject() {
        let sut = SystemKeychainAccessHelper()

        expect(
            try sut.genericPassword(for: self.account, ofService: self.service)
        ).to(beNil())
    }

    func testCreationAndDeletionKeychainObject() throws {
        let sut = SystemKeychainAccessHelper()

        expect(try sut.setGenericPassword("ABC", for: self.account, service: self.service)) == true

        let password = try sut.genericPassword(for: account, ofService: service)

        expect(password) == "ABC"

        expect(try sut.unsetGenericPassword(for: self.account, ofService: self.service)) == true

        expect(
            try sut.genericPassword(for: self.account, ofService: self.service)
        ).to(beNil())
    }

    func testUpdateOfKeychainObject() throws {
        let sut = SystemKeychainAccessHelper()

        expect(try sut.setGenericPassword("ABC", for: self.account, service: self.service)) == true
        var password = try sut.genericPassword(for: account, ofService: service)

        expect(password).to(equal("ABC"))

        expect(try sut.setGenericPassword("DEF", for: self.account, service: self.service)) == true
        password = try sut.genericPassword(for: account, ofService: service)

        expect(password).to(equal("DEF"))

        expect(try sut.unsetGenericPassword(for: self.account, ofService: self.service)) == true
    }
}
