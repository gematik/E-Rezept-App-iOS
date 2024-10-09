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

import Foundation
import OSLog
import Security

protocol KeychainAccessHelper {
    /// Returns a password from the keychain. The password is identified by the service and the
    /// used account (or use case).
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    /// - Returns: When a password exists for the specified account and service the Data is returned otherwise nil.
    func genericPassword(for account: Data, ofService service: Data) throws -> Data?

    /// Removes a password from the keychain. The password is identified by the service and the used account (or use
    /// case).
    ///
    /// Does nothing if no password matches the given criteria.
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    /// - Returns: true when the password was successfully unset/removed
    func unsetGenericPassword(for account: Data, ofService service: Data) -> Bool

    /// Creates or Updates an existing password in the keychain. The password is identified by the service and the used
    /// account (or use case).
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    /// - Returns: true when the password has successfully been created or updated
    /// - Throws: `KeychainAccessHelperError`
    func setGenericPassword(_ password: Data, for account: Data, service: Data) throws -> Bool
}

// sourcery: CodedError = "020"
/// Errors used by KeychainAccessHelper for password retrieval.
enum KeychainAccessHelperError: Swift.Error, Equatable {
    // sourcery: errorCode = "01"
    case illegalArgument
    // sourcery: errorCode = "02"
    case keyChainError(status: OSStatus, message: String?)
    // sourcery: errorCode = "03"
    case decodingError
}

extension KeychainAccessHelper {
    // swiftlint:disable:next attributes
    @inline(__always) var defaultService: String {
        "de.gematik.ti.erp.app"
    }

    /// Returns a password from the keychain. The password is identified by a general service
    /// name and the used account (or use case).
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: When a password exists for the specified account and service the password
    ///             is returned as String otherwise nil.
    /// - Throws: `KeychainAccessHelperError`
    func genericPassword(for account: String, encoding: String.Encoding = .utf8) throws -> String? {
        try genericPassword(for: account, ofService: defaultService, encoding: encoding)
    }

    /// Removes a password from the keychain. The password is identified by a general service name and the used account
    /// (or use case).
    ///
    /// Does nothing if no password matches the given criteria.
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: true when successfully unset/removed.
    /// - Throws: `KeychainAccessHelperError`
    func unsetGenericPassword(for account: String, encoding: String.Encoding = .utf8) throws -> Bool {
        try unsetGenericPassword(for: account, ofService: defaultService, encoding: encoding)
    }

    /// Creates or Updates an existing password in the keychain.
    /// The password is identified by a general service name and the used account (or use case).
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: true when successfully set
    /// - Throws: `KeychainAccessHelperError`
    func setGenericPassword(_ password: String, for account: String, encoding: String.Encoding = .utf8) throws -> Bool {
        guard let service = defaultService.data(using: encoding),
              let encodedAccount = account.data(using: encoding),
              let encodedPassword = password.data(using: encoding) else {
            throw KeychainAccessHelperError.illegalArgument
        }
        return try setGenericPassword(encodedPassword, for: encodedAccount, service: service)
    }

    func genericPasswordData(for account: String, encoding: String.Encoding = .utf8) throws -> Data? {
        guard let accountData = account.data(using: encoding),
              let service = defaultService.data(using: encoding) else {
            throw KeychainAccessHelperError.illegalArgument
        }
        return try genericPassword(for: accountData, ofService: service)
    }

    func unsetGenericPassword(for account: Data) throws -> Bool {
        guard let service = defaultService.data(using: .utf8) else {
            throw KeychainAccessHelperError.illegalArgument
        }
        return unsetGenericPassword(for: account, ofService: service)
    }

    func setGenericPassword(_ password: Data, for account: String) throws -> Bool {
        guard let accountData = account.data(using: .utf8) else {
            throw KeychainAccessHelperError.illegalArgument
        }
        return try setGenericPassword(password, for: accountData)
    }

    func setGenericPassword(_ password: Data, for account: Data) throws -> Bool {
        guard let service = defaultService.data(using: .utf8) else {
            throw KeychainAccessHelperError.illegalArgument
        }
        return try setGenericPassword(password, for: account, service: service)
    }

    /// Returns a password from the keychain. The password is identified by the service and the
    /// used account (or use case).
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: When a password exists for the specified account and service the password
    ///             is returned as String otherwise nil.
    /// - Throws: `KeychainAccessHelperError`
    func genericPassword(for account: String, ofService service: String, encoding: String.Encoding = .utf8) throws
        -> String? {
        guard let accountData = account.data(using: .utf8),
              let serviceData = service.data(using: .utf8) else {
            throw KeychainAccessHelperError.illegalArgument
        }

        guard let password = try genericPassword(for: accountData, ofService: serviceData) else {
            return nil
        }
        guard let passwordString = String(data: password, encoding: encoding) else {
            throw KeychainAccessHelperError.decodingError
        }
        return passwordString
    }

    /// Removes a password from the keychain. The password is identified by the service and the used account (or use
    /// case).
    ///
    /// Does nothing if no password matches the given criteria.
    ///
    /// - Parameters:
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: true when successfully unset/removed.
    /// - Throws: `KeychainAccessHelperError`
    func unsetGenericPassword(for account: String, ofService service: String,
                              encoding: String.Encoding = .utf8) throws -> Bool {
        guard let accountData = account.data(using: encoding),
              let serviceData = service.data(using: encoding) else {
            throw KeychainAccessHelperError.illegalArgument
        }

        return unsetGenericPassword(for: accountData, ofService: serviceData)
    }

    /// Creates or Updates an existing password in the keychain. The password is identified by the service and the used
    /// account (or use case).
    ///
    /// - Parameters:
    ///   - password: The password to save.
    ///   - account: The account or use case name to use for identifying the password.
    ///   - service: The service to use for identifying the password.
    ///   - encoding: The encoding to use for string en/decoding. Default: .utf8
    /// - Returns: true when successfully set
    /// - Throws: `KeychainAccessHelperError`
    func setGenericPassword(
        _ password: String,
        for account: String,
        service: String,
        encoding: String.Encoding = .utf8
    ) throws -> Bool {
        guard let passwordData = password.data(using: encoding),
              let accountData = account.data(using: encoding),
              let serviceData = service.data(using: encoding) else {
            throw KeychainAccessHelperError.illegalArgument
        }

        return try setGenericPassword(passwordData, for: accountData, service: serviceData)
    }
}

struct SystemKeychainAccessHelper: KeychainAccessHelper {
    func genericPassword(for account: Data, ofService service: Data) throws -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrService as String: service,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data
        else {
            if status == errSecItemNotFound {
                return nil
            }
            let message = SecCopyErrorMessageString(status, nil)
                .map { String($0) } ?? "unknown keychain error: \(status)"
            Logger.eRpApp.debug("\(message)")
            throw KeychainAccessHelperError.keyChainError(status: status, message: message)
        }

        return passwordData
    }

    func unsetGenericPassword(for account: Data, ofService service: Data) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrService as String: service]
        let status = SecItemDelete(query as CFDictionary)

        if let string = SecCopyErrorMessageString(status, nil).map({ String($0) }) {
            Logger.eRpApp.debug("\(string)")
        }

        return status == errSecSuccess
    }

    func setGenericPassword(_ password: Data, for account: Data, service: Data) throws -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrService as String: service,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if let string = SecCopyErrorMessageString(status, nil).map({ String($0) }) {
            Logger.eRpApp.debug("\(string)")
        }

        if status == errSecItemNotFound {
            return try createGenericPassword(password, for: account, service: service)
        } else {
            return try updateGenericPassword(password, for: account, service: service)
        }
    }

    private func updateGenericPassword(_ securedData: Data, for account: Data, service: Data) throws -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrService as String: service]

        let attributes: [String: Any] = [kSecValueData as String: securedData,
                                         kSecAttrAccount as String: account,
                                         kSecAttrService as String: service]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus != errSecSuccess {
            let message = SecCopyErrorMessageString(updateStatus, nil).map { String($0) } ?? "no message"
            Logger.eRpApp.debug("\(message)")
            throw KeychainAccessHelperError.keyChainError(status: updateStatus, message: message)
        }
        return true
    }

    private func createGenericPassword(_ securedData: Data, for account: Data, service: Data) throws -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrService as String: service,
                                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                    kSecValueData as String: securedData]

        let createStatus = SecItemAdd(query as CFDictionary, nil)
        if createStatus != errSecSuccess {
            let message = SecCopyErrorMessageString(createStatus, nil).map { String($0) } ?? "no message"
            Logger.eRpApp.debug("\(message)")
            throw KeychainAccessHelperError.keyChainError(status: createStatus, message: message)
        }
        return true
    }
}
