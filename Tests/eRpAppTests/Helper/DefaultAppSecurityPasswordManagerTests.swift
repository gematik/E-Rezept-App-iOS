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
import SnapshotTesting
import SwiftUI
import XCTest

final class DefaultAppSecurityPasswordManagerTests: XCTestCase {
    func testSavePasswordCallsKeychainHelper() {
        let keychainAccess = MockKeychainAccessHelper()
        keychainAccess.setGenericPasswordForServiceReturnValue = true
        let sut = DefaultAppSecurityManager(keychainAccess: keychainAccess)

        expect(try sut.save(password: "abc")).to(beTrue())

        expect(keychainAccess.setGenericPasswordForServiceCalled).to(beTrue())
    }

    func testMatchingPasswordUsesSalt() throws {
        let storedHash = "stored_hash".data(using: .utf8)!
        let storedSalt = "stored_salt".data(using: .utf8)!
        let passwordData = "password".data(using: .utf8)!

        var dataToHash: Data?

        let keychainAccess = MockKeychainAccessHelper()

        let sut = DefaultAppSecurityManager(
            keychainAccess: keychainAccess,
            hash: { data in
                dataToHash = data
                return storedHash
            }
        )

        expect(keychainAccess.setGenericPasswordForServiceCalled).to(beFalse())
        expect(keychainAccess.genericPasswordForOfServiceCalled).to(beFalse())

        keychainAccess.genericPasswordForOfServiceClosure = { service, _ in
            switch String(data: service, encoding: .utf8) {
            case "de.gematik.DefaultAppSecurityPasswordManagerSalt":
                return storedSalt
            case "de.gematik.DefaultAppSecurityPasswordManagerHash":
                return storedHash
            case "de.gematik.DefaultAppSecurityPasswordManager":
                return "".data(using: .utf8)
            default:
                return nil
            }
        }

        expect(try sut.matches(password: "password")).to(beTrue())

        let data = try XCTUnwrap(dataToHash)
        expect(data).to(equal(passwordData + storedSalt))
    }

    func testMigrationOfPasswordToSalt() {
        let keychainAccess = MockKeychainAccessHelper()
        let sut = DefaultAppSecurityManager(keychainAccess: keychainAccess)

        expect(keychainAccess.setGenericPasswordForServiceCalled).to(beFalse())
        expect(keychainAccess.genericPasswordForOfServiceCalled).to(beFalse())

        keychainAccess.genericPasswordForOfServiceClosure = { service, _ in
            switch String(data: service, encoding: .utf8) {
            case "de.gematik.DefaultAppSecurityPasswordManagerSalt":
                return nil
            case "de.gematik.DefaultAppSecurityPasswordManagerHash":
                return "hashed".data(using: .utf8)
            case "de.gematik.DefaultAppSecurityPasswordManager":
                return "1234".data(using: .utf8)
            default:
                return nil
            }
        }

        keychainAccess.setGenericPasswordForServiceClosure = { password, service, data in
            print("""
            setGenericPasswordForServiceClosure:
            \(String(describing: String(data: password, encoding: .utf8)))
            \(String(describing: String(data: service, encoding: .utf8)))
            \(String(describing: String(data: data, encoding: .utf8)))
            """)
            return true
        }

        expect(try sut.migrate()).toNot(throwError())

        expect(keychainAccess.setGenericPasswordForServiceCalled).to(beTrue())
        expect(keychainAccess.setGenericPasswordForServiceCallsCount).to(equal(3)) // set salt, set password
        expect(keychainAccess.genericPasswordForOfServiceCalled).to(beTrue())
    }
}
