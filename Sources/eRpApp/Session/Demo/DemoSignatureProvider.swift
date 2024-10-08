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

import Combine
import CoreNFC
import Foundation
import IDP
import NFCCardReaderProvider

class DemoSignatureProvider: NFCSignatureProvider {
    func sign(can _: String, pin _: String,
              challenge: IDPChallengeSession) async -> Result<SignedChallenge, NFCSignatureProviderError> {
        guard let jwt = try? JWT(
            header: JWT.Header(),
            payload: DemoIDPSession.DemoPayload()
        )
        else {
            return .failure(NFCSignatureProviderError.genericError(DemoError.demo))
        }
        Task { @MainActor in try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3) }
        return .success(SignedChallenge(
            originalChallenge: challenge,
            signedChallenge: jwt
        ))
    }

    func signForBiometrics(
        can _: String,
        pin _: String,
        challenge _: IDPChallengeSession,
        registerDataProvider _: SecureEnclaveSignatureProvider,
        in _: PairingSession
    ) async -> Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
        .failure(.nfcHealthCardSession(.couldNotInitializeSession))
    }
}
