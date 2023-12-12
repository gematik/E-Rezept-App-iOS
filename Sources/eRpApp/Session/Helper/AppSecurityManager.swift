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

import CryptoKit
import Dependencies
import eRpKit
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

    // [REQ:BSI-eRp-ePA:O.Auth_6#3] Actual password check
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
            return ([.password],
                    AppSecurityManagerError.localAuthenticationContext(error))
        }

        switch authenticationContext.biometryType {
        case .faceID:
            return ([.biometry(.faceID), .password, .biometryAndPassword(.faceID)], nil)
        case .touchID:
            return ([.biometry(.touchID), .password, .biometryAndPassword(.touchID)], nil)
        // apple vision pro only
        case .opticID:
            return ([.password], nil)
        case .none:
            return ([.password], nil)
        @unknown default:
            return ([.password], nil)
        }
    }
}

// sourcery: CodedError = "006"
enum AppSecurityManagerError: Error, Equatable {
    // sourcery: errorCode = "01"
    case savePasswordFailed
    // sourcery: errorCode = "02"
    case retrievePasswordFailed
    // sourcery: errorCode = "03"
    case localAuthenticationContext(NSError?)

    var errorDescription: String? {
        switch self {
        case let .localAuthenticationContext(error):
            guard let error = error else { return nil }

            if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                return L10n.authTxtBiometricsFailedNotEnrolled.text
            }

            return error.localizedDescription
        case .savePasswordFailed, .retrievePasswordFailed:
            return nil
        }
    }
}

// MARK: TCA Dependency

struct AppSecurityManagerDependency: DependencyKey {
    static let liveValue: AppSecurityManager = DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper())

    static let previewValue: AppSecurityManager = DemoAppSecurityPasswordManager()

    static let testValue: AppSecurityManager = UnimplementedAppSecurityManager()
}

extension DependencyValues {
    var appSecurityManager: AppSecurityManager {
        get { self[AppSecurityManagerDependency.self] }
        set { self[AppSecurityManagerDependency.self] = newValue }
    }
}

// MARK: Dummies

struct DummyAppSecurityManager: AppSecurityManager {
    private let underlyingOptions: [AppSecurityOption]
    private let underlyingError: AppSecurityManagerError?

    init(
        options: [AppSecurityOption] = [AppSecurityOption.biometry(.faceID), AppSecurityOption.password],
        error: AppSecurityManagerError? = nil
    ) {
        underlyingOptions = options
        underlyingError = error
    }

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) {
        return (options: underlyingOptions, error: underlyingError)
    }

    func save(password _: String) throws -> Bool {
        true
    }

    func matches(password _: String) throws -> Bool {
        true
    }
}
