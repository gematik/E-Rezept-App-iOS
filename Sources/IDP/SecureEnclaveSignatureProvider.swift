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
import OpenSSL

// sourcery: CodedError = "109"
public enum SecureEnclaveSignatureProviderError: Swift.Error {
    // sourcery: errorCode = "01"
    case fetchingPrivateKey(Swift.Error?)
    // sourcery: errorCode = "02"
    case signing(Swift.Error?)
    // sourcery: errorCode = "03"
    case packagingAuthCertificate
    // sourcery: errorCode = "04"
    case packagingSeCertificate
    // sourcery: errorCode = "05"
    case gatheringPairingData(Swift.Error)
    // sourcery: errorCode = "06"
    case `internal`(String, Swift.Error?)
}

extension SecureEnclaveSignatureProviderError: Equatable {
    public static func ==(lhs: SecureEnclaveSignatureProviderError, rhs: SecureEnclaveSignatureProviderError) -> Bool {
        switch (lhs, rhs) {
        case (.fetchingPrivateKey, .fetchingPrivateKey),
             (.signing, .signing),
             (.packagingAuthCertificate, .packagingAuthCertificate),
             (.packagingSeCertificate, .packagingSeCertificate),
             (.gatheringPairingData, .gatheringPairingData):
            return true
        case let (.internal(lhsText, _), .internal(rhsText, _)):
            return lhsText == rhsText
        default:
            return false
        }
    }
}

/// Provides access for gathering biometrics related registration and authentication data.
public protocol SecureEnclaveSignatureProvider {
    /// Opens a pairing session and creates a `PairingSession` object with it. The `PairingSession` object must be
    /// aborted with `abort` when the registration process was unsuccessfull.
    /// - Throws: SecureEnclaveSignatureProviderError
    /// - Returns: Instance of `PairingSession`
    func createPairingSession() throws -> PairingSession

    /// Creates a RegistrationData object using a `JWTSigner` to sign the `PairingData`.
    ///
    /// - Parameters:
    ///   - pairingSession: `PairingSession` instance that is used to identify the biometric key.
    ///   - signer: The `JWTSigner` that is used to authenticate the key that is paired. Usually this is a eGK.
    ///   - certificate: Certificate of the signer that is used to sign the `PairingData`.
    func signPairingSession(_ pairingSession: PairingSession, with signer: JWTSigner, certificate: X509)
        -> AnyPublisher<RegistrationData, SecureEnclaveSignatureProviderError>

    /// Cancels the signing session and delete all temporary data, such as `PrK_SE_AUT` and `PuK_SE_AUT`.
    ///
    /// - Parameter pairingSession: The `PairingSession` that needs cancelation.
    func abort(pairingSession: PairingSession) throws

    /// Provides `SignedAuthenticationData` by gathering all necessary data and signing them with `PrK_SE_AUT`. Will
    /// automatically handle biometric unlock such as FaceID or TouchID.
    /// - Parameter challenge: The `IDPChallengeSession` to sign with `PrK_SE_AUT`.
    func authenticationData(for challenge: IDPChallengeSession)
        -> AnyPublisher<SignedAuthenticationData, SecureEnclaveSignatureProviderError>

    /// If the Publishers value is true, biometrics is successfully registered, false otherwise.
    var isBiometrieRegistered: AnyPublisher<Bool, Never> { get }
}
