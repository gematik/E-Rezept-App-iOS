//
//  Copyright (c) 2022 gematik GmbH
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
import IDP
import OpenSSL

// swiftlint:disable large_tuple

// MARK: - MockSecureEnclaveSignatureProvider -

final class MockSecureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
    // MARK: - isBiometrieRegistered

    var isBiometryRegistered_CallsCount = 0
    var isBiometryRegistered_Called: Bool {
        isBiometryRegistered_CallsCount > 0
    }

    var isBiometryRegistered_ReceivedInvocations: [UUID] = []
    var isBiometryRegistered_ReturnValue: AnyPublisher<Bool, Never>!

    var isBiometrieRegistered: AnyPublisher<Bool, Never> {
        isBiometryRegistered_CallsCount += 1
        return isBiometryRegistered_ReturnValue
    }

    // MARK: - registerData

    var registerDataThrowableError: Error?
    var registerDataCallsCount = 0
    var registerDataCalled: Bool {
        registerDataCallsCount > 0
    }

    var registerDataReturnValue: PairingSession!
    var registerDataClosure: (() throws -> PairingSession)?

    func registerData() throws -> PairingSession {
        if let error = registerDataThrowableError {
            throw error
        }
        registerDataCallsCount += 1
        return try registerDataClosure.map { try $0() } ?? registerDataReturnValue
    }

    // MARK: - signPairingSession

    var signPairingSessionWithCertificateCallsCount = 0
    var signPairingSessionWithCertificateCalled: Bool {
        signPairingSessionWithCertificateCallsCount > 0
    }

    var signPairingSessionWithCertificateReceivedArguments: (
        pairingSession: PairingSession,
        signer: JWTSigner,
        certificate: X509
    )?
    var signPairingSessionWithCertificateReceivedInvocations: [(pairingSession: PairingSession, signer: JWTSigner,
                                                                certificate: X509)] = []
    var signPairingSessionWithCertificateReturnValue: AnyPublisher<RegistrationData, Swift.Error>!
    var signPairingSessionWithCertificateClosure: ((PairingSession, JWTSigner, X509)
        -> AnyPublisher<RegistrationData, Swift.Error>)?

    func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner,
                            certificate: X509) -> AnyPublisher<RegistrationData, Swift.Error> {
        signPairingSessionWithCertificateCallsCount += 1
        signPairingSessionWithCertificateReceivedArguments = (
            pairingSession: pairingSession,
            signer: signer,
            certificate: certificate
        )
        signPairingSessionWithCertificateReceivedInvocations
            .append((pairingSession: pairingSession, signer: signer, certificate: certificate))
        return signPairingSessionWithCertificateClosure
            .map { $0(pairingSession, signer, certificate) } ?? signPairingSessionWithCertificateReturnValue
    }

    // MARK: - abort

    var abortPairingSessionThrowableError: Error?
    var abortPairingSessionCallsCount = 0
    var abortPairingSessionCalled: Bool {
        abortPairingSessionCallsCount > 0
    }

    var abortPairingSessionReceivedPairingSession: PairingSession?
    var abortPairingSessionReceivedInvocations: [PairingSession] = []
    var abortPairingSessionClosure: ((PairingSession) throws -> Void)?

    func abort(pairingSession: PairingSession) throws {
        if let error = abortPairingSessionThrowableError {
            throw error
        }
        abortPairingSessionCallsCount += 1
        abortPairingSessionReceivedPairingSession = pairingSession
        abortPairingSessionReceivedInvocations.append(pairingSession)
        try abortPairingSessionClosure?(pairingSession)
    }

    // MARK: - authenticationData

    var authenticationDataForCallsCount = 0
    var authenticationDataForCalled: Bool {
        authenticationDataForCallsCount > 0
    }

    var authenticationDataForReceivedChallenge: IDPChallengeSession?
    var authenticationDataForReceivedInvocations: [IDPChallengeSession] = []
    var authenticationDataForReturnValue: AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>!
    var authenticationDataForClosure: ((IDPChallengeSession)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>)?

    func authenticationData(for challenge: IDPChallengeSession)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError> {
        authenticationDataForCallsCount += 1
        authenticationDataForReceivedChallenge = challenge
        authenticationDataForReceivedInvocations.append(challenge)
        return authenticationDataForClosure.map { $0(challenge) } ?? authenticationDataForReturnValue
    }
}
