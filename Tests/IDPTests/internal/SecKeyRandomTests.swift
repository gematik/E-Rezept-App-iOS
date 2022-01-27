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

@testable import IDP
import Nimble
import XCTest

class SecKeyRandomTests: XCTestCase {
    func testRandom12() throws {
        let randomBytes = try generateSecureRandom(length: 12)
        expect(randomBytes.count) == 12
        expect(randomBytes) != Data(repeating: 0x0, count: 12)
    }
}
