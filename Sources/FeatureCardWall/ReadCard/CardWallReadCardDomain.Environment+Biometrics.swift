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
import Combine
import ComposableArchitecture
import Foundation
import HealthCardAccess
import HealthCardControl
import IDP
import OpenSSL
import Profiles

extension CardWallReadCardDomain.Environment {
    func loginWithBiometrics(
        for profileID: UUID
    ) async -> Result<IDPToken, CardWallReadCardDomain.State.Error> {
        let idTokenValidator: IDTokenValidator
        do {
            idTokenValidator = try await sessionProvider.idTokenValidator(profileID)
                .async()
        } catch let error as IDTokenValidatorError {
            return .failure(.profileValidation(error))
        } catch {
            return .failure(.profileValidation(.other(error: error)))
        }
        let idpToken: IDPToken
        do {
            let idpSession = try sessionProvider.idpSession(profileID)
            let challenge = try await idpSession.requestChallenge()
                .async() // IDPError
            let signatureProvider = try sessionProvider.signatureProvider(profileID)
            let signedAuthenticationData = try await signatureProvider
                .authenticationData(for: challenge) // IDP SecureEnclaveSignatureProviderError
                .async()
            let exchangeToken = try await idpSession.altVerify(signedAuthenticationData) // IDPError
                .async()
            idpToken = try await idpSession.exchange(
                token: exchangeToken,
                challengeSession: challenge,
                idTokenValidator: idTokenValidator.validate(idToken:)
            ) // IDPError
            .async()
        } catch let error as SecureEnclaveSignatureProviderError {
            return .failure(.idpError(IDPError.pairing(error)))
        } catch let error as IDPError {
            return .failure(.idpError(error))
        } catch {
            return .failure(.idpError(.unspecified(error: error)))
        }
        return .success(idpToken)
    }

    // swiftlint:disable:next function_body_length
    func signChallengeThenAltAuthWithNFCCard(
        can: String,
        pin: String,
        profileID: UUID,
        send: Send<CardWallReadCardDomain.Action>
    ) async {
        let pairingSession: PairingSession
        do {
            // [REQ:BSI-eRp-ePA:O.Source_5#4] Creation of the pairing session
            pairingSession = try sessionProvider.signatureProvider(profileID).createPairingSession()
        } catch {
            await send(.response(.state(.signingChallenge(.error(.biometrieError(error))))))
            return
        }
        await send(.response(.state(.signingChallenge(.loading))))

        let idpChallengeSession: IDPChallengeSession
        let signedChallengeResponse: Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError>
        do {
            let biometrieIdpSession = try sessionProvider.biometrieIdpSession(profileID)
            idpChallengeSession = try await biometrieIdpSession.requestChallenge()
                .async(\CardWallReadCardDomain.State.Error.Cases.idpError) // IDPError
            signedChallengeResponse = try await nfcSessionProvider.signForBiometrics(
                can: can,
                pin: pin,
                challenge: idpChallengeSession,
                registerDataProvider: sessionProvider.signatureProvider(profileID),
                pairingSession: pairingSession,
                profileId: profileID
            )
        } catch let error as CardWallReadCardDomain.State.Error {
            // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
            // [REQ:BSI-eRp-ePA:O.Source_5#5] Failure will delete paring data
            _ = try? sessionProvider.signatureProvider(profileID).abort(pairingSession: pairingSession)
            await send(.response(.state(.signingChallenge(.error(error)))))
            return
        } catch {
            _ = try? sessionProvider.signatureProvider(profileID).abort(pairingSession: pairingSession)
            await send(.response(.state(.signingChallenge(.error(.idpError(.unspecified(error: error)))))))
            return
        }

        let signedChallenge: SignedChallenge
        let registrationData: RegistrationData
        switch signedChallengeResponse {
        case let .success((signedChallengeResponse, registrationDataResponse)):
            signedChallenge = signedChallengeResponse
            registrationData = registrationDataResponse
        case let .failure(error):
            await send(.response(.state(.signingChallenge(.error(.signChallengeError(error))))))
            return
        }

        do {
            let idpSession = try sessionProvider.biometrieIdpSession(profileID)
            _ = try await sessionProvider.idTokenValidator(profileID) // ignore return value `PairingData`
                .mapError(CardWallReadCardDomain.State.Error.profileValidation)
                .flatMap { idTokenValidator in
                    idpSession
                        .verifyAndExchange(signedChallenge: signedChallenge,
                                           idTokenValidator: idTokenValidator.validate(idToken:))
                        .flatMap { token -> AnyPublisher<IDPToken, IDPError> in
                            idpSession
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
                .async()
        } catch let error as CardWallReadCardDomain.State.Error {
            // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
            // [REQ:BSI-eRp-ePA:O.Source_5#5] Failure will delete paring data
            _ = try? sessionProvider.signatureProvider(profileID).abort(pairingSession: pairingSession)
            await send(.response(.state(.signingChallenge(.error(error)))))
            return
        } catch {
            await send(.response(.state(.signingChallenge(.error(.idpError(.unspecified(error: error)))))))
            return
        }

        let tokenResult = await loginWithBiometrics(for: profileID)
        switch tokenResult {
        case let .success(token):
            let stateOutput = CardWallReadCardDomain.State.Output.loggedIn(token)
            await send(.response(.state(stateOutput)))
        case let .failure(error):
            // [REQ:gemSpec_IDP_Frontend:A_21598,A_21595] Failure will delete paring data
            // [REQ:BSI-eRp-ePA:O.Source_5#5] Failure will delete paring data
            _ = try? sessionProvider.signatureProvider(profileID).abort(pairingSession: pairingSession)
            await send(.response(.state(.signingChallenge(.error(error)))))
        }
    }
}
