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

#if ENABLE_DEBUG_VIEW

import ASN1Kit
import Foundation
import Security

/// Builds a `SecIdentity` from a PEM-encoded client certificate and EC private key so that the
/// debug push request can authenticate via mutual TLS. Debug builds only.
enum DebugPushClientIdentity {
    enum Error: Swift.Error, LocalizedError {
        case invalidCertificatePEM
        case invalidKeyPEM
        case keyParsingFailed
        case secKeyCreationFailed(String)
        case keychainError(OSStatus)
        case identityNotFound

        var errorDescription: String? {
            switch self {
            case .invalidCertificatePEM: return "Invalid client certificate PEM"
            case .invalidKeyPEM: return "Invalid client key PEM"
            case .keyParsingFailed: return "Could not parse EC private key (SEC1)"
            case let .secKeyCreationFailed(message): return "Could not create private key: \(message)"
            case let .keychainError(status): return "Keychain error (OSStatus \(status))"
            case .identityNotFound: return "Could not derive a client identity from cert and key"
            }
        }
    }

    /// Unique keychain identifiers used for the transient debug identity items.
    private static let keyTag = Data("de.gematik.erp4ios.debugpush.clientkey".utf8)
    private static let certLabel = "de.gematik.erp4ios.debugpush.clientcert"

    /// Creates a `SecIdentity` for the given PEM client certificate and EC private key.
    ///
    /// Any previously stored debug identity items are removed first, then the certificate and key
    /// are added to the keychain so the system can form the matching identity. The temporary items
    /// are intentionally kept in place until the next call so the identity stays valid for the
    /// in-flight request.
    static func makeIdentity(certPEM: String, keyPEM: String) throws -> SecIdentity {
        guard let certDER = pemBody(certPEM, marker: "CERTIFICATE"),
              let certificate = SecCertificateCreateWithData(nil, certDER as CFData) else {
            throw Error.invalidCertificatePEM
        }

        guard let keyDER = pemBody(keyPEM, marker: "EC PRIVATE KEY") else {
            throw Error.invalidKeyPEM
        }
        let privateKey = try makeECPrivateKey(sec1DER: keyDER)

        cleanupKeychainItems()

        try keychainAdd([
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecValueRef as String: privateKey,
        ])
        try keychainAdd([
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: certLabel,
            kSecValueRef as String: certificate,
        ])

        return try identity(matching: certificate)
    }

    /// Removes the transient debug identity items from the keychain.
    static func cleanupKeychainItems() {
        SecItemDelete([
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
        ] as CFDictionary)
        SecItemDelete([
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: certLabel,
        ] as CFDictionary)
    }

    // MARK: - Helpers

    private static func keychainAdd(_ attributes: [String: Any]) throws {
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw Error.keychainError(status)
        }
    }

    /// Finds the identity whose certificate matches the given certificate.
    private static func identity(matching certificate: SecCertificate) throws -> SecIdentity {
        let query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let identities = result as? [SecIdentity] else {
            throw Error.identityNotFound
        }

        let certificateData = SecCertificateCopyData(certificate) as Data
        for identity in identities {
            var identityCert: SecCertificate?
            guard SecIdentityCopyCertificate(identity, &identityCert) == errSecSuccess,
                  let identityCert else { continue }
            if (SecCertificateCopyData(identityCert) as Data) == certificateData {
                return identity
            }
        }
        throw Error.identityNotFound
    }

    /// Creates an EC `SecKey` from a SEC1 ("EC PRIVATE KEY") DER blob by extracting the private
    /// scalar and public point and building the ANSI X9.63 representation.
    private static func makeECPrivateKey(sec1DER: Data) throws -> SecKey {
        let decoded = try ASN1Decoder.decode(asn1: sec1DER)
        guard let items = decoded.data.items, items.count >= 2,
              let scalar = items[1].data.primitive else {
            throw Error.keyParsingFailed
        }

        guard let publicPoint = items
            .first(where: { $0.tag == .taggedTag(1) })?
            .data.items?.first?
            .data.primitive else {
            throw Error.keyParsingFailed
        }
        // BIT STRING content may carry a leading "unused bits" byte (0x00); strip it so the point
        // starts with the 0x04 uncompressed-point marker.
        let point = (publicPoint.first == 0x04) ? publicPoint : publicPoint.dropFirst()

        let x963 = Data(point) + scalar

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        ]
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(x963 as CFData, attributes as CFDictionary, &error) else {
            let message = (error?.takeRetainedValue()).map { String(describing: $0) } ?? "unknown"
            throw Error.secKeyCreationFailed(message)
        }
        return key
    }

    /// Extracts and base64-decodes the body of a PEM block with the given marker.
    private static func pemBody(_ pem: String, marker: String) -> Data? {
        let base64 = pem
            .replacingOccurrences(of: "-----BEGIN \(marker)-----", with: "")
            .replacingOccurrences(of: "-----END \(marker)-----", with: "")
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
        guard !base64.isEmpty else { return nil }
        return Data(base64Encoded: base64)
    }
}

#endif
