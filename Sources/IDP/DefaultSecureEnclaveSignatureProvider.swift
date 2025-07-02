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

import Combine
import Foundation
import OpenSSL

public
class DefaultSecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
    public init(storage: SecureEGKCertificateStorage,
                // [REQ:gemSpec_IDP_Frontend:A_21588] key identfier generator, number of bytes 32
                keyIdentifierGenerator: @escaping (() throws -> Data) = { try generateSecureRandom(length: 32) },
                privateKeyContainerProvider: @escaping ((String) throws -> PrivateKeyContainer) = { identifier in
                    try PrivateKeyContainer.createFromSecureEnclave(with: identifier)
                }) {
        certificateStorage = storage
        self.keyIdentifierGenerator = keyIdentifierGenerator
        self.privateKeyContainerProvider = privateKeyContainerProvider
    }

    let keyIdentifierGenerator: () throws -> Data
    let privateKeyContainerProvider: (String) throws -> PrivateKeyContainer
    private let certificateStorage: SecureEGKCertificateStorage

    public var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        certificateStorage.keyIdentifier.first()
            .zip(certificateStorage.certificate.first())
            .map { $0.0 != nil && $0.1 != nil }
            .eraseToAnyPublisher()
    }

    public func createPairingSession() throws -> PairingSession {
        do {
            // [REQ:gemSpec_IDP_Frontend:A_21588] Key generation
            let keyIdentifier = try keyIdentifierGenerator()

            return PairingSession(
                tempKeyIdentifier: keyIdentifier,
                deviceInformation: deviceInformation()
            )
        } catch {
            throw SecureEnclaveSignatureProviderError
                .internal("Generating a key identifier failed.", error)
        }
    }

    public func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: X509)
        -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595,A_21595] Store pairing data
        certificateStorage.set(certificate: certificate)
        certificateStorage.set(keyIdentifier: pairingSession.tempKeyIdentifier)
        guard let base64KeyIdentifier = pairingSession.tempKeyIdentifier.encodeBase64UrlSafe(),
              let identifier = String(data: base64KeyIdentifier, encoding: .utf8) else {
            return Fail(error: SecureEnclaveSignatureProviderError.fetchingPrivateKey(nil))
                .eraseToAnyPublisher()
        }

        do {
            let privateKeyContainer = try privateKeyContainerProvider(identifier)

            return pairingSession.sign(with: signer, certificate: certificate, privateKeyContainer: privateKeyContainer)
        } catch {
            return Fail(error: SecureEnclaveSignatureProviderError.fetchingPrivateKey(error)).eraseToAnyPublisher()
        }
    }

    // [REQ:gemSpec_IDP_Frontend:A_21598] Delete all stored keys/identifiers/certificate in case of an unsuccessful
    // registration
    public func abort(pairingSession: PairingSession) throws {
        certificateStorage.set(keyIdentifier: nil)
        // [REQ:gemSpec_IDP_Frontend:A_21595] case deletion
        certificateStorage.set(certificate: nil)
        guard let base64KeyIdentifier = pairingSession.tempKeyIdentifier.encodeBase64UrlSafe(),
              let keyIdentifier = String(data: base64KeyIdentifier, encoding: .utf8) else {
            return
        }
        _ = try PrivateKeyContainer.deleteExistingKey(for: keyIdentifier)
    }

    public func authenticationData(for challenge: IDPChallengeSession)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        certificateStorage.certificate
            .setFailureType(to: SecureEnclaveSignatureProviderError.self)
            .flatMap { certificate -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> in
                guard let certificate = certificate else {
                    return Fail(error: SecureEnclaveSignatureProviderError.packagingAuthCertificate)
                        .eraseToAnyPublisher()
                }
                return self.authenticationData(for: challenge, with: certificate)
            }
            .eraseToAnyPublisher()
    }
}

extension DefaultSecureEnclaveSignatureProvider {
    private func authenticationData(for challenge: IDPChallengeSession, with certificate: X509)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        certificateStorage.keyIdentifier
            .setFailureType(to: SecureEnclaveSignatureProviderError.self)
            .flatMap { identifier -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> in
                // [REQ:gemSpec_IDP_Frontend:A_21588] usage as base64 encoded string
                guard let someIdentifier = identifier,
                      let base64SomeIdentifier = someIdentifier.encodeBase64UrlSafe(),
                      let identifier = String(data: base64SomeIdentifier, encoding: .utf8) else {
                    return Fail(error: SecureEnclaveSignatureProviderError.internal("keyMissing", nil))
                        .eraseToAnyPublisher()
                }

                guard let privateKeyContainer = try? PrivateKeyContainer(with: identifier) else {
                    return Fail(error: SecureEnclaveSignatureProviderError.fetchingPrivateKey(nil))
                        .eraseToAnyPublisher()
                }

                let signer = BiometricsSHA256Signer(privateKeyContainer: privateKeyContainer)

                guard let expiresInterval = try? certificate.notAfter().timeIntervalSince1970,
                      let authCertRaw = certificate.derBytes,
                      let base64authCertRaw = authCertRaw.encodeBase64UrlSafe(),
                      let authCert = String(data: base64authCertRaw, encoding: .utf8) else {
                    return Fail(error: SecureEnclaveSignatureProviderError.packagingAuthCertificate)
                        .eraseToAnyPublisher()
                }
                let expires = Int(expiresInterval)

                let authenticationData = AuthenticationData(
                    authCert: authCert,
                    challengeToken: challenge.challenge.challenge.serialize(),
                    deviceInformation: self.deviceInformation(),
                    // [REQ:gemSpec_IDP_Frontend:A_20700-07] Biometrics only, other modes currently not supported
                    amr: [
                        "mfa",
                        "hwk",
                        "generic-biometric",
                    ],
                    keyIdentifier: identifier,
                    exp: expires
                )

                let biometricSession = BiometricAuthenticationSession(
                    authenticationData: authenticationData,
                    originalChallenge: challenge
                )

                return biometricSession
                    .sign(with: signer, alg: .secp256r1)
                    .mapError { SecureEnclaveSignatureProviderError.signing($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
