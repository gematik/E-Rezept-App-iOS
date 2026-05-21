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
import IDP
import Profiles

extension CardWallReadCardDomain.Environment {
    static let delay: DispatchQueue.SchedulerTimeType.Stride = {
        // on slower device use a longer delay
        if ProcessInfo().isLowPowerModeEnabled {
            return .seconds(4)
        } else if ProcessInfo().physicalMemory <= 4_000_000_000 {
            return .seconds(2.0)
        } else {
            return .seconds(0.5)
        }
    }()

    // swiftlint:disable:next function_parameter_count
    func saveProfileWith(
        profileId: UUID,
        insuranceId: String?,
        insurance: String?,
        insuranceIK: String?,
        givenName: String?,
        familyName: String?
    ) -> Effect<CardWallReadCardDomain.Action> {
        @Dependency(\.profilesStore) var profilesStore
        @Dependency(\.schedulers) var schedulers

        return .publisher(
            profilesStore.update(profileId: profileId) { profile in
                if let insuranceId {
                    profile.insuranceId = insuranceId
                }
                // This is needed to ensure proper pKV faking.
                // It can be removed when the debug option to fake pKV is removed.
                if profile.insuranceType == .unknown {
                    profile.insuranceType = .gKV
                }
                if let insurance {
                    profile.insurance = insurance
                }
                if let givenName {
                    profile.givenName = givenName
                    profile.displayName = givenName + " "
                }
                if let familyName {
                    profile.familyName = familyName
                    profile.displayName = ((profile.displayName ?? "") + familyName)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }

                if profile.shouldAutoUpdateNameAtNextLogin,
                   let displayName = profile.displayName {
                    profile.name = displayName
                    profile.shouldAutoUpdateNameAtNextLogin = false
                }

                if let ikNumber = insuranceIK {
                    profile.insuranceIK = ikNumber
                }
            }
            .map { _ in
                CardWallReadCardDomain.Action.delegate(.close)
            }
            .delay(for: Self.delay, scheduler: schedulers.main)
            .catch { error in
                Just(CardWallReadCardDomain.Action.saveError(error))
            }
            .receive(on: schedulers.main)
            .eraseToAnyPublisher
        )
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    // [REQ:gemSpec_IDP_Frontend:A_20526-01] sign and verify with idp
    func signChallengeWithNFCCard(
        can: String,
        pin: String,
        profileID: UUID,
        send: Send<CardWallReadCardDomain.Action>
    ) async {
        await send(.response(.state(.signingChallenge(.loading))))

        let challenge: IDPChallengeSession
        do {
            let idpSession = try sessionProvider.idpSession(profileID)
            challenge = try await idpSession.requestChallenge()
                .async(\CardWallReadCardDomain.State.Error.Cases.idpError)
        } catch let error as CardWallReadCardDomain.State.Error {
            await send(.response(.state(.signingChallenge(.error(error)))))
            return
        } catch {
            // cannot be called since requestChallenge() returns an IDPError
            await send(.response(.state(.signingChallenge(.error(.idpError(.unspecified(error: error)))))))
            return
        }

        let signedChallengeResult = await nfcSessionProvider.sign(
            can: can,
            pin: pin,
            challenge: challenge,
            profileId: profileID
        )

        let signedChallenge: SignedChallenge
        switch signedChallengeResult {
        case let .success(value):
            signedChallenge = value
        case let .failure(error):
            await send(.response(.state(.signingChallenge(.error(CardWallReadCardDomain.State.Error
                    .signChallengeError(error))))))
            return
        }

        await send(.response(.state(.verifying(.loading))))

        let actionAfterVerify = await verifyResultWithIDP(signedChallenge, profileID: profileID)
        await send(actionAfterVerify)
    }

    // [REQ:gemSpec_eRp_FdV:A_20172]
    // [REQ:gemSpec_IDP_Frontend:A_20526-01] verify with idp
    func verifyResultWithIDP(
        _ signedChallenge: SignedChallenge,
        profileID: UUID
    ) async -> CardWallReadCardDomain.Action {
        let idTokenValidator: IDTokenValidator
        do {
            idTokenValidator = try await sessionProvider.idTokenValidator(profileID) //  IDTokenValidatorError
                .async(\CardWallReadCardDomain.State.Error.Cases.profileValidation)
        } catch let error as CardWallReadCardDomain.State.Error {
            return .response(.state(.verifying(.error(error))))
        } catch {
            return .response(.state(.verifying(.error(.profileValidation(.other(error: error))))))
        }

        let stateOutput: CardWallReadCardDomain.State.Output
        do {
            let idpSession = try sessionProvider.idpSession(profileID)
            let idpExchangeToken = try await idpSession.verify(signedChallenge).async()
            let idpToken = try await idpSession.exchange(
                token: idpExchangeToken,
                challengeSession: signedChallenge.originalChallenge,
                idTokenValidator: idTokenValidator.validate(idToken:)
            ) // IDPError
            .async()
            stateOutput = .loggedIn(idpToken)
        } catch let error as IDPError {
            let stateError: CardWallReadCardDomain.State.Error
            if case let .unspecified(error) = error,
               let validationError = error as? IDTokenValidatorError {
                stateError = .profileValidation(validationError)
            } else {
                stateError = .idpError(error)
            }
            stateOutput = .verifying(.error(stateError))
        } catch {
            return .response(.state(.verifying(.error(.profileValidation(.other(error: error))))))
        }
        return .response(.state(stateOutput))
    }
}
