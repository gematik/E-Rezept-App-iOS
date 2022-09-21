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
import HealthCardControl
import NFCCardReaderProvider

protocol NFCResetRetryCounterController {
    func resetEgkMrPinRetryCounter(can: String, puk: String, mode: NFCResetRetryCounterControllerMode)
        -> AnyPublisher<ResetRetryCounterResponse, ResetRetryCounterControllerError>
}

enum NFCResetRetryCounterControllerMode: Equatable {
    case withoutNewPassword
    case setNewPassword(String)
}

// sourcery: CodedError = "026"
enum ResetRetryCounterControllerError: Swift.Error {
    // sourcery: errorCode = "01"
    case cardError(NFCTagReaderSession.Error)
    // sourcery: errorCode = "02"
    case openSecureSession(Swift.Error)
    // sourcery: errorCode = "03"
    case resetRetryCounter(Swift.Error)
    // sourcery: errorCode = "04"
    case wrongCan
}

struct DefaultNFCResetRetryCounterController: NFCResetRetryCounterController {
    init(schedulers: Schedulers) {
        self.schedulers = schedulers
    }

    let schedulers: Schedulers
    private var uiScheduler: AnySchedulerOf<DispatchQueue> {
        schedulers.main
    }

    func resetEgkMrPinRetryCounter(
        can: String,
        puk: String,
        mode: NFCResetRetryCounterControllerMode
    ) -> AnyPublisher<ResetRetryCounterResponse, ResetRetryCounterControllerError> {
        NFCTagReaderSession
            .publisher(messages: .defaultMessages)
            .mapError { ResetRetryCounterControllerError.cardError($0) }
            .flatMap { session in
                session.card
                    .openSecureSession(can: can)
                    .mapError { error -> ResetRetryCounterControllerError in
                        if let error = error as? HealthCardControl.KeyAgreement.Error,
                           case .macPcdVerificationFailedOnCard = error {
                            return ResetRetryCounterControllerError.wrongCan
                        } else {
                            return ResetRetryCounterControllerError.openSecureSession(error)
                        }
                    }
                    .userMessage(session: session, message: mode.nfcDialogStartUnlockCardMessage)
                    .flatMap { card -> AnyPublisher<ResetRetryCounterResponse, ResetRetryCounterControllerError> in
                        switch mode {
                        case .withoutNewPassword:
                            return card.resetRetryCounter(puk: puk, affectedPassWord: .mrPinHomeNoDfSpecific)
                                .mapError {
                                    ResetRetryCounterControllerError.resetRetryCounter($0)
                                }
                                .eraseToAnyPublisher()
                        case let .setNewPassword(newPin):
                            return card.resetRetryCounterAndSetNewPin(
                                puk: puk,
                                newPin: newPin,
                                affectedPassWord: .mrPinHomeNoDfSpecific
                            )
                            .mapError {
                                ResetRetryCounterControllerError.resetRetryCounter($0)
                            }
                            .eraseToAnyPublisher()
                        }
                    }
                    .handleEvents(
                        receiveOutput: { resetRetryCounterResponse in
                            if case .success = resetRetryCounterResponse {
                                session.invalidateSession(with: nil)
                            } else {
                                session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                            }
                        },
                        receiveCancel: {
                            session.invalidateSession(with: EGKSignatureProvider.systemNFCDialogCancel)
                        }
                    )
                    .mapError { error -> ResetRetryCounterControllerError in
                        session.invalidateSession(with: L10n.stgTxtCardResetRcNfcDialogError.text)
                        return error
                    }
            }
            .eraseToAnyPublisher()
    }
}

extension NFCResetRetryCounterControllerMode {
    var nfcDialogStartUnlockCardMessage: String {
        switch self {
        case .withoutNewPassword: return L10n.stgTxtCardResetRcNfcDialogUnlockCard.text
        case .setNewPassword: return L10n.stgTxtCardResetRcNfcDialogUnlockCardWithPin.text
        }
    }
}

extension ResetRetryCounterControllerError: Equatable {
    public static func ==(lhs: ResetRetryCounterControllerError, rhs: ResetRetryCounterControllerError) -> Bool {
        switch (lhs, rhs) {
        case let (.cardError(lhsError), .cardError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.openSecureSession(lhsError), .openSecureSession(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.resetRetryCounter(lhsError), .resetRetryCounter(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

extension ResetRetryCounterControllerError: CustomStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case let .cardError(error):
            return "cardError: \(error.localizedDescription)"
        case let .openSecureSession(error):
            return "openSecureSessionError: \(error.localizedDescription)"
        case let .resetRetryCounter(error):
            return "resetRetryCounterError: \(error.localizedDescription)"
        case .wrongCan:
            return "wrongCANError"
        }
    }

    var errorDescription: String? {
        switch self {
        case let .cardError(error):
            return error.localizedDescription
        case let .openSecureSession(error):
            return error.localizedDescription
        case let .resetRetryCounter(error):
            return error.localizedDescription
        case .wrongCan:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .cardError(error as LocalizedError),
             let .openSecureSession(error as LocalizedError),
             let .resetRetryCounter(error as LocalizedError):
            return error.recoverySuggestion
        case .resetRetryCounter, .openSecureSession, .wrongCan:
            return nil
        }
    }
}

struct DummyResetRetryCounterController: NFCResetRetryCounterController {
    func resetEgkMrPinRetryCounter(can _: String, puk _: String, mode _: NFCResetRetryCounterControllerMode)
        -> AnyPublisher<ResetRetryCounterResponse, ResetRetryCounterControllerError> {
        Just(ResetRetryCounterResponse.success).setFailureType(to: ResetRetryCounterControllerError.self)
            .eraseToAnyPublisher()
    }
}
