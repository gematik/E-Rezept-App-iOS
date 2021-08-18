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

import Combine
import ComposableArchitecture
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
                    return Fail(error: NFCSignatureProviderError.signingFailure(nil)).eraseToAnyPublisher()
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
            .mapError { $0.asNFCSignatureError() }
            .flatMap { certificate -> AnyPublisher<RegistrationData, Swift.Error> in
                // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
                guard certificate.info.algorithm.alg == .bp256r1 else {
                    return Fail(error: NFCSignatureProviderError.signingFailure(nil)).eraseToAnyPublisher()
                }

                do {
                    let cert = try X509(der: certificate.certificate)

                    return registerDataProvider
                        .signPairingSession(pairingSession, with: EGKSigner(card: self), certificate: cert)
                        .mapError { $0 as Swift.Error }
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: NFCSignatureProviderError.signingFailure(error)).eraseToAnyPublisher()
                }
            }
            .mapError { $0.asNFCSignatureError() }
            .map { (signedChallenge, $0) }
            .eraseToAnyPublisher()
    }
}

extension CardWallReadCardDomain.Environment {
    func loginWithBiometrics() -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> {
        userSession.idpSession.requestChallenge()
            .flatMap { (challenge: IDPChallengeSession) -> AnyPublisher<IDPToken, IDPError> in
                self.signatureProvider.authenticationData(for: challenge)
                    .mapError(IDPError.pairing)
                    .flatMap { (signedAuthenticationData: SignedAuthenticationData)
                        -> AnyPublisher<IDPToken, IDPError> in
                        self.userSession.idpSession.altVerify(signedAuthenticationData)
                            .flatMap { (exchangeToken: IDPExchangeToken) -> AnyPublisher<IDPToken, IDPError> in
                                self.userSession.idpSession.exchange(token: exchangeToken, challengeSession: challenge)
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .mapError(CardWallReadCardDomain.State.Error.idpError)
            .eraseToAnyPublisher()
    }

    func signChallengeThenAltAuthWithNFCCard(can: CAN, pin: Format2Pin) // swiftlint:disable:this function_body_length
    -> Effect<CardWallReadCardDomain.Action, Never> {
        let pairingSession: PairingSession
        do {
            pairingSession = try signatureProvider.registerData()
        } catch {
            return Just(.stateReceived(.retrievingChallenge(.error(.biometrieError(error))))).eraseToEffect()
        }

        return Effect<CardWallReadCardDomain.Action, Never>.run { subscriber -> Cancellable in

            subscriber.send(.stateReceived(.signingChallenge(.loading)))

            return self.userSession.biometrieIdpSession
                .requestChallenge() // AnyPublisher<IDPChallengeSession, IDPError>
                .mapError(CardWallReadCardDomain.State.Error.idpError)
                .flatMap { challengeSession -> AnyPublisher<IDPToken, CardWallReadCardDomain.State.Error> in
                    self.userSession.nfcSessionProvider
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
                                            registerDataProvider: self.signatureProvider,
                                            in: pairingSession,
                                            signedChallenge: signedChallenge
                                        )
                                }
                                .userMessage(
                                    session: healthCard,
                                    message: EGKSignatureProvider.systemNFCDialogSuccess
                                )
                                // The delay is needed to show the success message
                                .delay(for: 0.01, scheduler: self.schedulers.main)
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
                        .mapError(CardWallReadCardDomain.State.Error.signChallengeError)
                        .flatMap { signedChallenge, registrationData -> AnyPublisher<
                            IDPToken,
                            CardWallReadCardDomain.State.Error
                        > in
                            self.userSession.biometrieIdpSession
                                .verifyAndExchange(signedChallenge: signedChallenge)
                                .flatMap { token -> AnyPublisher<IDPToken, IDPError> in
                                    self.userSession.biometrieIdpSession.pairDevice(
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
                            self.loginWithBiometrics()
                        }
                        .eraseToAnyPublisher()
                }
                .map { _ in
                    // If we receive any IDPToken, user is considered logged in
                    CardWallReadCardDomain.State.Output.loggedIn
                }
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        subscriber.send(CardWallReadCardDomain.Action.stateReceived(.signingChallenge(.error(error))))
                        // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
                        _ = try? self.signatureProvider.abort(pairingSession: pairingSession)
                    }
                    subscriber.send(completion: .finished)
                }, receiveValue: { value in
                    subscriber.send(.stateReceived(value))
                })
        }
    }
}
