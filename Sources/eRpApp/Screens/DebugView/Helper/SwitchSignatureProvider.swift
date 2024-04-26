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
import Foundation
import IDP

#if ENABLE_DEBUG_VIEW
class SwitchSignatureProvider: NFCSignatureProvider {
    let defaultSignatureProvider: NFCSignatureProvider
    let alternativeSignatureProvider: NFCSignatureProvider

    init(defaultSignatureProvider: NFCSignatureProvider, alternativeSignatureProvider: NFCSignatureProvider) {
        self.defaultSignatureProvider = defaultSignatureProvider
        self.alternativeSignatureProvider = alternativeSignatureProvider
    }

    func sign(
        can: String,
        pin: String,
        challenge: IDPChallengeSession
    ) async -> Result<SignedChallenge, NFCSignatureProviderError> {
        if UserDefaults.standard.isVirtualEGKEnabled {
            return await alternativeSignatureProvider.sign(can: can, pin: pin, challenge: challenge)
        } else {
            return await defaultSignatureProvider.sign(can: can, pin: pin, challenge: challenge)
        }
    }

    func signForBiometrics(
        can: String,
        pin: String,
        challenge: IDPChallengeSession,
        registerDataProvider: SecureEnclaveSignatureProvider,
        in pairingSession: PairingSession
    ) async -> Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
        if UserDefaults.standard.isVirtualEGKEnabled {
            return await alternativeSignatureProvider.signForBiometrics(
                can: can,
                pin: pin,
                challenge: challenge,
                registerDataProvider: registerDataProvider,
                in: pairingSession
            )
        } else {
            return await defaultSignatureProvider.signForBiometrics(
                can: can,
                pin: pin,
                challenge: challenge,
                registerDataProvider: registerDataProvider,
                in: pairingSession
            )
        }
    }
}
#endif
