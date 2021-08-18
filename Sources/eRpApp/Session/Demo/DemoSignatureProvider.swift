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
import CoreNFC
import Foundation
import HealthCardAccess
import HealthCardControl
import IDP
import NFCCardReaderProvider

class DemoSignatureProvider: NFCSignatureProvider {
    func openSecureSession(can _: CAN,
                           pin _: Format2Pin) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        Fail(error: NFCSignatureProviderError.cardError(NFCTagReaderSession.Error.unsupportedTag)).eraseToAnyPublisher()
    }

    func sign(can _: CAN, pin _: Format2Pin,
              challenge: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        do {
            let jwt = try JWT(
                header: JWT.Header(),
                payload: DemoIDPSession.DemoPayload()
            )

            return Just(SignedChallenge(
                originalChallenge: challenge,
                signedChallenge: jwt
            ))
                .setFailureType(to: NFCSignatureProviderError.self)
                .delay(for: 3, scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NFCSignatureProviderError.genericError(DemoError.demo)).eraseToAnyPublisher()
        }
    }

    func sign(can _: CAN, pin _: Format2Pin,
              registrationDataProvider _: SecureEnclaveSignatureProvider)
        -> AnyPublisher<RegistrationData, NFCSignatureProviderError> {
        Fail(error: NFCSignatureProviderError.signingFailure(nil))
            .delay(for: 3, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
