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

import Combine
import DataKit
import Foundation
import IDP
import OpenSSL

#if ENABLE_DEBUG_VIEW
class VirtualEGKSignatureProvider: NFCSignatureProvider {
    func openSecureSession(can _: String,
                           pin _: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        let cchaut = UserDefaults.standard.virtualEGKCCHAut ?? ""
        let prkchaut = UserDefaults.standard.virtualEGKPrkCHAut ?? ""

        let signatureSession = Session(privateKey: prkchaut, certificate: cchaut)

        return Just(signatureSession).setFailureType(to: NFCSignatureProviderError.self).eraseToAnyPublisher()
    }

    func sign(can: String,
              pin: String,
              challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        openSecureSession(can: can, pin: pin)
            .flatMap { session in
                session.sign(challengeSession: challenge)
            }
            .eraseToAnyPublisher()
    }

    class Session: SignatureSession {
        var encodedPrivateKey: String
        var encodedCertificate: String

        init(privateKey: String, certificate: String) {
            encodedPrivateKey = privateKey
            encodedCertificate = certificate
        }

        func sign(challengeSession: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
            do {
                let signer = try Brainpool256r1Signer(
                    x5c: encodedCertificate,
                    key: encodedPrivateKey
                )

                return challengeSession
                    .sign(with: signer, using: signer.certificates)
                    .mapError { error in
                        error.asNFCSignatureError()
                    }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(outputType: SignedChallenge.self,
                            failure: NFCSignatureProviderError.signingFailure(.certificate(error)))
                    .eraseToAnyPublisher()
            }
        }

        func sign(registerDataProvider: SecureEnclaveSignatureProvider,
                  in pairingSession: PairingSession,
                  signedChallenge: SignedChallenge)
            -> AnyPublisher<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
            do {
                let signer = try Brainpool256r1Signer(
                    x5c: encodedCertificate,
                    key: encodedPrivateKey
                )
                guard let certificate = signer.certificates.first else {
                    return Fail(
                        error: NFCSignatureProviderError.signingFailure(.missingCertificate)
                    ).eraseToAnyPublisher()
                }
                let cert = try X509(der: certificate)
                return registerDataProvider
                    .signPairingSession(pairingSession, with: signer, certificate: cert)
                    .mapError(NFCSignatureProviderError.secureEnclaveError)
                    .map { (signedChallenge, $0) }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: NFCSignatureProviderError.signingFailure(.certificate(error))).eraseToAnyPublisher()
            }
        }

        func updateAlert(message _: String) {}

        func invalidateSession(with _: String?) {}

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
}
#endif
