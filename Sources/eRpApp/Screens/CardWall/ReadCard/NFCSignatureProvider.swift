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
import CombineSchedulers
import CoreNFC
import HealthCardAccess
import HealthCardControl
import IDP
import NFCCardReaderProvider
import OpenSSL

/// sourcery: StreamWrapped
protocol NFCSignatureProvider {
    func openSecureSession(can: CAN, pin: Format2Pin) -> AnyPublisher<SignatureSession, NFCSignatureProviderError>

    func sign(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession)
        -> AnyPublisher<SignedChallenge, NFCSignatureProviderError>
}

enum NFCSignatureProviderError: Error {
    // Error while establishing a connection to the card
    case cardError(NFCTagReaderSession.Error)
    // Error while establishing a secure channel, might be a `HealthCard.Error`
    case authenticationError(Swift.Error)
    // Error while verifying the CAN
    case wrongCAN(Swift.Error)
    // Error while establishing Secure channel or card connection
    case cardConnectionError(Swift.Error)

    // generic verify card error while testing for correct PIN, but not wrong pin
    case verifyCardError(Swift.Error)
    // ESIGN Failed
    case signingFailure(Swift.Error?)
    // Wrong pin while opening secure channel
    case wrongPin(retryCount: Int)

    // Generic error while trying to sign the challenge
    case genericError(Swift.Error)
}

extension NFCSignatureProviderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongCAN:
            return Self.wrongCANDescription
        case let .wrongPin(retryCount: retryCount):
            return String(format: Self.wrongPinDescriptionFormat, String(retryCount))
        default:
            return Self.genericDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .wrongCAN:
            return Self.wrongCANRecovery
        case let .wrongPin(retryCount: retryCount):
            return String(format: Self.wrongPinRecoveryFormat, String(retryCount))
        default:
            return Self.genericRecovery
        }
    }

    static var wrongPinDescriptionFormat: String = NSLocalizedString(
        "cdw_txt_rc_error_wrong_pin_description_%@",
        comment: ""
    )

    static var wrongPinRecoveryFormat: String = NSLocalizedString(
        "cdw_txt_rc_error_wrong_pin_recovery_%@",
        comment: ""
    )

    static var wrongCANDescription: String = NSLocalizedString(
        "cdw_txt_rc_error_wrong_can_description",
        comment: ""
    )

    static var wrongCANRecovery: String = NSLocalizedString(
        "cdw_txt_rc_error_wrong_can_recovery",
        comment: ""
    )

    static var genericDescription: String = NSLocalizedString(
        "cdw_txt_rc_error_generic_card_description",
        comment: ""
    )

    static var genericRecovery: String = NSLocalizedString(
        "cdw_txt_rc_error_generic_card_recovery",
        comment: ""
    )
}

extension EGKSignatureProvider {
    static var systemNFCDialogOpenPACEMessage: String = NSLocalizedString(
        "cdw_txt_rc_nfc_dialog_open_pace",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogVerifyPin: String = NSLocalizedString(
        "cdw_txt_rc_nfc_dialog_verify_pin",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogSignChallenge: String = NSLocalizedString(
        "cdw_txt_rc_nfc_dialog_sign_challenge",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogSignAltAuth: String = NSLocalizedString(
        "Alternative Authentification",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogSuccess: String = NSLocalizedString(
        "cdw_txt_rc_nfc_dialog_success",
        comment: "CardWall System NFC Dialog, info message"
    )
    static var systemNFCDialogCancel: String = NSLocalizedString(
        "cdw_txt_rc_nfc_dialog_cancel",
        comment: "CardWall System NFC Dialog, info message"
    )
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

    func openSecureSession(can: CAN, pin: Format2Pin) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        NFCTagReaderSession
            .publisher(messages: messages)
            .mapError { NFCSignatureProviderError.cardError($0) }
            .flatMap { session -> AnyPublisher<SignatureSession, NFCSignatureProviderError> in
                session.updateAlert(message: Self.systemNFCDialogOpenPACEMessage)

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
    func sign(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession)
        -> AnyPublisher<SignedChallenge, Error> {
        NFCTagReaderSession
            .publisher(messages: messages)
            .mapError { Error.cardError($0) }
            .flatMap { session in
                self.openSessionAndSignChallenge(can: can, pin: pin, challenge: challenge, session: session)
            }
            .eraseToAnyPublisher()
    }

    private func openSessionAndSignChallenge(can: CAN, pin: Format2Pin, challenge: IDPChallengeSession,
                                             session: NFCCardSession) -> AnyPublisher<SignedChallenge, Error> {
        session.updateAlert(message: Self.systemNFCDialogOpenPACEMessage)

        return session
            // swiftlint:disable:previous trailing_closure
            .openSecureSession(can: can)
            .userMessage(session: session, message: Self.systemNFCDialogVerifyPin)
            .verifyCard(pin: pin)
            .userMessage(session: session, message: Self.systemNFCDialogSignChallenge)
            .sign(challenge: challenge)
            .userMessage(session: session, message: Self.systemNFCDialogSuccess)
            .delay(for: 0.01, scheduler: uiScheduler) // The delay is needed to show the success message
            .handleEvents(receiveOutput: { _ in
                session.invalidateSession(with: nil)
            })
            .mapError { error -> Error in
                session.invalidateSession(with: error.localizedDescription)
                return error
            }
            .eraseToAnyPublisher()
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

extension EGKSignatureProvider {
    var messages: NFCTagReaderSession.Messages {
        NFCTagReaderSession.Messages(
            discoveryMessage: NSLocalizedString("cdw_txt_rc_nfc_message_discoveryMessage",
                                                comment: "NFC System Sheet message"),
            connectMessage: NSLocalizedString("cdw_txt_rc_nfc_message_connectMessage",
                                              comment: "NFC System Sheet message"),
            noCardMessage: NSLocalizedString("cdw_txt_rc_nfc_message_noCardMessage",
                                             comment: "NFC System Sheet message"),
            multipleCardsMessage: NSLocalizedString("cdw_txt_rc_nfc_message_multipleCardsMessage",
                                                    comment: "NFC System Sheet message"),
            unsupportedCardMessage: NSLocalizedString("cdw_txt_rc_nfc_message_unsupportedCardMessage",
                                                      comment: "NFC System Sheet message"),
            connectionErrorMessage: NSLocalizedString("cdw_txt_rc_nfc_message_connectionErrorMessage",
                                                      comment: "NFC System Sheet message")
        )
    }
}

extension NFCCardSession {
    func openSecureSession(can: CAN) -> AnyPublisher<HealthCardType, NFCSignatureProviderError> {
        card
            .openSecureSession(can: can, writeTimeout: 0, readTimeout: 0)
            .map { $0 as HealthCardType }
            .mapError { error in
                if let error = error as? HealthCardControl.KeyAgreement.Error {
                    return NFCSignatureProviderError.wrongCAN(error)
                }
                return NFCSignatureProviderError.cardConnectionError(error)
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == HealthCardType, Self.Failure == NFCSignatureProviderError {
    func verifyCard(pin: Format2Pin) -> AnyPublisher<HealthCardType, Failure> {
        flatMap { secureCard in
            secureCard.verify(pin: pin, type: EgkFileSystem.Pin.mrpinHome)
                .mapError(NFCSignatureProviderError.verifyCardError)
                .tryMap { response -> HealthCardType in
                    if case let VerifyPinResponse.failed(retryCount: count) = response {
                        throw NFCSignatureProviderError.wrongPin(retryCount: count)
                    }
                    return secureCard
                }
                .mapError { error -> NFCSignatureProviderError in
                    error.asNFCSignatureError()
                }
                .eraseToAnyPublisher()
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
                    guard let alg = certificate.info.algorithm.alg else {
                        return Fail(error: NFCSignatureProviderError.signingFailure(nil)).eraseToAnyPublisher()
                    }
                    // [REQ:gemSpec_IDP_Frontend:A_20700-07] sign with C.CH.AUT
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
                    throw NFCSignatureProviderError.signingFailure(nil)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension PSOAlgorithm {
    // [REQ:gemSpec_Krypt:A_17207] Assure only brainpoolP256r1 is used
    var alg: JWT.Algorithm? {
        if case .signECDSA = self {
            return .bp256r1
        }
        return nil
    }
}
