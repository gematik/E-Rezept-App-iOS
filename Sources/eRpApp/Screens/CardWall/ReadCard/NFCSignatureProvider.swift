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
            return L10n.cdwTxtRcErrorWrongCanDescription.text
        case .wrongPin:
            return L10n.cdwTxtRcErrorWrongPinDescription.text
        default:
            return L10n.cdwTxtRcErrorGenericCardDescription.text
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .wrongCAN:
            return L10n.cdwTxtRcErrorWrongCanRecovery.text
        case let .wrongPin(retryCount: retryCount):
            return L10n.cdwTxtRcErrorWrongPinRecovery("\(retryCount)").text
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

    func openSecureSession(can: CAN, pin: Format2Pin) -> AnyPublisher<SignatureSession, NFCSignatureProviderError> {
        NFCTagReaderSession
            .publisher(messages: messages)
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
        session.updateAlert(message: L10n.cdwTxtRcNfcDialogOpenPace.text)

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
            discoveryMessage: L10n.cdwTxtRcNfcMessageDiscoveryMessage.text,
            connectMessage: L10n.cdwTxtRcNfcMessageConnectMessage.text,
            noCardMessage: L10n.cdwTxtRcNfcMessageNoCardMessage.text,
            multipleCardsMessage: L10n.cdwTxtRcNfcMessageMultipleCardsMessage.text,
            unsupportedCardMessage: L10n.cdwTxtRcNfcMessageUnsupportedCardMessage.text,
            connectionErrorMessage: L10n.cdwTxtRcNfcMessageConnectionErrorMessage.text
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
