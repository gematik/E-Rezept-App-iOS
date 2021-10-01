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
import LocalAuthentication

protocol AppSecurityManager {
    func save(password: String) throws -> Bool

    func matches(password: String) throws -> Bool

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) { get }
}

struct DefaultAppSecurityManager: AppSecurityManager {
    private static let passwordIdentifier = "de.gematik.DefaultAppSecurityPasswordManager"

    private let keychainAccess: KeychainAccessHelper

    init(keychainAccess: KeychainAccessHelper) {
        self.keychainAccess = keychainAccess
    }

    func save(password: String) throws -> Bool {
        guard let data = password.data(using: .utf8) else {
            throw AppSecurityManagerError.savePasswordFailed
        }

        do {
            return try keychainAccess.setGenericPassword(data, for: Self.passwordIdentifier)
        } catch {
            throw AppSecurityManagerError.savePasswordFailed
        }
    }

    func matches(password: String) throws -> Bool {
        guard let data = password.data(using: .utf8) else {
            throw AppSecurityManagerError.retrievePasswordFailed
        }

        do {
            let referenceHash: Data = try keychainAccess.genericPassword(for: Self.passwordIdentifier) ?? Data()
            return referenceHash == data
        } catch {
            throw AppSecurityManagerError.retrievePasswordFailed
        }
    }

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        var error: NSError?
        let authenticationContext = LAContext()

        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                      error: &error) == true else {
            return ([.password, .unsecured],
                    AppSecurityManagerError.localAuthenticationContext(error))
        }

        switch authenticationContext.biometryType {
        case .faceID:
            return ([.biometry(.faceID), .password, .unsecured], nil)
        case .touchID:
            return ([.biometry(.touchID), .password, .unsecured], nil)
        case .none:
            return ([.password, .unsecured], nil)
        @unknown default:
            return ([.password, .unsecured], nil)
        }
    }
}

enum AppSecurityOption: Identifiable, Equatable {
    case unsecured
    case biometry(BiometryType)
    case password

    var id: Int { // swiftlint:disable:this identifier_name
        switch self {
        case .unsecured:
            return -1
        case let .biometry(biometryType):
            switch biometryType {
            case .faceID:
                return 1
            case .touchID:
                return 2
            }
        case .password:
            return 3
        }
    }

    init?(fromId id: Int) { // swiftlint:disable:this identifier_name
        switch id {
        case -1:
            self = .unsecured
        case 1:
            self = .biometry(.faceID)
        case 2:
            self = .biometry(.touchID)
        case 3:
            self = .password
        default:
            return nil
        }
    }
}

enum AppSecurityManagerError: Error, Equatable {
    case savePasswordFailed
    case retrievePasswordFailed
    case localAuthenticationContext(NSError?)

    var errorDescription: String? {
        switch self {
        case let .localAuthenticationContext(error):
            guard let error = error else { return nil }

            if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                return NSLocalizedString("auth_txt_biometrics_failed_not_enrolled",
                                         comment: "")
            }

            return error.localizedDescription
        case .savePasswordFailed, .retrievePasswordFailed:
            return nil
        }
    }
}

struct DummyAppSecurityManager: AppSecurityManager {
    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        return (options: [AppSecurityOption.password], error: nil)
    }

    func save(password _: String) throws -> Bool {
        true
    }

    func matches(password _: String) throws -> Bool {
        true
    }
}
