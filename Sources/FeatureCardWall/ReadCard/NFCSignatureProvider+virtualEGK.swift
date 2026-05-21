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

import AsyncHelpers
import CasePaths
import Combine
import Foundation
import IDP
import OpenSSL
import Sharing

extension SharedReaderKey
    where Self == AppStorageKey<String>.Default {
    /// C.CH.AUT public key for virtual EGK
    public static var virtualEGKCCHAut: Self {
        Self[.appStorage(.kVirtualEGKCCHAUTKey), default: ""]
    }

    /// Private key for virtual EGK CH authentication
    public static var virtualEGKPrkCHAut: Self {
        Self[.appStorage(.kVirtualEGKPrkCHAUTKey), default: ""]
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    /// Whether virtual EGK is enabled
    public static var isVirtualEGKEnabled: Self {
        Self[.appStorage(.kIsVirtualEGKEnabledKey), default: false]
    }
}

extension String {
    static let kIsVirtualEGKEnabledKey = "kIsVirtualEGKEnabled"
    static let kVirtualEGKPrkCHAUTKey = "kVirtualEGKPrkCHAUT"
    static let kVirtualEGKCCHAUTKey = "kVirtualEGKCCHAUT"
}

extension NFCSignatureProvider {
    /// NFCSignatureProvider using a virtual EGK for signing
    public static var virtualEGK: Self {
        NFCSignatureProvider { _, _, challengeSession, _ in
            @Shared(.virtualEGKCCHAut) var cchaut
            @Shared(.virtualEGKPrkCHAut) var prkchaut

            guard let signer = Brainpool256r1Signer(
                x5c: cchaut,
                key: prkchaut
            )
            else {
                return .failure(.signingFailure(.missingCertificate))
            }

            do {
                let signedChallenge = try await challengeSession.sign(with: signer, using: signer.certificates)
                    .async()
                return .success(signedChallenge)
            } catch {
                return .failure(error.asNFCSignatureError())
            }
        } signForBiometrics: { _, _, challengeSession, registerDataProvider, pairingSession, _ in
            @Shared(.virtualEGKCCHAut) var cchaut
            @Shared(.virtualEGKPrkCHAut) var prkchaut

            let cert: X509
            guard let signer = Brainpool256r1Signer(
                x5c: cchaut,
                key: prkchaut
            ),
                let certificate = signer.certificates.first
            else {
                return .failure(.signingFailure(.missingCertificate))
            }
            do {
                cert = try X509(der: certificate)
            } catch {
                return .failure(.signingFailure(.certificate(error)))
            }

            do {
                let signedChallenge = try await challengeSession
                    .sign(with: signer, using: signer.certificates)
                    .async()
                let registrationData = try await registerDataProvider
                    .signPairingSession(pairingSession, with: signer, certificate: cert)
                    .async(\NFCSignatureProviderError.Cases.secureEnclaveError)
                return .success((signedChallenge, registrationData))
            } catch {
                return .failure(error.asNFCSignatureError())
            }
        }
    }

    class Brainpool256r1Signer: JWTSigner {
        let x5c: X509
        let derBytes: Data
        let key: BrainpoolP256r1.Verify.PrivateKey

        init?(x5c x5cBase64: String, key keyBase64: String) {
            guard
                let derBytes = Data(
                    base64Encoded: x5cBase64.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                ),
                let x5c = try? X509(der: derBytes),
                let keyBytes = Data(
                    base64Encoded: keyBase64.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                ),
                let key = try? BrainpoolP256r1.Verify.PrivateKey(raw: keyBytes)
            else {
                return nil
            }

            self.derBytes = derBytes
            self.x5c = x5c
            self.key = key
        }

        var certificates: [Data] {
            [derBytes]
        }

        func sign(message: Data) async throws -> Data {
            try key.sign(message: message).rawRepresentation
        }
    }
}
