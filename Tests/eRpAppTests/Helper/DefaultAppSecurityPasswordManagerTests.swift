//
//  Copyright (c) 2023 gematik GmbH
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
import SnapshotTesting
import SwiftUI
import XCTest

final class DefaultAppSecurityPasswordManagerTests: XCTestCase {
    func testSavePasswordCallsKeychainHelper() {
        let keychainAccess = KeychainAccessHelperMock()
        let sut = DefaultAppSecurityManager(keychainAccess: keychainAccess)

        expect(try sut.save(password: "abc")).to(beTrue())

        expect(keychainAccess.setGenericPasswordCalled).to(beTrue())
    }
}
