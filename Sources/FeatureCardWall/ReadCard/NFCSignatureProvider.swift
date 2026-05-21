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
// swiftlint:disable file_length

import AsyncHelpers
import CasePaths
import CodedError
import Combine
import CoreNFC
import Dependencies
import DependenciesMacros
import eRpResources
import HealthCardAccess
import HealthCardControl
import IDP
import IDPLive
import NFCCardReaderProvider
import OpenSSL

@CodedError("004")
@CasePathable
public enum NFCSignatureProviderError: Error {
    /// Error while establishing a connection to the card
    @ErrorCode("01")

    case cardError(NFCTagReaderSession.Error)

    /// Error while verifying the CAN
    @ErrorCode("03")
    case wrongCAN(Swift.Error)

    /// Error while establishing Secure channel or card connection
    @ErrorCode("04")
    case cardConnectionError(Swift.Error)

    /// Any error related to PIN verification
    @ErrorCode("05")
    case verifyCardError(VerifyPINError)

    /// ESIGN Failed
    @ErrorCode("06")
    case signingFailure(SigningError)

    /// Wrong pin while opening secure channel
    @ErrorCode("07")
    case wrongPin(retryCount: Int)

    /// Generic error while trying to sign the challenge
    @ErrorCode("08")
    case genericError(Swift.Error)

    /// Generic error while reading something from the card
    @ErrorCode("09")
    case cardReadingError(Swift.Error)

    /// Generic error while reading something from the card
    @ErrorCode("10")
    case secureEnclaveError(SecureEnclaveSignatureProviderError)

    /// Any error regarding the communication with the NFC health card itself
    /// or sending/receiving data (operation execution)
    @ErrorCode("11")
    case nfcHealthCardSession(NFCHealthCardSessionError)

    @CodedError("005")
    public enum SigningError: Error, LocalizedError {
        @ErrorCode("01")
        case unsupportedAlgorithm
        @ErrorCode("02")
        case responseStatus(ResponseStatus)
        @ErrorCode("03")
        case certificate(Swift.Error)
        @ErrorCode("04")
        case missingCertificate

        public var errorDescription: String? {
            switch self {
            case .unsupportedAlgorithm:
                return "Unsupported Algorithm"
            case let .responseStatus(status):
                return "Signing failed with status: \(status)"
            case let .certificate(error):
                return "Unable to construct the certificate. Error \(error.localizedDescription)"
            case .missingCertificate:
                return "missing certificate"
            }
        }
    }

    @CodedError("006")
    public enum VerifyPINError: Error, LocalizedError {
        /// Pin verification failed, retry count is the number of retries left for the given `EgkFileSystem.Pin` type
        @ErrorCode("01")
        case wrongSecretWarning(retryCount: Int)
        /// Access rule evaluation failure
        @ErrorCode("02")
        case securityStatusNotSatisfied
        /// Write action unsuccessful
        @ErrorCode("03")
        case memoryFailure
        /// Exhausted retry counter
        @ErrorCode("04")
        case passwordBlocked
        /// Password is transport protected
        @ErrorCode("05")
        case passwordNotUsable
        /// Referenced password could not be found
        @ErrorCode("06")
        case passwordNotFound
        /// Any (unexpected) error not specified in gemSpec_COS 14.6.6.2
        @ErrorCode("07")
        case unknownFailure

        static func from(_ response: VerifyPinResponse) -> VerifyPINError? {
            switch response {
            case .success: return nil
            case let .wrongSecretWarning(retryCount: retryCount): return .wrongSecretWarning(retryCount: retryCount)
            case .securityStatusNotSatisfied: return .securityStatusNotSatisfied
            case .memoryFailure: return .memoryFailure
            case .passwordBlocked: return .passwordBlocked
            case .passwordNotUsable: return .passwordNotUsable
            case .passwordNotFound: return .passwordNotFound
            case .unknownFailure: return .unknownFailure
            }
        }

        public var errorDescription: String? {
            switch self {
            case .passwordBlocked, .wrongSecretWarning(retryCount: 0):
                return L10n.cdwTxtRcErrorCardLockedDescription.text
            case .wrongSecretWarning:
                return L10n.cdwTxtRcErrorWrongPinDescription.text
            case .securityStatusNotSatisfied:
                return L10n.cdwTxtRcErrorSecStatusDescription.text
            case .memoryFailure:
                return L10n.cdwTxtRcErrorMemoryFailureDescription.text
            case .passwordNotUsable:
                return L10n.cdwTxtRcErrorOwnPinDescription.text
            case .passwordNotFound:
                return L10n.cdwTxtRcErrorPasswordMissingDescription.text
            case .unknownFailure:
                return L10n.cdwTxtRcErrorUnknownFailureDescription.text
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .passwordBlocked, .wrongSecretWarning(retryCount: 0):
                return L10n.cdwTxtRcErrorCardLockedRecovery.text
            case let .wrongSecretWarning(retryCount: retryCount):
                return L10n.cdwTxtRcErrorWrongPinRecovery("\(retryCount)").text
            case .securityStatusNotSatisfied:
                return L10n.cdwTxtRcErrorSecStatusRecovery.text
            case .memoryFailure:
                return L10n.cdwTxtRcErrorMemoryFailureRecovery.text
            case .passwordNotUsable:
                return L10n.cdwTxtRcErrorOwnPinRecovery.text
            case .passwordNotFound:
                return L10n.cdwTxtRcErrorPasswordMissingRecovery.text
            case .unknownFailure:
                return L10n.cdwTxtRcErrorUnknownFailureRecovery.text
            }
        }
    }
}

extension NFCSignatureProviderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongCAN:
            return L10n.cdwTxtRcErrorWrongCanDescription.text
        case .secureEnclaveError:
            return L10n.cdwTxtRcErrorSecureEnclaveIssue.text
        case let .cardError(.nfcTag(error: tagError)):
            return tagError.localizedDescription
        case let .nfcHealthCardSession(.coreNFC(coreNFCError)):
            return coreNFCError.localizedDescription
        case let .verifyCardError(pinError):
            return pinError.localizedDescription
        case let .cardConnectionError(error),
             let .genericError(error):
            if let cardError = error as? NFCCardError,
               case let .nfcTag(error: tagError) = cardError {
                return tagError.localizedDescription
            } else if let readerError = error as? NFCTagReaderSession.Error,
                      case let .nfcTag(error: tagError) = readerError {
                return tagError.localizedDescription
            } else {
                return L10n.cdwTxtRcErrorGenericCardDescription.text
            }
        case let .signingFailure(error): return error.localizedDescription
        default:
            return L10n.cdwTxtRcErrorGenericCardDescription.text
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .wrongCAN:
            return L10n.cdwTxtRcErrorWrongCanRecovery.text
        case let .cardError(.nfcTag(error: tagError)):
            return tagError.recoverySuggestion
        case let .nfcHealthCardSession(.coreNFC(coreNFCError)):
            return coreNFCError.recoverySuggestion
        case let .verifyCardError(pinError):
            return pinError.recoverySuggestion
        case let .cardConnectionError(error),
             let .genericError(error):
            if let cardError = error as? NFCCardError,
               case let .nfcTag(error: tagError) = cardError {
                return tagError.recoverySuggestion
            } else if let readerError = error as? NFCTagReaderSession.Error,
                      case let .nfcTag(error: tagError) = readerError {
                return tagError.recoverySuggestion
            } else {
                return L10n.cdwTxtRcErrorGenericCardRecovery.text
            }
        default:
            return L10n.cdwTxtRcErrorGenericCardRecovery.text
        }
    }
}

enum EGKSignatureProvider {
    static var systemNFCDialogOpenPACEMessage: String {
        L10n.cdwTxtRcNfcDialogOpenPace.text
    }

    static var systemNFCDialogVerifyPin: String {
        L10n.cdwTxtRcNfcDialogVerifyPin.text
    }

    static var systemNFCDialogSignChallenge: String {
        L10n.cdwTxtRcNfcDialogSignChallenge.text
    }

    // TODO: localization missing   swiftlint:disable:this todo
    static var systemNFCDialogSignAltAuth: String = NSLocalizedString(
        "Alternative Authentification",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogSuccess: String {
        L10n.cdwTxtRcNfcDialogSuccess.text
    }

    static var systemNFCDialogCancel: String {
        L10n.cdwTxtRcNfcDialogCancel.text
    }
}

extension NFCHealthCardSession<Result<SignedChallenge, NFCSignatureProviderError>>.Messages {
    /// Default messages for the sign use case
    static let defaultMessages: Self = .init(
        discoveryMessage: L10n.cdwTxtRcNfcMessageDiscoveryMessage.text,
        connectMessage: L10n.cdwTxtRcNfcMessageConnectMessage.text,
        secureChannelMessage: L10n.cdwTxtRcNfcDialogOpenPace.text,
        noCardMessage: L10n.cdwTxtRcNfcMessageNoCardMessage.text,
        multipleCardsMessage: L10n.cdwTxtRcNfcMessageMultipleCardsMessage.text,
        unsupportedCardMessage: L10n.cdwTxtRcNfcMessageUnsupportedCardMessage.text,
        connectionErrorMessage: L10n.cdwTxtRcNfcMessageConnectionErrorMessage.text
    )
}

extension NFCHealthCardSession<Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError>>.Messages {
    /// Default messages for the signChallengeThenAltAuthWithNFCCard() use case
    static let defaultMessages: Self = .init(
        discoveryMessage: L10n.cdwTxtRcNfcMessageDiscoveryMessage.text,
        connectMessage: L10n.cdwTxtRcNfcMessageConnectMessage.text,
        secureChannelMessage: L10n.cdwTxtRcNfcDialogOpenPace.text,
        noCardMessage: L10n.cdwTxtRcNfcMessageNoCardMessage.text,
        multipleCardsMessage: L10n.cdwTxtRcNfcMessageMultipleCardsMessage.text,
        unsupportedCardMessage: L10n.cdwTxtRcNfcMessageUnsupportedCardMessage.text,
        connectionErrorMessage: L10n.cdwTxtRcNfcMessageConnectionErrorMessage.text
    )
}

extension Swift.Error {
    func asNFCHealthCardSessionError() -> NFCHealthCardSessionError {
        if let error = self as? NFCHealthCardSessionError {
            return error
        } else if let error = self as? CoreNFCError {
            return NFCHealthCardSessionError.coreNFC(error)
        } else {
            return NFCHealthCardSessionError.operation(self)
        }
    }

    func asNFCSignatureError() -> NFCSignatureProviderError {
        if let error = self as? NFCSignatureProviderError {
            return error
        }
        return NFCSignatureProviderError.genericError(self)
    }
}

class EGKSigner: JWTSigner {
    private let card: HealthCardType

    init(card: HealthCardType) {
        self.card = card
    }

    // [REQ:BSI-eRp-ePA:O.Cryp_4#7|12] Signature creation with eGK with dedicated C.CH.AUT
    func sign(message: Data) async throws -> Data {
        // [REQ:gemSpec_IDP_Frontend:A_20700-07] perform signature with OpenHealthCardKit
        let response = try await card.signAsync(data: message)
        if response.responseStatus == ResponseStatus.success, let signature = response.data {
            return signature
        } else {
            throw NFCSignatureProviderError.signingFailure(.responseStatus(response.responseStatus))
        }
    }
}

extension PSOAlgorithm {
    // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
    // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
    var alg: JWT.Algorithm? {
        if case .signECDSA = self {
            return .bp256r1
        }
        return nil
    }
}

/// NFC Signature Provider for handling card authentication
@DependencyClient
public struct NFCSignatureProvider {
    /// Signs a challenge using NFC card authentication
    public var sign: (
        _ can: String,
        _ pin: String,
        _ challenge: IDPChallengeSession,
        _ profileId: UUID
    ) async -> Result<SignedChallenge, NFCSignatureProviderError> = { _, _, _, _ in
        .failure(.genericError(Unimplemented("unimplemented")))
    }

    /// Signs a challenge for biometrics authentication and returns registration data
    public var signForBiometrics: (
        _ can: String,
        _ pin: String,
        _ challenge: IDPChallengeSession,
        _ registerDataProvider: SecureEnclaveSignatureProvider,
        _ pairingSession: PairingSession,
        _ profileId: UUID
    ) async -> Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError> = { _, _, _, _, _, _ in
        .failure(.genericError(Unimplemented("unimplemented")))
    }
}

extension NFCSignatureProvider: TestDependencyKey {
    /// Test value for dependency injection
    public static var testValue = NFCSignatureProvider()
    /// Preview value for SwiftUI previews
    public static var previewValue = NFCSignatureProvider()
}

extension DependencyValues {
    /// Dependency accessor for NFCSignatureProvider
    public var nfcSignatureProvider: NFCSignatureProvider {
        get { self[NFCSignatureProvider.self] }
        set { self[NFCSignatureProvider.self] = newValue }
    }
}

extension NFCSignatureProvider {
    /// Default implementation of the NFC signature provider
    public static var defaultImplementation = NFCSignatureProvider { can, pin, challenge, profileId in
        guard let nfcHealthCardSession = NFCHealthCardSession(
            messages: .defaultMessages,
            can: can,
            operation: { nfcHealthCardSessionHandle in
                try await Self.verifyPin(pin: pin, nfcHealthCardSessionHandle: nfcHealthCardSessionHandle)

                let jwtSigner = EGKSigner(card: nfcHealthCardSessionHandle.card)
                let (signedChallenge, _) = try await Self.signChallenge(
                    challenge: challenge,
                    nfcHealthCardSessionHandle: nfcHealthCardSessionHandle,
                    readCertificateFromCard: { try await nfcHealthCardSessionHandle.card.readAutCertificateAsync()
                    },
                    jwtSigner: jwtSigner,
                    idpChallengeSigner: IDPChallengeSessionSigner.liveValue,
                    signedChallengeSignatureVerifier: SignedChallengeSignatureVerifier.liveValue,
                    profileId: profileId
                )

                nfcHealthCardSessionHandle.updateAlert(message: EGKSignatureProvider.systemNFCDialogSuccess)
                return .success(signedChallenge)
            }
        )
        else {
            // The initializer only returns nil if `NFCTagReaderSession` could not be initialized.
            return .failure(.nfcHealthCardSession(.couldNotInitializeSession))
        }

        let signedChallengeResult: Result<SignedChallenge, NFCSignatureProviderError>
        do {
            signedChallengeResult = try await nfcHealthCardSession.executeOperation()
        } catch let error as NFCHealthCardSessionError {
            let nfcSignatureProviderError: NFCSignatureProviderError
            if case .wrongCAN = error {
                nfcSignatureProviderError = .wrongCAN(error)
            } else if case let .operation(error) = error,
                      let verifyPINError = error as? NFCSignatureProviderError.VerifyPINError {
                nfcSignatureProviderError = .verifyCardError(verifyPINError)
            } else {
                nfcSignatureProviderError = .nfcHealthCardSession(error)
            }

            signedChallengeResult = .failure(nfcSignatureProviderError)
        } catch {
            signedChallengeResult = .failure(.cardReadingError(error))
        }

        switch signedChallengeResult {
        case .success:
            nfcHealthCardSession.invalidateSession(with: nil)
        case let .failure(error):
            nfcHealthCardSession.invalidateSession(with: error.localizedDescription)
        }
        do {
            // The delay is needed to show the error/success message
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
        } catch {}
        return signedChallengeResult
    } signForBiometrics: { can, pin, idpChallengeSession, registerDataProvider, pairingSession, profileId in
        guard let nfcHealthCardSession = NFCHealthCardSession(
            messages: .defaultMessages,
            can: can,
            operation: { nfcHealthCardSessionHandle in
                try await Self.verifyPin(pin: pin, nfcHealthCardSessionHandle: nfcHealthCardSessionHandle)

                let jwtSigner = EGKSigner(card: nfcHealthCardSessionHandle.card)
                let (signedChallenge, certificateData) = try await Self.signChallenge(
                    challenge: idpChallengeSession,
                    nfcHealthCardSessionHandle: nfcHealthCardSessionHandle,
                    readCertificateFromCard: { try await nfcHealthCardSessionHandle.card.readAutCertificateAsync()
                    },
                    jwtSigner: jwtSigner,
                    idpChallengeSigner: IDPChallengeSessionSigner.liveValue,
                    signedChallengeSignatureVerifier: SignedChallengeSignatureVerifier.liveValue,
                    profileId: profileId
                )

                // request the pairing data and sign it
                let registrationData: RegistrationData
                do {
                    let cert = try X509(der: certificateData)
                    registrationData = try await registerDataProvider.signPairingSession(
                        pairingSession,
                        with: jwtSigner,
                        certificate: cert
                    )
                    .async(\NFCSignatureProviderError.Cases.secureEnclaveError)
                } catch let error as CoreNFCError {
                    return .failure(.nfcHealthCardSession(.coreNFC(error)))
                } catch {
                    return .failure(.signingFailure(.certificate(error)))
                }

                nfcHealthCardSessionHandle.updateAlert(message: EGKSignatureProvider.systemNFCDialogSuccess)

                return .success((signedChallenge, registrationData))
            }
        )
        else {
            // The initializer only returns nil if `NFCTagReaderSession` could not be initialized.
            return .failure(NFCSignatureProviderError.nfcHealthCardSession(.couldNotInitializeSession))
        }

        let signForBiometricsResult: Result<(SignedChallenge, RegistrationData), NFCSignatureProviderError>
        do {
            signForBiometricsResult = try await nfcHealthCardSession.executeOperation()
        } catch let error as NFCHealthCardSessionError {
            let nfcSignatureProviderError: NFCSignatureProviderError
            if case .wrongCAN = error {
                nfcSignatureProviderError = .wrongCAN(error)
            } else if case let .operation(error) = error,
                      let verifyPINError = error as? NFCSignatureProviderError.VerifyPINError {
                nfcSignatureProviderError = .verifyCardError(verifyPINError)
            } else {
                nfcSignatureProviderError = .nfcHealthCardSession(error)
            }
            signForBiometricsResult = .failure(nfcSignatureProviderError)
        } catch {
            signForBiometricsResult = .failure(.cardReadingError(error))
        }

        switch signForBiometricsResult {
        case .success:
            nfcHealthCardSession.invalidateSession(with: nil)
        case let .failure(error):
            nfcHealthCardSession.invalidateSession(with: error.localizedDescription)
        }
        do {
            // The delay is needed to show the error/success message
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
        } catch {}
        return signForBiometricsResult
    }
}

extension NFCSignatureProvider {
    private static func verifyPin(
        pin: String,
        nfcHealthCardSessionHandle: NFCHealthCardSessionHandle
    ) async throws {
        nfcHealthCardSessionHandle.updateAlert(message: EGKSignatureProvider.systemNFCDialogVerifyPin)
        let verifyResponse = try await nfcHealthCardSessionHandle.card.verifyAsync(
            pin: pin,
            affectedPassword: .mrPinHomeNoDfSpecific
        )
        guard case .success = verifyResponse
        else {
            if let verifyPINError = NFCSignatureProviderError.VerifyPINError.from(verifyResponse) {
                throw verifyPINError
            } else {
                throw NFCSignatureProviderError.VerifyPINError.unknownFailure
            }
        }
    }

    struct IDPChallengeSessionSigner {
        var sign: (IDPChallengeSession, JWTSigner, [Data], JWT.Algorithm) async throws -> (SignedChallenge)

        static let liveValue = IDPChallengeSessionSigner { idpChallengeSession, jwtSigner, certificates, alg in
            try await idpChallengeSession.sign(with: jwtSigner, using: certificates, alg: alg).async()
        }
    }

    struct SignedChallengeSignatureVerifier {
        var verify: (SignedChallenge, JWTSignatureVerifier) throws -> Bool

        static let liveValue = SignedChallengeSignatureVerifier { signedChallenge, jwtSignatureVerifier in
            try signedChallenge.signedChallenge.verify(with: jwtSignatureVerifier)
        }
    }

    // swiftlint:disable:next function_parameter_count
    static func signChallenge(
        challenge: IDPChallengeSession,
        nfcHealthCardSessionHandle: NFCHealthCardSessionHandle,
        readCertificateFromCard: () async throws -> AutCertificateResponse,
        jwtSigner: JWTSigner,
        idpChallengeSigner: IDPChallengeSessionSigner,
        signedChallengeSignatureVerifier: SignedChallengeSignatureVerifier,
        profileId: UUID
    ) async throws -> (SignedChallenge, Data) {
        @Dependency(\.secureEGKCertificateStorageClient) var certificateStorage
        // Get the authentication certificate from storage.
        // If not available, read the certificate from card and sign the challenge.
        guard let storedCertificate: X509 = try await certificateStorage.certificate(profileId).async(),
              let storedCertificateData = storedCertificate.derBytes
        else {
            return try await readCertificateFromCardAndSignChallenge(
                challenge: challenge,
                readCertificateFromCard: readCertificateFromCard,
                jwtSigner: jwtSigner,
                idpChallengeSigner: idpChallengeSigner,
                profileId: profileId
            )
        }

        // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
        // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
        let alg: JWT.Algorithm = .bp256r1

        nfcHealthCardSessionHandle.updateAlert(message: EGKSignatureProvider.systemNFCDialogSignChallenge)
        // [REQ:gemSpec_IDP_Frontend:A_20700-05,A_20700-07] sign with C.CH.AUT
        let signedChallenge = try await idpChallengeSigner.sign(
            challenge,
            jwtSigner,
            [storedCertificateData],
            alg
        )

        // Check whether the certificate loaded from storage is actually the one
        // that verifies the presented card's issued signature.
        //
        // If not, try to recover by reading the certificate from card and signing again (the `SignedChallenge`
        // includes also the newly read certificate that has to be signed along with the challenge)
        let storedCertificateVerifiesSignature = try signedChallengeSignatureVerifier.verify(
            signedChallenge,
            storedCertificate
        )

        if storedCertificateVerifiesSignature {
            return (signedChallenge, storedCertificateData)
        } else {
            return try await readCertificateFromCardAndSignChallenge(
                challenge: challenge,
                readCertificateFromCard: readCertificateFromCard,
                jwtSigner: jwtSigner,
                idpChallengeSigner: idpChallengeSigner,
                profileId: profileId
            )
        }
    }

    private static func readCertificateFromCardAndSignChallenge(
        challenge: IDPChallengeSession,
        readCertificateFromCard: () async throws -> AutCertificateResponse,
        jwtSigner: JWTSigner,
        idpChallengeSigner: IDPChallengeSessionSigner,
        profileId: UUID
    ) async throws -> (SignedChallenge, Data) {
        @Dependency(\.secureEGKCertificateStorageClient) var certificateStorage

        try certificateStorage.setCertificate(profileId: profileId, certificate: nil)

        let autCertificateResponse: AutCertificateResponse
        autCertificateResponse = try await readCertificateFromCard()
        // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
        // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
        guard let alg = autCertificateResponse.info.algorithm.alg
        else {
            throw NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
        }
        // [REQ:gemSpec_IDP_Frontend:A_20700-05,A_20700-07] sign with C.CH.AUT
        let signedChallenge = try await idpChallengeSigner.sign(
            challenge,
            jwtSigner,
            [autCertificateResponse.certificate],
            alg
        )

        try certificateStorage.setCertificate(
            profileId: profileId,
            certificate: try? X509(der: autCertificateResponse.certificate)
        )

        return (signedChallenge, autCertificateResponse.certificate)
    }
}
