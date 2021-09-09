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

import CryptoKit
import Foundation

enum AppSecurityPasswordManagerError: Error {
    case savePasswordFailed
    case retrievePasswordFailed
}

protocol AppSecurityPasswordManager {
    func save(password: String) throws -> Bool

    func matches(password: String) throws -> Bool
}

struct DefaultAppSecurityPasswordManager: AppSecurityPasswordManager {
    private static let passwordIdentifier = "de.gematik.DefaultAppSecurityPasswordManager"

    private let keychainAccess: KeychainAccessHelper

    init(keychainAccess: KeychainAccessHelper) {
        self.keychainAccess = keychainAccess
    }

    func save(password: String) throws -> Bool {
        guard let data = password.data(using: .utf8) else {
            throw AppSecurityPasswordManagerError.savePasswordFailed
        }

        do {
            return try keychainAccess.setGenericPassword(data, for: Self.passwordIdentifier)
        } catch {
            throw AppSecurityPasswordManagerError.savePasswordFailed
        }
    }

    func matches(password: String) throws -> Bool {
        guard let data = password.data(using: .utf8) else {
            throw AppSecurityPasswordManagerError.retrievePasswordFailed
        }

        do {
            let referenceHash: Data = try keychainAccess.genericPassword(for: Self.passwordIdentifier) ?? Data()
            return referenceHash == data
        } catch {
            throw AppSecurityPasswordManagerError.retrievePasswordFailed
        }
    }
}

struct DummyAppSecurityPasswordManager: AppSecurityPasswordManager {
    func save(password _: String) throws -> Bool {
        true
    }

    func matches(password _: String) throws -> Bool {
        true
    }
}
