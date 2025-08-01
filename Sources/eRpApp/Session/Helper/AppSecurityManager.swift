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

import CryptoKit
import Darwin
import Dependencies
import eRpKit
import Foundation
import IDP // for generateSecureRandom
import LocalAuthentication

protocol AppSecurityManager {
    func save(password: String) throws -> Bool

    func matches(password: String) throws -> Bool

    /// Call this after a failed password authentication attempt
    func registerFailedPasswordAttempt() throws

    /// Call this after a successful authentication or to clear the delay
    func resetPasswordDelay() throws

    /// Returns the remaining delay in seconds, or 0 if no delay is active
    func currentPasswordDelay() throws -> TimeInterval

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

    private static let passwordDelayStartTimeIdentifier = "de.gematik.DefaultAppSecurityPasswordManagerDelayStartTime"
    private static let passwordFailedAttemptsCountIdentifier =
        "de.gematik.DefaultAppSecurityPasswordManagerFailedAttemptsCount"

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

    // Fibonacci sequence for delay steps * 5 seconds multiplier.
    // First 5 tries don't come with a delay penalty.
    // [REQ:BSI-eRp-ePA:O.Auth_7#4|1] Delay sequence
    private static let delaySequence: [TimeInterval] = [0, 0, 0, 0, 0, 5, 5, 10, 15, 25, 40]

    private static let zeroIntegerData = withUnsafeBytes(of: Int(0)) { Data($0) }
    private static let zeroTimeIntervalData = withUnsafeBytes(of: 0.0) { Data($0) }

    func registerFailedPasswordAttempt() throws {
        do {
            let failedAttemptsData: Data = try keychainAccess
                .genericPasswordData(for: Self.passwordFailedAttemptsCountIdentifier) ?? Self.zeroIntegerData
            let failedAttempts: Int = failedAttemptsData.withUnsafeBytes { $0.load(as: Int.self) }
            let newFailedAttempts = failedAttempts + 1
            let newFailedAttemptsData = withUnsafeBytes(of: newFailedAttempts) { Data($0) }
            let bool = try keychainAccess.setGenericPassword(
                newFailedAttemptsData,
                for: Self.passwordFailedAttemptsCountIdentifier
            )

            let step = min(newFailedAttempts, Self.delaySequence.count - 1)
            let delay = Self.delaySequence[step]
            if delay > 0 {
                guard let uptime = DefaultAppSecurityManager.uptime() else {
                    throw AppSecurityManagerError.passwordDelayInfoIOFailed
                }
                let uptimeData = withUnsafeBytes(of: uptime) { Data($0) }

                _ = try keychainAccess.setGenericPassword(uptimeData, for: Self.passwordDelayStartTimeIdentifier)
            } else {
                // Reset delay if no delay is needed
                _ = try keychainAccess.setGenericPassword(
                    Self.zeroTimeIntervalData,
                    for: Self.passwordDelayStartTimeIdentifier
                )
            }
        } catch {
            throw AppSecurityManagerError.passwordDelayInfoIOFailed
        }
    }

    func resetPasswordDelay() throws {
        do {
            _ = try keychainAccess.setGenericPassword(
                Self.zeroTimeIntervalData,
                for: Self.passwordDelayStartTimeIdentifier
            )
            _ = try keychainAccess.setGenericPassword(
                Self.zeroIntegerData,
                for: Self.passwordFailedAttemptsCountIdentifier
            )
        } catch {
            throw AppSecurityManagerError.passwordDelayInfoIOFailed
        }
    }

    // [REQ:BSI-eRp-ePA:O.Auth_7#5|35] A delay is implemented according to its current delay status.
    // The calculationbasis is the devices uptime, because there is no meddling possible for a non-root user.
    func currentPasswordDelay() throws -> TimeInterval {
        do {
            let delayStartUptimeData: Data = try keychainAccess
                .genericPasswordData(for: Self.passwordDelayStartTimeIdentifier) ?? Self.zeroTimeIntervalData
            let delayStartUptime: TimeInterval = delayStartUptimeData.withUnsafeBytes { $0.load(as: TimeInterval.self) }
            let failedAttemptsData: Data = try keychainAccess
                .genericPasswordData(for: Self.passwordFailedAttemptsCountIdentifier) ?? Self.zeroIntegerData
            let failedAttempts: Int = failedAttemptsData.withUnsafeBytes { $0.load(as: Int.self) }
            let delayDuration: TimeInterval = Self.delaySequence[min(failedAttempts, Self.delaySequence.count - 1)]

            let currentSystemUptime = DefaultAppSecurityManager.uptime() ?? 0

            // If device rebooted, reset delay
            if currentSystemUptime < delayStartUptime {
                _ = try keychainAccess.setGenericPassword(
                    Self.zeroTimeIntervalData,
                    for: Self.passwordDelayStartTimeIdentifier
                )
                return 0
            }

            // Else calculate remaining delay
            let remaining = (delayStartUptime + delayDuration) - currentSystemUptime
            if remaining <= 0 {
                _ = try keychainAccess.setGenericPassword(
                    Self.zeroTimeIntervalData,
                    for: Self.passwordDelayStartTimeIdentifier
                )
                return 0
            }
            return remaining

        } catch {
            throw AppSecurityManagerError.passwordDelayInfoIOFailed
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

extension DefaultAppSecurityManager {
    static func bootTime() -> Date? {
        // swiftlint:disable:next identifier_name
        var tv = timeval()
        var tvSize = MemoryLayout<timeval>.size
        let err = sysctlbyname("kern.boottime", &tv, &tvSize, nil, 0)
        guard err == 0, tvSize == MemoryLayout<timeval>.size else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0)
    }

    static func uptime() -> TimeInterval? {
        guard let bootTime = bootTime() else { return nil }
        return Date().timeIntervalSince(bootTime)
    }
}

// sourcery: CodedError = "044"
enum AppSecurityManagerError: Error, Equatable {
    // sourcery: errorCode = "01"
    case savePasswordFailed
    // sourcery: errorCode = "02"
    case retrievePasswordFailed
    // sourcery: errorCode = "03"
    case localAuthenticationContext(NSError?)
    // sourcery: errorCode = "04"
    case migrationFailed
    // sourcery: errorCode = "05"
    case passwordDelayInfoIOFailed

    var errorDescription: String? {
        switch self {
        case let .localAuthenticationContext(error):
            guard let error = error else { return nil }

            if error.code == LAError.Code.biometryNotEnrolled.rawValue {
                return L10n.authTxtBiometricsFailedNotEnrolled.text
            }

            return error.localizedDescription
        case .savePasswordFailed, .retrievePasswordFailed, .migrationFailed, .passwordDelayInfoIOFailed:
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

    func registerFailedPasswordAttempt() throws {
        // no-op
    }

    func resetPasswordDelay() throws {
        // no-op
    }

    func currentPasswordDelay() throws -> TimeInterval {
        2.0
    }
}
