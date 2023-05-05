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
import ComposableArchitecture
import Foundation
import HealthCardAccess
import IDP
import OpenSSL

extension HealthCardType {
    func sign(challengeSession: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        readAutCertificate()
            .mapError { $0.asNFCSignatureError() }
            .flatMap { certificate -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> in
                // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
                guard let alg = certificate.info.algorithm.alg else {
                    return Fail(
                        error: NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
                    ).eraseToAnyPublisher()
                }
                // [REQ:gemSpec_IDP_Frontend:A_20700-07] sign with C.CH.AUT
                return challengeSession.sign(
                    with: EGKSigner(card: self),
                    using: [certificate.certificate],
                    alg: alg
                )
                .mapError { $0.asNFCSignatureError() }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func sign(registerDataProvider: SecureEnclaveSignatureProvider,
              in pairingSession: PairingSession,
              signedChallenge: SignedChallenge)
        -> AnyPublisher<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
        readAutCertificate() // AnyPublisher<HealthCardControl.AutCertificateResponse, Error>
            .mapError(NFCSignatureProviderError.cardReadingError)
            .flatMap { certificate -> AnyPublisher<RegistrationData, NFCSignatureProviderError> in
                // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
                guard certificate.info.algorithm.alg == .bp256r1 else {
                    return Fail(
                        error: NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
                    ).eraseToAnyPublisher()
                }

                do {
                    let cert = try X509(der: certificate.certificate)

                    return registerDataProvider
                        .signPairingSession(pairingSession, with: EGKSigner(card: self), certificate: cert)
                        .mapError(NFCSignatureProviderError.secureEnclaveError)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(
                        error: NFCSignatureProviderError.signingFailure(.certificate(error))
                    ).eraseToAnyPublisher()
                }
            }
            .map { (signedChallenge, $0) }
            .eraseToAnyPublisher()
    }
}

extension CardWallReadCardDomain.Environment {
    func loginWithBiometrics(for profileID: UUID) -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> {
        sessionProvider.idTokenValidator(for: profileID)
            .mapError(CardWallReadCardDomain.State.Error.profileValidation)
            .flatMap { idTokenValidator in
                sessionProvider
                    .idpSession(for: profileID)
                    .requestChallenge()
                    .flatMap { (challenge: IDPChallengeSession) -> AnyPublisher<IDPToken, IDPError> in
                        signatureProvider.authenticationData(for: challenge)
                            .first()
                            .mapError(IDPError.pairing)
                            .flatMap { (signedAuthenticationData: SignedAuthenticationData)
                                -> AnyPublisher<IDPToken, IDPError> in
                                sessionProvider
                                    .idpSession(for: profileID)
                                    .altVerify(signedAuthenticationData)
                                    .flatMap { (exchangeToken: IDPExchangeToken) -> AnyPublisher<IDPToken, IDPError> in
                                        sessionProvider.idpSession(for: profileID).exchange(
                                            token: exchangeToken,
                                            challengeSession: challenge,
                                            idTokenValidator: idTokenValidator.validate(idToken:)
                                        )
                                    }
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .mapError(CardWallReadCardDomain.State.Error.idpError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable:next function_body_length
    func signChallengeThenAltAuthWithNFCCard(
        can: String,
        pin: String,
        profileID: UUID
    ) -> Effect<CardWallReadCardDomain.Action, Never> {
        let pairingSession: PairingSession
        do {
            pairingSession = try signatureProvider.createPairingSession()
        } catch {
            return Just(.response(.state(.retrievingChallenge(.error(.biometrieError(error)))))).eraseToEffect()
        }

        return Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in

            subscriber.send(.response(.state(.signingChallenge(.loading))))

            return sessionProvider
                .biometrieIdpSession(for: profileID)
                .requestChallenge() // AnyPublisher<IDPChallengeSession, IDPError>
                .first()
                .mapError(CardWallReadCardDomain.State.Error.idpError)
                .flatMap { challengeSession -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> in
                    self.nfcSessionProvider
                        .openSecureSession(can: can,
                                           pin: pin) // -> AnyPublisher<EGKSignatureSession, NFCSignatureProviderError>
                        .flatMap { healthCard -> AnyPublisher<
                            (SignedChallenge, RegistrationData),
                            NFCSignatureProviderError
                        > in
                        healthCard
                            // [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
                            // [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
                            // [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
                            .sign(challengeSession: challengeSession)
                            .flatMap { signedChallenge -> AnyPublisher<
                                (SignedChallenge, RegistrationData),
                                NFCSignatureProviderError
                            > in
                            healthCard
                                .sign(
                                    registerDataProvider: signatureProvider,
                                    in: pairingSession,
                                    signedChallenge: signedChallenge
                                )
                            }
                            .userMessage(
                                session: healthCard,
                                message: EGKSignatureProvider.systemNFCDialogSuccess
                            )
                            // The delay is needed to show the success message
                            .delay(for: 0.01, scheduler: schedulers.main)
                            .handleEvents(receiveOutput: { _ in
                                healthCard.invalidateSession(with: nil)
                            }, receiveCompletion: { result in
                                if case let .failure(error) = result {
                                    healthCard.invalidateSession(with: error.localizedDescription)
                                }
                            }, receiveCancel: {
                                healthCard.invalidateSession(with: EGKSignatureProvider.systemNFCDialogCancel)
                            })
                            .eraseToAnyPublisher()
                        } // -> AnyPublisher<(SignedChallenge, RegistrationData), NFCSignatureProviderError>
                        .first()
                        .mapError(CardWallReadCardDomain.State.Error.signChallengeError)
                        .flatMap { signedChallenge, registrationData -> AnyPublisher<
                            IDPToken,
                            CardWallReadCardDomain.State.Error
                        > in
                        sessionProvider.idTokenValidator(for: profileID)
                            .mapError(CardWallReadCardDomain.State.Error.profileValidation)
                            .flatMap { idTokenValidator in
                                sessionProvider
                                    .biometrieIdpSession(for: profileID)
                                    .verifyAndExchange(signedChallenge: signedChallenge,
                                                       idTokenValidator: idTokenValidator.validate(idToken:))
                                    .flatMap { token -> AnyPublisher<IDPToken, IDPError> in
                                        sessionProvider
                                            .biometrieIdpSession(for: profileID)
                                            .pairDevice(
                                                with: registrationData,
                                                token: token
                                            )
                                            .map { _ in token }
                                            .eraseToAnyPublisher()
                                    }
                                    .mapError(CardWallReadCardDomain.State.Error.idpError)
                                    .eraseToAnyPublisher()
                            }
                            .flatMap { _ -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> in
                                loginWithBiometrics(for: profileID)
                            }
                            .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .map(CardWallReadCardDomain.State.Output.loggedIn)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        subscriber
                            .send(CardWallReadCardDomain.Action.response(.state(.signingChallenge(.error(error)))))
                        // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
                        _ = try? signatureProvider.abort(pairingSession: pairingSession)
                    }
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(.response(.state(value)))
                })
        }
    }
}
