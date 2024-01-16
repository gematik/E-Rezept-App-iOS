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
import IDP
import OpenSSL

class DummySecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
    var isBiometrieRegistered: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    func createPairingSession() throws -> PairingSession {
        throw SecureEnclaveSignatureProviderError.packagingAuthCertificate
    }

    func signPairingSession(_: PairingSession, with _: JWTSigner, certificate _: X509)
        -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError> {
        Fail(error: SecureEnclaveSignatureProviderError.packagingAuthCertificate).eraseToAnyPublisher()
    }

    func abort(pairingSession _: PairingSession) throws {}

    func authenticationData(for _: IDPChallengeSession)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        Fail(error: SecureEnclaveSignatureProviderError.packagingAuthCertificate).eraseToAnyPublisher()
    }
}
