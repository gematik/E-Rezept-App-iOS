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
// swiftlint:disable file_length

import Combine
import CombineSchedulers
import CoreNFC
import HealthCardAccess
import HealthCardControl
import IDP
import NFCCardReaderProvider
import OpenSSL

/// sourcery: StreamWrapped
protocol NFCSignatureProvider {
    func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError>

    func sign(
        can: String,
        pin: String,
        challenge: IDPChallengeSession
    ) async -> Result<SignedChallenge, NFCSignatureProviderError>
}

// sourcery: CodedError = "004"
enum NFCSignatureProviderError: Error {
    // sourcery: errorCode = "01"
    /// Error while establishing a connection to the card
    case cardError(NFCTagReaderSession.Error)
    // sourcery: errorCode = "03"
    /// Error while verifying the CAN
    case wrongCAN(Swift.Error)
    // sourcery: errorCode = "04"
    /// Error while establishing Secure channel or card connection
    case cardConnectionError(Swift.Error)

    // sourcery: errorCode = "05"
    /// Any error related to PIN verification
    case verifyCardError(VerifyPINError)
    // sourcery: errorCode = "06"
    /// ESIGN Failed
    case signingFailure(SigningError)
    // sourcery: errorCode = "07"
    // Wrong pin while opening secure channel
//    case wrongPin(retryCount: Int)

    // sourcery: errorCode = "08"
    /// Generic error while trying to sign the challenge
    case genericError(Swift.Error)

    // sourcery: errorCode = "09"
    /// Generic error while reading something from the card
    case cardReadingError(Swift.Error)

    // sourcery: errorCode = "10"
    /// Generic error while reading something from the card
    case secureEnclaveError(SecureEnclaveSignatureProviderError)

    // sourcery: errorCode = "11"
    /// Any error regarding the communication with the NFC health card itself
    /// or sending/receiving data (operation execution)
    case nfcHealthCardSession(NFCHealthCardSessionError)

    // sourcery: CodedError = "005"
    enum SigningError: Error, LocalizedError {
        // sourcery: errorCode = "01"
        case unsupportedAlgorithm
        // sourcery: errorCode = "02"
        case responseStatus(ResponseStatus)
        // sourcery: errorCode = "03"
        case certificate(Swift.Error)
        // sourcery: errorCode = "04"
        case missingCertificate

        var errorDescription: String? {
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

    // sourcery: CodedError = "006"
    enum VerifyPINError: Error, LocalizedError {
        // sourcery: errorCode = "01"
        // Pin verification failed, retry count is the number of retries left for the given `EgkFileSystem.Pin` type
        case wrongSecretWarning(retryCount: Int)
        // sourcery: errorCode = "02"
        // Access rule evaluation failure
        case securityStatusNotSatisfied
        // sourcery: errorCode = "03"
        // Write action unsuccessful
        case memoryFailure
        // sourcery: errorCode = "04"
        // Exhausted retry counter
        case passwordBlocked
        // sourcery: errorCode = "05"
        // Password is transport protected
        case passwordNotUsable
        // sourcery: errorCode = "06"
        // Referenced password could not be found
        case passwordNotFound
        // sourcery: errorCode = "07"
        // Any (unexpected) error not specified in gemSpec_COS 14.6.6.2
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
            @unknown default:
                assertionFailure("There are missing cases that need to be implemented")
                return nil
            }
        }

        var errorDescription: String? {
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

        var recoverySuggestion: String? {
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
    var errorDescription: String? {
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
//        case let .signingFailure(error): return error.localizedDescription
        default:
            return L10n.cdwTxtRcErrorGenericCardDescription.text
        }
    }

    var recoverySuggestion: String? {
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

extension EGKSignatureProvider {
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

class EGKSignatureSession: SignatureSession {
    internal init(healthCard: HealthCardType, nfcCardSession: NFCCardSession) {
        self.healthCard = healthCard
        self.nfcCardSession = nfcCardSession
    }

    let healthCard: HealthCardType
    let nfcCardSession: NFCCardSession

    func sign(challengeSession: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError> {
        healthCard.sign(challengeSession: challengeSession)
    }

    func sign(registerDataProvider: SecureEnclaveSignatureProvider,
              in pairingSession: PairingSession,
              signedChallenge: SignedChallenge)
        -> AnyPublisher<(SignedChallenge, RegistrationData), NFCSignatureProviderError> {
        healthCard.sign(registerDataProvider: registerDataProvider,
                        in: pairingSession,
                        signedChallenge: signedChallenge)
    }

    func updateAlert(message: String) {
        nfcCardSession.updateAlert(message: message)
    }

    func invalidateSession(with error: String?) {
        nfcCardSession.invalidateSession(with: error)
    }
}

protocol SignatureSession: AnyObject {
    func sign(challengeSession: IDPChallengeSession) -> AnyPublisher<SignedChallenge, NFCSignatureProviderError>

    func sign(registerDataProvider: SecureEnclaveSignatureProvider,
              in pairingSession: PairingSession,
              signedChallenge: SignedChallenge)
        -> AnyPublisher<(SignedChallenge, RegistrationData), NFCSignatureProviderError>

    func updateAlert(message: String)

    func invalidateSession(with error: String?)
}

final class EGKSignatureProvider: NFCSignatureProvider {
    typealias Error = NFCSignatureProviderError

    init(schedulers: Schedulers) {
        self.schedulers = schedulers
    }

    let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    func openSecureSession(can: String, pin: String) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        NFCTagReaderSession
            .publisher(messages: .defaultMessages)
            .mapError { NFCSignatureProviderError.cardError($0) }
            .flatMap { session -> AnyPublisher<SignatureSession, NFCSignatureProviderError> in
                session.updateAlert(message: L10n.cdwTxtRcNfcDialogOpenPace.text)

                return session
                    .openSecureSession(can: can)
                    .userMessage(session: session, message: Self.systemNFCDialogVerifyPin)
                    .verifyCard(pin: pin)
                    .userMessage(session: session, message: Self.systemNFCDialogSignChallenge)
                    .map { healthCard -> EGKSignatureSession in
                        EGKSignatureSession(healthCard: healthCard, nfcCardSession: session)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // [REQ:gemSpec_IDP_Frontend:A_20526-01] sign
    // [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
    func sign( // swiftlint:disable:this function_body_length
        can: String,
        pin: String,
        challenge: IDPChallengeSession
    ) async -> Result<SignedChallenge, NFCSignatureProviderError> {
        guard let nfcHealthCardSession = NFCHealthCardSession(
            messages: .defaultMessages,
            can: can,
            operation: { session in
                session.updateAlert(message: Self.systemNFCDialogVerifyPin)
                let verifyResponse = try await session.card.verifyAsync(
                    pin: pin,
                    affectedPassword: .mrPinHomeNoDfSpecific
                )
                guard case .success = verifyResponse
                else {
                    if let verifyPINError = NFCSignatureProviderError.VerifyPINError.from(verifyResponse) {
                        return Result<SignedChallenge, NFCSignatureProviderError>
                            .failure(NFCSignatureProviderError.verifyCardError(verifyPINError))
                    } else {
                        return Result<SignedChallenge, NFCSignatureProviderError>
                            .failure(NFCSignatureProviderError.verifyCardError(.unknownFailure))
                    }
                }
                session.updateAlert(message: Self.systemNFCDialogSignChallenge)
                let signedChallengeResult: Result<SignedChallenge, NFCSignatureProviderError>
                signedChallengeResult = await session.card.sign(challenge: challenge)
                switch signedChallengeResult {
                case .success:
                    session.updateAlert(message: Self.systemNFCDialogSuccess)
                case let .failure(error):
                    session.invalidateSession(with: error.localizedDescription)
                }
                // The delay is needed to show the success message
                try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 100)
                return signedChallengeResult
            }
        )
        else {
            // The initializer only returns nil if `NFCTagReaderSession` could not be initialized.
            return .failure(NFCSignatureProviderError.nfcHealthCardSession(.couldNotInitializeSession))
        }
        let signedChallengeResult: Result<SignedChallenge, NFCSignatureProviderError>
        do {
            signedChallengeResult = try await nfcHealthCardSession.executeOperation()
        } catch let error as NFCHealthCardSessionError {
            let nfcSignatureProviderError: NFCSignatureProviderError
            if case .wrongCAN = error {
                nfcSignatureProviderError = .wrongCAN(error)
            } else {
                nfcSignatureProviderError = NFCSignatureProviderError.nfcHealthCardSession(error)
            }
            nfcHealthCardSession.invalidateSession(with: nfcSignatureProviderError.localizedDescription)
            return .failure(nfcSignatureProviderError)
        } catch {
            nfcHealthCardSession.invalidateSession(with: error.localizedDescription)
            return .failure(.cardReadingError(error))
        }
        return signedChallengeResult
    }
}

extension Publisher {
    func userMessage(session: NFCCardSession, message: String) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(receiveOutput: { _ in
            // swiftlint:disable:previous trailing_closure
            session.updateAlert(message: message)
        })
            .eraseToAnyPublisher()
    }

    func userMessage(session: SignatureSession, message: String) -> AnyPublisher<Self.Output, Self.Failure> {
        handleEvents(receiveOutput: { _ in
            // swiftlint:disable:previous trailing_closure
            session.updateAlert(message: message)
        })
            .eraseToAnyPublisher()
    }
}

extension NFCHealthCardSession<Result<SignedChallenge, NFCSignatureProviderError>>.Messages {
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

extension NFCTagReaderSession.Messages {
    static let defaultMessages: Self = .init(
        discoveryMessage: L10n.cdwTxtRcNfcMessageDiscoveryMessage.text,
        connectMessage: L10n.cdwTxtRcNfcMessageConnectMessage.text,
        noCardMessage: L10n.cdwTxtRcNfcMessageNoCardMessage.text,
        multipleCardsMessage: L10n.cdwTxtRcNfcMessageMultipleCardsMessage.text,
        unsupportedCardMessage: L10n.cdwTxtRcNfcMessageUnsupportedCardMessage.text,
        connectionErrorMessage: L10n.cdwTxtRcNfcMessageConnectionErrorMessage.text
    )
}

extension NFCCardSession {
    func openSecureSession(can: String) -> AnyPublisher<HealthCardType, NFCSignatureProviderError> {
        card
            .openSecureSession(can: can, writeTimeout: 0, readTimeout: 0)
            .map { $0 as HealthCardType }
            .mapError { error in
                if let error = error as? HealthCardControl.KeyAgreement.Error,
                   case .macPcdVerificationFailedOnCard = error {
                    return NFCSignatureProviderError.wrongCAN(error)
                }
                return NFCSignatureProviderError.cardConnectionError(error)
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == HealthCardType, Self.Failure == NFCSignatureProviderError {
    func verifyCard(pin: String) -> AnyPublisher<HealthCardType, Failure> {
        flatMap { secureCard in
            secureCard.verify(pin: pin, affectedPassword: .mrPinHomeNoDfSpecific)
                .tryMap { response -> HealthCardType in
                    if case .success = response {
                        return secureCard
                    } else {
                        guard let verifyPINError = NFCSignatureProviderError.VerifyPINError.from(response) else {
                            throw NFCSignatureProviderError.VerifyPINError.unknownFailure
                        }
                        throw NFCSignatureProviderError.verifyCardError(verifyPINError)
                    }
                }
                .mapError { error -> NFCSignatureProviderError in
                    error.asNFCSignatureError()
                }
        }.eraseToAnyPublisher()
    }

    func sign(challenge session: IDPChallengeSession) -> AnyPublisher<SignedChallenge, Failure> {
        flatMap { secureCard in
            secureCard
                // [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
                // [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
                // [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
                .readAutCertificate()
                .flatMap { certificate -> AnyPublisher<SignedChallenge, Swift.Error> in
                    // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
                    // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
                    guard let alg = certificate.info.algorithm.alg else {
                        return Fail(
                            error: NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm)
                        ).eraseToAnyPublisher()
                    }
                    // [REQ:gemSpec_IDP_Frontend:A_20700-05,A_20700-07] sign with C.CH.AUT
                    return session.sign(
                        with: EGKSigner(card: secureCard),
                        using: [certificate.certificate],
                        alg: alg
                    )
                    .eraseToAnyPublisher()
                }
                .mapError { $0.asNFCSignatureError() }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

extension HealthCardType {
    func sign(challenge session: IDPChallengeSession) async
        -> Result<SignedChallenge, NFCSignatureProviderError> {
        // [REQ:gemSpec_IDP_Frontend:A_20700-07] C.CH.AUT
        // [REQ:gemF_Tokenverschlüsselung:A_20526-01] Smartcard signature
        // [REQ:gemF_Tokenverschlüsselung:A_20700-06] sign
        let certificate: AutCertificateResponse
        do {
            certificate = try await readAutCertificateAsync()
        } catch {
            return .failure(NFCSignatureProviderError.cardReadingError(error))
        }
        // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
        // [REQ:gemSpec_Krypt:GS-A_4357-01,GS-A_4357-02,GS-A_4361-02] Assure that brainpoolP256r1 is used
        guard let alg = certificate.info.algorithm.alg else {
            return .failure(NFCSignatureProviderError.signingFailure(.unsupportedAlgorithm))
        }

        do {
            // [REQ:gemSpec_IDP_Frontend:A_20700-05,A_20700-07] sign with C.CH.AUT
            let signedChallenge = try await session.sign(
                with: EGKSigner(card: self),
                using: [certificate.certificate],
                alg: alg
            )
            .async()
            return .success(signedChallenge)
        } catch {
            return .failure(error.asNFCSignatureError())
        }
    }
}

extension Swift.Error {
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

    func sign(message: Data) -> AnyPublisher<Data, Swift.Error> {
        // [REQ:gemSpec_IDP_Frontend:A_20700-07] perform signature with OpenHealthCardKit
        card.sign(data: message)
            .tryMap { response in
                if response.responseStatus == ResponseStatus.success, let signature = response.data {
                    return signature
                } else {
                    throw NFCSignatureProviderError.signingFailure(.responseStatus(response.responseStatus))
                }
            }
            .eraseToAnyPublisher()
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

// swiftlint:enable file_length
