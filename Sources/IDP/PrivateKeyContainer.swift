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

import ASN1Kit
import Combine
import Foundation
import OpenSSL
import Security

/// Represents a (SecureEnclave) private key, namely `PrK_SE_AUT`, secured by iOS Biometrics.
public struct PrivateKeyContainer {
    enum Error: Swift.Error {
        case keyNotFound(String)
        case unknownError(String)
        case retrievingPublicKeyFailed
        case creationFromBiometrie(Swift.Error?)
        case creationWithoutBiometrie(Swift.Error?)
        case convertingKey(Swift.Error?)
        case signing(Swift.Error?)
    }

    let privateKey: SecKey
    let publicKey: SecKey

    let tag: String

    /// Initializes a `PrivateKeyContainer` for a given tag. Throws `PrivateKeyContainer.Error` in case of a failure.
    /// - Parameter tag: The `tag` or identifier of the key.
    /// - Throws: `PrivateKeyContainer.Error` in case of a failure.
    public init(with tag: String) throws {
        let privateKey = try Self.findExistingKey(for: tag)

        try self.init(withTag: tag, privateKey: privateKey)
    }

    private init(withTag tag: String,
                 privateKey: SecKey) throws {
        self.tag = tag
        self.privateKey = privateKey
        publicKey = try Self.publicKeyForPrivateKey(privateKey)
    }

    private static func findExistingKey(for tag: String) throws -> SecKey {
        // Keychain Query
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                    kSecAttrKeySizeInBits as String: 256,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnRef as String: true]
        var item: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil).map { String($0) } ?? "Not Found"

            if status == errSecItemNotFound {
                throw Error.keyNotFound(message)
            }

            throw Error.unknownError(message)
        }

        return (item as! SecKey) // swiftlint:disable:this force_cast
    }

    /// Deletes an existing secure enclave key.
    /// - Parameter tag: The `tag` or identifier of the key.
    /// - Throws: `PrivateKeyContainer.Error` in case of a failure or a missing key.
    /// - Returns: `true` in case of a success, `throws` otherwise.
    public static func deleteExistingKey(for tag: String) throws -> Bool {
        // Keychain Query
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag]

        let status: OSStatus = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil).map { String($0) } ?? "Not Found"

            if status == errSecItemNotFound {
                throw Error.keyNotFound(message)
            }

            throw Error.unknownError(message)
        }

        return true
    }

    private static func publicKeyForPrivateKey(_ privateKey: SecKey) throws -> SecKey {
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw Error.retrievingPublicKeyFailed
        }
        return publicKey
    }

    /// Creates a `PrivateKeyContainer` with a given tag. Throws `PrivateKeyContainer.Error` in case of a failure.
    /// - Parameter tag: The `tag` or identifier of the key.
    /// - Throws: `PrivateKeyContainer.Error` in case of a failure or a missing key.
    /// - Returns: An instance of `PrivateKeyContainer` if successfull.
    public static func createFromSecureEnclave(with tag: String) throws -> Self {
        var error: Unmanaged<CFError>?

        guard let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            // [REQ:gemSpec_IDP_Frontend:A_21586] prevents migration to other devices
                                            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                            // [REQ:gemSpec_IDP_Frontend:A_21582] method selection
                                            // [REQ:gemSpec_IDP_Frontend:A_21587] via `.privateKeyUsage`
                                            [.privateKeyUsage,
                                             // [REQ:gemSpec_IDP_Frontend:A_21586] invalidates biometry after changes
                                             .biometryCurrentSet], &error) else {
            guard let error = error else {
                throw Error.unknownError("Access Control creation failed")
            }
            throw Error.creationFromBiometrie(error.takeRetainedValue() as Swift.Error)
        }

        let attributes: [String: Any] = [
            // [REQ:gemSpec_IDP_Frontend:A_21581,A_21589] Algorithm selection
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            // [REQ:gemSpec_IDP_Frontend:A_21589] Key length
            kSecAttrKeySizeInBits as String: 256,
            // [REQ:gemSpec_IDP_Frontend:A_21578,A_21579,A_21580,A_21583] Enforced via access attribute
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access,
            ],
        ]

        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw Error.creationFromBiometrie(error?.takeRetainedValue())
        }
        return try Self(withTag: tag, privateKey: privateKey)
    }

    #if targetEnvironment(simulator)

    /// key creation without secure enclave for integration tests. Only available for simulator builds to enable
    /// integration tests.
    public static func createFromKeyChain(with tag: String) throws -> Self {
        var error: Unmanaged<CFError>?

        guard let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlocked,
                                            [.privateKeyUsage],
                                            &error) else {
            guard let error = error else {
                throw Error.unknownError("Access Control creation failed")
            }
            throw Error.creationWithoutBiometrie(error.takeRetainedValue() as Swift.Error)
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access,
            ],
        ]

        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw Error.creationWithoutBiometrie(error?.takeRetainedValue())
        }
        return try Self(withTag: tag, privateKey: privateKey)
    }
    #endif

    func publicKeyData() throws -> Data {
        var error: Unmanaged<CFError>?

        let keyData = SecKeyCopyExternalRepresentation(publicKey, &error)

        guard let unwrappedKeyData = keyData else {
            throw Error.convertingKey(error?.takeRetainedValue())
        }

        return unwrappedKeyData as Data
    }

    func asn1PublicKey() throws -> Data {
        let asn1 = ASN1Data.constructed(
            [
                create(tag: .universal(.sequence), data: ASN1Data.constructed(
                    [
                        try ObjectIdentifier.from(string: "1.2.840.10045.2.1").asn1encode(),
                        try ObjectIdentifier.from(string: "1.2.840.10045.3.1.7").asn1encode(),
                    ]
                )),

                try publicKeyData().asn1bitStringEncode(),
            ]
        )
        return try create(tag: .universal(.sequence), data: asn1).serialize()
    }

    /// Sign the given `Data` with the private key.
    /// - Parameter data: Data to sign with the private key.
    /// - Throws: `PrivateKeyContainer.Error` in case of a failure or a missing key.
    /// - Returns: Data in concat format containing the Signature `r` | `s`.
    public func sign(data: Data) throws -> Data {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256

        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            throw Error.unknownError("Algorithm not supported")
        }

        var error: Unmanaged<CFError>?

        // [REQ:gemSpec_IDP_Frontend:A_21584] private key usage triggers biometric unlock
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    algorithm,
                                                    data as CFData,
                                                    &error) as Data? else {
            throw Error.signing(error?.takeRetainedValue())
        }

        return try signature.derToConcat()
    }
}

enum ConversionError: Swift.Error {
    case generic(String?)
}

extension Data {
    // From jose4j EcdsaUsingShaAlgorithm.java
    func derToConcat() throws -> Data {
        let wholeASN1 = try ASN1Decoder.decode(asn1: self)
        let sequence = try Array(from: wholeASN1)

        guard sequence.count == 2 else {
            throw ConversionError.generic("Error converting EC signature. Expected 2 elements, found \(sequence.count)")
        }

        let signatureR = try Data(from: sequence[0]).dropLeadingZeroByte.padWithLeadingZeroes(totalLength: 32)
        let signatureS = try Data(from: sequence[1]).dropLeadingZeroByte.padWithLeadingZeroes(totalLength: 32)

        return signatureR + signatureS
    }
}
