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

import CryptoKit
import Dependencies
import eRpKit
import Foundation
import IDP // for generateSecureRandom
import LocalAuthentication

protocol AppSecurityManager {
    func save(password: String) throws -> Bool

    func matches(password: String) throws -> Bool

    func migrate() throws

    var availableSecurityOptions: (options: [AppSecurityOption], error: AppSecurityManagerError?) { get }
}

struct DefaultAppSecurityManager: AppSecurityManager {
    typealias Random<T> = (Int) throws -> T
    typealias Hash = (Data) -> Data

    // deprecated, do not use
    private static let passwordIdentifier = "de.gematik.DefaultAppSecurityPasswordManager"
    private static let passwordSaltIdentifier = "de.gematik.DefaultAppSecurityPasswordManagerSalt"
    private static let passwordHashIdentifier = "de.gematik.DefaultAppSecurityPasswordManagerHash"

    private let keychainAccess: KeychainAccessHelper
    private let randomGenerator: Random<Data>
    private let hash: Hash

    init(keychainAccess: KeychainAccessHelper,
         randomGenerator: @escaping Random<Data> = { try generateSecureRandom(length: $0) },
         hash: @escaping Hash = { Data(SHA512.hash(data: $0)) }) {
        self.keychainAccess = keychainAccess
        self.randomGenerator = randomGenerator
        self.hash = hash
    }

    func save(password: String) throws -> Bool {
        // [REQ:BSI-eRp-ePA:O.Pass_5#2|4] The salt is regenerated, whenever a new password is stored.
        guard let data = password.data(using: .utf8),
              let salt = try? randomGenerator(32) else {
            throw AppSecurityManagerError.savePasswordFailed
        }

        // [REQ:BSI-eRp-ePA:O.Pass_5#3|8] Password is stored alongside hash within keychain.
        do {
            let hashedPassword = hash(data + salt)
            guard try keychainAccess.setGenericPassword(salt, for: Self.passwordSaltIdentifier),
                  try keychainAccess.setGenericPassword(hashedPassword, for: Self.passwordHashIdentifier) else {
                throw AppSecurityManagerError.savePasswordFailed
            }
            return true
        } catch {
            throw AppSecurityManagerError.savePasswordFailed
        }
    }

    // [REQ:BSI-eRp-ePA:O.Auth_7#3,REQ:BSI-eRp-ePA:O.Pass_5#4|13] Actual password check
    func matches(password: String) throws -> Bool {
        guard let data = password.data(using: .utf8),
              let salt = try? keychainAccess.genericPasswordData(for: Self.passwordSaltIdentifier) else {
            throw AppSecurityManagerError.retrievePasswordFailed
        }

        do {
            let hashedPassword = hash(data + salt)
            let referenceHash: Data = try keychainAccess.genericPasswordData(for: Self.passwordHashIdentifier) ?? Data()
            return referenceHash == hashedPassword
        } catch {
            throw AppSecurityManagerError.retrievePasswordFailed
        }
    }

    func migrate() throws {
        // Skip migration if salt already exists or no old password exists (migration done or app is freshly installed)
        guard (try? keychainAccess.genericPasswordData(for: Self.passwordSaltIdentifier)) == nil,
              let password = try keychainAccess.genericPassword(for: Self.passwordIdentifier) else {
            return
        }
        // retrieve current password:
        do {
            _ = try save(password: password)
            _ = try keychainAccess.setGenericPassword(Data(), for: Self.passwordIdentifier)
        } catch {
            throw AppSecurityManagerError.migrationFailed
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
    // sourcery: errorCode = "04"
    case migrationFailed

    var errorDescription: String? {
        switch self {
        case let .localAuthenticationContext(error):
            guard let error = error else { return nil }

            if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                return L10n.authTxtBiometricsFailedNotEnrolled.text
            }

            return error.localizedDescription
        case .savePasswordFailed, .retrievePasswordFailed, .migrationFailed:
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
    func migrate() {}

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
