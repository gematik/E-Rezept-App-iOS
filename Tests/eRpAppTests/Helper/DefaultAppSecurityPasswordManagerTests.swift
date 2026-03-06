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

@testable import eRpFeatures
import Nimble
import SnapshotTesting
import SwiftUI
import XCTest

final class DefaultAppSecurityPasswordManagerTests: XCTestCase {
    func testSavePasswordCallsKeychainHelper() {
        let keychainAccess = KeychainAccessHelperMock()
        keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolReturnValue = true
        let sut = DefaultAppSecurityManager(keychainAccess: keychainAccess)

        expect(try sut.save(password: "abc")).to(beTrue())

        expect(keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolCalled).to(beTrue())
    }

    func testMatchingPasswordUsesSalt() throws {
        let storedHash = Data("stored_hash".utf8)
        let storedSalt = Data("stored_salt".utf8)
        let passwordData = Data("password".utf8)

        var dataToHash: Data?

        let keychainAccess = KeychainAccessHelperMock()

        let sut = DefaultAppSecurityManager(
            keychainAccess: keychainAccess,
            hash: { data in
                dataToHash = data
                return storedHash
            }
        )

        expect(keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolCalled).to(beFalse())
        expect(keychainAccess.genericPasswordForAccountDataOfServiceServiceDataDataCalled).to(beFalse())

        keychainAccess.genericPasswordForAccountDataOfServiceServiceDataDataClosure = { service, _ in
            switch String(data: service, encoding: .utf8) {
            case "de.gematik.DefaultAppSecurityPasswordManagerSalt":
                return storedSalt
            case "de.gematik.DefaultAppSecurityPasswordManagerHash":
                return storedHash
            case "de.gematik.DefaultAppSecurityPasswordManager":
                return Data("".utf8)
            default:
                return nil
            }
        }

        expect(try sut.matches(password: "password")).to(beTrue())

        let data = try XCTUnwrap(dataToHash)
        expect(data).to(equal(passwordData + storedSalt))
    }

    func testMigrationOfPasswordToSalt() {
        let keychainAccess = KeychainAccessHelperMock()
        let sut = DefaultAppSecurityManager(keychainAccess: keychainAccess)

        expect(keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolCalled).to(beFalse())
        expect(keychainAccess.genericPasswordForAccountDataOfServiceServiceDataDataCalled).to(beFalse())

        keychainAccess.genericPasswordForAccountDataOfServiceServiceDataDataClosure = { service, _ in
            switch String(data: service, encoding: .utf8) {
            case "de.gematik.DefaultAppSecurityPasswordManagerSalt":
                return nil
            case "de.gematik.DefaultAppSecurityPasswordManagerHash":
                return Data("hashed".utf8)
            case "de.gematik.DefaultAppSecurityPasswordManager":
                return Data("1234".utf8)
            default:
                return nil
            }
        }

        keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolClosure = { password, service, data in
            print("""
            setGenericPasswordForServiceClosure:
            \(String(describing: String(data: password, encoding: .utf8)))
            \(String(describing: String(data: service, encoding: .utf8)))
            \(String(describing: String(data: data, encoding: .utf8)))
            """)
            return true
        }

        expect(try sut.migrate()).toNot(throwError())

        expect(keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolCalled).to(beTrue())
        expect(keychainAccess.setGenericPasswordPasswordDataForAccountDataServiceDataBoolCallsCount)
            .to(equal(3)) // set salt, set password
        expect(keychainAccess.genericPasswordForAccountDataOfServiceServiceDataDataCalled).to(beTrue())
    }
}
