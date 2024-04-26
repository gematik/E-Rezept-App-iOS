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

import CasePaths
import Combine
import DataKit
import Foundation
import IDP
import OpenSSL

#if ENABLE_DEBUG_VIEW
class VirtualEGKSignatureProvider: NFCSignatureProvider {
    func sign(
        can _: String,
        pin _: String,
        challenge challengeSession: IDPChallengeSession
    ) async -> Result<SignedChallenge, NFCSignatureProviderError> {
        let cchaut = UserDefaults.standard.virtualEGKCCHAut ?? ""
        let prkchaut = UserDefaults.standard.virtualEGKPrkCHAut ?? ""

        let signer: Brainpool256r1Signer
        do {
            signer = try Brainpool256r1Signer(
                x5c: cchaut,
                key: prkchaut
            )
        } catch {
            return .failure(.signingFailure(.certificate(error)))
        }

        do {
            let signedChallenge = try await challengeSession.sign(with: signer, using: signer.certificates)
                .async()
            return .success(signedChallenge)
        } catch {
            return .failure(error.asNFCSignatureError())
        }
    }

    func signForBiometrics(
        can _: String,
        pin _: String,
        challenge challengeSession: IDPChallengeSession,
        registerDataProvider: SecureEnclaveSignatureProvider,
        in pairingSession: PairingSession
    ) async -> Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
        let cchaut = UserDefaults.standard.virtualEGKCCHAut ?? ""
        let prkchaut = UserDefaults.standard.virtualEGKPrkCHAut ?? ""

        let signer: Brainpool256r1Signer
        let cert: X509
        do {
            signer = try Brainpool256r1Signer(
                x5c: cchaut,
                key: prkchaut
            )
            guard let certificate = signer.certificates.first
            else {
                return .failure(.signingFailure(.missingCertificate))
            }
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
                .async(/NFCSignatureProviderError.secureEnclaveError)
            return .success((signedChallenge, registrationData))
        } catch {
            return .failure(error.asNFCSignatureError())
        }
    }

    class Brainpool256r1Signer: JWTSigner {
        let x5c: X509
        let derBytes: Data
        let key: BrainpoolP256r1.Verify.PrivateKey

        init(x5c x5cBase64: String, key keyBase64: String) throws {
            derBytes = try Base64.decode(string: x5cBase64)
            x5c = try X509(der: derBytes)
            key = try BrainpoolP256r1.Verify.PrivateKey(raw: try Base64.decode(string: keyBase64))
        }

        var certificates: [Data] {
            [derBytes]
        }

        func sign(message: Data) -> AnyPublisher<Data, Error> {
            Future { promise in
                promise(Result {
                    try self.key.sign(message: message).rawRepresentation
                })
            }
            .eraseToAnyPublisher()
        }
    }
}
#endif
