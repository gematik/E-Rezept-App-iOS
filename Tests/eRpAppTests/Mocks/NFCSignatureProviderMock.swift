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
@testable import eRpApp
import Foundation
import HealthCardAccess
import HealthCardControl
import IDP

// MARK: - NFCSignatureProviderMock -

final class NFCSignatureProviderMock: NFCSignatureProvider {
    func openSecureSession(can _: CAN,
                           pin _: Format2Pin) -> AnyPublisher<EGKSignatureSession, NFCSignatureProviderError> {
        Fail(error: NFCSignatureProviderError.signingFailure(nil)).eraseToAnyPublisher()
    }

   // MARK: - sign

    var signResult = PassthroughSubject<SignedChallenge, NFCSignatureProviderError>()

    var signCalledCount = 0
    var signCalled: Bool {
        signCalledCount > 0
    }

    func sign(can _: CAN, pin _: Format2Pin,
              challenge _: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        signCalledCount += 1
        return signResult
            .eraseToAnyPublisher()
    }

   // MARK: - sign

    var signRegistrationDataCallsCount = 0
    var signRegistrationDataCalled: Bool {
        signRegistrationDataCallsCount > 0
    }

    var signRegistrationDataReceivedArguments: ( // swiftlint:disable:this large_tuple
        can: CAN,
        pin: Format2Pin,
        registrationDataProvider: SecureEnclaveSignatureProvider
    )?
    var signRegistrationDataReceivedInvocations: [( // swiftlint:disable:this large_tuple
        can: CAN,
        pin: Format2Pin,
        registrationDataProvider: SecureEnclaveSignatureProvider
    )] = [
    ]
    var signRegistrationDataReturnValue: AnyPublisher<RegistrationData, NFCSignatureProviderError>!
    var signRegistrationDataClosure: ((CAN, Format2Pin, SecureEnclaveSignatureProvider)
        -> AnyPublisher<RegistrationData, NFCSignatureProviderError>)?

    func sign(can: CAN, pin: Format2Pin,
              registrationDataProvider: SecureEnclaveSignatureProvider)
        -> AnyPublisher<RegistrationData, NFCSignatureProviderError> {
        signRegistrationDataCallsCount += 1
        signRegistrationDataReceivedArguments = (
            can: can,
            pin: pin,
            registrationDataProvider: registrationDataProvider
        )
        signRegistrationDataReceivedInvocations
            .append((can: can, pin: pin, registrationDataProvider: registrationDataProvider))
        return signRegistrationDataClosure
            .map { $0(can, pin, registrationDataProvider) } ?? signRegistrationDataReturnValue
    }
}
