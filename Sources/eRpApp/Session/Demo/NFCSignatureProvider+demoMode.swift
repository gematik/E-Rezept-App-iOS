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

import Combine
import CoreNFC
import FeatureCardWall
import Foundation
import IDP
import NFCCardReaderProvider

extension NFCSignatureProvider {
    static var demoMode = NFCSignatureProvider { _, _, challenge, _ in
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
    } signForBiometrics: { _, _, _, _, _, _ in
        .failure(.nfcHealthCardSession(.couldNotInitializeSession))
    }
}
